import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import '../services/analytics_service.dart';
import 'shared/buttons.dart';

/// The above-the-fold hero: name, tagline, and the two primary CTAs.
class HeroSection extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onContact;

  const HeroSection({required this.onExplore, required this.onContact, super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 1100 ? 100.0 : 28.0;
    final t = AppLocalizations.of(context).t;

    return Container(
      constraints: const BoxConstraints(minHeight: 680),
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 100),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('hero_eyebrow'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                t('hero_name'),
                style: TextStyle(
                  fontSize: width > 700 ? 92 : 58,
                  height: 0.98,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -4,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  t('hero_tagline'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: width > 700 ? 24 : 19,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 42),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  PrimaryButton(
                    label: t('hero_cta_explore'),
                    icon: Icons.arrow_downward_rounded,
                    onPressed: () {
                      trackEvent('cta_click', parameter1Name: 'cta_name', parameter1Value: 'explore');
                      onExplore();
                    },
                  ),
                  SecondaryButton(
                    label: t('hero_cta_contact'),
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      trackEvent('cta_click', parameter1Name: 'cta_name', parameter1Value: 'contact');
                      onContact();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
