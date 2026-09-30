// Covers the "Expertise" section: the capability list and the AI-education call
// to action, including that the CTA actually reaches the contact section.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/localization/app_localizations.dart';
import 'package:abidnasim/widgets/expertise_section.dart';

Future<void> pumpExpertise(
  WidgetTester tester, {
  VoidCallback? onContact,
  Locale locale = const Locale('en'),
  Size size = const Size(1280, 2000),
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
      home: Scaffold(
        body: SingleChildScrollView(child: ExpertiseSection(onContact: onContact ?? () {})),
      ),
    ),
  );

  await tester.pump();
}

void main() {
  testWidgets('lays out the capability areas', (tester) async {
    await pumpExpertise(tester);

    for (final number in const ['01', '02', '03', '04', '05', '06']) {
      expect(find.text(number), findsOneWidget, reason: 'missing row $number');
    }

    expect(find.text('Software & platform architecture'), findsOneWidget);
    expect(find.text('Enterprise integration'), findsOneWidget);
    expect(find.text('AI & language technology'), findsOneWidget);
    expect(find.text('Teaching & mentoring'), findsOneWidget);
  });

  testWidgets('offers AI education with a call to action', (tester) async {
    await pumpExpertise(tester);

    expect(find.text('AVAILABLE FOR AI EDUCATION'), findsOneWidget);
    expect(find.text('Bring your team up to speed on AI.'), findsOneWidget);
    expect(find.text('Arrange a session'), findsOneWidget);
  });

  testWidgets('the AI call to action reaches the contact section', (tester) async {
    var taps = 0;
    await pumpExpertise(tester, onContact: () => taps++);

    await tester.tap(find.text('Arrange a session'));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('localizes the section for Urdu / RTL', (tester) async {
    await pumpExpertise(tester, locale: const Locale('ur'));

    expect(find.text('سافٹ ویئر اور پلیٹ فارم آرکیٹیکچر'), findsOneWidget);
    expect(find.text('اے آئی کی تعلیم کے لیے دستیاب'), findsOneWidget);
    expect(find.text('سیشن ترتیب دیں'), findsOneWidget);
  });
}
