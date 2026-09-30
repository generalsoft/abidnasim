// Covers the "Global presence" cards on the VM. The live preview is the non-web
// fallback here — the real <iframe> platform view only exists in the browser, so
// it can't be exercised from `flutter test`. What this locks in: all three
// regional cards render, each shows one of that region's real section
// permalinks picked at random, and tapping a card runs its navigation path
// without throwing.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/data/site_pages.dart';
import 'package:abidnasim/localization/app_localizations.dart';
import 'package:abidnasim/widgets/presence_section.dart';
import 'package:abidnasim/widgets/site_preview.dart';

/// Market code → host, matching `_RegionData` in the presence section.
const Map<String, String> _domainsByMarket = <String, String>{
  'AE': 'nasim.ae',
  'PK': 'nasim.pk',
  'US': 'nasim.us',
};

/// Pumps the presence section on its own, mirroring the app's localization
/// delegates so ur/ar really resolve to RTL.
Future<void> pumpPresenceSection(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  Size size = const Size(1280, 1200),
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
      home: const Scaffold(body: SingleChildScrollView(child: PresenceSection())),
    ),
  );

  await tester.pump();
}

void main() {
  testWidgets('renders one preview card per regional site', (tester) async {
    await pumpPresenceSection(tester);

    expect(find.byType(SitePreview), findsNWidgets(3));
    expect(find.text('United Arab Emirates'), findsOneWidget);
    expect(find.text('Pakistan'), findsOneWidget);
    expect(find.text('United States'), findsOneWidget);
  });

  testWidgets('previews a random known page of each site', (tester) async {
    await pumpPresenceSection(tester);

    // The address line reads "<domain><path>": the domain must match the card
    // and the path must come from that market's curated page list.
    for (final entry in _domainsByMarket.entries) {
      final addresses = tester
          .widgetList<Text>(find.textContaining(entry.value))
          .map((text) => text.data!)
          .toList();

      expect(addresses, hasLength(1), reason: 'expected one address line for ${entry.value}');

      final path = addresses.single.substring(entry.value.length);
      expect(
        regionalSitePages[entry.key],
        contains(path),
        reason: 'unexpected preview address: ${addresses.single}',
      );
    }
  });

  testWidgets('tapping a card runs its navigation path without throwing', (tester) async {
    await pumpPresenceSection(tester);

    await tester.tap(find.byType(SitePreview).first);
    await tester.pump();
  });

  testWidgets('localizes the region names in Urdu', (tester) async {
    await pumpPresenceSection(tester, locale: const Locale('ur'));

    expect(find.text('متحدہ عرب امارات'), findsOneWidget);
    expect(find.text('پاکستان'), findsOneWidget);
    expect(find.text('ریاستہائے متحدہ امریکہ'), findsOneWidget);
  });
}
