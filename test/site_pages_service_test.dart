// Covers the sitemap reader behind the "Global presence" previews. All network
// access goes through the injected MockClient, so these run offline.

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:abidnasim/services/site_pages_service.dart';

void main() {
  group('parseSitemapPaths', () {
    final base = Uri.parse('https://nasim.us');

    test('keeps same-origin page paths, in document order', () {
      const xml = '''
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url><loc>https://nasim.us/work/esb-banking/</loc></url>
  <url><loc>https://nasim.us/about/</loc></url>
  <url><loc>https://nasim.us/</loc></url>
</urlset>
''';

      expect(parseSitemapPaths(xml, base), ['/work/esb-banking/', '/about/', '/']);
    });

    test('drops other hosts, machine files and duplicates', () {
      const xml = '''
<urlset>
  <url><loc>https://nasim.us/feed.xml</loc></url>
  <url><loc>https://nasim.us/google12b16012375a624c.html</loc></url>
  <url><loc>https://example.com/work/elsewhere/</loc></url>
  <url><loc>https://nasim.us/blog/</loc></url>
  <url><loc>https://nasim.us/blog/</loc></url>
</urlset>
''';

      expect(parseSitemapPaths(xml, base), ['/blog/']);
    });

    test('returns nothing when there are no usable entries', () {
      expect(parseSitemapPaths('<html><body>404</body></html>', base), isEmpty);
    });
  });

  group('fetchLiveSitePages', () {
    test('reads the page list out of the site sitemap', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), 'https://nasim.us/sitemap.xml');
        return http.Response(
          '<urlset><url><loc>https://nasim.us/work/</loc></url>'
          '<url><loc>https://nasim.us/blog/how-ai-thinks/</loc></url></urlset>',
          200,
        );
      });

      expect(
        await fetchLiveSitePages('https://nasim.us', client: client),
        ['/work/', '/blog/how-ai-thinks/'],
      );
    });

    test('returns null when the site has no sitemap', () async {
      final client = MockClient((request) async => http.Response('Not Found', 404));

      expect(await fetchLiveSitePages('https://nasim.ae', client: client), isNull);
    });

    test('returns null when the request fails', () async {
      final client = MockClient((request) async => throw Exception('offline'));

      expect(await fetchLiveSitePages('https://nasim.pk', client: client), isNull);
    });

    test('returns null when the sitemap lists no usable pages', () async {
      final client = MockClient((request) async => http.Response('<urlset></urlset>', 200));

      expect(await fetchLiveSitePages('https://nasim.us', client: client), isNull);
    });

    test('returns null for an unusable site url', () async {
      final client = MockClient((request) async => fail('no request may be made'));

      expect(await fetchLiveSitePages('not a url', client: client), isNull);
    });
  });
}
