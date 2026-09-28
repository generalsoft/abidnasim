import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

/// Site footer: brand mark and copyright year.
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 50),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              Text(
                AppLocalizations.of(context).t('footer_brand'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '© ${DateTime.now().year}',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.32), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
