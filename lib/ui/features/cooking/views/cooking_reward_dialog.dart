import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/pouch_badge.dart';
import '../../../../data/models/recipe_model.dart';

class CookingRewardDialog extends StatefulWidget {
  final RecipeModel recipe;

  const CookingRewardDialog({super.key, required this.recipe});

  @override
  State<CookingRewardDialog> createState() => _CookingRewardDialogState();
}

class _CookingRewardDialogState extends State<CookingRewardDialog> {
  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                color: AppColors.primary,
                child: const Icon(Icons.emoji_events, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 16),

              Text(
                'RECIPE MASTERED!',
                style: AppTypography.displayXl.copyWith(fontSize: 22, color: AppColors.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                recipe.title,
                style: AppTypography.headlineSm.copyWith(
                  color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              PouchBadge(
                pouchNumber: recipe.masalaPouchNumber,
                pouchName: recipe.pouchName,
                isLarge: true,
              ),
              const SizedBox(height: 16),

              Text(
                'You unlocked +50 Kitchen XP and completed 1 meal toward your Weekly Cooking Challenge!',
                style: AppTypography.bodyMd.copyWith(
                  color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              BrutalistButton(
                text: 'Return to Dashboard',
                isFullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop(); // dismiss dialog
                  Navigator.of(context).pop(); // exit cooking protocol
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
