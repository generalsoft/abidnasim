import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import 'shared/buttons.dart';
import 'shared/content_section.dart';

/// "Expertise" section: where the work actually lives, and the standing offer to
/// teach AI.
///
/// The six rows are deliberately layered — architecture, integration, cloud,
/// AI/language, delivery, teaching — because the breadth *is* the point; the
/// closing card then turns the teaching side into a call to action.
class ExpertiseSection extends StatelessWidget {
  /// Scrolls to the contact section. Wired from [HomePage], mirroring the hero's
  /// calls to action.
  final VoidCallback onContact;

  const ExpertiseSection({required this.onContact, super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return ContentSection(
      eyebrow: t('expertise_eyebrow'),
      title: t('expertise_title'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 780),
            child: Text(
              t('expertise_lead'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.58), fontSize: 18, height: 1.6),
            ),
          ),
          const SizedBox(height: 44),
          const _ExpertiseList(),
          const SizedBox(height: 48),
          _AiEducationCallout(onContact: onContact),
        ],
      ),
    );
  }
}

/// One row per capability area, numbered — the shape the section always had, now
/// six rows deep and responsive below tablet width.
class _ExpertiseList extends StatelessWidget {
  /// How many `expertise_item_<n>_title` / `_desc` pairs each string set defines.
  static const int itemCount = 6;

  const _ExpertiseList();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Below this width the title and the description would each be a thin
        // column, so the rows stack instead.
        final stacked = constraints.maxWidth < 760;

        return Column(
          children: [
            for (var index = 0; index < itemCount; index++)
              _ExpertiseRow(
                number: '${index + 1}'.padLeft(2, '0'),
                title: t('expertise_item_${index + 1}_title'),
                description: t('expertise_item_${index + 1}_desc'),
                stacked: stacked,
              ),
          ],
        );
      },
    );
  }
}

class _ExpertiseRow extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool stacked;

  const _ExpertiseRow({
    required this.number,
    required this.title,
    required this.description,
    required this.stacked,
  });

  @override
  Widget build(BuildContext context) {
    final heading = Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700));
    final body = Text(
      description,
      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 15, height: 1.55),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: stacked
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [heading, const SizedBox(height: 8), body],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: heading),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: body),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// The AI-education offer, given a card of its own so it reads as an invitation
/// rather than one more row of experience.
class _AiEducationCallout extends StatelessWidget {
  final VoidCallback onContact;

  const _AiEducationCallout({required this.onContact});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF11141B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AvailabilityBadge(),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              t('expertise_ai_title'),
              style: const TextStyle(fontSize: 34, height: 1.15, fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              t('expertise_ai_body'),
              style: TextStyle(color: Colors.white.withValues(alpha: 0.62), fontSize: 16, height: 1.6),
            ),
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            label: t('expertise_ai_cta'),
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              trackEvent('cta_click', parameter1Name: 'cta_name', parameter1Value: 'ai_education');

              onContact();
            },
          ),
        ],
      ),
    );
  }
}

/// Pill with a status dot, so the offer reads as "currently available".
class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge();

  /// The one spot of colour on the page — it is a status light, not decoration.
  static const Color _availableDot = Color(0xFF4ADE80);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(color: _availableDot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              AppLocalizations.of(context).t('expertise_ai_badge'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
