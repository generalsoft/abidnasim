import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/work_items.dart';
import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import 'shared/content_section.dart';

/// Fraction of the section width a single slide occupies. Kept below 1 so the
/// neighbouring slides peek in at the sides — that's what makes it read as a
/// carousel rather than a full-bleed page.
const double _viewportFraction = 0.88;

/// Gap between two slides (half of it is applied to each side of a slide).
const double _slideGap = 9;

/// How far off-centre slides are turned around the vertical axis, in radians
/// (≈ 22°). This is what gives the page-turn its depth.
const double _maxSlideTurn = 0.38;

/// "Selected work" section: an auto-flipping hero carousel of the case studies.
///
/// The grid of cards was replaced by one hero slide per project: it page-turns
/// to the next project on its own, and the visitor can take over at any time
/// with the arrow buttons, the dot indicators, or a swipe on touch devices —
/// the countdown then restarts. The thin line under the slides shows how long
/// the current slide has left before it flips.
///
/// Timing is tunable from the call site, so no value is buried in the layout:
/// * [autoPlayInterval] — how long a slide stays on screen before it flips.
/// * [flipDuration] — how long the page-turn animation itself takes.
///
/// The defaults are tuned for the homepage, so `const WorkSection()` behaves
/// exactly as before. Pass shorter values to speed the carousel up, e.g.
/// `WorkSection(autoPlayInterval: Duration(seconds: 4))`.
class WorkSection extends StatelessWidget {
  /// How long a slide stays on screen before the carousel flips to the next
  /// project. This is the "flip frequency" knob.
  final Duration autoPlayInterval;

  /// How long the page-turn transition takes, for the automatic flips as well
  /// as for taps on the arrows / dots.
  final Duration flipDuration;

  const WorkSection({
    this.autoPlayInterval = const Duration(seconds: 7),
    this.flipDuration = const Duration(milliseconds: 750),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(
      eyebrow: t('work_eyebrow'),
      title: t('work_title'),
      child: _WorkCarousel(autoPlayInterval: autoPlayInterval, flipDuration: flipDuration),
    );
  }
}

/// The carousel: a [PageView] of hero slides plus its auto-flip state, arrow
/// buttons, dot indicators and countdown line.
class _WorkCarousel extends StatefulWidget {
  final Duration autoPlayInterval;
  final Duration flipDuration;

  const _WorkCarousel({required this.autoPlayInterval, required this.flipDuration});

  @override
  State<_WorkCarousel> createState() => _WorkCarouselState();
}

class _WorkCarouselState extends State<_WorkCarousel>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final PageController _pageController = PageController(viewportFraction: _viewportFraction);

  /// Drives both the auto-flip countdown and the progress line under the
  /// slides: its duration *is* [WorkSection.autoPlayInterval], so the two can
  /// never drift apart.
  late final AnimationController _timer = AnimationController(
    vsync: this,
    duration: widget.autoPlayInterval,
  )..addStatusListener(_handleCountdownCompleted);

  /// Index of the slide currently on screen. Updated as the visitor navigates,
  /// which is what the dots and the "01 / 08" counter read.
  int _index = 0;

  /// True while a swipe is in flight, the visitor paused the carousel, the app
  /// is in the background, or the OS asks for reduced motion. Any of those
  /// freezes the countdown instead of flipping the page.
  bool _dragging = false;
  bool _pausedByVisitor = false;
  bool _appInactive = false;
  bool _reduceMotion = false;

