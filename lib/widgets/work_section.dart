import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/work_items.dart';
import '../localization/app_localizations.dart';
import 'shared/content_section.dart';

/// "Selected work" section: a grid of project cards built from the same
/// case-study data published as Jekyll posts on the regional sites (see
/// lib/data/work_items.dart for the sync note).
class WorkSection extends StatelessWidget {
  const WorkSection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(eyebrow: t('work_eyebrow'), title: t('work_title'), child: const _WorkGrid());
  }
}

class _WorkGrid extends StatelessWidget {
  const _WorkGrid();

  @override
  Widget build(BuildContext context) {
    final localeCode = AppLocalizations.of(context).locale.languageCode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1000
            ? 3
            : width >= 640
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: workItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            // A fixed extent (rather than an aspect ratio) keeps card height
            // stable even though Urdu/Arabic text can wrap differently than
            // the English original.
            mainAxisExtent: 400,
          ),
          itemBuilder: (context, index) {
            return _WorkCard(item: workItems[index], localeCode: localeCode);
          },
        );
      },
    );
  }
}

class _WorkCard extends StatelessWidget {
  final WorkItem item;
  final String localeCode;

  const _WorkCard({required this.item, required this.localeCode});

  @override
  Widget build(BuildContext context) {
    final isSvg = item.imageAsset.endsWith('.svg');

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF101217),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Container(
              color: Colors.white.withValues(alpha: 0.04),
              padding: const EdgeInsets.all(12),
              child: isSvg
                  ? SvgPicture.asset(item.imageAsset, fit: BoxFit.contain)
                  : Image.asset(item.imageAsset, fit: BoxFit.cover, width: double.infinity),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.titleFor(localeCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.25),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Text(
                      item.descriptionFor(localeCode),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.58),
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.tagsFor(localeCode).take(3).map((tag) => _Tag(label: tag)).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
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
