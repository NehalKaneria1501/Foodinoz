import 'package:flutter/material.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/repositories/meal_plan_repository.dart';
import '../../../../data/repositories/recipe_repository.dart';
import '../../../../data/repositories/shopping_repository.dart';

class MealPlannerViewModel extends ChangeNotifier {
  final MealPlanRepository _mealPlanRepository;
  final RecipeRepository _recipeRepository;
  final ShoppingRepository _shoppingRepository;

  MealPlannerViewModel({
    required this._mealPlanRepository,
    required this._recipeRepository,
    required this._shoppingRepository,
  }) {
    _loadPlan();
  }

  List<PlannedDay> _plan = [];
  List<RecipeModel> _allAvailableRecipes = [];
  int _selectedDuration = 7;
  bool _isLoading = false;

  List<PlannedDay> get plan => _plan;
  List<RecipeModel> get allAvailableRecipes => _allAvailableRecipes;
  int get selectedDuration => _selectedDuration;
  bool get isLoading => _isLoading;

  Future<void> _loadPlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedDuration = _mealPlanRepository.planDurationDays;
      _plan = _mealPlanRepository.currentPlan;
      _allAvailableRecipes = await _recipeRepository.getAllRecipes();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeDuration(int days) async {
    _isLoading = true;
    _selectedDuration = days;
    notifyListeners();

    try {
      _plan = await _mealPlanRepository.setPlanDuration(days);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> swapRecipe({
    required int dayNumber,
    required bool isLunch,
    required RecipeModel newRecipe,
  }) async {
    await _mealPlanRepository.swapRecipe(
      dayNumber: dayNumber,
      isLunch: isLunch,
      newRecipe: newRecipe,
    );
    _plan = _mealPlanRepository.currentPlan;
    notifyListeners();
  }

  /// Builds consolidated cart from current planned meals
  Future<void> generateShoppingList() async {
    final recipes = _mealPlanRepository.getAllPlannedRecipes();
    await _shoppingRepository.generateFromRecipes(recipes);
  }
}
