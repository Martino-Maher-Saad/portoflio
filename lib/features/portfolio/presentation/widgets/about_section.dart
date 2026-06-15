import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/hover_container.dart';
import '../../../../core/widgets/section_title.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';

class AboutSection extends StatelessWidget {
  final PersonalInfo personalInfo;
  final VoidCallback onHireMePressed;

  const AboutSection({
    super.key,
    required this.personalInfo,
    required this.onHireMePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;
    final primaryColor = theme.colorScheme.primary;

    Widget buildGraphic() {
      final size = isMobile ? context.width * 0.65 : 320.0;
      return HoverContainer(
        hoverOffset: const Offset(0, -10),
        hoverScale: 1.03,
        glowColor: primaryColor.withOpacity(0.3),
        glowRadius: 20,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
            border: Border.all(color: primaryColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusL - 2),
            child: Image.network(
              personalInfo.imageUrl,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (context, error, stackTrace) => Container(
                color: theme.cardColor,
                child: Icon(
                  Icons.person,
                  size: size * 0.5,
                  color: primaryColor,
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget buildTextContent() {
      final String subtitle = personalInfo.titles.isNotEmpty
          ? personalInfo.titles.first
          : "Software Engineer";
      return Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SectionTitle(
            firstPart: AppStrings.aboutHeaderMain,
            coloredPart: AppStrings.aboutHeaderSub,
            isCentered: isMobile,
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: AppTextStyles.outfit(
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "I am a passionate Software Engineer and Flutter Developer with a strong foundation in building high-performance cross-platform applications. I specialize in designing structured, maintainable, and clean codebases (Clean Architecture & Feature-First) and integrating modern serverless backends like Supabase and Firebase. "
            "\n\nIn addition to mobile development, I engineer agentic AI workflows and automate business ecosystems. I love tackling complex logical puzzles and building scalable software that offers highly optimized user experiences.",
            textAlign: isMobile ? TextAlign.center : TextAlign.justify,
            style: AppTextStyles.body(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: AppStrings.hireMe,
            isFilled: true,
            onPressed: onHireMePressed,
          ),
        ],
      );
    }

    return Container(
      constraints: BoxConstraints(minHeight: context.height * 0.8),
      color: theme.cardColor.withOpacity(0.15),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSizes.paddingL : AppSizes.paddingXXL,
        vertical: isMobile
            ? AppSizes.sectionSpacingMobile
            : AppSizes.sectionSpacingDesktop,
      ),
      child: Center(
        child: ResponsiveLayout(
          mobile: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildGraphic(),
              const SizedBox(height: 48),
              buildTextContent(),
            ],
          ),
          desktop: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 2, child: Center(child: buildGraphic())),
              const SizedBox(width: 60),
              Expanded(flex: 3, child: buildTextContent()),
            ],
          ),
        ),
      ),
    );
  }
}
