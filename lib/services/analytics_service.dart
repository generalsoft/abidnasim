/// Cross-platform entry point for the analytics bridge.
///
/// GTM/GA4 only exist in the browser, so the real implementation (which talks
/// to JavaScript through `dart:js_interop`) is web-only and everything else —
/// VM test runs, iOS/Android/macOS builds — gets [analytics_service_stub.dart],
/// where `trackEvent` is a no-op. Widgets keep importing this file either way.
library;

export 'analytics_service_stub.dart' if (dart.library.js_interop) 'analytics_service_web.dart';
