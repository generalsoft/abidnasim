import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'shared/content_section.dart';

/// "Selected work" section. Currently a placeholder card until real
/// case studies are ready.
class WorkSection extends StatelessWidget {
  const WorkSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(eyebrow: t('work_eyebrow'), title: t('work_title'), child: const _WorkPlaceholder());
  }
}

class _WorkPlaceholder extends StatelessWidget {
  const _WorkPlaceholder();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: const Color(0xFF101217),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('work_placeholder_label'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          Text(t('work_placeholder_heading'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text(
            t('work_placeholder_desc'),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.52), fontSize: 16, height: 1.6),
          ),
        ],
      ),
    );
  }
}
