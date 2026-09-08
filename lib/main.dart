import 'dart:js_interop';

import 'package:flutter/material.dart';

void main() {
  runApp(const AbidNasimApp());
}

// -----------------------------------------------------------------------------
// GTM / DATA LAYER
// -----------------------------------------------------------------------------
//
// GTM itself is loaded from web/index.html.
//
// Flutter calls this JavaScript function to push events into window.dataLayer.
// We keep the GA4 Measurement ID out of Flutter.
// -----------------------------------------------------------------------------

@JS('trackGtmEvent')
external void _trackGtmEvent(
  String eventName,
  String? parameter1Name,
  String? parameter1Value,
  String? parameter2Name,
  String? parameter2Value,
);

void trackEvent(
  String eventName, {
  String? parameter1Name,
  String? parameter1Value,
  String? parameter2Name,
  String? parameter2Value,
}) {
  try {
    _trackGtmEvent(
      eventName,
      parameter1Name,
      parameter1Value,
      parameter2Name,
      parameter2Value,
    );
  } catch (_) {
    // Analytics should never prevent the website from working.
  }
}

// -----------------------------------------------------------------------------
// APP
// -----------------------------------------------------------------------------

class AbidNasimApp extends StatelessWidget {
  const AbidNasimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abid Nasim',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08090D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8E8E8),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

// -----------------------------------------------------------------------------
// HOME PAGE
// -----------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _homeKey = GlobalKey();
  final _presenceKey = GlobalKey();
  final _expertiseKey = GlobalKey();
  final _workKey = GlobalKey();
  final _aboutKey = GlobalKey();
  final _contactKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;

