import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/hover_container.dart';
import '../../../../core/widgets/section_title.dart';
import '../pages/project_details_page.dart';

class ProjectsSection extends StatelessWidget {
  final List<ProjectItem> projects;

  const ProjectsSection({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;
    final isTablet = context.isTablet;

    int crossAxisCount = 3;
    if (isMobile) {
      crossAxisCount = 1;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSizes.paddingL : AppSizes.paddingXXL,
        vertical: isMobile ? AppSizes.sectionSpacingMobile : AppSizes.sectionSpacingDesktop,
      ),
      child: Column(
        children: [
          const SectionTitle(
            firstPart: AppStrings.projectsHeaderMain,
            coloredPart: AppStrings.projectsHeaderSub,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.projectsSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.outfit(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 48),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: projects.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isMobile ? 1.1 : 1.0,
            ),
            itemBuilder: (context, index) {
              final project = projects[index];
              return _ProjectCard(project: project);
            },
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectItem project;

  const _ProjectCard({required this.project});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Could not launch $url: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return HoverContainer(
      hoverOffset: const Offset(0, AppSizes.hoverShiftDistance),
      glowRadius: 15,
      glowColor: primaryColor.withOpacity(0.3),
      borderRadius: BorderRadius.circular(AppSizes.radiusL),
      builder: (context, isHovered, child) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProjectDetailsPage(project: project),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(AppSizes.radiusL),
              border: Border.all(
                color: isHovered ? primaryColor : theme.dividerColor.withOpacity(0.15),
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          _getProjectIcon(project.name),
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        project.name,
                        style: AppTextStyles.cardTitle(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        project.subtitle,
                        style: AppTextStyles.tag(
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        project.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.cardBody(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: project.techStack.take(4).map((tech) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(AppSizes.radiusS),
                            ),
                            child: Text(
                              tech,
                              style: AppTextStyles.tag(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Slide-up Hover Overlay
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: 0,
                  right: 0,
                  bottom: isHovered ? 0 : -context.height,
                  top: isHovered ? 0 : context.height,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.95),
                          Colors.blue.withOpacity(0.95),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          project.name,
                          style: AppTextStyles.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: project.bulletPoints.map((point) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4.0, right: 6.0),
                                        child: Icon(Icons.check_circle, size: 12, color: Colors.black),
                                      ),
                                      Expanded(
                                        child: Text(
                                          point,
                                          style: AppTextStyles.outfit(
                                            fontSize: 13,
                                            color: Colors.black87,
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (project.githubLink != null)
                              _OverlayIconButton(
                                icon: FontAwesomeIcons.github,
                                tooltip: "View Source Code",
                                  onPressed: () => _launchUrl(project.githubLink!),
                              ),
                            if (project.githubLink != null && project.liveLink != null)
                              const SizedBox(width: 20),
                            if (project.liveLink != null)
                              _OverlayIconButton(
                                icon: FontAwesomeIcons.arrowUpRightFromSquare,
                                tooltip: "View Project",
                                onPressed: () => _launchUrl(project.liveLink!),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  IconData _getProjectIcon(String projectName) {
    final name = projectName.toLowerCase();
    if (name.contains("sala") || name.contains("ecommerce") || name.contains("market")) {
      return Icons.shopping_bag_outlined;
    } else if (name.contains("handly")) {
      return Icons.handyman_outlined;
    } else if (name.contains("hungry") || name.contains("food")) {
      return Icons.restaurant_menu;
    } else if (name.contains("chatbot") || name.contains("medical") || name.contains("health")) {
      return Icons.chat_bubble_outline_rounded;
    }
    return Icons.code_rounded;
  }
}

class _OverlayIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _OverlayIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  State<_OverlayIconButton> createState() => _OverlayIconButtonState();
}

class _OverlayIconButtonState extends State<_OverlayIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isHovered ? Colors.black : Colors.black12,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Icon(
              widget.icon,
              color: _isHovered ? Colors.cyanAccent : Colors.black,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
