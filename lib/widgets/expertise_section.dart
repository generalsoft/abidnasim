import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'shared/content_section.dart';

/// "Expertise" section: a simple row-per-item list of focus areas.
class ExpertiseSection extends StatelessWidget {
  const ExpertiseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(eyebrow: t('expertise_eyebrow'), title: t('expertise_title'), child: const _ExpertiseGrid());
  }
}

class _ExpertiseGrid extends StatelessWidget {
  const _ExpertiseGrid();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    final items = [
      ('01', t('expertise_item_1_title'), t('expertise_item_1_desc')),
      ('02', t('expertise_item_2_title'), t('expertise_item_2_desc')),
      ('03', t('expertise_item_3_title'), t('expertise_item_3_desc')),
      ('04', t('expertise_item_4_title'), t('expertise_item_4_desc')),
    ];

    return Column(
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    item.$1,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(item.$2, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                ),
                Expanded(
                  child: Text(
                    item.$3,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.48), fontSize: 15, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
