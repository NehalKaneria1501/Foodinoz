import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Experimental Brutalist Card
/// Sharp 0-radius borders with high-contrast outlines and optional offset accent border.
class BrutalistCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const BrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<BrutalistCard> createState() => _BrutalistCardState();
}

class _BrutalistCardState extends State<BrutalistCard> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = widget.backgroundColor ?? (isDark ? AppColors.surfaceContainer : Colors.white);
    final effectiveBorder = widget.borderColor ?? (isDark ? AppColors.gridLine : AppColors.lightBorder);
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    Widget card = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: radius,
        border: Border.all(
          color: effectiveBorder,
          width: widget.borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0E8A4B08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: radius,
          border: Border.all(
            color: effectiveBorder,
            width: widget.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0E8A4B08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            splashColor: AppColors.primaryContainer.withValues(alpha: 0.15),
            highlightColor: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: radius,
            child: Padding(
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      );
    }

    return card;
  }
}

