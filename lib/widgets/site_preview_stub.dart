import 'package:flutter/material.dart';

// -----------------------------------------------------------------------------
// STYLISED SITE PREVIEW (non-web)
// -----------------------------------------------------------------------------
//
// The fallback implementation of lib/widgets/site_preview.dart, used on every
// platform without a browser: the Dart VM that runs `flutter test`, and the
// iOS/Android/macOS builds.
//
// It mirrors the web implementation's behaviour — a tall page mock scrolls
// upward inside the card, on the same timing and with the same reduced-motion
// handling — so the layout and the click-through read identically off the web.
// -----------------------------------------------------------------------------

/// One full upward pass. Matches [_scrollDuration] in `site_preview_web.dart`.
const Duration _passDuration = Duration(seconds: 26);

/// How many card-heights of mock page are rendered. Matches
/// `_frameHeightFactor` in `site_preview_web.dart`.
const double _frameHeightFactor = 3;

Widget buildSitePreview({required String region, required String url, required String title}) {
  return _FallbackSitePreview(path: _pathOf(url));
}

/// The path portion of [url] (e.g. `/work/`), shown as the mock address.
String _pathOf(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || uri.path.isEmpty) return '/';
  return uri.path;
}

class _FallbackSitePreview extends StatefulWidget {
  final String path;

  const _FallbackSitePreview({required this.path});

  @override
  State<_FallbackSitePreview> createState() => _FallbackSitePreviewState();
}

class _FallbackSitePreviewState extends State<_FallbackSitePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scroll = AnimationController(vsync: this, duration: _passDuration);

  @override
  void initState() {
    super.initState();
    _scroll.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Mirror the web CSS `prefers-reduced-motion` rule: hold still when the OS
    // asks for reduced motion.
    if (MediaQuery.disableAnimationsOf(context)) {
      _scroll.stop();
      _scroll.value = 0;
    } else if (!_scroll.isAnimating) {
      _scroll.repeat();
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight.isFinite ? constraints.maxHeight : 200.0;
        final contentHeight = height * _frameHeightFactor;

        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: const Color(0xFF0B0D12),
            child: AnimatedBuilder(
              animation: _scroll,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -_scroll.value * (contentHeight - height)),
                child: child,
              ),
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: contentHeight,
                child: SizedBox(
                  height: contentHeight,
                  width: double.infinity,
                  child: _MockPage(path: widget.path),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A rough website mock: a header, a title, the current path, then stacked
/// panels that give the upward scroll something to reveal.
class _MockPage extends StatelessWidget {
  final String path;

  const _MockPage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _bar(width: 84, height: 9, opacity: 0.24),
          const SizedBox(height: 20),
          _bar(width: double.infinity, height: 15, opacity: 0.44),
          const SizedBox(height: 8),
          _bar(width: 150, height: 15, opacity: 0.44),
          const SizedBox(height: 14),
          Text(
            path,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, letterSpacing: 1),
          ),
          const SizedBox(height: 18),
          _panel(),
          const SizedBox(height: 12),
          _panel(),
          const SizedBox(height: 12),
          _panel(),
          const SizedBox(height: 12),
          _panel(),
        ],
      ),
    );
  }

  Widget _bar({required double width, required double height, required double opacity}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _panel() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
    );
  }
}
