import 'package:flutter/material.dart';
import '../styles/app_text_styles.dart';
import '../../utils/responsive_layout.dart';

class SectionTitle extends StatelessWidget {
  final String firstPart;
  final String coloredPart;
  final bool isCentered;

  const SectionTitle({
    super.key,
    required this.firstPart,
    required this.coloredPart,
    this.isCentered = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isMobile = context.isMobile;

    return Row(
      mainAxisAlignment: isCentered ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Text(
          firstPart,
          style: AppTextStyles.sectionHeader(
            color: theme.colorScheme.onSurface,
            isMobile: isMobile,
          ),
        ),
        Text(
          coloredPart,
          style: AppTextStyles.sectionHeader(
            color: primaryColor,
            isMobile: isMobile,
          ),
        ),
      ],
    );
  }
}
