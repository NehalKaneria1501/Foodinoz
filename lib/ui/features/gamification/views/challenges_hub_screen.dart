import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../data/models/gamification_model.dart';
import '../../../../data/repositories/cooking_repository.dart';
import 'badge_detail_dialog.dart';

class ChallengesHubScreen extends StatefulWidget {
  final CookingRepository cookingRepository;

  const ChallengesHubScreen({
    super.key,
    required this.cookingRepository,
  });

  @override
  State<ChallengesHubScreen> createState() => _ChallengesHubScreenState();
}

class _ChallengesHubScreenState extends State<ChallengesHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.cookingRepository.addListener(_onRepositoryUpdated);
  }

  @override
  void dispose() {
    widget.cookingRepository.removeListener(_onRepositoryUpdated);
    _tabController.dispose();
    super.dispose();
  }

  void _onRepositoryUpdated() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.cookingRepository.gamificationProfile;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'CHEF BADGES & CHALLENGES',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
              border: Border.all(color: isDark ? Colors.transparent : AppColors.lightBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, color: AppColors.saffronYellow, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${profile.totalKitchenXp} XP',
                  style: AppTypography.numericData.copyWith(
                    color: isDark ? AppColors.saffronYellow : const Color(0xFFC85A32),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.outline : AppColors.lightTextTertiary,
          labelStyle: AppTypography.metadata.copyWith(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'ACTIVE CHALLENGES (${profile.challenges.length})'),
            Tab(text: 'BADGE GALLERY (${profile.badges.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Global Gamification Metrics Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceContainer : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(child: _buildStatItem('STREAK', '🔥 ${profile.streakDays}d', AppColors.secondaryOrange, isDark)),
                Expanded(child: _buildStatItem('WEEKLY', '🎯 ${profile.weeklyMealsCooked}/${profile.weeklyMealTarget}', AppColors.sproutGreen, isDark)),
                Expanded(child: _buildStatItem('BADGES', '🏆 ${profile.unlockedBadgeCount}/${profile.badges.length}', AppColors.primary, isDark)),
                Expanded(child: _buildStatItem('RECIPES', '🍳 ${profile.totalRecipesMastered}', isDark ? AppColors.onSurface : AppColors.lightTextPrimary, isDark)),
              ],
            ),
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChallengesTab(profile, isDark),
                _buildBadgesTab(profile, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.metadata.copyWith(
            fontSize: 10,
            color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.numericData.copyWith(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildChallengesTab(GamificationProfileModel profile, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Explainer banner
        BrutalistCard(
          backgroundColor: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
          borderColor: AppColors.primary.withValues(alpha: 0.4),
          child: Row(
            children: [
              const Icon(Icons.military_tech_outlined, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEKLY & MILESTONE CHALLENGES ACTIVE',
                      style: AppTypography.metadata.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Complete recipe sessions and maintain stove streaks to earn Kitchen XP and unlock prestigious badges.',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Challenge Cards
        ...profile.challenges.map((chal) {
          final isCompleted = chal.isCompleted;
          final isClaimed = chal.isClaimed;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isClaimed
                  ? (isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm)
                  : isCompleted
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : (isDark ? AppColors.surfaceContainer : Colors.white),
              border: Border.all(
                color: isCompleted ? AppColors.primary : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                width: isCompleted ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Title + XP pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            chal.title,
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 15,
                              color: isCompleted ? AppColors.sproutGreen : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            chal.description, 
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceBlack : AppColors.lightSurfaceWarm,
                        border: Border.all(color: isDark ? Colors.transparent : AppColors.lightBorder),
                      ),
                      child: Text(
                        '+${chal.rewardXp} XP',
                        style: AppTypography.metadata.copyWith(
                          color: isDark ? AppColors.saffronYellow : const Color(0xFFC85A32),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROGRESS: ${chal.currentProgress}/${chal.targetProgress} ${chal.unit.toUpperCase()}',
                      style: AppTypography.metadata.copyWith(
                        fontSize: 11,
                        color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                      ),
                    ),
                    Text(
                      '${(chal.progressRatio * 100).toInt()}%',
                      style: AppTypography.numericData.copyWith(
                        color: isCompleted ? AppColors.sproutGreen : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: chal.progressRatio,
                  backgroundColor: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? AppColors.sproutGreen : AppColors.primary,
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: 14),

                // Interactive Buttons
                Row(
                  children: [
                    if (chal.canClaim) ...[
                      Expanded(
                        child: BrutalistButton(
                          text: 'CLAIM REWARD & BADGE',
                          isFullWidth: true,
                          variant: BrutalistButtonVariant.primary,
                          icon: Icon(Icons.card_giftcard, size: 16, color: isDark ? AppColors.surfaceBlack : Colors.white),
                          onPressed: () {
                            widget.cookingRepository.claimChallengeReward(chal.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('🎉 Claimed +${chal.rewardXp} XP! Badge unlocked.')),
                            );
                          },
                        ),
                      ),
                    ] else if (isClaimed) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        color: AppColors.sproutGreen.withValues(alpha: 0.15),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: AppColors.sproutGreen, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'CHALLENGE COMPLETED & CLAIMED',
                                style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Quick action to log/simulate meal progress
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          icon: const Icon(Icons.add_task, size: 16, color: AppColors.primary),
                          label: Text(
                            chal.unit == 'days' ? 'LOG +1 DAY STREAK' : 'LOG +1 MEAL COOKED',
                            style: AppTypography.labelButton.copyWith(color: AppColors.primary, fontSize: 11),
                          ),
                          onPressed: () {
                            widget.cookingRepository.recordMealCooked();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Logged progress for: ${chal.title}')),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBadgesTab(GamificationProfileModel profile, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'CHEF AWARDS & HALL OF FAME',
                style: AppTypography.metadata.copyWith(
                  color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${profile.unlockedBadgeCount} OF ${profile.badges.length} EARNED',
              style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...profile.badges.map((badge) {
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

          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => BadgeDetailDialog(
                  badge: badge,
                  cookingRepository: widget.cookingRepository,
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: badge.isUnlocked
                    ? (isDark ? AppColors.surfaceContainer : Colors.white)
                    : (isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm),
                border: Border.all(
                  color: badge.isUnlocked ? AppColors.primary : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                  width: badge.isUnlocked ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    color: badge.isUnlocked ? AppColors.primary : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm),
                    child: Icon(
                      badge.isUnlocked ? icon : Icons.lock_outline,
                      size: 26,
                      color: badge.isUnlocked ? (isDark ? AppColors.surfaceBlack : Colors.white) : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                badge.title,
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 15,
                                  color: badge.isUnlocked ? (isDark ? AppColors.onSurface : AppColors.lightTextPrimary) : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              color: badge.isUnlocked
                                  ? AppColors.sproutGreen.withValues(alpha: 0.2)
                                  : (isDark ? AppColors.surfaceBlack : AppColors.lightSurfaceWarm),
                              child: Text(
                                badge.isUnlocked ? 'EARNED' : 'LOCKED',
                                style: AppTypography.metadata.copyWith(
                                  color: badge.isUnlocked ? AppColors.sproutGreen : (isDark ? AppColors.outline : AppColors.lightTextTertiary),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.description,
                          style: AppTypography.bodySm.copyWith(
                            color: badge.isUnlocked ? (isDark ? AppColors.onSurface : AppColors.lightTextSecondary) : (isDark ? AppColors.outlineVariant : AppColors.lightTextTertiary),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '+${badge.rewardXp} XP',
                              style: AppTypography.metadata.copyWith(
                                color: isDark ? AppColors.saffronYellow : const Color(0xFFC85A32),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Tap to inspect details →',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