  bool get _autoFlipEnabled => !_dragging && !_pausedByVisitor && !_appInactive && !_reduceMotion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the OS "reduce motion" setting: the slides hold still and the
    // visitor drives the carousel with the arrows / dots instead.
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncCountdown();
  }

  @override
  void didUpdateWidget(covariant _WorkCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _timer.duration = widget.autoPlayInterval;
      _restartCountdown();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appInactive = state != AppLifecycleState.resumed;
    _syncCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Auto-flip
  // ---------------------------------------------------------------------------

  /// Resumes or freezes the countdown where it stands. Used when the reason for
  /// pausing is not the visitor changing slides (app lifecycle, reduced
  /// motion), so the elapsed part of the interval is kept.
  void _syncCountdown() {
    if (!mounted) return;

    if (_autoFlipEnabled) {
      if (!_timer.isAnimating) _timer.forward();
    } else {
      _timer.stop();
    }
  }

  /// Restarts the interval from zero, so a slide always gets the full
  /// [WorkSection.autoPlayInterval] after the visitor interacted with it.
  void _restartCountdown() {
    if (!mounted) return;

    if (_autoFlipEnabled) {
      _timer.forward(from: 0);
    } else {
      _timer.stop();
      _timer.value = 0;
    }
  }

  void _handleCountdownCompleted(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _flipTo(_index + 1, wrap: true);
  }

  /// Page-turns to [target]. With [wrap] the carousel loops instead of stopping
  /// at the last project.
  Future<void> _flipTo(int target, {bool wrap = false}) async {
    if (!mounted) return;

    final total = workItems.length;
    final page = wrap ? target % total : target.clamp(0, total - 1);

    if (!_pageController.hasClients) {
      // Not laid out yet, or the section currently sits outside the scroll
      // cache extent. Retry on the next tick rather than stalling for good.
      _restartCountdown();
      return;
    }

    if (_reduceMotion) {
      _pageController.jumpToPage(page);
    } else {
      await _pageController.animateToPage(
        page,
        duration: widget.flipDuration,
        curve: Curves.easeInOutCubic,
      );
    }

    if (mounted) _restartCountdown();
  }

  void _handlePageChanged(int index) {
    setState(() => _index = index);
    _restartCountdown();
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification && notification.dragDetails != null) {
      // Only a real finger/mouse drag pauses: the automatic page animation also
      // emits start/end notifications, which must not cancel the countdown.
      _dragging = true;
      _syncCountdown();
    } else if (notification is ScrollEndNotification && _dragging) {
      _dragging = false;
      _restartCountdown();
    }

    return false;
  }

  /// Visitor-driven navigation shared by the arrows and the dots. Automatic
  /// flips deliberately do not come through here: tracking them would flood the
  /// data layer with one event every [WorkSection.autoPlayInterval].
  void _goTo(int index, String trigger) {
    if (index != _index) {
      trackEvent(
        'work_carousel_navigation',
        parameter1Name: 'trigger',
        parameter1Value: trigger,
        parameter2Name: 'slide_slug',
        parameter2Value: workItems[index % workItems.length].slug,
      );
    }

    // Freeze the countdown while the visitor's page-turn plays, so a timer that
    // was about to expire can't flip the page out from under it. [_flipTo]
    // restarts it once the turn has settled.
    _timer.stop();
    _flipTo(index, wrap: true);
  }

  void _handlePrevious() => _goTo(_index - 1, 'previous');

  void _handleNext() => _goTo(_index + 1, 'next');

  void _handleToggleAutoPlay() {
    setState(() => _pausedByVisitor = !_pausedByVisitor);

    if (_pausedByVisitor) {
      _timer.stop();
    } else {
      _restartCountdown();
    }

    trackEvent(
      'work_carousel_autoplay',
      parameter1Name: 'state',
      parameter1Value: _pausedByVisitor ? 'paused' : 'resumed',
    );
  }

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final t = AppLocalizations.of(context).t;
    final localeCode = AppLocalizations.of(context).locale.languageCode;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final wide = width >= 900;

    // Fixed slide height (rather than an aspect ratio) keeps the carousel from
    // jumping when Urdu/Arabic copy wraps differently than the English original.
    final slideHeight = wide
        ? 400.0
        : width >= 600
        ? 470.0
        : 520.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: slideHeight,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _handlePageChanged,
              scrollBehavior: const _CarouselScrollBehavior(),
              itemCount: workItems.length,
              itemBuilder: (context, index) => _FlipPage(
                controller: _pageController,
                index: index,
                rtl: isRtl,
                child: _WorkHeroCard(
                  item: workItems[index],
                  localeCode: localeCode,
                  index: index,
                  total: workItems.length,
                  wide: wide,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            if (width >= 640) ...[
              Text('${_index + 1}'.padLeft(2, '0'), style: _counterStyle(0.86)),
              Text(' / ${workItems.length.toString().padLeft(2, '0')}', style: _counterStyle(0.38)),
            ],
            const Spacer(),
            if (!_reduceMotion)
              IconButton(
                onPressed: _handleToggleAutoPlay,
                tooltip: t(_pausedByVisitor ? 'work_play' : 'work_pause'),
                icon: Icon(_pausedByVisitor ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 18),
                style: _controlButtonStyle,
              ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: _handlePrevious,
              tooltip: t('work_prev'),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              style: _controlButtonStyle,
            ),
            const SizedBox(width: 4),
            IconButton(
              onPressed: _handleNext,
              tooltip: t('work_next'),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              style: _controlButtonStyle,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < workItems.length; i++)
              _CarouselDot(
                active: i == _index,
                label: '${t('work_slide')} ${i + 1}',
                onTap: () => _goTo(i, 'dot'),
              ),
          ],
        ),
        const SizedBox(height: 18),
        _buildCountdownLine(),
      ],
    );
  }

  /// Thin line that fills up as the current slide's interval elapses — the
  /// visible version of the auto-flip timer.
  Widget _buildCountdownLine() {
    return SizedBox(
      height: 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(99),
        ),
        child: AnimatedBuilder(
          animation: _timer,
          builder: (context, _) => Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: _timer.value,
              heightFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _counterStyle(double alpha) => TextStyle(
    color: Colors.white.withValues(alpha: alpha),
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2,
  );

  static final ButtonStyle _controlButtonStyle = IconButton.styleFrom(
    foregroundColor: Colors.white,
    padding: const EdgeInsets.all(10),
    side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
    shape: const CircleBorder(),
  );
}

// -----------------------------------------------------------------------------
// SLIDES
// -----------------------------------------------------------------------------

/// Applies the page-turn look to one slide: the slides off-centre are turned a
/// few degrees around the vertical axis (with a touch of perspective) and
/// scaled down, so the pages visibly flip past each other as the carousel
/// moves — including while the visitor drags.
class _FlipPage extends StatelessWidget {
  final PageController controller;
  final int index;
  final bool rtl;
  final Widget child;

  const _FlipPage({
    required this.controller,
    required this.index,
    required this.rtl,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      // The card itself never changes while the page turns, so keep it out of
      // the rebuild path and only recompute the transform.
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: _slideGap), child: child),
      builder: (context, child) {
        final delta = (index - _currentPage()).clamp(-1.0, 1.0);
        final scale = 1 - delta.abs() * 0.09;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0016)
            ..rotateY((rtl ? -delta : delta) * _maxSlideTurn),
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }

  /// The page the carousel currently sits on as a double (1.4 mid-turn), while
  /// guarding the "asked before the viewport has dimensions" states.
  double _currentPage() {
    if (!controller.hasClients) return controller.initialPage.toDouble();

    final position = controller.position;

    if (!position.hasPixels || !position.hasViewportDimension || !position.hasContentDimensions) {
      return controller.initialPage.toDouble();
    }

    return controller.page ?? controller.initialPage.toDouble();
  }
}

