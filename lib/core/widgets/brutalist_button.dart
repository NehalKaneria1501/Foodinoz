import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BrutalistButtonVariant {
  primary,
  secondary,
  outline,
  danger,
}

class BrutalistButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final BrutalistButtonVariant variant;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  const BrutalistButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = BrutalistButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<BrutalistButton> createState() => _BrutalistButtonState();
}

class _BrutalistButtonState extends State<BrutalistButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeOnSurface = theme.colorScheme.onSurface;

    Color bg;
    Color fg;
    Color border;

    final isDark = theme.brightness == Brightness.dark;

    switch (widget.variant) {
      case BrutalistButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        border = AppColors.sproutGreen;
        break;
      case BrutalistButtonVariant.secondary:
        bg = AppColors.secondaryOrange;
        fg = AppColors.surfaceBlack;
        border = AppColors.secondary;
        break;
      case BrutalistButtonVariant.outline:
        bg = Colors.transparent;
        fg = themeOnSurface;
        border = theme.colorScheme.outline;
        break;
      case BrutalistButtonVariant.danger:
        bg = isDark ? AppColors.errorContainer : const Color(0xFFFFEBEE);
        fg = AppColors.error;
        border = AppColors.error;
        break;
    }

    final content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          widget.icon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text.toUpperCase(),
            style: AppTypography.labelButton.copyWith(color: fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    final disabledBg = isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceSubtle;
    final disabledBorder = isDark ? AppColors.outlineVariant : AppColors.lightBorder;

    return InkWell(
      onTap: widget.isLoading ? null : widget.onPressed,
      borderRadius: BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.onPressed == null ? disabledBg : bg,
          borderRadius: BorderRadius.zero,
          border: Border.all(
            color: widget.onPressed == null ? disabledBorder : border,
            width: 1.5,
          ),
        ),
        child: content,
      ),
    );
  }
}
