import 'package:flutter/material.dart';

import '../widgets/about_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/expertise_section.dart';
import '../widgets/footer.dart';
import '../widgets/hero_section.dart';
import '../widgets/nav_bar.dart';
import '../widgets/presence_section.dart';
import '../widgets/shared/section_divider.dart';
import '../widgets/work_section.dart';

/// The single-page scrolling layout: nav bar plus one section per anchor.
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

    Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 650), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: NavBar(
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
                child: HeroSection(
                  onExplore: () => _scrollTo(_presenceKey),
                  onContact: () => _scrollTo(_contactKey),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(key: _presenceKey, child: const SectionDivider()),
            ),
            const SliverToBoxAdapter(child: PresenceSection()),
            SliverToBoxAdapter(
              child: Container(key: _expertiseKey, child: const ExpertiseSection()),
            ),
            SliverToBoxAdapter(
              child: Container(key: _workKey, child: const WorkSection()),
            ),
            SliverToBoxAdapter(
              child: Container(key: _aboutKey, child: const AboutSection()),
            ),
            SliverToBoxAdapter(
              child: Container(key: _contactKey, child: const ContactSection()),
            ),
            const SliverToBoxAdapter(child: Footer()),
          ],
        ),
      ),
    );
  }
}
