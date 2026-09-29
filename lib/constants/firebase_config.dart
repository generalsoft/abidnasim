/// Firebase project configuration for the contact form.
///
/// These are the standard Firebase **web** config values, and they are supplied
/// at build time with `--dart-define` (or `--dart-define-from-file=.env`
/// locally) so no real value is ever committed:
///
/// ```
/// flutter run -d chrome --dart-define-from-file=.env
/// flutter build web --release --dart-define-from-file=.env
/// ```
///
/// CI passes the same six names as `--dart-define` flags read from repository
/// secrets — see `.github/workflows/flutter-web.yml`.
///
/// Two notes that matter:
/// * The full client config is kept here (not just the two values the REST write
///   needs), because the same six names are the contract with the regional
///   sites' generated `firebase-config.js`. Only [apiKey] and [projectId] are
///   read today, so the compiler leaves the rest out of the bundle; they're here
///   so switching to the Firebase JS SDK later needs no plumbing.
/// * This config is *public by design*. Firebase's client config is not a
///   secret; what protects the project is the Firestore security rules (and,
///   optionally, an API key restricted by HTTP referrer in Google Cloud). See
///   README_HANDOFF.md, "Contact form".
library;

class FirebaseConfig {
  FirebaseConfig._();

  static const String apiKey = String.fromEnvironment('PUBLIC_FIREBASE_API_KEY');
  static const String authDomain = String.fromEnvironment('PUBLIC_FIREBASE_AUTH_DOMAIN');
  static const String projectId = String.fromEnvironment('PUBLIC_FIREBASE_PROJECT_ID');
  static const String storageBucket = String.fromEnvironment('PUBLIC_FIREBASE_STORAGE_BUCKET');
  static const String messagingSenderId = String.fromEnvironment('PUBLIC_FIREBASE_MESSAGING_SENDER_ID');
  static const String appId = String.fromEnvironment('PUBLIC_FIREBASE_APP_ID');

  /// Firestore collection the contact form writes to. Every surface — this app
  /// and nasim.pk / nasim.us / nasim.ae — writes here, so the messages land in
  /// one place. It must match the collection in `firestore.rules`; if it ever
  /// moves, change it there, in
  /// `content/common/assets/js/contact-form.js`, and in
  /// `content/common/_includes/contact_form.html`.
  static const String contactCollection = 'contacts';

  /// True once the two values an unauthenticated REST write needs are present.
  /// When this is false (a local run without `.env`, or CI before the secrets
  /// are configured) the form renders disabled and points at the email /
  /// WhatsApp buttons instead of failing at submit time.
  static bool get isConfigured => apiKey.isNotEmpty && projectId.isNotEmpty;

  /// The Firestore REST endpoint that creates a document in
  /// [contactCollection]. The API key is added as a `key` query parameter.
  static Uri get contactDocumentsUri => Uri.parse(
    'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/$contactCollection',
  );
}
