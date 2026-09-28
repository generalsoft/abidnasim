import 'package:flutter/widgets.dart';

import 'strings_ar.dart';
import 'strings_en.dart';
import 'strings_ur.dart';

/// Central localization lookup for the site.
///
/// Strings live in language-specific files (`strings_en.dart`,
/// `strings_ur.dart`, `strings_ar.dart`) as plain key/value maps.
/// This class resolves the right map for the active locale and exposes
/// a small `t(key)` helper that widgets call directly — no `.arb` files,
/// no code generation, per the "proper Flutter localization" requirement
/// without pulling in Google Translate or a heavier package.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ur'),
    Locale('ar'),
  ];

  static const List<String> _rtlLanguageCodes = ['ur', 'ar'];

  static const Map<String, Map<String, String>> _allStrings = {
    'en': stringsEn,
    'ur': stringsUr,
    'ar': stringsAr,
  };

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(
      localizations != null,
      'AppLocalizations not found in context. Wrap the app with AppLocalizations.delegate.',
    );
    return localizations!;
  }

  static bool isRtl(Locale locale) => _rtlLanguageCodes.contains(locale.languageCode);

  TextDirection get textDirection => isRtl(locale) ? TextDirection.rtl : TextDirection.ltr;

  /// Looks up [key] for the active locale, falling back to English and then
  /// to the raw key itself, so a missing translation never crashes the UI.
  String t(String key) {
    final languageStrings = _allStrings[locale.languageCode] ?? stringsEn;
    return languageStrings[key] ?? stringsEn[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((supported) => supported.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
