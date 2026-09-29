/// Data for the "Projects" (work) section on the home page.
///
/// This intentionally duplicates the same 8 case studies published as Jekyll
/// posts under content/{ae,us,pk}/_posts (section: work) on the regional
/// sites. Titles, descriptions and tags are kept in sync by hand — if you
/// edit a work post's front matter on the website, mirror the change here
/// too, since there's no shared source between the Flutter app and the
/// Jekyll content.
///
/// Images live in assets/images/work/ and are shared across all three
/// languages, matching the regional sites: the source diagrams have English
/// text baked into the image itself, so no per-locale image variants exist.
library;

class WorkItem {
  /// Matches the Jekyll post's slug (content/{region}/_posts/...-<slug>.md),
  /// kept only as a stable identifier — not currently used to build a URL.
  final String slug;

  /// Path under assets/images/work/. SVGs are architecture diagrams;
  /// the two .jpg files are a photo and a mixed photo/diagram graphic.
  final String imageAsset;

  /// Title, keyed by locale code ('en' | 'ur' | 'ar').
  final Map<String, String> title;

  /// Short description, keyed by locale code.
  final Map<String, String> description;

  /// Tags, keyed by locale code. English tags are used for any tag shown
  /// in mixed-language contexts (there are none currently).
  final Map<String, List<String>> tags;

  const WorkItem({
    required this.slug,
    required this.imageAsset,
    required this.title,
    required this.description,
    required this.tags,
  });

  String titleFor(String localeCode) => title[localeCode] ?? title['en']!;

  String descriptionFor(String localeCode) => description[localeCode] ?? description['en']!;

  List<String> tagsFor(String localeCode) => tags[localeCode] ?? tags['en']!;
}

