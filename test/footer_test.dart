// Covers the footer credit: "© <year> Abid Nasim · Developed by Generalsoft
// FZ-LLC", with the Generalsoft link pointing at the right Generalsoft site for
// the reader's language.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/constants/site_constants.dart';
import 'package:abidnasim/localization/app_localizations.dart';
import 'package:abidnasim/widgets/footer.dart';

Future<void> pumpFooter(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size size = const Size(1280, 400),
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
      home: const Scaffold(body: Align(alignment: Alignment.bottomCenter, child: Footer())),
    ),
  );

  await tester.pump();
}

void main() {
  group('generalsoftWebsiteFor', () {
    test('sends Arabic readers to the Arabic site', () {
      expect(SiteConstants.generalsoftWebsiteFor('ar'), 'https://generalsoft.ae/ar/');
    });

    test('sends English and Urdu readers to the English site', () {
      expect(SiteConstants.generalsoftWebsiteFor('en'), 'https://generalsoft.ae/en/');
      expect(SiteConstants.generalsoftWebsiteFor('ur'), 'https://generalsoft.ae/en/');
    });
  });

  testWidgets('credits Abid Nasim and Generalsoft FZ-LLC', (tester) async {
    await pumpFooter(tester);

    expect(find.text('© ${DateTime.now().year} Abid Nasim'), findsOneWidget);
    expect(find.text('Developed by'), findsOneWidget);
    expect(find.text('Generalsoft'), findsOneWidget);
    expect(find.text('FZ-LLC'), findsOneWidget);
  });

  testWidgets('localizes the credit, keeping the company name in LTR', (tester) async {
    await pumpFooter(tester, locale: const Locale('ar'));

    expect(find.text('© ${DateTime.now().year} عابد نسيم'), findsOneWidget);
    expect(find.text('تم التطوير بواسطة'), findsOneWidget);

    // "Generalsoft" sits to the left of "FZ-LLC" even on the RTL page, rather
    // than bidi flipping the Latin name to "FZ-LLC Generalsoft".
    expect(
      tester.getTopLeft(find.text('Generalsoft')).dx,
      lessThan(tester.getTopLeft(find.text('FZ-LLC')).dx),
    );
  });

  testWidgets('stacks its runs without overflowing on a narrow screen', (tester) async {
    await pumpFooter(tester, size: const Size(360, 400));

    expect(tester.takeException(), isNull);
    expect(find.text('ABID NASIM'), findsOneWidget);
    expect(find.text('Generalsoft'), findsOneWidget);
  });
}
