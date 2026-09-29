import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abidnasim/localization/app_localizations.dart';
import 'package:abidnasim/services/contact_service.dart';
import 'package:abidnasim/widgets/contact_form.dart';

/// Pumps the form on its own. [enabled] stands in for "this build has Firebase
/// config", so both states are testable without dart-defines.
Future<void> pumpForm(
  WidgetTester tester, {
  required ContactSubmitter submit,
  bool enabled = true,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(900, 1400);
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
        body: SingleChildScrollView(
          child: ContactForm(submit: submit, enabled: enabled),
        ),
      ),
    ),
  );

  // AppLocalizations.load is async, so the first frame is the empty
  // Localizations placeholder — one more pump renders the form itself.
  await tester.pump();
}

/// Field order in the widget tree: name, email, message.
Finder fieldAt(int index) => find.byType(TextFormField).at(index);

Future<void> fillValidForm(WidgetTester tester) async {
  await tester.enterText(fieldAt(0), 'Ada Lovelace');
  await tester.enterText(fieldAt(1), 'ada@example.com');
  await tester.enterText(fieldAt(2), 'Hello from the test suite.');
  await tester.pump();
}

Future<void> tapSubmit(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton));
  await tester.pump();
}

void main() {
  testWidgets('stands down with a note when the build has no Firebase config', (tester) async {
    await pumpForm(tester, enabled: false, submit: (submission) async {
      fail('the form must not send anything when it is not configured');
    });

    expect(
      find.text('The form is not available in this build. Please use the email or WhatsApp buttons above.'),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed, isNull);
    expect(tester.widget<TextFormField>(fieldAt(0)).enabled, isFalse);
  });

  testWidgets('blocks an empty form and never calls the backend', (tester) async {
    var calls = 0;
    await pumpForm(tester, submit: (submission) async {
      calls++;
      return const ContactResult(ContactStatus.success);
    });

    await tapSubmit(tester);

    expect(find.text('This field is required'), findsNWidgets(3));
    expect(calls, 0);
  });

  testWidgets('rejects a malformed email address before sending', (tester) async {
    var calls = 0;
    await pumpForm(tester, submit: (submission) async {
      calls++;
      return const ContactResult(ContactStatus.success);
    });

    await tester.enterText(fieldAt(0), 'Ada Lovelace');
    await tester.enterText(fieldAt(1), 'ada@example');
    await tester.enterText(fieldAt(2), 'Hello.');
    await tester.pump();
    await tapSubmit(tester);

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('sends the trimmed values, then confirms and clears the form', (tester) async {
    ContactSubmission? sent;
    await pumpForm(tester, submit: (submission) async {
      sent = submission;
      return const ContactResult(ContactStatus.success);
    });

    await tester.enterText(fieldAt(0), '  Ada Lovelace  ');
    await tester.enterText(fieldAt(1), ' ada@example.com ');
    await tester.enterText(fieldAt(2), '  Hello from the test suite.  ');
    await tester.pump();
    await tapSubmit(tester);
    await tester.pump();

    expect(sent, isNotNull);
    expect(sent!.name, 'Ada Lovelace');
    expect(sent!.email, 'ada@example.com');
    expect(sent!.message, 'Hello from the test suite.');
    expect(sent!.source, 'abidnasim-com-app');
    expect(sent!.locale, 'en');

    expect(
      find.text('Thank you — your message is on its way. I will reply to the email address you gave.'),
      findsOneWidget,
    );
    expect(tester.widget<TextFormField>(fieldAt(0)).controller!.text, isEmpty);
    expect(tester.widget<TextFormField>(fieldAt(2)).controller!.text, isEmpty);
  });

  testWidgets('explains a failed submission and keeps what was typed', (tester) async {
    await pumpForm(
      tester,
      submit: (submission) async => const ContactResult(ContactStatus.rejected, detail: 'HTTP 403'),
    );

    await fillValidForm(tester);
    await tapSubmit(tester);
    await tester.pump();

    expect(
      find.text('The message could not be sent. Please try again, or use the email / WhatsApp buttons above.'),
      findsOneWidget,
    );
    expect(tester.widget<TextFormField>(fieldAt(0)).controller!.text, 'Ada Lovelace');
  });

  testWidgets('renders its labels in Urdu for the RTL locale', (tester) async {
    await pumpForm(
      tester,
      locale: const Locale('ur'),
      submit: (submission) async => const ContactResult(ContactStatus.success),
    );

    expect(find.text('پیغام بھیجیں'), findsWidgets);
    expect(find.text('نام'), findsOneWidget);
    expect(Directionality.of(tester.element(find.byType(ContactForm))), TextDirection.rtl);
  });
}
