import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/social_icon.dart';
import '../../../../data/portfolio_data.dart';
import '../../../../utils/responsive_layout.dart';

class HeroSection extends StatefulWidget {
  final PersonalInfo personalInfo;

  const HeroSection({super.key, required this.personalInfo});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
    final isMobile = context.isMobile;
    final primaryColor = theme.colorScheme.primary;

    Widget buildTextContent() {
      return Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.heroGreeting,
            style: AppTextStyles.outfit(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            widget.personalInfo.name,
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
            style: AppTextStyles.heroName(
              color: theme.colorScheme.onSurface,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Text(
                AppStrings.heroTitleAnd,
                style: AppTextStyles.outfit(
                  fontSize: isMobile ? 20 : 28,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(
                height: isMobile ? 30 : 40,
                child: AnimatedTextKit(
                  repeatForever: true,
                  animatedTexts: widget.personalInfo.titles.map((title) {
                    return TypewriterAnimatedText(
                      title,
                      cursor: '|',
                      textStyle: AppTextStyles.outfit(
                        fontSize: isMobile ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      speed: const Duration(milliseconds: 100),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: 550,
            child: Text(
              widget.personalInfo.aboutMe,
              textAlign: isMobile ? TextAlign.center : TextAlign.justify,
              style: AppTextStyles.body(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              if (widget.personalInfo.linkedin.isNotEmpty)
                SocialIcon(
                  icon: FontAwesomeIcons.linkedinIn,
                  onPressed: () => _launchUrl(widget.personalInfo.linkedin),
                ),
              if (widget.personalInfo.linkedin.isNotEmpty)
                const SizedBox(width: 16),
              if (widget.personalInfo.github.isNotEmpty)
                SocialIcon(
                  icon: FontAwesomeIcons.github,
                  onPressed: () => _launchUrl(widget.personalInfo.github),
                ),
              if (widget.personalInfo.github.isNotEmpty && widget.personalInfo.email.isNotEmpty)
                const SizedBox(width: 16),
              if (widget.personalInfo.email.isNotEmpty)
                SocialIcon(
                  icon: Icons.email,
                  onPressed: () => _launchUrl("mailto:${widget.personalInfo.email}"),
                ),
            ],
          ),
          const SizedBox(height: 32),

          if (widget.personalInfo.cvUrl.isNotEmpty)
            CustomButton(
              text: AppStrings.downloadCV,
              isFilled: true,
              onPressed: () => _launchUrl(widget.personalInfo.cvUrl),
            ),
        ],
      );
    }

    Widget buildAvatar() {
      final size = isMobile ? context.width * 0.65 : 360.0;
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.4),
                  blurRadius: 15.0 + _pulseAnimation.value,
                  spreadRadius: 2.0 + _pulseAnimation.value / 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size),
              child: widget.personalInfo.imageUrl.startsWith("http")
                  ? Image.network(
                      widget.personalInfo.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.cardColor,
                        child: Icon(Icons.person, size: size * 0.5, color: primaryColor),
                      ),
                    )
                  : Image.asset(
                      widget.personalInfo.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.cardColor,
                        child: Icon(Icons.person, size: size * 0.5, color: primaryColor),
                      ),
                    ),
            ),
          );
        },
      );
    }

    return Container(
      constraints: BoxConstraints(
        minHeight: context.height - AppSizes.navBarHeight,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? AppSizes.paddingL : AppSizes.paddingXXL,
        vertical: isMobile ? AppSizes.paddingXL : AppSizes.paddingXXL,
      ),
      child: Center(
        child: ResponsiveLayout(
          mobile: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildAvatar(),
              const SizedBox(height: 40),
              buildTextContent(),
            ],
          ),
          desktop: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 3, child: buildTextContent()),
              const SizedBox(width: 40),
              Expanded(flex: 2, child: Center(child: buildAvatar())),
            ],
          ),
        ),
      ),
    );
  }
}
