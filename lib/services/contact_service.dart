import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/firebase_config.dart';

// -----------------------------------------------------------------------------
// CONTACT FORM → FIRESTORE
// -----------------------------------------------------------------------------
//
// Submissions go straight to the Firestore REST API from the client, using the
// same request shape as the regional sites' contact form
// (content/common/assets/js/contact-form.js), so all four surfaces write
// identical documents into FirebaseConfig.contactCollection:
//
//   name, email, message, source, locale, pageUrl, createdAt
//
// Why REST instead of the Firebase JS SDK: it keeps the web-only JS interop out
// of this app (the SDK would also need a valid `appId`, which the config we're
// given doesn't include), and it lets this file be unit-tested on the Dart VM.
//
// Nothing here throws. A failed submission is a value the UI can render, since a
// visitor must never see a broken page because the network or the project
// config was unhappy.
// -----------------------------------------------------------------------------

/// Field limits. Enforced in the form UI and mirrored in the Firestore rules
/// documented in README_HANDOFF.md, so the collection can't be filled with
/// unbounded documents.
const int contactNameMaxLength = 80;
const int contactEmailMaxLength = 160;
const int contactMessageMaxLength = 2000;

/// How long a submission may take before it is treated as unreachable.
const Duration _submitTimeout = Duration(seconds: 20);

/// What happened to a submission. The UI maps these to localized copy.
enum ContactStatus {
  /// Firestore created the document.
  success,

  /// The build has no Firebase config, so nothing was sent.
  notConfigured,

  /// Firestore answered, but refused the write (security rules, quota,
  /// invalid/mis-restricted API key…).
  rejected,

  /// The request never completed (offline, blocked, timeout…).
  unreachable,
}

/// The visitor's input, plus the context needed to triage it later.
class ContactSubmission {
  final String name;
  final String email;
  final String message;

  /// Which surface sent this: `abidnasim-com-app` for this app, or the regional
  /// site's host/short name (`nasim.pk`, `nasim.us`, `nasim.ae`).
  final String source;

  /// Locale the visitor was reading in: `en`, `ur` or `ar`.
  final String locale;

  /// Where the form was submitted from.
  final String pageUrl;

  const ContactSubmission({
    required this.name,
    required this.email,
    required this.message,
    required this.source,
    required this.locale,
    required this.pageUrl,
  });
}

/// Outcome of a submission, with an optional technical detail that is only used
/// for logging/analytics — never shown raw to a visitor.
class ContactResult {
  final ContactStatus status;
  final String? detail;

  const ContactResult(this.status, {this.detail});

  bool get isSuccess => status == ContactStatus.success;
}

/// Signature of the submit function, so widgets (and tests) can swap the real
/// Firestore call for a fake.
typedef ContactSubmitter = Future<ContactResult> Function(ContactSubmission submission);

/// Creates one document in [FirebaseConfig.contactCollection].
///
/// The app's entry point: it refuses early when the build carries no Firebase
/// config, and otherwise delegates the HTTP work to [sendContactMessageTo].
/// Pass [client] to reuse an HTTP client (and to test without a network).
Future<ContactResult> submitContactMessage(ContactSubmission submission, {http.Client? client}) {
  if (!FirebaseConfig.isConfigured) {
    return Future.value(
      const ContactResult(
        ContactStatus.notConfigured,
        detail: 'PUBLIC_FIREBASE_API_KEY / PUBLIC_FIREBASE_PROJECT_ID are not set in this build',
      ),
    );
  }

  return sendContactMessageTo(
    documentsUri: FirebaseConfig.contactDocumentsUri,
    apiKey: FirebaseConfig.apiKey,
    submission: submission,
    client: client,
  );
}

/// The actual Firestore write.
///
/// Kept separate from [submitContactMessage] so tests can drive it with an
/// explicit endpoint, key and mock client — no build-time `--dart-define`
/// needed — and so it stays a pure "given a request, what came back" function.
Future<ContactResult> sendContactMessageTo({
  required Uri documentsUri,
  required String apiKey,
  required ContactSubmission submission,
  http.Client? client,
}) async {
  final uri = documentsUri.replace(queryParameters: {'key': apiKey});

  final http.Client httpClient = client ?? http.Client();

  try {
    final response = await httpClient
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'fields': firestoreFieldsFor(submission)}),
        )
        .timeout(_submitTimeout);

    if (response.statusCode == 200) {
      return const ContactResult(ContactStatus.success);
    }

    return ContactResult(
      ContactStatus.rejected,
      detail: 'HTTP ${response.statusCode}: ${_shorten(response.body)}',
    );
  } on TimeoutException {
    return const ContactResult(ContactStatus.unreachable, detail: 'request timed out');
  } catch (error) {
    return ContactResult(ContactStatus.unreachable, detail: error.toString());
  } finally {
    if (client == null) httpClient.close();
  }
}

/// Firestore's typed-field representation of a submission, in the exact shape
/// the REST API expects (and that `contact-form.js` produces on the sites).
Map<String, Map<String, String>> firestoreFieldsFor(ContactSubmission submission) {
  return {
    'name': {'stringValue': submission.name},
    'email': {'stringValue': submission.email},
    'message': {'stringValue': submission.message},
    'source': {'stringValue': submission.source},
    'locale': {'stringValue': submission.locale},
    'pageUrl': {'stringValue': submission.pageUrl},
    'createdAt': {'stringValue': DateTime.now().toUtc().toIso8601String()},
  };
}

/// Deliberately strict-but-simple address check: something, an `@`, something,
/// a dot, and a plausible TLD. Same pattern as the sites' JavaScript.
bool isValidContactEmail(String value) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(value);

/// Keeps response bodies short enough for logs and analytics parameters.
String _shorten(String value) => value.length <= 160 ? value : '${value.substring(0, 160)}…';
