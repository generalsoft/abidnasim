import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';
import 'language_selector.dart';

/// Top navigation: brand mark, section links (desktop only), and the
/// language selector.
class NavBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onPresence;
  final VoidCallback onExpertise;
  final VoidCallback onWork;
  final VoidCallback onAbout;
  final VoidCallback onContact;

  const NavBar({
    required this.onHome,
    required this.onPresence,
    required this.onExpertise,
    required this.onWork,
    required this.onAbout,
    required this.onContact,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context).t;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF08090D).withValues(alpha: 0.94),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          GestureDetector(onTap: onHome, child: const _BrandMark()),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width > 850)
            Row(
              children: [
                _NavItem(label: t('nav_presence'), onTap: onPresence),
                _NavItem(label: t('nav_expertise'), onTap: onExpertise),
                _NavItem(label: t('nav_work'), onTap: onWork),
                _NavItem(label: t('nav_about'), onTap: onAbout),
                _NavItem(label: t('nav_contact'), onTap: onContact),
                const SizedBox(width: 20),
                const LanguageSelector(),
              ],
            )
          else
            const LanguageSelector(),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: const Center(
            child: Text('AN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          AppLocalizations.of(context).t('footer_brand'),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.68), fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
