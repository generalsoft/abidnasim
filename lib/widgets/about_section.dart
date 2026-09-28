import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'shared/content_section.dart';

/// "About" section: placeholder personal narrative copy.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(eyebrow: t('about_eyebrow'), title: t('about_title'), child: const _AboutContent());
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context).t('about_body'),
      style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 21, height: 1.7),
    );
  }
}
