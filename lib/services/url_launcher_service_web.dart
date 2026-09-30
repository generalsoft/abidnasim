import 'package:web/web.dart' as web;

// -----------------------------------------------------------------------------
// BROWSER URL LAUNCHER (web)
// -----------------------------------------------------------------------------
//
// The browser implementation of lib/services/url_launcher_service.dart, which
// exports this file when `dart.library.js_interop` is available and the no-op
// stub everywhere else.
//
// Opens the target in a new tab, so the visitor keeps their place on the
// landing site. Used by the regional site cards (nasim.ae / .pk / .us) and the
// contact channels (mailto:, tel:, wa.me).
// -----------------------------------------------------------------------------

/// Opens [url] in a new browser tab.
///
/// `noopener,noreferrer` keeps the opened page from reaching back into this
/// one. Navigation failures must never crash or block the UI, so any interop
/// error is swallowed silently — the same rule the analytics bridge follows.
void openUrl(String url) {
  try {
    web.window.open(url, '_blank', 'noopener,noreferrer');
  } catch (_) {
    // Opening a tab should never prevent the website from working.
  }
}
