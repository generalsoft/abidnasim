/// Cross-platform entry point for outbound navigation.
///
/// A browser only exists on the web, so the real implementation (which calls
/// `window.open` through `package:web`) is web-only and every other target — VM
/// test runs, iOS/Android/macOS builds — gets [url_launcher_service_stub.dart],
/// where [openUrl] is a no-op. Widgets keep importing this file either way,
/// mirroring the analytics bridge in `analytics_service.dart`.
library;

export 'url_launcher_service_stub.dart'
    if (dart.library.js_interop) 'url_launcher_service_web.dart';
