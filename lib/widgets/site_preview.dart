import 'package:flutter/widgets.dart';

import 'site_preview_stub.dart' if (dart.library.js_interop) 'site_preview_web.dart' as impl;

/// A live, slowly-scrolling preview of one of the regional websites.
///
/// On the web (see `site_preview_web.dart`) this embeds the real page in an
/// `<iframe>` platform view that scrolls upward, revealing more of the page.
/// Everywhere else (see `site_preview_stub.dart`) it falls back to a stylised
/// mock that scrolls the same way, so the card reads correctly in `flutter test`
/// and in native builds.
///
/// The preview is intentionally passive: it never captures the pointer, so the
/// surrounding card keeps its tap target and opens the real site in a new tab.
///
/// [region] must be unique per card — it names the web platform view type.
/// [url] is the exact page to show (the card picks a random one of the region's
/// pages); [title] becomes the accessible name of the embedded frame.
class SitePreview extends StatelessWidget {
  final String region;
  final String url;
  final String title;

  const SitePreview({
    required this.region,
    required this.url,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) => impl.buildSitePreview(region: region, url: url, title: title);
}
