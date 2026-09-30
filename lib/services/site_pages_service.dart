import 'dart:async';

import 'package:http/http.dart' as http;

// -----------------------------------------------------------------------------
// REGIONAL SITE PAGES (from the live sitemap)
// -----------------------------------------------------------------------------
//
// The "Global presence" cards preview a real page of each regional site. Rather
// than hard-coding the page list, they ask for the site's /sitemap.xml — all
// three sites build with Jekyll and ship `jekyll-sitemap`, so the file lists
// every published page (sections and posts). New posts therefore start being
// previewed with no code change here.
//
// Nothing throws. A sitemap that is missing, blocked by CORS, slow or not XML
// simply yields `null`, and the caller keeps the curated list in
// data/site_pages.dart. GitHub Pages answers these sites with
// `access-control-allow-origin: *`, so the browser is allowed to read it.
// -----------------------------------------------------------------------------

/// How long a sitemap request may take before it is abandoned.
const Duration _sitemapTimeout = Duration(seconds: 8);

/// The page paths listed in `[siteUrl]/sitemap.xml`, or `null` when the sitemap
/// could not be read.
///
/// [siteUrl] is the site root, e.g. `https://nasim.us`. Pass [client] to reuse
/// an HTTP client (and to test without a network).
Future<List<String>?> fetchLiveSitePages(String siteUrl, {http.Client? client}) async {
  final base = Uri.tryParse(siteUrl);
  if (base == null) return null;

  return _downloadSitemapPaths(base.replace(path: '/sitemap.xml'), base, client: client);
}

Future<List<String>?> _downloadSitemapPaths(Uri sitemapUri, Uri base, {http.Client? client}) async {
  final httpClient = client ?? http.Client();

  try {
    final response = await httpClient.get(sitemapUri).timeout(_sitemapTimeout);
    if (response.statusCode != 200) return null;

    final pages = parseSitemapPaths(response.body, base);
    return pages.isEmpty ? null : pages;
  } on TimeoutException {
    return null;
  } catch (_) {
    return null;
  } finally {
    if (client == null) httpClient.close();
  }
}

/// Pulls the page paths out of a sitemap document.
///
/// Only same-origin "pretty" URLs are kept: a sitemap that also lists another
/// host, `/feed.xml`, or a site-verification `.html` cannot send the preview
/// somewhere unexpected. Order is preserved and duplicates are dropped.
List<String> parseSitemapPaths(String xml, Uri base) {
  final locPattern = RegExp(r'<loc>\s*(.*?)\s*</loc>', caseSensitive: false);
  final seen = <String>{};
  final paths = <String>[];

  for (final match in locPattern.allMatches(xml)) {
    final uri = Uri.tryParse((match.group(1) ?? '').trim());
    if (uri == null || uri.host != base.host) continue;

    final path = uri.path.isEmpty ? '/' : uri.path;

    // Jekyll's pages use trailing-slash permalinks; the same test drops the
    // machine-readable files a sitemap may still carry.
    if (path != '/' && !path.endsWith('/')) continue;

    if (seen.add(path)) paths.add(path);
  }

  return paths;
}
