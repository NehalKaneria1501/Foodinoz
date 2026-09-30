import 'package:flutter/material.dart';
import '../../../../data/models/recipe_model.dart';
import '../../../../data/repositories/recipe_repository.dart';

class RecipeViewModel extends ChangeNotifier {
  final RecipeRepository _recipeRepository;

  RecipeViewModel({required this._recipeRepository}) {
    _loadRecipes();
  }

  List<RecipeModel> _recipes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCuisine = 'All';
  MealType? _selectedMealType;
  bool _isVegOnly = false;
  bool _withoutAsafoetidaOnly = false;

  List<RecipeModel> get recipes => _recipes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCuisine => _selectedCuisine;
  MealType? get selectedMealType => _selectedMealType;
  bool get isVegOnly => _isVegOnly;
  bool get withoutAsafoetidaOnly => _withoutAsafoetidaOnly;

  final List<String> availableCuisines = [
    'All',
    'Farali & Vrat',
    'Gujarati',
    'Jain',
    'Swaminarayan',
    'Street Food',
    'Indo-Chinese',
    'Mexican & Fusion',
    'North Indian',
    'Desserts & Sweets',
  ];

  Future<void> _loadRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recipes = await _recipeRepository.searchAndFilter(
        query: _searchQuery,
        cuisine: _selectedCuisine,
        mealType: _selectedMealType,
        isVegOnly: _isVegOnly ? true : null,
        withoutAsafoetidaOnly: _withoutAsafoetidaOnly ? true : null,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onSearch(String query) {
    _searchQuery = query;
    _loadRecipes();
  }

  void onSelectCuisine(String cuisine) {
    _selectedCuisine = cuisine;
    _loadRecipes();
  }

  void onSelectMealType(MealType? mealType) {
    _selectedMealType = mealType;
    _loadRecipes();
  }

  void onToggleVegOnly(bool vegOnly) {
    _isVegOnly = vegOnly;
    _loadRecipes();
  }

  void onToggleWithoutAsafoetida(bool withoutHing) {
    _withoutAsafoetidaOnly = withoutHing;
    _loadRecipes();
  }
}
