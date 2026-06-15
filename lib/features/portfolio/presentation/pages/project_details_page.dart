import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/hover_container.dart';
import '../../../../core/services/supabase_helper.dart';

class ProjectDetailsPage extends StatefulWidget {
  final ProjectItem project;

  const ProjectDetailsPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  List<Map<String, dynamic>> _projectLinks = [];
  bool _isLoadingLinks = true;

  @override
  void initState() {
    super.initState();
    _fetchProjectLinks();
  }

  Future<void> _fetchProjectLinks() async {
    if (!SupabaseHelper.instance.isSupabaseAvailable) {
      setState(() {
        _projectLinks = [
          if (widget.project.githubLink != null)
            {'label': 'GitHub', 'url': widget.project.githubLink!, 'type': 'github'},
          if (widget.project.liveLink != null)
            {'label': 'Live Demo', 'url': widget.project.liveLink!, 'type': 'live'},
        ];
        _isLoadingLinks = false;
      });
      return;
    }

    try {
      final data = await Supabase.instance.client
          .from('projects')
          .select('links')
          .eq('name', widget.project.name)
          .maybeSingle();
          
      if (data != null && data['links'] != null) {
        final List<dynamic> list = data['links'];
        setState(() {
          _projectLinks = list.map((l) => Map<String, dynamic>.from(l)).toList();
          _isLoadingLinks = false;
        });
      } else {
        throw 'Project links not found in DB';
      }
    } catch (e) {
      debugPrint("Error loading project links: $e");
      setState(() {
        _projectLinks = [
          if (widget.project.githubLink != null)
            {'label': 'GitHub', 'url': widget.project.githubLink!, 'type': 'github'},
          if (widget.project.liveLink != null)
            {'label': 'Live Demo', 'url': widget.project.liveLink!, 'type': 'live'},
        ];
        _isLoadingLinks = false;
      });
    }
  }

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
    final isMobile = context.isMobile;

    final screenshots = widget.project.screenshots.isNotEmpty
        ? widget.project.screenshots
        : List.generate(3, (i) => "https://picsum.photos/seed/${widget.project.name}_${i + 1}/600/400");

    Widget buildScreenshot(String url, int index) {
      return HoverContainer(
        hoverScale: 1.03,
        hoverOffset: const Offset(0, -5),
        glowRadius: 10,
        glowColor: primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusM - 1),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.cardColor,
                    child: Icon(Icons.broken_image, color: primaryColor, size: 48),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black87, Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Screenshot #${index + 1}",
                      style: AppTextStyles.tag(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Project Detail",
          style: AppTextStyles.outfit(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AppSizes.paddingL : AppSizes.paddingXXL,
          vertical: AppSizes.paddingXL,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.name,
                  style: AppTextStyles.heroName(
                    color: theme.colorScheme.onSurface,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.project.subtitle,
                  style: AppTextStyles.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.project.techStack.map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        tech,
                        style: AppTextStyles.tag(color: theme.colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                
                Text(
                  "Project Description",
                  style: AppTextStyles.cardTitle(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 12),
                Text(
                  "${widget.project.description}\n\nThis system was engineered to deliver pixel-perfect responsiveness, high efficiency, and maximum security. Following professional patterns and clean architecture standards, the codebase maintains robust state separation and provides modular wrappers for future feature scaling.",
                  style: AppTextStyles.body(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 40),
                
                if (widget.project.bulletPoints.isNotEmpty) ...[
                  Text(
                    "Key Features",
                    style: AppTextStyles.cardTitle(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.project.bulletPoints.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: isMobile ? 3.5 : 4.0,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          border: Border.all(color: theme.dividerColor.withOpacity(0.15)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: primaryColor, size: 24),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                widget.project.bulletPoints[index],
                                style: AppTextStyles.cardBody(
                                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                ],

                Text(
                  "Screenshots & Demos",
                  style: AppTextStyles.cardTitle(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: screenshots.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isMobile ? 1 : (screenshots.length > 3 ? 3 : screenshots.length),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.5,
                  ),
                  itemBuilder: (context, index) {
                    return buildScreenshot(screenshots[index], index);
                  },
                ),
                const SizedBox(height: 50),
                
                Text(
                  "Project Links & Resources",
                  style: AppTextStyles.cardTitle(color: theme.colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                _isLoadingLinks
                    ? const Center(child: CircularProgressIndicator())
                    : Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          ..._projectLinks.map((link) {
                            final label = link['label'] as String? ?? 'Link';
                            final url = link['url'] as String? ?? '';
                            final type = link['type'] as String? ?? 'link';
                            return CustomButton(
                              text: label,
                              isFilled: type == 'live',
                              icon: _getLinkIcon(type),
                              onPressed: () => _launchUrl(url),
                            );
                          }),
                          
                          CustomButton(
                            text: "Download README.md",
                            icon: Icons.description_outlined,
                            onPressed: () => _launchUrl(
                              widget.project.githubLink ?? "https://github.com/Martino-Maher-Saad",
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getLinkIcon(String type) {
    switch (type.toLowerCase()) {
      case 'github':
        return FontAwesomeIcons.github;
      case 'live':
        return FontAwesomeIcons.arrowUpRightFromSquare;
      case 'figma':
        return FontAwesomeIcons.figma;
      case 'play_store':
      case 'store':
        return Icons.play_arrow;
      case 'video':
        return Icons.play_circle_outline;
      default:
        return Icons.link;
    }
  }
}