/// One project on a hero slide: the diagram or photo on one side, the localized
/// copy on the other, stacked on narrow screens.
class _WorkHeroCard extends StatelessWidget {
  final WorkItem item;
  final String localeCode;
  final int index;
  final int total;
  final bool wide;

  const _WorkHeroCard({
    required this.item,
    required this.localeCode,
    required this.index,
    required this.total,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    final copy = _WorkCopy(item: item, localeCode: localeCode, index: index, total: total, wide: wide);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF141821), Color(0xFF0B0D12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: wide
          ? Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 6, 18),
                    child: _WorkImage(item: item),
                  ),
                ),
                Expanded(flex: 6, child: Padding(padding: const EdgeInsets.all(34), child: copy)),
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: 176,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 0),
                    child: _WorkImage(item: item),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(22, 20, 22, 22),
                    child: copy,
                  ),
                ),
              ],
            ),
    );
  }
}

/// The project's image: SVG architecture diagrams are letterboxed (they have
/// English text baked in and must not be cropped), the two JPGs are covered.
class _WorkImage extends StatelessWidget {
  final WorkItem item;

  const _WorkImage({required this.item});

  @override
  Widget build(BuildContext context) {
    final isSvg = item.imageAsset.endsWith('.svg');

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.all(isSvg ? 16 : 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
      ),
      child: isSvg
          ? SvgPicture.asset(item.imageAsset, fit: BoxFit.contain)
          : Image.asset(
              item.imageAsset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
    );
  }
}

/// The localized copy for one slide: slide counter, title, description and up
/// to four tags.
class _WorkCopy extends StatelessWidget {
  final WorkItem item;
  final String localeCode;
  final int index;
  final int total;
  final bool wide;

  const _WorkCopy({
    required this.item,
    required this.localeCode,
    required this.index,
    required this.total,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    final counter = '${(index + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              counter,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.38),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.08))),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          item.titleFor(localeCode),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: wide ? 32 : 22,
            height: 1.16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 14),
        Flexible(
          child: Text(
            item.descriptionFor(localeCode),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: wide ? 15.5 : 14,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: item.tagsFor(localeCode).take(4).map((tag) => _Tag(label: tag)).toList(),
        ),
      ],
    );
  }
}

/// One dot in the carousel's slide indicator. Kept as a small custom button
/// (rather than an [IconButton]) so the hit area can stay comfortably larger
/// than the 7px dot itself.
class _CarouselDot extends StatefulWidget {
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _CarouselDot({required this.active, required this.label, required this.onTap});

  @override
  State<_CarouselDot> createState() => _CarouselDotState();
}

class _CarouselDotState extends State<_CarouselDot> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.active,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovering = true),
          onExit: (_) => setState(() => _hovering = false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: SizedBox(
              width: 26,
              height: 26,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: widget.active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: widget.active ? 0.92 : (_hovering ? 0.45 : 0.22),
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11)),
    );
  }
}

/// The whole page sits inside a [SelectionArea], and a [PageView] that drags
/// with the mouse would fight it for the same gesture on desktop/web.
/// Restricting dragging to touch-like input leaves the mouse to text selection
/// while the arrows, the dots and the auto-flip still drive the carousel.
class _CarouselScrollBehavior extends MaterialScrollBehavior {
  const _CarouselScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
  };
}
