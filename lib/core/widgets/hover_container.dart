import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class HoverContainer extends StatefulWidget {
  final Widget child;
  final Offset hoverOffset;
  final double hoverScale;
  final Color? glowColor;
  final double glowRadius;
  final BorderRadius borderRadius;
  final Duration duration;
  final Widget Function(BuildContext context, bool isHovered, Widget child)? builder;

  const HoverContainer({
    super.key,
    required this.child,
    this.hoverOffset = const Offset(0, AppSizes.hoverShiftDistance),
    this.hoverScale = AppSizes.hoverScaleFactor,
    this.glowColor,
    this.glowRadius = 15.0,
    this.borderRadius = BorderRadius.zero,
    this.duration = const Duration(milliseconds: 200),
    this.builder,
  });

  @override
  State<HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<HoverContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glow = widget.glowColor ?? theme.colorScheme.primary.withOpacity(0.3);

    Widget currentChild = widget.builder != null
        ? widget.builder!(context, _isHovered, widget.child)
        : widget.child;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: widget.duration,
        transform: Matrix4.identity()
          ..translate(_isHovered ? widget.hoverOffset.dx : 0.0, _isHovered ? widget.hoverOffset.dy : 0.0)
          ..scale(_isHovered ? widget.hoverScale : 1.0),
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: _isHovered && widget.glowRadius > 0
              ? [
                  BoxShadow(
                    color: glow,
                    blurRadius: widget.glowRadius,
                    spreadRadius: 1.0,
                  )
                ]
              : [],
        ),
        child: currentChild,
      ),
    );
  }
}
