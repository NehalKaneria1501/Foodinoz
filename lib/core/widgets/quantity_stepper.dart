import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Brutalist Quantity Stepper: [-] [Qty] [+]
/// Features 1px internal dividers and monospaced number styling.
class QuantityStepper extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final String? suffix;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.minValue = 1,
    this.maxValue = 99,
    this.suffix,
  });

  @override
  State<QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  @override
  Widget build(BuildContext context) {
    final value = widget.value;
    final minValue = widget.minValue;
    final maxValue = widget.maxValue;
    final onChanged = widget.onChanged;
    final suffix = widget.suffix;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
        border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement button
          InkWell(
            onTap: value > minValue ? () => onChanged(value - 1) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: value > minValue
                  ? Colors.transparent
                  : (isDark ? AppColors.surfaceContainerHigh.withValues(alpha: 0.3) : AppColors.lightBorder.withValues(alpha: 0.3)),
              child: Icon(
                Icons.remove,
                size: 16,
                color: value > minValue
                    ? (isDark ? AppColors.onSurface : AppColors.lightTextPrimary)
                    : (isDark ? AppColors.outlineVariant : AppColors.lightBorder),
              ),
            ),
          ),
          // Divider
          Container(width: 1, height: 28, color: isDark ? AppColors.gridLine : AppColors.lightBorder),
          // Value
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Text(
              suffix != null ? '$value $suffix' : '$value',
              style: AppTypography.numericData.copyWith(
                fontSize: 14,
                color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
              ),
            ),
          ),
          // Divider
          Container(width: 1, height: 28, color: isDark ? AppColors.gridLine : AppColors.lightBorder),
          // Increment button
          InkWell(
            onTap: value < maxValue ? () => onChanged(value + 1) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
