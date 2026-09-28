import 'dart:js_interop';

// -----------------------------------------------------------------------------
// GTM / DATA LAYER
// -----------------------------------------------------------------------------
//
// GTM itself is loaded from web/index.html.
//
// Flutter calls this JavaScript function to push events into window.dataLayer.
// We deliberately keep the GA4 Measurement ID out of Flutter — GA4 is wired
// up through GTM, not directly here.
// -----------------------------------------------------------------------------

@JS('trackGtmEvent')
external void _trackGtmEvent(
  String eventName,
  String? parameter1Name,
  String? parameter1Value,
  String? parameter2Name,
  String? parameter2Value,
);

/// Sends an analytics event into the GTM dataLayer via the JS bridge.
///
/// Analytics failures must never crash or block the UI, so any JS
/// interop error is swallowed silently.
void trackEvent(
  String eventName, {
  String? parameter1Name,
  String? parameter1Value,
  String? parameter2Name,
  String? parameter2Value,
}) {
  try {
    _trackGtmEvent(eventName, parameter1Name, parameter1Value, parameter2Name, parameter2Value);
  } catch (_) {
    // Analytics should never prevent the website from working.
  }
}
