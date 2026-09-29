import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:abidnasim/constants/firebase_config.dart';
import 'package:abidnasim/services/contact_service.dart';

const _submission = ContactSubmission(
  name: 'Ada Lovelace',
  email: 'ada@example.com',
  message: 'Hello from the test suite.',
  source: 'abidnasim-com-app',
  locale: 'en',
  pageUrl: 'https://abidnasim.com/',
);

final _documentsUri = Uri.parse(
  'https://example.test/v1/projects/demo/databases/(default)/documents/contact_messages',
);

Future<ContactResult> _send(MockClient client) => sendContactMessageTo(
  documentsUri: _documentsUri,
  apiKey: 'test-api-key',
  submission: _submission,
  client: client,
);

void main() {
  group('firestoreFieldsFor', () {
    test('builds the typed-field document every surface writes', () {
      final fields = firestoreFieldsFor(_submission);

      expect(
        fields.keys,
        containsAll(['name', 'email', 'message', 'source', 'locale', 'pageUrl', 'createdAt']),
      );
      expect(fields['name'], {'stringValue': 'Ada Lovelace'});
      expect(fields['email'], {'stringValue': 'ada@example.com'});
      expect(fields['message'], {'stringValue': 'Hello from the test suite.'});
      expect(fields['source'], {'stringValue': 'abidnasim-com-app'});
      expect(fields['locale'], {'stringValue': 'en'});
      expect(fields['pageUrl'], {'stringValue': 'https://abidnasim.com/'});
    });

    test('stamps createdAt as an ISO-8601 UTC timestamp', () {
      final createdAt = firestoreFieldsFor(_submission)['createdAt']!['stringValue']!;

      expect(createdAt, matches(RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$')));
      expect(DateTime.parse(createdAt).isUtc, isTrue);
    });
  });

  group('submitContactMessage', () {
    test('refuses to send when the build has no Firebase config', () async {
      // `flutter test` runs without --dart-define, which is exactly the state
      // this guards (a CI run whose secrets aren't set up yet). When the suite is
      // run *with* dart-defines, the configured paths below cover the send.
      if (FirebaseConfig.isConfigured) return;

      final result = await submitContactMessage(
        _submission,
        client: MockClient((request) async => fail('no request may be made without a config')),
      );

      expect(result.status, ContactStatus.notConfigured);
      expect(result.isSuccess, isFalse);
    });
  });

  group('sendContactMessageTo', () {
    test('POSTs the document to the collection endpoint with the API key', () async {
      late http.Request captured;

      final result = await _send(
        MockClient((request) async {
          captured = request;
          return http.Response('{"name":"projects/demo/databases/(default)/documents/x"}', 200);
        }),
      );

      expect(result.status, ContactStatus.success);
      expect(result.isSuccess, isTrue);
      expect(captured.method, 'POST');
      expect(captured.url.host, 'example.test');
      expect(captured.url.path, '/v1/projects/demo/databases/(default)/documents/contact_messages');
      expect(captured.url.queryParameters['key'], 'test-api-key');
      expect(captured.headers['Content-Type'], contains('application/json'));

      final fields = (jsonDecode(captured.body) as Map<String, dynamic>)['fields'] as Map<String, dynamic>;
      expect(fields['message'], {'stringValue': 'Hello from the test suite.'});
      expect(fields['source'], {'stringValue': 'abidnasim-com-app'});
    });

    test('reports a refused write as rejected, with the status code in the detail', () async {
      final result = await _send(
        MockClient((request) async => http.Response('{"error":{"status":"PERMISSION_DENIED"}}', 403)),
      );

      expect(result.status, ContactStatus.rejected);
      expect(result.detail, contains('403'));
      expect(result.detail, contains('PERMISSION_DENIED'));
    });

    test('truncates a long error body so it fits in an analytics parameter', () async {
      final result = await _send(
        MockClient((request) async => http.Response('x' * 5000, 500)),
      );

      expect(result.detail, contains('HTTP 500:'));
      expect(result.detail, endsWith('…'));
      expect(result.detail!.length, lessThan(200));
    });

    test('reports a transport failure as unreachable instead of throwing', () async {
      final result = await _send(MockClient((request) async => throw Exception('network down')));

      expect(result.status, ContactStatus.unreachable);
      expect(result.isSuccess, isFalse);
    });
  });

  group('isValidContactEmail', () {
    test('accepts ordinary addresses', () {
      expect(isValidContactEmail('ada@example.com'), isTrue);
      expect(isValidContactEmail('ada.lovelace+work@sub.example.co.uk'), isTrue);
    });

    test('rejects the shapes a visitor mistypes', () {
      expect(isValidContactEmail(''), isFalse);
      expect(isValidContactEmail('ada'), isFalse);
      expect(isValidContactEmail('ada@example'), isFalse);
      expect(isValidContactEmail('ada example@mail.com'), isFalse);
      expect(isValidContactEmail('ada@@example.com'), isFalse);
    });
  });
}
