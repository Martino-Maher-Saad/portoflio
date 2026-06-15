import 'package:flutter/material.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/hover_container.dart';
import '../../../../core/widgets/section_title.dart';

class SkillsSection extends StatelessWidget {
  final List<SkillCategory> skills;

  const SkillsSection({super.key, required this.skills});

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
            firstPart: AppStrings.skillsHeaderMain,
            coloredPart: AppStrings.skillsHeaderSub,
          ),
          const SizedBox(height: 12),
          Text(
            AppStrings.skillsSubtitle,
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
            itemCount: skills.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: isMobile ? 1.8 : 1.5,
            ),
            itemBuilder: (context, index) {
              final category = skills[index];
              return _SkillCard(category: category);
            },
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final SkillCategory category;

  const _SkillCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return HoverContainer(
      hoverOffset: const Offset(0, AppSizes.hoverShiftDistance),
      glowRadius: 15,
      glowColor: primaryColor.withOpacity(0.35),
      borderRadius: BorderRadius.circular(AppSizes.radiusM),
      builder: (context, isHovered, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
            border: Border.all(
              color: isHovered ? primaryColor : theme.dividerColor.withOpacity(0.15),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category.name),
                color: primaryColor,
                size: 44,
              ),
              const SizedBox(height: 16),
              
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    category.skills.join(', '),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.cardBody(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ).copyWith(height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains("mobile")) {
      return Icons.phone_android;
    } else if (name.contains("state")) {
      return Icons.layers;
    } else if (name.contains("architecture")) {
      return Icons.account_tree_outlined;
    } else if (name.contains("backend")) {
      return Icons.dns_outlined;
    } else if (name.contains("language")) {
      return Icons.translate;
    } else if (name.contains("tools")) {
      return Icons.construction_outlined;
    } else if (name.contains("ai")) {
      return Icons.psychology;
    }
    return Icons.code;
  }
}
