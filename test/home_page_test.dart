// Covers the app shell: the nav bar is docked to the top and the footer to the
// bottom, with only the sections between them scrolling. Before this, both lived
// inside the scroll view and scrolled away with the content.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/app.dart';
import 'package:abidnasim/widgets/footer.dart';
import 'package:abidnasim/widgets/nav_bar.dart';

void main() {
  testWidgets('header and footer stay docked while the sections scroll', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AbidNasimApp());
    await tester.pump();

    final header = find.byType(NavBar);
    final footer = find.byType(Footer);
    final scrollView = find.byType(CustomScrollView);

    // The two bars frame the scroll viewport rather than living inside it.
    expect(
      tester.getBottomLeft(header).dy,
      lessThanOrEqualTo(tester.getTopLeft(scrollView).dy),
      reason: 'the header should sit above the scrolling region',
    );
    expect(
      tester.getTopLeft(footer).dy,
      greaterThanOrEqualTo(tester.getBottomLeft(scrollView).dy),
      reason: 'the footer should sit below the scrolling region',
    );

    final headerBefore = tester.getTopLeft(header);
    final footerBefore = tester.getTopLeft(footer);

    // Drive the middle viewport directly, so the test does not depend on which
    // widget a synthetic drag happens to land on (the work carousel claims
    // gestures of its own).
    final position = tester
        .state<ScrollableState>(
          find.descendant(of: scrollView, matching: find.byType(Scrollable)).first,
        )
        .position;

    position.jumpTo(600);
    await tester.pump();

    expect(position.pixels, 600, reason: 'the sections should have scrolled');
    expect(tester.getTopLeft(header), headerBefore, reason: 'the header should not move');
    expect(tester.getTopLeft(footer), footerBefore, reason: 'the footer should not move');
  });
}
