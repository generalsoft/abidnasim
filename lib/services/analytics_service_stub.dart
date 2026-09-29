/// No-op implementation of the analytics bridge for platforms without a DOM
/// (the Dart VM used by `flutter test`, and iOS/Android/macOS builds).
///
/// See [analytics_service.dart], which picks this file up automatically on
/// those platforms.
library;

/// Does nothing off the web. Signature matches the web implementation so
/// callers never need to know which platform they run on.
void trackEvent(
  String eventName, {
  String? parameter1Name,
  String? parameter1Value,
  String? parameter2Name,
  String? parameter2Value,
}) {}
