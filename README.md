# abidnasim.com

## flutter demo
I am continuing development of my personal-brand Flutter Web website.

## Project

* Main website: `abidnasim.com`
* Pakistan website: `nasim.pk`
* United States website: `nasim.us`
* UAE website: `nasim.ae`
* GitHub repository: `generalsoft/abidnasim`
* Framework: Flutter Web
* Flutter version: `3.47.1`
* Dart version: `3.13.1`
* Deployment: GitHub Pages through GitHub Actions
* Current deployment is working.

## Design direction

The website should feel:

* Dark
* Premium
* Minimal
* Modern
* Strong typography
* Restrained animation
* Responsive on desktop, tablet, and mobile

The main site is the global personal-brand hub. It should link clearly to the three regional websites:

* Pakistan → `https://nasim.pk`
* United States → `https://nasim.us`
* United Arab Emirates → `https://nasim.ae`

## Existing setup

Google Tag Manager:

* GTM account: `Abid Nasim - Personal Brand`
* Main container: `AN - abidnasim.com`
* Main container ID: `GTM-N3H2VWT3`

GA4:

* One GA4 property with four web streams
* Main website Measurement ID: `G-Z73YPJPLY7`
* GA4 is configured through GTM, not directly in Flutter

The main website’s `web/index.html` already contains:

* Google Tag Manager container `GTM-N3H2VWT3`
* `window.dataLayer` initialization
* A JavaScript function named `trackGtmEvent`
* Flutter bootstrap script

The site uses the architecture:

Flutter → JavaScript bridge → dataLayer → GTM → GA4

## Contact details

These are public contact details and should be stored in a constants file:

* Email: `me@abidnasim.com`
* Phone display: `+1.206.218.8385`
* Phone link: `+12062188385`
* WhatsApp display: `+1.206.218.8385`
* WhatsApp link: `12062188385`

WhatsApp URL:

`https://wa.me/12062188385`

## Current project folders

I have already created these folders:

```text
lib/
├── localization/
├── pages/
├── widgets/
└── services/
```

We also plan to use:

```text
lib/
├── main.dart
├── app.dart
├── constants/
│   └── site_constants.dart
├── localization/
├── pages/
├── widgets/
└── services/
```

## Localization plan

The site should be multilingual:

* English — default
* Urdu — `ur`
* Arabic — `ar`

The navigation should have a compact language dropdown, such as:

`EN ▾`

The implementation should use proper Flutter localization rather than Google Translate.

Urdu and Arabic must support RTL layout.

The selected language should preferably be remembered between visits.

## Current code status

The first large `main.dart` prototype had several compilation problems. Those were corrected, and the current version successfully passed the Wasm dry run.

The only remaining error at the last build was:

```text
FontWeight.w750
```

This must be changed to:

```dart
FontWeight.w700
```

The build command is:

```bash
flutter build web
```

The successful build should produce:

```text
build/web
```

## Important coding preferences

Please work incrementally and keep the site compiling after each major change.

Do not replace the entire project unnecessarily.

When providing code:

1. Clearly state the file path.
2. Explain whether to create, replace, or edit the file.
3. Provide complete file contents when practical.
4. Avoid deprecated or unnecessary web APIs.
5. Keep contact details in `site_constants.dart`.
6. Keep analytics logic in `services/analytics_service.dart`.
7. Keep localization separate from UI widgets.
8. Keep page sections in separate files.
9. Do not place GA4 Measurement IDs directly in Flutter event code.
10. Do not add fake form-success or lead-conversion events.

## Planned architecture

```text
lib/
├── main.dart
├── app.dart
├── constants/
│   └── site_constants.dart
├── localization/
│   ├── app_localizations.dart
│   ├── strings_en.dart
│   ├── strings_ur.dart
│   └── strings_ar.dart
├── pages/
│   └── home_page.dart
├── widgets/
│   ├── nav_bar.dart
│   ├── language_selector.dart
│   ├── hero_section.dart
│   ├── presence_section.dart
│   ├── expertise_section.dart
│   ├── work_section.dart
│   ├── about_section.dart
│   ├── contact_section.dart
│   └── footer.dart
└── services/
    └── analytics_service.dart
```

## Analytics events

The planned events include:

* `regional_site_click`
* `cta_click`
* `contact_click`
* `phone_click`
* `whatsapp_click`
* `file_download`
* `call_booked`
* `generate_lead`

Useful parameters include:

* `site_region`
* `inquiry_type`
* `form_name`
* `destination_domain`
* `link_url`
* `link_text`
* `contact_method`
* `cta_name`

Avoid duplicate events already automatically collected by GA4 Enhanced Measurement.

## What I want to do next

Continue by creating the clean, maintainable foundation:

1. Fix the remaining `FontWeight.w750` error.
2. Create `lib/constants/site_constants.dart`.
3. Create `lib/services/analytics_service.dart`.
4. Create the localization files for English, Urdu, and Arabic.
5. Create `app.dart`.
6. Add the language selector.
7. Move the home page and sections into separate widget files.
8. Connect the contact buttons to:

   * `mailto:me@abidnasim.com`
   * `tel:+12062188385`
   * `https://wa.me/12062188385`
9. Preserve the dark premium visual design.
10. Build locally and verify:

```bash
flutter clean
flutter pub get
flutter build web
```

Please start by checking the current file structure and then guide me one file at a time. Do not move on to the next file until the current step is clear and compiling.
