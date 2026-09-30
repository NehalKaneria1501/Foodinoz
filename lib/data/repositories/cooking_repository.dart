import 'package:flutter/foundation.dart';
import '../models/gamification_model.dart';
import '../models/recipe_model.dart';
import '../services/mock_data_service.dart';

class CookingRepository extends ChangeNotifier {
  GamificationProfileModel _profile = MockDataService.defaultGamification;
  final Set<String> _completedRecipeIds = {'rec_01', 'rec_03', 'rec_04'};

  GamificationProfileModel get gamificationProfile => _profile;

  Set<String> get completedRecipeIds => Set.unmodifiable(_completedRecipeIds);

  /// Records a completed meal cooking session
  Future<void> completeCookingSession(RecipeModel recipe) async {
    _completedRecipeIds.add(recipe.id);
    await recordMealCooked(recipe: recipe);
  }

  /// Manually or automatically records that a meal was cooked
  Future<void> recordMealCooked({RecipeModel? recipe}) async {
    final newCookedCount = _profile.weeklyMealsCooked + 1;
    final newStreak = _profile.streakDays + 1;
    final newXp = _profile.totalKitchenXp + 50;

    // Check Weekly 7-Meal Challenge & Badge
    final isWeeklyGoalMet = newCookedCount >= _profile.weeklyMealTarget;
    final isStreakGoalMet = newStreak >= 7;

    // Update Challenges
    final updatedChallenges = _profile.challenges.map((chal) {
      if (chal.id == 'chal_01') {
        return chal.copyWith(
          currentProgress: newCookedCount,
          isCompleted: isWeeklyGoalMet,
        );
      }
      if (chal.id == 'chal_02') {
        return chal.copyWith(
          currentProgress: newStreak,
          isCompleted: isStreakGoalMet,
        );
      }
      return chal;
    }).toList();

    // Update Badges
    final updatedBadges = _profile.badges.map((b) {
      if (b.id == 'badge_01' && isWeeklyGoalMet) {
        return b.copyWith(
          isUnlocked: true,
          unlockedAt: b.unlockedAt ?? DateTime.now(),
          description: 'Cooked $newCookedCount meals this week! 7-Meal Goal Completed! 🎉',
        );
      }
      if (b.id == 'badge_03' && isStreakGoalMet) {
        return b.copyWith(
          isUnlocked: true,
          unlockedAt: b.unlockedAt ?? DateTime.now(),
          description: 'Stove burning hot! 7-Day Cooking Streak Achieved! 🔥',
        );
      }
      if (recipe != null && b.id == 'badge_02' && recipe.masalaPouchNumber == 'P-08') {
        return b.copyWith(
          isUnlocked: true,
          unlockedAt: b.unlockedAt ?? DateTime.now(),
        );
      }
      return b;
    }).toList();

    _profile = _profile.copyWith(
      weeklyMealsCooked: newCookedCount,
      streakDays: newStreak,
      totalKitchenXp: newXp,
      totalRecipesMastered: _profile.totalRecipesMastered + 1,
      badges: updatedBadges,
      challenges: updatedChallenges,
    );

    notifyListeners();
  }

  /// Claim an earned challenge reward and badge
  void claimChallengeReward(String challengeId) {
    ChallengeModel? target;
    final updatedChallenges = _profile.challenges.map((c) {
      if (c.id == challengeId && c.isCompleted && !c.isClaimed) {
        target = c;
        return c.copyWith(isClaimed: true);
      }
      return c;
    }).toList();

    if (target == null) return;

    // Unlock badge associated with challenge
    final updatedBadges = _profile.badges.map((b) {
      if (b.id == target!.rewardBadgeId) {
        return b.copyWith(
          isUnlocked: true,
          unlockedAt: b.unlockedAt ?? DateTime.now(),
        );
      }
      return b;
    }).toList();

    _profile = _profile.copyWith(
      totalKitchenXp: _profile.totalKitchenXp + target!.rewardXp,
      challenges: updatedChallenges,
      badges: updatedBadges,
    );

    notifyListeners();
  }

  /// Unlock a badge directly (e.g. from special kitchen events)
  void unlockBadge(String badgeId) {
    final updatedBadges = _profile.badges.map((b) {
      if (b.id == badgeId) {
        return b.copyWith(
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
      return b;
    }).toList();

    _profile = _profile.copyWith(badges: updatedBadges);
    notifyListeners();
  }
}
