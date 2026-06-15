import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../styles/app_text_styles.dart';
import 'hover_container.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFilled;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFilled = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return HoverContainer(
      hoverOffset: const Offset(0, -4),
      hoverScale: 1.02,
      glowRadius: 12,
      glowColor: primaryColor.withOpacity(0.5),
      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      builder: (context, isHovered, child) {
        // According to 1.PNG, filled buttons have solid primary color (cyan) and black text
        // Let's implement the solid glowing hover design.
        final Color buttonBg = isFilled 
            ? primaryColor 
            : (isHovered ? primaryColor : Colors.transparent);
        final Color textColor = isFilled 
            ? (isHovered ? Colors.white : Colors.black) 
            : (isHovered ? Colors.black : primaryColor);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: buttonBg,
            border: Border.all(color: primaryColor, width: 2),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            boxShadow: isFilled
                ? [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.4),
                      blurRadius: isHovered ? 12.0 : 6.0,
                      spreadRadius: 1.0,
                    )
                  ]
                : [],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon!,
                      color: textColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTextStyles.outfit(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
