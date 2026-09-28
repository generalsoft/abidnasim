import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization/app_localizations.dart';
import 'pages/home_page.dart' show HomePage;

// -----------------------------------------------------------------------------
// LOCALE SCOPE
// -----------------------------------------------------------------------------
//
// A small InheritedWidget that exposes the current locale and a way to
// change it, without pulling in a state-management package. The language
// selector calls `LocaleScope.of(context).onLocaleChanged(...)`.
// -----------------------------------------------------------------------------

class LocaleScope extends InheritedWidget {
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  const LocaleScope({
    required this.locale,
    required this.onLocaleChanged,
    required super.child,
    super.key,
  });

  static LocaleScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope not found in context. Is the app wrapped in AbidNasimApp?');
    return scope!;
  }

  @override
  bool updateShouldNotify(LocaleScope oldWidget) => oldWidget.locale != locale;
}

// -----------------------------------------------------------------------------
// APP
// -----------------------------------------------------------------------------

class AbidNasimApp extends StatefulWidget {
  const AbidNasimApp({super.key});

  @override
  State<AbidNasimApp> createState() => _AbidNasimAppState();
}

class _AbidNasimAppState extends State<AbidNasimApp> {
  // English by default. A follow-up step can load a remembered choice here.
  Locale _locale = const Locale('en');

  void _setLocale(Locale locale) {
    if (locale == _locale) return;
    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      locale: _locale,
      onLocaleChanged: _setLocale,
      child: MaterialApp(
        title: 'Abid Nasim',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF08090D),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE8E8E8), brightness: Brightness.dark),
          fontFamily: 'Arial',
        ),
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        // The Global* delegates provide Material/Widgets/Cupertino strings for
        // en, ur and ar. Without them, built-in widgets such as the language
        // popup menu fail for ur/ar. GlobalWidgetsLocalizations also sets the
        // text direction (RTL for ur/ar) automatically.
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const HomePage(),
      ),
    );
  }
}
