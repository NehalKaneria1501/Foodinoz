import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/data/models/recipe_model.dart';
import 'package:jeerola/data/models/ingredient_model.dart';
import 'package:jeerola/data/models/cooking_step_model.dart';
import 'package:jeerola/data/mock/mock_recipes.dart';
import 'package:jeerola/data/services/recipe_localization_service.dart';

void main() {
  group('Multilingual Recipe & Scratch-to-Advanced Tests', () {
    test('Translates recipe titles accurately into Gujarati and Hindi', () {
      final gujaratiTitle = RecipeLocalizationService.getRecipeTitle('Farali Pizza', RecipeLanguage.gujarati);
      final hindiTitle = RecipeLocalizationService.getRecipeTitle('Farali Pizza', RecipeLanguage.hindi);

      expect(gujaratiTitle, contains('ફરાળી'));
      expect(hindiTitle, contains('फराली'));

      final dalvadaGu = RecipeLocalizationService.getRecipeTitle('Dalvada', RecipeLanguage.gujarati);
      final dalvadaHi = RecipeLocalizationService.getRecipeTitle('Dalvada', RecipeLanguage.hindi);
      expect(dalvadaGu, contains('દાળવડા'));
      expect(dalvadaHi, contains('दालवड़ा'));
    });

    test('Translates ingredients and units into Gujarati and Hindi', () {
      const ingredient = IngredientModel(
        id: 'ing_1',
        name: 'Paneer Cubes',
        quantity: 250,
        unit: 'g',
        category: IngredientCategory.dairy,
      );

      final guName = RecipeLocalizationService.getIngredientName(ingredient.name, RecipeLanguage.gujarati);
      final hiName = RecipeLocalizationService.getIngredientName(ingredient.name, RecipeLanguage.hindi);

      expect(guName, contains('પનીર'));
      expect(hiName, contains('पनीर'));

      expect(ingredient.getUnit(RecipeLanguage.gujarati), 'ગ્રા.');
      expect(ingredient.getUnit(RecipeLanguage.hindi), 'ग्रा.');
      expect(ingredient.getUnit(RecipeLanguage.english), 'g');
    });

    test('Provides scratch-to-advanced flame control and pro chef tips', () {
      const stepPrep = CookingStepModel(
        stepNumber: 1,
        title: 'Chop vegetables and prepare dough',
        instruction: 'Chop everything finely from scratch.',
      );

      expect(stepPrep.getFlameLevelLabel(RecipeLanguage.gujarati), contains('તાપ'));
      expect(stepPrep.getFlameLevelLabel(RecipeLanguage.hindi), contains('आंच'));

      // Test dynamically localized recipe
      final sample = MockRecipes.allRecipes.first;
      final localizedGu = RecipeLocalizationService.localize(sample, RecipeLanguage.gujarati);
      final localizedHi = RecipeLocalizationService.localize(sample, RecipeLanguage.hindi);

      expect(localizedGu.title.isNotEmpty, true);
      expect(localizedHi.title.isNotEmpty, true);
      expect(localizedGu.steps.isNotEmpty, true);

      // Verify flame levels and pro tips are present in steps
      for (final step in localizedGu.steps) {
        expect(step.getFlameLevelLabel(RecipeLanguage.gujarati).isNotEmpty, true);
        expect(step.getInstruction(RecipeLanguage.gujarati).isNotEmpty, true);
      }
    });

    test('Localizes all mock recipes without crash', () {
      expect(MockRecipes.allRecipes.length, greaterThanOrEqualTo(60));
      for (final recipe in MockRecipes.allRecipes) {
        final gu = RecipeLocalizationService.localize(recipe, RecipeLanguage.gujarati);
        final hi = RecipeLocalizationService.localize(recipe, RecipeLanguage.hindi);

        expect(gu.title.isNotEmpty, true);
        expect(hi.title.isNotEmpty, true);
        expect(gu.ingredients.length, recipe.ingredients.length);
        expect(hi.ingredients.length, recipe.ingredients.length);
        expect(gu.steps.length, recipe.steps.length);
        expect(hi.steps.length, recipe.steps.length);
      }
    });
  });
}
