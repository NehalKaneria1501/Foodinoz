class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String iconCode;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int rewardXp;
  final String category; // 'WEEKLY', 'MASTERY', 'STREAK', 'ECO'

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.iconCode,
    this.isUnlocked = false,
    this.unlockedAt,
    this.rewardXp = 50,
    this.category = 'MASTERY',
  });

  BadgeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? iconCode,
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? rewardXp,
    String? category,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconCode: iconCode ?? this.iconCode,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rewardXp: rewardXp ?? this.rewardXp,
      category: category ?? this.category,
    );
  }
}

class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final String unit; // 'meals', 'days', 'pouches', 'packs'
  final int rewardXp;
  final String rewardBadgeId;
  final bool isCompleted;
  final bool isClaimed;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    this.unit = 'meals',
    this.rewardXp = 100,
    required this.rewardBadgeId,
    this.isCompleted = false,
    this.isClaimed = false,
  });

  double get progressRatio =>
      targetProgress > 0 ? (currentProgress / targetProgress).clamp(0.0, 1.0) : 0.0;

  bool get canClaim => isCompleted && !isClaimed;

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    int? currentProgress,
    int? targetProgress,
    String? unit,
    int? rewardXp,
    String? rewardBadgeId,
    bool? isCompleted,
    bool? isClaimed,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      currentProgress: currentProgress ?? this.currentProgress,
      targetProgress: targetProgress ?? this.targetProgress,
      unit: unit ?? this.unit,
      rewardXp: rewardXp ?? this.rewardXp,
      rewardBadgeId: rewardBadgeId ?? this.rewardBadgeId,
      isCompleted: isCompleted ?? this.isCompleted,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}

class GamificationProfileModel {
  final int weeklyMealsCooked;
  final int weeklyMealTarget;
  final int streakDays;
  final int totalRecipesMastered;
  final int totalKitchenXp;
  final List<BadgeModel> badges;
  final List<ChallengeModel> challenges;

  const GamificationProfileModel({
    this.weeklyMealsCooked = 5,
    this.weeklyMealTarget = 7,
    this.streakDays = 6,
    this.totalRecipesMastered = 14,
    this.totalKitchenXp = 350,
    this.badges = const [],
    this.challenges = const [],
  });

  double get weeklyProgress =>
      weeklyMealTarget > 0 ? (weeklyMealsCooked / weeklyMealTarget).clamp(0.0, 1.0) : 0.0;

  int get unlockedBadgeCount => badges.where((b) => b.isUnlocked).length;
  int get activeChallengeCount => challenges.where((c) => !c.isClaimed).length;
  int get completedChallengeCount => challenges.where((c) => c.isCompleted).length;

  GamificationProfileModel copyWith({
    int? weeklyMealsCooked,
    int? weeklyMealTarget,
    int? streakDays,
    int? totalRecipesMastered,
    int? totalKitchenXp,
    List<BadgeModel>? badges,
    List<ChallengeModel>? challenges,
  }) {
    return GamificationProfileModel(
      weeklyMealsCooked: weeklyMealsCooked ?? this.weeklyMealsCooked,
      weeklyMealTarget: weeklyMealTarget ?? this.weeklyMealTarget,
      streakDays: streakDays ?? this.streakDays,
      totalRecipesMastered: totalRecipesMastered ?? this.totalRecipesMastered,
      totalKitchenXp: totalKitchenXp ?? this.totalKitchenXp,
      badges: badges ?? this.badges,
      challenges: challenges ?? this.challenges,
    );
  }
}
