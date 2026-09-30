/// No-op implementation of the outbound-navigation bridge for platforms without
/// a browser (the Dart VM used by `flutter test`, and the native builds).
///
/// See [url_launcher_service.dart], which picks this file up automatically on
/// those platforms.
library;

/// Does nothing off the web, so tapping a regional card or a contact button is
/// harmless in a native build. Signature matches the web implementation, so
/// callers never need to know which platform they run on.
void openUrl(String url) {}
