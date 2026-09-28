import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/url_launcher_service.dart';
import 'shared/content_section.dart';

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
            childAspectRatio: columns == 3 ? 1.35 : 2.1,
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
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
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
          padding: const EdgeInsets.all(28),
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
              const Spacer(),
              Text(
                AppLocalizations.of(context).t(widget.data.labelKey),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(widget.data.domain, style: TextStyle(color: Colors.white.withValues(alpha: 0.48), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