    if (context == null) return;

    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
    );
  }

  void _openRegionalSite({
    required String region,
    required String url,
  }) {
    trackEvent(
      'regional_site_click',
      parameter1Name: 'site_region',
      parameter1Value: region,
      parameter2Name: 'destination_domain',
      parameter2Value: url,
    );

    // Use an HTML anchor via the browser's normal navigation is preferable
    // for accessibility and reliability. The actual regional cards below
    // use InkWell + Link-style behavior through UrlLauncherSection.
    //
    // This function intentionally remains available for future use.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _NavBar(
                onHome: () => _scrollTo(_homeKey),
                onPresence: () => _scrollTo(_presenceKey),
                onExpertise: () => _scrollTo(_expertiseKey),
                onWork: () => _scrollTo(_workKey),
                onAbout: () => _scrollTo(_aboutKey),
                onContact: () => _scrollTo(_contactKey),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                key: _homeKey,
                child: _HeroSection(
                  onExplore: () => _scrollTo(_presenceKey),
                  onContact: () => _scrollTo(_contactKey),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                key: _presenceKey,
                child: const _SectionDivider(),
              ),
            ),
            SliverToBoxAdapter(
              child: _PresenceSection(
                onRegionalClick: _openRegionalSite,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                key: _expertiseKey,
                child: const _ExpertiseSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                key: _workKey,
                child: const _WorkSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                key: _aboutKey,
                child: const _AboutSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                key: _contactKey,
                child: const _ContactSection(),
              ),
            ),
            const SliverToBoxAdapter(
              child: _Footer(),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NAVIGATION
// -----------------------------------------------------------------------------

class _NavBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onPresence;
  final VoidCallback onExpertise;
  final VoidCallback onWork;
  final VoidCallback onAbout;
  final VoidCallback onContact;

  const _NavBar({
    required this.onHome,
    required this.onPresence,
    required this.onExpertise,
    required this.onWork,
    required this.onAbout,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF08090D).withValues(alpha: 0.94),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onHome,
            child: const _BrandMark(),
          ),
          const Spacer(),
          if (MediaQuery.sizeOf(context).width > 850)
            Row(
              children: [
                _NavItem(label: 'Presence', onTap: onPresence),
                _NavItem(label: 'Expertise', onTap: onExpertise),
                _NavItem(label: 'Work', onTap: onWork),
                _NavItem(label: 'About', onTap: onAbout),
                _NavItem(label: 'Contact', onTap: onContact),
              ],
            ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          child: const Center(
            child: Text(
              'AN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'ABID NASIM',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.68),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HERO
// -----------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
  final VoidCallback onExplore;
  final VoidCallback onContact;

  const _HeroSection({
    required this.onExplore,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width > 1100 ? 100.0 : 28.0;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 680,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GLOBAL PRESENCE.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Abid Nasim',
                style: TextStyle(
                  fontSize: width > 700 ? 92 : 58,
                  height: 0.98,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -4,
                ),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 720,
                ),
                child: Text(
                  'A personal brand framework connecting ideas, work, '
                  'business, and presence across markets.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.66),
                    fontSize: width > 700 ? 24 : 19,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 42),
              Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _PrimaryButton(
                    label: 'Explore',
                    icon: Icons.arrow_downward_rounded,
                    onPressed: () {
                      trackEvent(
                        'cta_click',
                        parameter1Name: 'cta_name',
                        parameter1Value: 'explore',
                      );
                      onExplore();
                    },
                  ),
                  _SecondaryButton(
                    label: 'Get in touch',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      trackEvent(
                        'cta_click',
                        parameter1Name: 'cta_name',
                        parameter1Value: 'contact',
                      );
                      onContact();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// PRESENCE
// -----------------------------------------------------------------------------

class _PresenceSection extends StatelessWidget {
  final void Function({
    required String region,
    required String url,
  }) onRegionalClick;

  const _PresenceSection({
    required this.onRegionalClick,
  });

  @override
  Widget build(BuildContext context) {
    return const _ContentSection(
      eyebrow: 'GLOBAL PRESENCE',
      title: 'One identity.\nMultiple markets.',
      child: _PresenceCards(),
    );
  }
}

class _PresenceCards extends StatelessWidget {
  const _PresenceCards();

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _RegionData(
        region: 'United Arab Emirates',
        code: 'AE',
        domain: 'nasim.ae',
        url: 'https://nasim.ae',
      ),
      const _RegionData(
        region: 'Pakistan',
        code: 'PK',
        domain: 'nasim.pk',
        url: 'https://nasim.pk',
      ),
      const _RegionData(
        region: 'United States',
        code: 'US',
        domain: 'nasim.us',
        url: 'https://nasim.us',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900 ? 3 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            childAspectRatio: columns == 3 ? 1.35 : 2.1,
          ),
          itemBuilder: (context, index) {
            return _RegionCard(data: cards[index]);
          },
        );
      },
    );
  }
}

class _RegionData {
  final String region;
  final String code;
  final String domain;
  final String url;

  const _RegionData({
    required this.region,
    required this.code,
    required this.domain,
    required this.url,
  });
}

class _RegionCard extends StatefulWidget {
  final _RegionData data;

  const _RegionCard({
    required this.data,
  });

  @override
  State<_RegionCard> createState() => _RegionCardState();
}

class _RegionCardState extends State<_RegionCard> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: () {
          trackEvent(
            'regional_site_click',
            parameter1Name: 'site_region',
            parameter1Value: widget.data.region,
            parameter2Name: 'destination_domain',
            parameter2Value: widget.data.domain,
          );

          _openUrl(widget.data.url);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: hovering ? const Color(0xFF151820) : const Color(0xFF101217),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: hovering ? 0.18 : 0.08,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.data.code,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  AnimatedRotation(
                    turns: hovering ? -0.08 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                widget.data.region,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.domain,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.48),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EXPERTISE
// -----------------------------------------------------------------------------

class _ExpertiseSection extends StatelessWidget {
  const _ExpertiseSection();

  @override
  Widget build(BuildContext context) {
    return const _ContentSection(
      eyebrow: 'EXPERTISE',
      title: 'Built around\nwhat matters.',
      child: _ExpertiseGrid(),
    );
  }
}

class _ExpertiseGrid extends StatelessWidget {
  const _ExpertiseGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('01', 'Strategy', 'Ideas into focused direction.'),
      ('02', 'Technology', 'Digital systems that scale.'),
      ('03', 'Business', 'Execution with commercial intent.'),
      ('04', 'Growth', 'Building meaningful momentum.'),
    ];

    return Column(
      children: [
        for (final item in items)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    item.$1,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.$3,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.48),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// WORK
// -----------------------------------------------------------------------------

class _WorkSection extends StatelessWidget {
  const _WorkSection();

  @override
  Widget build(BuildContext context) {
    return const _ContentSection(
      eyebrow: 'SELECTED WORK',
      title: 'For over 30 years\nI have delivered projects, like:',
      child: _WorkPlaceholder(),
    );
  }
}

class _WorkPlaceholder extends StatelessWidget {
  const _WorkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: const Color(0xFF101217),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROJECTS',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'coming soon ...',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'projects, companies, products, achievements, and case studies.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.52),
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// ABOUT
// -----------------------------------------------------------------------------

class _AboutSection extends StatelessWidget {
  const _AboutSection();

  @override
  Widget build(BuildContext context) {
    return const _ContentSection(
      eyebrow: 'ABOUT',
      title: 'The person\nbehind the work.',
      child: _AboutContent(),
    );
  }
}

class _AboutContent extends StatelessWidget {
  const _AboutContent();

  @override
  Widget build(BuildContext context) {
    return Text(
      'This section will become the core personal narrative: '
      'who Abid is, what he believes, what he builds, and why the work matters.',
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.62),
        fontSize: 21,
        height: 1.7,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CONTACT
// -----------------------------------------------------------------------------

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return _ContentSection(
      eyebrow: 'CONTACT',
      title: 'Let’s talk.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For partnerships, projects, ideas, or simply a conversation.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 18,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              _ContactButton(
                icon: Icons.email_outlined,
                label: 'Email',
                onTap: () {
                  trackEvent(
                    'contact_click',
                    parameter1Name: 'contact_method',
                    parameter1Value: 'email',
                  );
                },
              ),
              _ContactButton(
                icon: Icons.phone_outlined,
                label: 'Phone',
                onTap: () {
                  trackEvent(
                    'phone_click',
                    parameter1Name: 'contact_method',
                    parameter1Value: 'phone',
                  );
                },
              ),
              _ContactButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'WhatsApp',
                onTap: () {
                  trackEvent(
                    'whatsapp_click',
                    parameter1Name: 'contact_method',
                    parameter1Value: 'whatsapp',
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 18,
        ),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.14),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SHARED SECTION
// -----------------------------------------------------------------------------

class _ContentSection extends StatelessWidget {
  final String eyebrow;
  final String title;
  final Widget child;

  const _ContentSection({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width > 1100 ? 100 : 28,
        vertical: 110,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: TextStyle(
                  fontSize: width > 700 ? 58 : 42,
                  height: 1.02,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
              const SizedBox(height: 54),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// FOOTER / MISC
// -----------------------------------------------------------------------------

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 28),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        side: BorderSide(
          color: Colors.white.withValues(alpha: 0.16),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 50),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1200,
          ),
          child: Row(
            children: [
              Text(
                'ABID NASIM',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '© ${DateTime.now().year}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.32),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// BROWSER URL PLACEHOLDER
// -----------------------------------------------------------------------------
//
// We deliberately don't use dart:html here.
// The three regional cards can be converted to normal browser links once
// the visual framework is approved.
//
// For the first clean compilation pass, this method is intentionally empty.
// -----------------------------------------------------------------------------

void _openUrl(String url) {
  // TODO: Connect browser navigation after the clean foundation compiles.
  //
  // The URLs are:
  // https://nasim.pk
  // https://nasim.us
  // https://nasim.ae
}
