/// Page paths on the three regional sites, used by the "Global presence"
/// previews (see widgets/presence_section.dart).
///
/// This is a hand-maintained duplicate of the `permalink:` front matter under
/// content/{ae,pk,us} — the same convention `work_items.dart` documents. It is
/// only the *fallback*: at runtime the previews read each site's live
/// /sitemap.xml first (see services/site_pages_service.dart) and draw from that,
/// so a newly published page shows up without touching this file.
library;

/// Listing pages, shared by all three sites (content/{ae,pk,us}/
/// {index,about,work,blog,hobby,contact}.md).
const List<String> _sectionPaths = <String>[
  '/',
  '/about/',
  '/work/',
  '/blog/',
  '/hobby/',
  '/contact/',
];

/// Post permalinks, shared by all three sites — mirrored from the `permalink:`
/// front matter of content/{ae,pk,us}/_posts/*.md.
const List<String> _postPaths = <String>[
  // work
  '/work/seamless-backend-replacement/',
  '/work/healthcare-exchange-obamacare/',
  '/work/clinical-erp-ai-iot/',
  '/work/esb-banking/',
  '/work/multicloud-iot-poc/',
  '/work/cruise-fleet-integration/',
  '/work/sme-erp-elahi-electronics/',
  '/work/nasa-knowledge-wiki/',
  // blog
  '/blog/how-ai-thinks/',
  '/blog/explainai/',
  '/blog/paradigm-econ/',
  '/blog/athen2bukhara/',
  // hobby
  '/hobby/iotsaveday/',
];

/// Every known page path, sections first.
const List<String> _allPaths = <String>[..._sectionPaths, ..._postPaths];

/// The fallback page list per market code ('AE' | 'PK' | 'US'), keyed the same
/// way as `_RegionData.code`.
///
/// All three sites publish the same sections and posts today, so they point at
/// the same list; keeping the map per market means one site can diverge later
/// without affecting the others.
const Map<String, List<String>> regionalSitePages = <String, List<String>>{
  'AE': _allPaths,
  'PK': _allPaths,
  'US': _allPaths,
};
