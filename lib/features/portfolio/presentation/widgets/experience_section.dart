import 'package:flutter/material.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/hover_container.dart';
import '../../../../core/widgets/section_title.dart';

class ExperienceSection extends StatelessWidget {
  final List<ExperienceItem> experiences;

  const ExperienceSection({super.key, required this.experiences});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;

    final workList = experiences.where((e) => !e.isEducation).toList();
    final eduList = experiences.where((e) => e.isEducation).toList();

    Widget buildTimelineSection({
      required String title,
      required List<ExperienceItem> items,
    }) {
      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionSubHeader(
              color: theme.colorScheme.onSurface,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(height: 32),
          
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _TimelineItem(
                item: item,
                isLast: index == items.length - 1,
              );
            },
          ),
        ],
      );
    }

    return Container(
      color: theme.cardColor.withOpacity(0.15),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSizes.paddingL : AppSizes.paddingXXL,
        vertical: isMobile ? AppSizes.sectionSpacingMobile : AppSizes.sectionSpacingDesktop,
      ),
      child: Column(
        children: [
          const SectionTitle(
            firstPart: AppStrings.professionalExperience,
            coloredPart: AppStrings.experienceColumn,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.experienceSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.outfit(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 60),
          
          ResponsiveLayout(
            mobile: Column(
              children: [
                buildTimelineSection(
                  title: AppStrings.experienceColumn,
                  items: workList,
                ),
                if (workList.isNotEmpty && eduList.isNotEmpty) const SizedBox(height: 48),
                buildTimelineSection(
                  title: AppStrings.educationColumn,
                  items: eduList,
                ),
              ],
            ),
            desktop: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: buildTimelineSection(
                    title: AppStrings.experienceColumn,
                    items: workList,
                  ),
                ),
                if (workList.isNotEmpty && eduList.isNotEmpty) const SizedBox(width: 60),
                Expanded(
                  child: buildTimelineSection(
                    title: AppStrings.educationColumn,
                    items: eduList,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final ExperienceItem item;
  final bool isLast;

  const _TimelineItem({
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: primaryColor,
                  ),
                )
              else
                const SizedBox(height: 16),
            ],
          ),
          const SizedBox(width: 24),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: HoverContainer(
                hoverOffset: const Offset(4, 0),
                glowRadius: 10,
                glowColor: primaryColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                builder: (context, isHovered, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: isHovered ? primaryColor : theme.dividerColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.duration,
                              style: AppTextStyles.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        Text(
                          item.role == "B.S.E. in Computers and Systems Engineering"
                              ? "Bachelor of Software Engineering"
                              : "${item.role} - ${item.company}",
                          style: AppTextStyles.cardTitle(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        Text(
                          _buildDescriptionText(),
                          style: AppTextStyles.cardBody(
                            color: theme.colorScheme.onSurface.withOpacity(0.85),
                          ).copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildDescriptionText() {
    final buffer = StringBuffer();
    if (item.location.isNotEmpty) {
      buffer.write("${item.location}. ");
    }
    buffer.write(item.bullets.map((b) {
      if (b.contains(':')) {
        final parts = b.split(':');
        if (parts.length > 1) return parts[1].trim();
      }
      return b.trim();
    }).join(' '));
    return buffer.toString();
  }
}
