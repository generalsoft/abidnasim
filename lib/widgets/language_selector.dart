import 'package:flutter/material.dart';

import '../app.dart';

/// Compact language dropdown for the nav bar, e.g. "EN ▾".
///
/// Reads the active locale from [LocaleScope] and calls back into it when
/// the user picks a different language. Purely a UI control — it knows
/// nothing about how strings are looked up or persisted.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  static const _languages = [
    (code: 'en', label: 'EN', name: 'English'),
    (code: 'ur', label: 'UR', name: 'اردو'),
    (code: 'ar', label: 'AR', name: 'العربية'),
  ];

  @override
  Widget build(BuildContext context) {
    final scope = LocaleScope.of(context);
    final currentCode = scope.locale.languageCode;
    final current = _languages.firstWhere(
      (lang) => lang.code == currentCode,
      orElse: () => _languages.first,
    );

    return PopupMenuButton<String>(
      tooltip: 'Change language',
      offset: const Offset(0, 36),
      color: const Color(0xFF12141A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      onSelected: (code) {
        scope.onLocaleChanged(Locale(code));
      },
      itemBuilder: (context) {
        return [
          for (final lang in _languages)
            PopupMenuItem<String>(
              value: lang.code,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32,
                    child: Text(
                      lang.label,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: lang.code == currentCode ? 1 : 0.6),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    lang.name,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: lang.code == currentCode ? 1 : 0.6),
                      fontSize: 13,
                    ),
                  ),
                  if (lang.code == currentCode) ...[
                    const Spacer(),
                    const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                  ],
                ],
              ),
            ),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.expand_more_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
