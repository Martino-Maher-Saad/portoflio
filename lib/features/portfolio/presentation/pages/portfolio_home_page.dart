import 'package:flutter/material.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/nav_bar.dart';
import '../../../../core/services/supabase_helper.dart';

import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/skills_section.dart';
import '../widgets/experience_section.dart';
import '../widgets/projects_section.dart';
import '../widgets/contact_section.dart';

class PortfolioHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const PortfolioHomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<GlobalKey> _sectionKeys = List.generate(6, (index) => GlobalKey());
  
  int _activeIndex = 0;
  bool _showBackToTop = false;
  bool _isScrollingProgrammatically = false;

  // Real-time fetched data
  PersonalInfo _personalInfo = PortfolioData.personalInfo;
  List<SkillCategory> _skills = PortfolioData.skills;
  List<ExperienceItem> _experiencesList = [];
  List<ProjectItem> _projectsList = PortfolioData.projects;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fetchDbData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDbData() async {
    if (!SupabaseHelper.instance.isSupabaseAvailable) {
      final list = <ExperienceItem>[];
      list.addAll(PortfolioData.experiences);
      list.addAll(PortfolioData.education);
      setState(() {
        _experiencesList = list;
        _isLoading = false;
      });
      return;
    }

    try {
      final info = await SupabaseHelper.instance.getPersonalInfo();
      final sks = await SupabaseHelper.instance.getSkills();
      final exps = await SupabaseHelper.instance.getExperiences();
      final projs = await SupabaseHelper.instance.getProjects();

      setState(() {
        _personalInfo = info;
        _skills = sks;
        _experiencesList = exps;
        _projectsList = projs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading data from Supabase: $e");
      final list = <ExperienceItem>[];
      list.addAll(PortfolioData.experiences);
      list.addAll(PortfolioData.education);
      setState(() {
        _experiencesList = list;
        _isLoading = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.offset > 300) {
      if (!_showBackToTop) {
        setState(() => _showBackToTop = true);
      }
    } else {
      if (_showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    }

    if (_isScrollingProgrammatically) return;

    double screenHeight = MediaQuery.of(context).size.height;
    int newActiveIndex = 0;
    double minDiff = double.infinity;

    for (int i = 0; i < _sectionKeys.length; i++) {
      final key = _sectionKeys[i];
      if (key.currentContext != null) {
        final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
        final position = box.localToGlobal(Offset.zero);
        final double offset = position.dy;
        
        final diff = (offset - 80).abs();
        if (offset < screenHeight * 0.4 && offset > -box.size.height * 0.6) {
          if (diff < minDiff) {
            minDiff = diff;
            newActiveIndex = i;
          }
        }
      }
    }

    if (newActiveIndex != _activeIndex) {
      setState(() {
        _activeIndex = newActiveIndex;
      });
    }
  }

  void _scrollToSection(int index) {
    setState(() {
      _activeIndex = index;
      _isScrollingProgrammatically = true;
    });

    final key = _sectionKeys[index];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      ).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() => _isScrollingProgrammatically = false);
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: NavBar(
        sectionKeys: _sectionKeys,
        isDarkMode: widget.isDarkMode,
        onThemeToggle: widget.onThemeToggle,
        activeIndex: _activeIndex,
        onIndexChanged: (index) => setState(() => _activeIndex = index),
      ),
      endDrawer: context.isMobile
          ? PortfolioDrawer(
              sectionKeys: _sectionKeys,
              activeIndex: _activeIndex,
              onIndexChanged: (index) => setState(() => _activeIndex = index),
            )
          : null,
      body: Stack(
        children: [
          SelectionArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  HeroSection(key: _sectionKeys[0], personalInfo: _personalInfo),
                  AboutSection(
                    key: _sectionKeys[1],
                    personalInfo: _personalInfo,
                    onHireMePressed: () => _scrollToSection(5),
                  ),
                  SkillsSection(key: _sectionKeys[2], skills: _skills),
                  ExperienceSection(key: _sectionKeys[3], experiences: _experiencesList),
                  ProjectsSection(key: _sectionKeys[4], projects: _projectsList),
                  ContactSection(key: _sectionKeys[5], personalInfo: _personalInfo),
                  _Footer(onScrollToTop: () => _scrollToSection(0)),
                ],
              ),
            ),
          ),
          if (_showBackToTop)
            Positioned(
              right: 24,
              bottom: 24,
              child: FloatingActionButton(
                onPressed: () => _scrollToSection(0),
                backgroundColor: primaryColor,
                child: const Icon(Icons.arrow_upward, color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onScrollToTop;

  const _Footer({required this.onScrollToTop});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 20),
          Text(
            AppStrings.copyright,
            textAlign: TextAlign.center,
            style: AppTextStyles.outfit(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
