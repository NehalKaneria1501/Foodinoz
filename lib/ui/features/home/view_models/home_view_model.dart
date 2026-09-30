import 'package:flutter/material.dart';
import '../../../../data/models/gamification_model.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/cooking_repository.dart';
import '../../../../data/repositories/meal_plan_repository.dart';
import '../../../../data/repositories/recipe_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final MealPlanRepository _mealPlanRepository;
  final RecipeRepository _recipeRepository;
  final CookingRepository _cookingRepository;

  HomeViewModel({
    required this._authRepository,
    required this._mealPlanRepository,
    required this._recipeRepository,
    required this._cookingRepository,
  }) {
    _loadHomeData();
    _cookingRepository.addListener(_onCookingUpdated);
  }

  void _onCookingUpdated() {
    _gamification = _cookingRepository.gamificationProfile;
    notifyListeners();
  }

  UserModel? _user;
  int _selectedDurationDays = 7;
  RecipeModel? _todayRecipe;
  GamificationProfileModel? _gamification;
  bool _isLoading = false;

  UserModel? get user => _user;
  int get selectedDurationDays => _selectedDurationDays;
  RecipeModel? get todayRecipe => _todayRecipe;
  GamificationProfileModel? get gamification => _gamification;
  bool get isLoading => _isLoading;
  CookingRepository get cookingRepository => _cookingRepository;

  Future<void> _loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = _authRepository.getCurrentUser();
      _selectedDurationDays = _mealPlanRepository.planDurationDays;
      _gamification = _cookingRepository.gamificationProfile;

      final all = await _recipeRepository.getAllRecipes();
      if (all.isNotEmpty) {
        _todayRecipe = all.first; // Paneer Butter Masala P-08
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDuration(int days) async {
    _selectedDurationDays = days;
    await _mealPlanRepository.setPlanDuration(days);
    notifyListeners();
  }

  Future<void> recordMealCookedQuick() async {
    await _cookingRepository.recordMealCooked(recipe: _todayRecipe);
  }

  void claimChallenge(String challengeId) {
    _cookingRepository.claimChallengeReward(challengeId);
  }

  void refreshData() {
    _gamification = _cookingRepository.gamificationProfile;
    _user = _authRepository.getCurrentUser();
    notifyListeners();
  }

  @override
  void dispose() {
    _cookingRepository.removeListener(_onCookingUpdated);
    super.dispose();
  }
}
