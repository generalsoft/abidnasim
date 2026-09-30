import 'dart:ui_web' as ui_web;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

// -----------------------------------------------------------------------------
// LIVE SITE PREVIEW (web)
// -----------------------------------------------------------------------------
//
// The browser implementation of lib/widgets/site_preview.dart, which imports
// this file when `dart.library.js_interop` is available and the stylised
// fallback everywhere else.
//
// Each card embeds the real regional page in an <iframe> (a Flutter platform
// view). Cross-origin rules stop us from scripting the embedded page, so a true
// programmatic scroll is impossible; instead the frame is rendered several
// times taller than the visible card and a CSS keyframe animation walks it
// upward, which reads as the page scrolling. The frame and its wrapper ignore
// pointer events, so taps fall through to the Flutter card underneath, which
// opens the real site.
// -----------------------------------------------------------------------------

/// View-type prefix; the market code and target URL are appended, so each
/// distinct preview owns its factory.
const String _viewTypePrefix = 'an-regional-site-preview-';

/// How much taller than the visible card the embedded page is rendered. The
/// frame travels from its top to its bottom, so 3x gives the card roughly two
/// card-heights of upward travel.
const double _frameHeightFactor = 3;

/// One full upward pass, in CSS time units.
const String _scrollDuration = '26s';

/// A view factory may only be registered once per view type (re-registering
/// throws), and the registry outlives rebuilds, so remember what is wired up.
/// There is one entry per (market, page) pair the visitor has seen.
final Set<String> _registeredViewTypes = <String>{};

/// Whether the shared scroll keyframes have already been added to the document.
bool _keyframesInjected = false;

Widget buildSitePreview({required String region, required String url, required String title}) {
  // The view type carries the target URL. A card re-rolls its page once the
  // site's sitemap has been read, and PlatformViewLink rebuilds the surface when
  // the view type changes — so the iframe follows the new URL.
  final viewType = '$_viewTypePrefix$region-$url';

  if (_registeredViewTypes.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) => _createPreviewFrame(url: url, title: title),
    );
  }

  return HtmlElementView(
    viewType: viewType,
    // The frame ignores pointer events, so it must not swallow them either:
    // `transparent` keeps hit testing flowing through to the card.
    hitTestBehavior: PlatformViewHitTestBehavior.transparent,
  );
}

/// Builds `<div class="an-site-preview"><iframe …></iframe></div>`.
///
/// The wrapper is the clipping window (it is exactly the card's size); the frame
/// inside it is [_frameHeightFactor] times taller and slides up.
Object _createPreviewFrame({required String url, required String title}) {
  _injectKeyframes();

  final wrapper = web.HTMLDivElement()
    ..setAttribute('class', 'an-site-preview')
    ..setAttribute('style', _wrapperStyle);

  final frame = web.HTMLIFrameElement()
    ..setAttribute('class', 'an-site-preview-frame')
    ..setAttribute('src', url)
    ..setAttribute('title', title)
    ..setAttribute('loading', 'lazy')
    ..setAttribute('scrolling', 'no')
    ..setAttribute('tabindex', '-1')
    ..setAttribute('referrerpolicy', 'no-referrer-when-downgrade')
    ..setAttribute('style', _frameStyle);

  wrapper.appendChild(frame);
  return wrapper;
}

/// The clipping window. Transparent so the Flutter fallback shows through while
/// the frame loads (or if the site refuses to be framed).
const String _wrapperStyle =
    'position: relative;'
    'width: 100%;'
    'height: 100%;'
    'overflow: hidden;'
    'border-radius: 14px;'
    'background: transparent;'
    'pointer-events: none;';

/// The scrolling frame. `height` and the `translateY` end point are kept in sync
/// with [_frameHeightFactor] so the whole rendered page is walked through.
const String _frameStyle =
    'position: absolute;'
    'top: 0;'
    'left: 0;'
    'width: 100%;'
    'height: ${_frameHeightFactor * 100}%;'
    'border: 0;'
    'margin: 0;'
    'background: transparent;'
    'pointer-events: none;'
    'will-change: transform;'
    'animation: anSitePreviewScroll $_scrollDuration linear infinite;';

/// Scrolls the frame from its top to its bottom, then loops. `translateY` is a
/// percentage of the frame's own height, so `-100% * (factor - 1) / factor`
/// lands the bottom of the frame at the bottom of the card.
String get _keyframesCss {
  final endOffset = -100 * (_frameHeightFactor - 1) / _frameHeightFactor;

  return '''
@keyframes anSitePreviewScroll {
  from { transform: translateY(0); }
  to   { transform: translateY(${endOffset.toStringAsFixed(4)}%); }
}
@media (prefers-reduced-motion: reduce) {
  .an-site-preview-frame { animation: none !important; transform: none !important; }
}
''';
}

/// Adds the scroll keyframes to the document head, once per page load.
void _injectKeyframes() {
  if (_keyframesInjected) return;
  _keyframesInjected = true;

  final head = web.document.head;
  if (head == null) return;

  final style = web.HTMLStyleElement()
    ..setAttribute('type', 'text/css')
    ..textContent = _keyframesCss;

  head.appendChild(style);
}
