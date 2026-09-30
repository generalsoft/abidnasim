import 'package:flutter/material.dart';

import '../constants/site_constants.dart';
import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/url_launcher_service.dart';

/// Shared look for the footer's fine print.
final TextStyle _creditStyle = TextStyle(color: Colors.white.withValues(alpha: 0.36), fontSize: 12);

/// Site footer: the brand mark on one side, and the copyright plus the
/// "Developed by Generalsoft FZ-LLC" credit on the other.
///
/// [HomePage] docks this at the bottom of the viewport, so it is kept compact
/// and stacks its two runs on narrow screens; the solid background lets it read
/// as a fixed strip against the sections scrolling above it.
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final brand = Text(
      localizations.t('footer_brand'),
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.5),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );

    final credits = _Credits(
      year: DateTime.now().year,
      generalsoftUrl: SiteConstants.generalsoftWebsiteFor(localizations.locale.languageCode),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF08090D),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Below this width the two runs would fight over one line, so the
              // credits drop onto their own line instead of overflowing.
              if (constraints.maxWidth < 720) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [brand, const SizedBox(height: 6), credits],
                );
              }

              return Row(children: [brand, const Spacer(), credits]);
            },
          ),
        ),
      ),
    );
  }
}

/// "© <year> Abid Nasim · Developed by Generalsoft FZ-LLC".
///
/// A [Wrap], so a narrow bar can break the credit across lines rather than
/// overflow it.
class _Credits extends StatelessWidget {
  final int year;
  final String generalsoftUrl;

  const _Credits({required this.year, required this.generalsoftUrl});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('© $year ${t('footer_copyright_name')}', style: _creditStyle),
        Text('·', style: _creditStyle),
        Text(t('footer_developed_by'), style: _creditStyle),
        _GeneralsoftCredit(url: generalsoftUrl),
      ],
    );
  }
}

/// The company credit: "Generalsoft" is the link, "FZ-LLC" stays plain text.
///
/// Pinned to LTR because the name is Latin — on the Arabic and Urdu pages, bidi
/// would otherwise lay the two words out in reverse.
class _GeneralsoftCredit extends StatelessWidget {
  final String url;

  const _GeneralsoftCredit({required this.url});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CreditLink(label: SiteConstants.generalsoftName, url: url),
          const SizedBox(width: 5),
          Text(SiteConstants.generalsoftLegalSuffix, style: _creditStyle),
        ],
      ),
    );
  }
}

/// An inline footer link: underlined, brightens on hover, opens in a new tab.
class _CreditLink extends StatefulWidget {
  final String label;
  final String url;

  const _CreditLink({required this.label, required this.url});

  @override
  State<_CreditLink> createState() => _CreditLinkState();
}

class _CreditLinkState extends State<_CreditLink> {
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
            'footer_link_click',
            parameter1Name: 'link_name',
            parameter1Value: 'generalsoft',
            parameter2Name: 'destination_url',
            parameter2Value: widget.url,
          );

          openUrl(widget.url);
        },
        child: Text(
          widget.label,
          style: _creditStyle.copyWith(
            color: Colors.white.withValues(alpha: hovering ? 0.9 : 0.62),
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white.withValues(alpha: hovering ? 0.55 : 0.26),
          ),
        ),
      ),
    );
  }
}

