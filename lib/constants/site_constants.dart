class SiteConstants {
  SiteConstants._();

  // ---------------------------------------------------------------------------
  // Personal brand
  // ---------------------------------------------------------------------------

  static const String name = 'Abid Nasim';
  static const String shortName = 'AN';
  static const String siteTitle = 'Abid Nasim';

  // ---------------------------------------------------------------------------
  // Contact information
  // ---------------------------------------------------------------------------

  static const String email = 'me@abidnasim.com';

  static const String phoneDisplay = '+1.206.218.8385';
  static const String phoneLink = '+12062188385';

  static const String whatsappDisplay = '+1.206.218.8385';
  static const String whatsappLink = '12062188385';

  // ---------------------------------------------------------------------------
  // Regional websites
  // ---------------------------------------------------------------------------

  static const String globalWebsite = 'https://abidnasim.com';
  static const String pakistanWebsite = 'https://nasim.pk';
  static const String unitedStatesWebsite = 'https://nasim.us';
  static const String uaeWebsite = 'https://nasim.ae';

  // ---------------------------------------------------------------------------
  // Generalsoft (who build and run the site)
  // ---------------------------------------------------------------------------

  /// Company name as it reads in the footer credit.
  static const String generalsoftName = 'Generalsoft';

  /// The legal suffix that follows [generalsoftName].
  static const String generalsoftLegalSuffix = 'FZ-LLC';

  /// Generalsoft's site in English — the target for English and Urdu readers.
  static const String generalsoftWebsite = 'https://generalsoft.ae/en/';

  /// Generalsoft's site in Arabic — the target for Arabic readers.
  static const String generalsoftArabicWebsite = 'https://generalsoft.ae/ar/';

  /// The Generalsoft page to open for [languageCode]: Arabic readers get the
  /// Arabic site, everyone else the English one.
  static String generalsoftWebsiteFor(String languageCode) =>
      languageCode == 'ar' ? generalsoftArabicWebsite : generalsoftWebsite;

  // ---------------------------------------------------------------------------
  // Social media
  // ---------------------------------------------------------------------------

  static const String linkedinUrl = 'https://www.linkedin.com/in/generalsoft/';
  static const String instagramUrl = '';
  static const String xUrl = 'https://twitter.com/generalsoft';
  static const String facebookUrl = '';

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  static const String gtmContainerId = 'GTM-N3H2VWT3';
  static const String ga4MeasurementId = 'G-Z73YPJPLY7';
}
