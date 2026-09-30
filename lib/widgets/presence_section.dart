import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/site_pages.dart';
import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/site_pages_service.dart';
import '../services/url_launcher_service.dart';
import 'shared/content_section.dart';
import 'site_preview.dart';

/// "Global presence" section: one card per regional site.
class PresenceSection extends StatelessWidget {
  const PresenceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(
      eyebrow: t('presence_eyebrow'),
      title: t('presence_title'),
      child: const _PresenceCards(),
    );
  }
}

class _PresenceCards extends StatelessWidget {
  const _PresenceCards();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _RegionData(
        region: 'United Arab Emirates',
        labelKey: 'presence_region_uae',
        code: 'AE',
        domain: 'nasim.ae',
        url: 'https://nasim.ae',
      ),
      _RegionData(
        region: 'Pakistan',
        labelKey: 'presence_region_pk',
        code: 'PK',
        domain: 'nasim.pk',
        url: 'https://nasim.pk',
      ),
      _RegionData(
        region: 'United States',
        labelKey: 'presence_region_us',
        code: 'US',
        domain: 'nasim.us',
        url: 'https://nasim.us',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 3 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            // Fixed card heights, so the live preview panel always gets a
            // dependable slice of room regardless of the column width.
            mainAxisExtent: columns == 3 ? 380 : 340,
          ),
          itemBuilder: (context, index) {
            return _RegionCard(data: cards[index]);
          },
        );
      },
    );
  }
}

class _RegionData {
  /// Canonical English name. Sent to analytics, so never translated.
  final String region;

  /// Localization key for the displayed name.
  final String labelKey;
  final String code;
  final String domain;
  final String url;

  const _RegionData({
    required this.region,
    required this.labelKey,
    required this.code,
    required this.domain,
    required this.url,
  });
}

class _RegionCard extends StatefulWidget {
  final _RegionData data;

  const _RegionCard({required this.data});

  @override
  State<_RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<_RegionCard> {
  /// The curated page list for this market (data/site_pages.dart). It is the
  /// fallback, and it is what paints first — the sitemap round-trip runs behind
  /// it, so a card is never empty while the network is busy.
  List<String> get _knownPaths => regionalSitePages[widget.data.code] ?? const <String>['/'];

  /// Picked at random per card, so the three cards (and repeat visits) preview
  /// different pages rather than every card opening on the same home page.
  late String _previewPath = _pickRandom(_knownPaths);

  bool hovering = false;

  String get _previewUrl => '${widget.data.url}$_previewPath';

  @override
  void initState() {
    super.initState();
    unawaited(_rollFromLiveSitemap());
  }

  /// Once the site's sitemap has been read, re-roll onto one of its pages, so
  /// the preview draws from everything the site publishes — every case study,
  /// blog post and hobby page, freshly added ones included — instead of the
  /// curated list. Re-rolling changes the URL, which swaps the iframe (see
  /// widgets/site_preview_web.dart).
  ///
  /// Web-only: off the web there is no live preview to feed, and skipping the
  /// request keeps `flutter test` off the network.
  Future<void> _rollFromLiveSitemap() async {
    if (!kIsWeb) return;

    final pages = await fetchLiveSitePages(widget.data.url);
    if (!mounted || pages == null || pages.isEmpty) return;

    final path = _pickRandom(pages);
    if (path == _previewPath) return;

    setState(() => _previewPath = path);
  }

  String _pickRandom(List<String> paths) => paths[Random().nextInt(paths.length)];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final regionName = localizations.t(widget.data.labelKey);
    final address = '${widget.data.domain}$_previewPath';

    return Semantics(
      button: true,
      label: '$regionName — $address',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => hovering = true),
        onExit: (_) => setState(() => hovering = false),
        child: GestureDetector(
          // The embedded preview ignores pointer events, so the card itself
          // receives the tap and opens the regional site in a new tab.
          behavior: HitTestBehavior.opaque,
          onTap: () {
            trackEvent(
              'regional_site_click',
              parameter1Name: 'site_region',
              parameter1Value: widget.data.region,
              parameter2Name: 'destination_domain',
              parameter2Value: widget.data.domain,
            );

            openUrl(widget.data.url);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: hovering ? const Color(0xFF151820) : const Color(0xFF101217),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: hovering ? 0.18 : 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.data.code,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.38),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: hovering ? -0.08 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.arrow_outward_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SitePreview(
                      region: widget.data.code,
                      url: _previewUrl,
                      title: regionName,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  regionName,
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.48), fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
