import '../models/recipe_model.dart';
import '../services/mock_data_service.dart';

class RecipeRepository {
  final List<RecipeModel> _recipes = List.from(MockDataService.recipes);

  Future<List<RecipeModel>> getAllRecipes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_recipes);
  }

  Future<RecipeModel?> getRecipeById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<RecipeModel>> searchAndFilter({
    String query = '',
    String? cuisine,
    MealType? mealType,
    bool? isVegOnly,
    bool? withoutAsafoetidaOnly,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _recipes.where((recipe) {
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        final matchTitle = recipe.title.toLowerCase().contains(q);
        final matchPouch = recipe.masalaPouchNumber.toLowerCase().contains(q);
        final matchDesc = recipe.description.toLowerCase().contains(q);
        if (!matchTitle && !matchPouch && !matchDesc) return false;
      }

      if (cuisine != null && cuisine.isNotEmpty && cuisine != 'All') {
        final c = cuisine.toLowerCase();
        if (c == 'jain') {
          final isJain = recipe.cuisine.toLowerCase() == 'jain' ||
              recipe.title.toLowerCase().contains('jain') ||
              recipe.description.toLowerCase().contains('jain') ||
              recipe.cuisine.toLowerCase() == 'farali & vrat';
          if (!isJain) return false;
        } else if (c == 'swaminarayan') {
          final isSwaminarayan = recipe.cuisine.toLowerCase() == 'swaminarayan' ||
              recipe.title.toLowerCase().contains('swaminarayan') ||
              recipe.description.toLowerCase().contains('swaminarayan') ||
              recipe.cuisine.toLowerCase() == 'farali & vrat';
          if (!isSwaminarayan) return false;
        } else {
          if (recipe.cuisine.toLowerCase() != c) return false;
        }
      }

      if (mealType != null) {
        if (recipe.mealType != mealType) return false;
      }

      if (isVegOnly == true) {
        if (!recipe.isVeg) return false;
      }

      if (withoutAsafoetidaOnly == true) {
        final isHingFree = recipe.isHingFree ||
            recipe.cuisine.toLowerCase() == 'jain' ||
            recipe.cuisine.toLowerCase() == 'farali & vrat' ||
            recipe.title.toLowerCase().contains('jain');
        if (!isHingFree) return false;
      }

      return true;
    }).toList();
  }
}
