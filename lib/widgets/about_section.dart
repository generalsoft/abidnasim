import 'package:flutter/material.dart';

import '../constants/site_constants.dart';
import '../localization/app_localizations.dart';
import 'shared/content_section.dart';
import 'shared/inline_link.dart';

/// "About" section: the personal layer.
///
/// Deliberately not another list of credentials — the expertise section owns
/// "what I do". This is who the work comes from and how he works, plus a pointer
/// to the regional sites for the CV detail (education, certifications), which is
/// the part that genuinely belongs on a per-region page.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final t = localizations.t;
    final regionalUrl = SiteConstants.regionalWebsiteFor(localizations.locale.languageCode);

    return ContentSection(
      eyebrow: t('about_eyebrow'),
      title: t('about_title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AboutLead(text: t('about_lead')),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Text(
              t('about_body'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 18, height: 1.7),
            ),
          ),
          const SizedBox(height: 46),
          const _HowIWork(),
          const SizedBox(height: 40),
          _RegionalNote(regionalUrl: regionalUrl),
        ],
      ),
    );
  }
}

/// The opening statement, set against a rule and given a larger size so the
/// section starts with a voice rather than another paragraph. Directional, so
/// the rule and the indent flip for the Arabic and Urdu pages.
class _AboutLead extends StatelessWidget {
  final String text;

  const _AboutLead({required this.text});

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 700;

    return Container(
      padding: const EdgeInsetsDirectional.only(start: 26),
      decoration: BoxDecoration(
        border: BorderDirectional(
          start: BorderSide(color: Colors.white.withValues(alpha: 0.24), width: 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: wide ? 30 : 23,
          height: 1.4,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }
}

/// Three short principles, side by side on a wide screen and stacked on a narrow
/// one — the "how" behind the "what" that the expertise section lists.
class _HowIWork extends StatelessWidget {
  /// How many `about_principle_<n>_title` / `_desc` pairs each string set defines.
  static const int principleCount = 3;

  const _HowIWork();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    final principles = [
      for (var index = 0; index < principleCount; index++)
        (
          t('about_principle_${index + 1}_title'),
          t('about_principle_${index + 1}_desc'),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('about_how_i_work'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.38),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 840) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < principles.length; index++) ...[
                    if (index > 0) const SizedBox(width: 32),
                    Expanded(
                      child: _Principle(title: principles[index].$1, body: principles[index].$2),
                    ),
                  ],
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < principles.length; index++) ...[
                  if (index > 0) const SizedBox(height: 24),
                  _Principle(title: principles[index].$1, body: principles[index].$2),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Principle extends StatelessWidget {
  final String title;
  final String body;

  const _Principle({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 26, height: 2, color: Colors.white.withValues(alpha: 0.28)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(
          body,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15, height: 1.55),
        ),
      ],
    );
  }
}

/// A quiet pointer to the regional site that matches the reader's language. The
/// CV detail — education, the certifications — only ever existed per region, so
/// this is where it belongs rather than duplicated above.
class _RegionalNote extends StatelessWidget {
  final String regionalUrl;

  const _RegionalNote({required this.regionalUrl});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;
    final host = Uri.parse(regionalUrl).host;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          t('about_regional_note'),
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
        ),
        InlineLink(
          label: '$host/about',
          url: '$regionalUrl/about/',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.68), fontSize: 13),
          analyticsName: 'regional_about',
        ),
      ],
    );
  }
}
