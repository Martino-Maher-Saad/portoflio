import 'package:flutter/material.dart';
import '../../data/portfolio_data.dart';
import '../../utils/responsive_layout.dart';
import '../constants/app_sizes.dart';
import '../constants/app_strings.dart';
import '../styles/app_text_styles.dart';

class NavBar extends StatelessWidget implements PreferredSizeWidget {
  final List<GlobalKey> sectionKeys;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final int activeIndex;
  final Function(int) onIndexChanged;

  const NavBar({
    super.key,
    required this.sectionKeys,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.activeIndex,
    required this.onIndexChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.navBarHeight);

  void _scrollToSection(int index) {
    onIndexChanged(index);
    final key = sectionKeys[index];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    return Container(
      height: AppSizes.navBarHeight,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.9),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingL, vertical: AppSizes.paddingXS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => _scrollToSection(0),
              child: Text(
                PortfolioData.personalInfo.logoText,
                style: AppTextStyles.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          
          // Navigation Items (Desktop only)
          if (!isMobile)
            Row(
              children: List.generate(
                6, // 6 sections
                (index) => _NavBarItem(
                  title: _getSectionTitle(index),
                  isActive: activeIndex == index,
                  onTap: () => _scrollToSection(index),
                ),
              ),
            ),

          // Theme Toggle and Mobile Drawer Button
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: onThemeToggle,
                tooltip: 'Toggle Theme',
              ),
              if (isMobile) ...[
                const SizedBox(width: AppSizes.paddingXS),
                IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getSectionTitle(int index) {
    switch (index) {
      case 0:
        return AppStrings.navHome;
      case 1:
        return AppStrings.navAbout;
      case 2:
        return AppStrings.navSkills;
      case 3:
        return AppStrings.navExperience;
      case 4:
        return AppStrings.navProjects;
      case 5:
        return AppStrings.navContact;
      default:
        return '';
    }
  }
}

class _NavBarItem extends StatefulWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final defaultColor = theme.colorScheme.onSurface.withOpacity(0.7);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: AppSizes.paddingXS),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.outfit(
                  color: (widget.isActive || _isHovered) ? primaryColor : defaultColor,
                  fontSize: 16,
                  fontWeight: (widget.isActive || _isHovered) ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(widget.title),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 2,
                width: widget.isActive ? 24 : (_isHovered ? 12 : 0),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PortfolioDrawer extends StatelessWidget {
  final List<GlobalKey> sectionKeys;
  final int activeIndex;
  final Function(int) onIndexChanged;

  const PortfolioDrawer({
    super.key,
    required this.sectionKeys,
    required this.activeIndex,
    required this.onIndexChanged,
  });

  void _scrollToSection(BuildContext context, int index) {
    onIndexChanged(index);
    Navigator.of(context).pop(); // Close drawer
    final key = sectionKeys[index];
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Text(
                PortfolioData.personalInfo.logoText,
                style: AppTextStyles.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM),
                children: List.generate(
                  6,
                  (index) => ListTile(
                    leading: Icon(
                      _getSectionIcon(index),
                      color: activeIndex == index ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    title: Text(
                      _getSectionTitle(index),
                      style: AppTextStyles.outfit(
                        fontSize: 18,
                        fontWeight: activeIndex == index ? FontWeight.bold : FontWeight.normal,
                        color: activeIndex == index ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: activeIndex == index,
                    onTap: () => _scrollToSection(context, index),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Text(
                "© 2026 ${PortfolioData.personalInfo.shortName}",
                style: AppTextStyles.outfit(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSectionIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.person;
      case 2:
        return Icons.code;
      case 3:
        return Icons.history;
      case 4:
        return Icons.work;
      case 5:
        return Icons.email;
      default:
        return Icons.help;
    }
  }

  String _getSectionTitle(int index) {
    switch (index) {
      case 0:
        return AppStrings.navHome;
      case 1:
        return AppStrings.navAbout;
      case 2:
        return AppStrings.navSkills;
      case 3:
        return AppStrings.navExperience;
      case 4:
        return AppStrings.navProjects;
      case 5:
        return AppStrings.navContact;
      default:
        return '';
    }
  }
}
