import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/data/work_items.dart';
import 'package:abidnasim/localization/app_localizations.dart';
import 'package:abidnasim/widgets/work_section.dart';

/// Pumps the work section on its own (no rest of the home page), mirroring the
/// app's localization delegates so ur/ar really resolve to RTL.
Future<void> pumpWorkSection(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size size = const Size(1280, 1000),
  Duration interval = const Duration(seconds: 2),
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
        body: SingleChildScrollView(child: WorkSection(autoPlayInterval: interval)),
      ),
    ),
  );

  await tester.pump();
}

/// An auto-flip carousel animates forever by design, so `pumpAndSettle` would
/// never return. Tests advance the clock explicitly instead: [interval] for the
/// countdown, then a little more for the page-turn itself.
Future<void> letCarouselFlip(
  WidgetTester tester, {
  Duration interval = const Duration(seconds: 2),
}) async {
  await tester.pump(interval + const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump();
}

void main() {
  testWidgets('flips to the next project on its own', (tester) async {
    await pumpWorkSection(tester);

    // The controls counter is split into "01" and " / 08" texts, so a bare "01"
    // can only be the current slide indicator.
    expect(find.text('01'), findsOneWidget);

    await letCarouselFlip(tester);

    expect(find.text('02'), findsOneWidget);
    expect(find.text('01'), findsNothing);
  });

  testWidgets('loops back to the first project after the last one', (tester) async {
    await pumpWorkSection(tester);

    for (var i = 0; i < workItems.length; i++) {
      await letCarouselFlip(tester);
    }

    expect(find.text('01'), findsOneWidget);
  });

  testWidgets('arrow buttons move one project at a time', (tester) async {
    await pumpWorkSection(tester);

    await tester.tap(find.byTooltip('Next project'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('02'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous project'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('01'), findsOneWidget);

    // Wrapping backwards from the first project lands on the last one.
    await tester.tap(find.byTooltip('Previous project'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text(workItems.length.toString().padLeft(2, '0')), findsOneWidget);
  });

  testWidgets('dot indicators jump straight to a project', (tester) async {
    await pumpWorkSection(tester);

    await tester.tap(find.byTooltip('Project 5'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('05'), findsOneWidget);
  });

  testWidgets('pause button holds the carousel, resume lets it flip again', (tester) async {
    await pumpWorkSection(tester);

    await tester.tap(find.byTooltip('Pause the automatic flip'));
    await tester.pump();

    // Well past the interval: nothing may move while paused.
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('01'), findsOneWidget);

    await tester.tap(find.byTooltip('Resume the automatic flip'));
    await tester.pump();

    await letCarouselFlip(tester);
    expect(find.text('02'), findsOneWidget);
  });

  testWidgets('honours the OS reduce-motion setting', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(
      disableAnimations: true,
    );
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpWorkSection(tester);

    await tester.pump(const Duration(seconds: 8));
    expect(find.text('01'), findsOneWidget);

    // With auto-flip off there is nothing to pause.
    expect(find.byTooltip('Pause the automatic flip'), findsNothing);
  });

  testWidgets('lays out in RTL with the Urdu copy and localizes its controls', (tester) async {
    await pumpWorkSection(tester, locale: const Locale('ur'));

    expect(Directionality.of(tester.element(find.byType(WorkSection))), TextDirection.rtl);
    expect(find.byTooltip('اگلا منصوبہ'), findsOneWidget);

    await tester.tap(find.byTooltip('اگلا منصوبہ'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('02'), findsOneWidget);
  });

  testWidgets('stacks the slide without overflow on a narrow phone', (tester) async {
    await pumpWorkSection(tester, size: const Size(360, 800));

    expect(tester.takeException(), isNull);
    expect(find.textContaining(workItems.first.titleFor('en')), findsOneWidget);
  });
}
