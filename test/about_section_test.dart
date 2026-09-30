// Covers the "About" section: the personal narrative, the "how I work"
// principles, and the pointer to the regional site — which must follow the
// reader's language.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/constants/site_constants.dart';
import 'package:abidnasim/localization/app_localizations.dart';
import 'package:abidnasim/widgets/about_section.dart';

Future<void> pumpAbout(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size size = const Size(1280, 1600),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const Scaffold(body: SingleChildScrollView(child: AboutSection())),
    ),
  );

  await tester.pump();
}

void main() {
  group('regionalWebsiteFor', () {
    test('matches the reader language to a regional site', () {
      expect(SiteConstants.regionalWebsiteFor('en'), 'https://nasim.us');
      expect(SiteConstants.regionalWebsiteFor('ur'), 'https://nasim.pk');
      expect(SiteConstants.regionalWebsiteFor('ar'), 'https://nasim.ae');
    });
  });

  testWidgets('tells the story and how he works', (tester) async {
    await pumpAbout(tester);

    expect(find.textContaining('Sinclair ZX81'), findsOneWidget);
    expect(find.text('HOW I WORK'), findsOneWidget);
    expect(find.text('Understand it properly'), findsOneWidget);
    expect(find.text('Name the trade-offs'), findsOneWidget);
    expect(find.text('Explain it plainly'), findsOneWidget);
  });

  testWidgets('points at the regional site for the CV detail', (tester) async {
    await pumpAbout(tester);
    expect(find.text('nasim.us/about'), findsOneWidget);

    await pumpAbout(tester, locale: const Locale('ur'));
    expect(find.text('nasim.pk/about'), findsOneWidget);

    await pumpAbout(tester, locale: const Locale('ar'));
    expect(find.text('nasim.ae/about'), findsOneWidget);
  });

  testWidgets('the regional link opens without throwing', (tester) async {
    await pumpAbout(tester);

    await tester.tap(find.text('nasim.us/about'));
    await tester.pump();
  });

  testWidgets('localizes the narrative for Arabic / RTL', (tester) async {
    await pumpAbout(tester, locale: const Locale('ar'));

    expect(find.textContaining('Sinclair ZX81'), findsOneWidget);
    expect(find.text('كيف أعمل'), findsOneWidget);
    expect(find.text('أُسمّي المقايضات'), findsOneWidget);
  });
}
