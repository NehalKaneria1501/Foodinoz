import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../data/models/gamification_model.dart';
import '../../../../data/repositories/cooking_repository.dart';

class BadgeDetailDialog extends StatelessWidget {
  final BadgeModel badge;
  final CookingRepository cookingRepository;

  const BadgeDetailDialog({
    super.key,
    required this.badge,
    required this.cookingRepository,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (badge.iconCode) {
      case 'emoji_events':
        icon = Icons.emoji_events;
        break;
      case 'auto_awesome':
        icon = Icons.auto_awesome;
        break;
      case 'local_fire_department':
        icon = Icons.local_fire_department;
        break;
      case 'eco':
        icon = Icons.eco;
        break;
      default:
        icon = Icons.military_tech;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          border: Border.all(
            color: badge.isUnlocked ? AppColors.primary : (isDark ? AppColors.gridLine : AppColors.lightBorder),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Category Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                color: badge.isUnlocked 
                    ? AppColors.sproutGreen.withValues(alpha: 0.2) 
                    : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                child: Text(
                  '${badge.category} BADGE',
                  style: AppTypography.metadata.copyWith(
                    color: badge.isUnlocked ? AppColors.sproutGreen : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Badge Big Icon
              Container(
                width: 72,
                height: 72,
                color: badge.isUnlocked ? AppColors.primary : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                child: Icon(
                  badge.isUnlocked ? icon : Icons.lock_outline,
                  size: 40,
                  color: badge.isUnlocked 
                      ? (isDark ? AppColors.surfaceBlack : Colors.white) 
                      : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                badge.title.toUpperCase(),
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 18,
                  letterSpacing: 1.2,
                  color: badge.isUnlocked ? (isDark ? AppColors.onSurface : AppColors.lightTextPrimary) : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                badge.description,
                style: AppTypography.bodyMd.copyWith(
                  color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Divider(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
              const SizedBox(height: 12),

              // XP and Status Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('REWARD VALUE', style: AppTypography.metadata.copyWith(color: isDark ? AppColors.outline : AppColors.lightTextTertiary)),
                      const SizedBox(height: 4),
                      Text(
                        '+${badge.rewardXp} XP',
                        style: AppTypography.numericData.copyWith(color: AppColors.sproutGreen, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text('STATUS', style: AppTypography.metadata.copyWith(color: isDark ? AppColors.outline : AppColors.lightTextTertiary)),
                      const SizedBox(height: 4),
                      Text(
                        badge.isUnlocked ? 'UNLOCKED' : 'LOCKED',
                        style: AppTypography.metadata.copyWith(
                          color: badge.isUnlocked ? AppColors.primary : AppColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Action Buttons
              if (!badge.isUnlocked) ...[
                BrutalistButton(
                  text: 'Simulate Unlock Badge',
                  isFullWidth: true,
                  variant: BrutalistButtonVariant.secondary,
                  icon: Icon(Icons.key, size: 16, color: isDark ? AppColors.surfaceBlack : Colors.white),
                  onPressed: () {
                    cookingRepository.unlockBadge(badge.id);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🎉 Unlocked badge: ${badge.title}!')),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],

              BrutalistButton(
                text: 'Close',
                isFullWidth: true,
                variant: BrutalistButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
