import 'package:flutter/material.dart';
import 'hover_container.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const SocialIcon({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return HoverContainer(
      hoverOffset: const Offset(0, -4),
      glowRadius: 8,
      glowColor: primaryColor.withOpacity(0.4),
      borderRadius: BorderRadius.circular(30),
      builder: (context, isHovered, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHovered ? primaryColor : Colors.transparent,
            border: Border.all(color: primaryColor, width: 2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  icon,
                  color: isHovered ? Colors.black : primaryColor,
                  size: 18,
                ),
              ),
            ),
          ),
        );
      },
      child: const SizedBox.shrink(),
    );
  }
}
