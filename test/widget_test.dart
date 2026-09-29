// Smoke test for the home page: the leftover "counter" template that shipped
// with the project referenced a `MyApp` class that never existed, so it did not
// even compile. This replaces it with a check that the real app builds and
// renders its sections.
//
// The work carousel itself is covered in test/work_section_test.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/app.dart';

void main() {
  testWidgets('home page renders the hero and the section headings', (tester) async {
    // Tall enough that every section of the single-page layout is laid out.
    tester.view.physicalSize = const Size(1280, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AbidNasimApp());
    await tester.pump();

    expect(find.text('Abid Nasim'), findsWidgets);
    expect(find.text('GLOBAL PRESENCE'), findsWidgets);
    expect(find.text('SELECTED WORK'), findsOneWidget);
    expect(find.text('Let’s talk.'), findsOneWidget);
  });
}