// Ordered newest-first by original publish date, matching how the Jekyll
// sites list these (site.posts sorts descending by date automatically):
// seamless-backend-replacement (05-03) > healthcare-exchange (04-28) >
// clinical-erp-ai-iot (04-25) > esb-banking (04-22) > multicloud-iot (04-18)
// > cruise-fleet (04-15) > sme-erp (04-12) > nasa-knowledge-wiki (04-08).
const List<WorkItem> workItems = [
  WorkItem(
    slug: 'seamless-backend-replacement',
    imageAsset: 'assets/images/work/NdPHR.jpg',
    title: {
      'en': 'Seamless Backend Replacement',
      'ur': 'بیک اینڈ کی بلا رکاوٹ تبدیلی',
      'ar': 'استبدال خلفي سلس',
    },
    description: {
      'en': 'I worked on this in 1999. Replaced a backend transparently for the front-end.',
      'ur': 'میں نے یہ کام 1999 میں کیا۔ فرنٹ اینڈ کو پتا چلے بغیر ایک بیک اینڈ تبدیل کیا۔',
      'ar': 'عملت على هذا المشروع في عام 1999. استبدلت نظاماً خلفياً بشفافية كاملة للواجهة الأمامية.',
    },
    tags: {
      'en': ['Project', 'RDBMS'],
      'ur': ['پراجیکٹ', 'RDBMS'],
      'ar': ['مشروع', 'قواعد بيانات علائقية'],
    },
  ),
  WorkItem(
    slug: 'healthcare-exchange-obamacare',
    imageAsset: 'assets/images/work/healthcare-exchange.svg',
    title: {
      'en': 'Healthcare Exchange — Obama Care Initiative',
      'ur': 'ہیلتھ کیئر ایکسچینج — اوباما کیئر انیشی ایٹو',
      'ar': 'منصة تبادل الرعاية الصحية — مبادرة أوباما كير',
    },
    description: {
      'en':
          'Designed and built a Healthcare Exchange platform under the Affordable Care Act, integrating EDI X12 transactions with Dynamics CRM and Azure cloud.',
      'ur':
          'ایفورڈیبل کیئر ایکٹ کے تحت ہیلتھ کیئر ایکسچینج کا ڈیزائن اور تعمیر، جس میں EDI X12 ٹرانزیکشنز کو Dynamics CRM اور Azure کلاؤڈ کے ساتھ مربوط کیا گیا۔',
      'ar':
          'تصميم وبناء منصة تبادل رعاية صحية بموجب قانون الرعاية الميسرة، ودمج معاملات EDI X12 مع Dynamics CRM وسحابة Azure.',
    },
    tags: {
      'en': ['Healthcare', 'Azure', 'Dynamics CRM', 'EDI', 'HIPAA'],
      'ur': ['ہیلتھ کیئر', 'Azure', 'Dynamics CRM', 'EDI', 'HIPAA'],
      'ar': ['رعاية صحية', 'أزور', 'Dynamics CRM', 'EDI', 'HIPAA'],
    },
  ),
  WorkItem(
    slug: 'clinical-erp-ai-iot',
    imageAsset: 'assets/images/work/clinical-erp.jpg',
    title: {
      'en': 'Clinical ERP with AI-Powered Fraud Detection & IoT Asset Tracking',
      'ur': 'مصنوعی ذہانت سے فراڈ کی شناخت اور IoT اثاثہ جاتی ٹریکنگ کے ساتھ کلینیکل ERP',
      'ar': 'نظام تخطيط موارد سريري مع كشف احتيال بالذكاء الاصطناعي وتتبع أصول بإنترنت الأشياء',
    },
    description: {
      'en':
          'Integrated a clinical ERP with AI-driven medical billing verification, fraud detection, and IoT-based asset tracking using HoloLens AR and Azure IoT Hub.',
      'ur':
          'ایک کلینیکل ERP سسٹم کا انٹیلیجنٹ میڈیکل بلنگ ویری فکیشن، فراڈ کی شناخت، اور HoloLens کے ذریعے آگمینٹڈ ریئلٹی اور Azure IoT Hub پر مبنی IoT اثاثہ جاتی ٹریکنگ کے ساتھ انضمام۔',
      'ar':
          'دمج نظام تخطيط موارد سريري مع تحقق ذكي من الفواتير الطبية، وكشف احتيال، وتتبع أصول بإنترنت الأشياء باستخدام الواقع المعزز عبر HoloLens ومنصة Azure IoT Hub.',
    },
    tags: {
      'en': ['AI', 'IoT', 'Azure', 'Healthcare', 'AR'],
      'ur': ['مصنوعی ذہانت', 'IoT', 'Azure', 'ہیلتھ کیئر', 'آگمینٹڈ ریئلٹی'],
      'ar': ['ذكاء اصطناعي', 'إنترنت الأشياء', 'أزور', 'رعاية صحية', 'واقع معزز'],
    },
  ),
  WorkItem(
    slug: 'esb-banking',
    imageAsset: 'assets/images/work/esb-banking.svg',
    title: {
      'en': 'Enterprise Service Bus for a Major Bank',
      'ur': 'ایک بڑے بینک کے لیے انٹرپرائز سروس بس',
      'ar': 'ناقل الخدمات المؤسسية لبنك كبير',
    },
    description: {
      'en':
          'Architected and implemented an Enterprise Service Bus integrating Microsoft Dynamics, SQL Server, BizTalk, and SharePoint for a large financial institution.',
      'ur':
          'ایک بڑے مالیاتی ادارے کے لیے Microsoft Dynamics، SQL Server، BizTalk اور SharePoint کو مربوط کرنے والی انٹرپرائز سروس بس کا ڈیزائن اور نفاذ۔',
      'ar':
          'تصميم وتنفيذ ناقل خدمات مؤسسية يدمج Microsoft Dynamics و SQL Server و BizTalk و SharePoint لمؤسسة مالية كبيرة.',
    },
    tags: {
      'en': ['Banking', 'ESB', 'BizTalk', 'SQL Server', 'SharePoint'],
      'ur': ['بینکاری', 'انٹرپرائز سروس بس', 'BizTalk', 'SQL Server', 'SharePoint'],
      'ar': ['قطاع مصرفي', 'ناقل خدمات مؤسسية', 'BizTalk', 'SQL Server', 'SharePoint'],
    },
  ),
  WorkItem(
    slug: 'multicloud-iot-poc',
    imageAsset: 'assets/images/work/multicloud-iot.svg',
    title: {
      'en': 'Multi-Cloud IoT & Big Data Proof of Concept',
      'ur': 'ملٹی کلاؤڈ IoT اور بگ ڈیٹا پروف آف کنسیپٹ',
      'ar': 'إثبات مفهوم إنترنت الأشياء والبيانات الضخمة متعدد السحابات',
    },
    description: {
      'en':
          'Built cross-cloud IoT, Big Data, and Machine Learning POCs across Azure, AWS, GCP, and IBM Bluemix — from Raspberry Pi edge devices to cloud data lakes.',
      'ur':
          'Azure، AWS، GCP اور IBM Bluemix پلیٹ فارمز پر IoT، بگ ڈیٹا اور مشین لرننگ کے پروف آف کنسیپٹس کی تعمیر — Raspberry Pi ایج ڈیوائسز سے لے کر کلاؤڈ ڈیٹا لیکس تک۔',
      'ar':
          'بناء إثباتات مفاهيم لإنترنت الأشياء والبيانات الضخمة والتعلم الآلي عبر منصات Azure و AWS و GCP و IBM Bluemix — من أجهزة Raspberry Pi الطرفية إلى بحيرات البيانات السحابية.',
    },
    tags: {
      'en': ['Cloud', 'IoT', 'Big Data', 'Machine Learning', 'Azure'],
      'ur': ['کلاؤڈ', 'IoT', 'بگ ڈیٹا', 'مشین لرننگ', 'Azure'],
      'ar': ['سحابة', 'إنترنت الأشياء', 'بيانات ضخمة', 'تعلم آلي', 'أزور'],
    },
  ),
  WorkItem(
    slug: 'cruise-fleet-integration',
    imageAsset: 'assets/images/work/cruise-fleet.svg',
    title: {
      'en': 'Cruise Ship Fleet Integration — 30+ Ships',
      'ur': 'کروز شپ فلیٹ انٹیگریشن — 30 سے زائد بحری جہاز',
      'ar': 'تكامل أسطول السفن السياحية — أكثر من 30 سفينة',
    },
    description: {
      'en':
          'Integrated a new Property Management System across 30+ cruise ships, with GIS-based customs reporting, Dynamics CRM build automation, and AS/400 host integration.',
      'ur':
          'ایک نئے پراپرٹی مینجمنٹ سسٹم کو 30 سے زائد کروز جہازوں میں مربوط کرنا، جس میں GIS پر مبنی کسٹمز رپورٹنگ، Dynamics CRM بلڈز کی آٹومیشن، اور AS/400 ہوسٹ انٹیگریشن شامل تھی۔',
      'ar':
          'دمج نظام إدارة ممتلكات جديد عبر أكثر من 30 سفينة سياحية، مع تقارير جمركية قائمة على نظم المعلومات الجغرافية، وأتمتة بناء Dynamics CRM، وتكامل مع نظام AS/400 المضيف.',
    },
    tags: {
      'en': ['Integration', 'GIS', 'BizTalk', 'Dynamics CRM', 'AS/400'],
      'ur': ['انٹیگریشن', 'GIS', 'BizTalk', 'Dynamics CRM', 'AS/400'],
      'ar': ['تكامل', 'نظم معلومات جغرافية', 'BizTalk', 'Dynamics CRM', 'AS/400'],
    },
  ),
  WorkItem(
    slug: 'sme-erp-elahi-electronics',
    imageAsset: 'assets/images/work/sme-erp.svg',
    title: {
      'en': 'Full SME ERP Solution — Elahi Electronics',
      'ur': 'مکمل SME ERP حل — الٰہی الیکٹرانکس',
      'ar': 'حل تخطيط موارد كامل للشركات الصغيرة والمتوسطة — الإلهي للإلكترونيات',
    },
    description: {
      'en':
          'Architected and delivered a complete ERP solution for a Small & Medium Enterprise, spanning BI, CRM, SharePoint portals, and Silverlight-based rich client applications.',
      'ur':
          'چھوٹے اور درمیانے کاروبار کے لیے ایک مکمل ERP حل کا آرکیٹیکچر اور نفاذ، جس میں BI، CRM، SharePoint پورٹلز اور Silverlight پر مبنی رِچ کلائنٹ ایپلی کیشنز شامل تھیں۔',
      'ar':
          'تصميم وتقديم حل تخطيط موارد مؤسسية كامل لشركة صغيرة ومتوسطة، يشمل ذكاء الأعمال وإدارة علاقات العملاء وبوابات SharePoint وتطبيقات عميل غنية بتقنية Silverlight.',
    },
    tags: {
      'en': ['ERP', 'Silverlight', 'SharePoint', 'SSAS', 'BizTalk'],
      'ur': ['ERP', 'Silverlight', 'SharePoint', 'SSAS', 'BizTalk'],
      'ar': ['تخطيط موارد مؤسسية', 'Silverlight', 'SharePoint', 'SSAS', 'BizTalk'],
    },
  ),
  WorkItem(
    slug: 'nasa-knowledge-wiki',
    imageAsset: 'assets/images/work/nasa-wiki.svg',
    title: {
      'en': 'Knowledge Management Wiki for NASA',
      'ur': 'NASA کے لیے نالج مینجمنٹ وکی',
      'ar': 'نظام ويكي إدارة المعرفة لناسا',
    },
    description: {
      'en':
          'Designed and implemented enterprise knowledge management wikis for NASA, with single sign-on, compliance workflows, and integrated enterprise search — as the sole architect and developer.',
      'ur':
          'NASA کے لیے انٹرپرائز نالج مینجمنٹ وکیز کا ڈیزائن اور نفاذ، جن میں سنگل سائن آن، تعمیلی ورک فلوز اور مربوط انٹرپرائز سرچ شامل تھی — واحد آرکیٹیکٹ اور ڈویلپر کے طور پر۔',
      'ar':
          'تصميم وتنفيذ منصات ويكي مؤسسية لإدارة المعرفة لناسا، مع دخول موحد وسير عمل امتثال وبحث مؤسسي مدمج — كمهندس ومطور وحيد.',
    },
    tags: {
      'en': ['NASA', 'SharePoint', 'Knowledge Management', 'Silverlight', 'Enterprise Search'],
      'ur': ['NASA', 'SharePoint', 'نالج مینجمنٹ', 'Silverlight', 'انٹرپرائز سرچ'],
      'ar': ['ناسا', 'SharePoint', 'إدارة معرفة', 'Silverlight', 'بحث مؤسسي'],
    },
  ),
];
