import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeerola/data/models/ingredient_model.dart';
import 'package:jeerola/data/repositories/meal_plan_repository.dart';
import 'package:jeerola/data/repositories/recipe_repository.dart';
import 'package:jeerola/data/repositories/shopping_repository.dart';
import 'package:jeerola/data/services/affiliate_service.dart';
import 'package:jeerola/data/services/local_storage_service.dart';
import 'package:jeerola/core/utils/market_pack_engine.dart';
import 'package:jeerola/ui/features/recipes/view_models/recipe_view_model.dart';
import 'package:jeerola/ui/features/recipes/views/recipe_catalog_screen.dart';
import 'package:jeerola/ui/features/shopping_list/view_models/shopping_list_view_model.dart';

void main() {
  group('Masala & Spice Packet Catalog Tests', () {
    test('Contains exactly the 5 specified packet sizes: 100g, 250g, 500g, 750g, 1kg', () {
      final tiers = MasalaPackTier.tiers;
      expect(tiers.length, 5);

      final labels = tiers.map((t) => t.label).toList();
      expect(labels, ['100g', '250g', '500g', '750g', '1kg']);

      final weights = tiers.map((t) => t.weightGrams).toList();
      expect(weights, [100.0, 250.0, 500.0, 750.0, 1000.0]);
    });

    test('Volume price multipliers offer realistic tier pricing', () {
      final base100g = 70;
      final price100g = (base100g * MasalaPackTier.tiers[0].priceMultiplier)
          .round();
      final price250g = (base100g * MasalaPackTier.tiers[1].priceMultiplier)
          .round();
      final price500g = (base100g * MasalaPackTier.tiers[2].priceMultiplier)
          .round();
      final price750g = (base100g * MasalaPackTier.tiers[3].priceMultiplier)
          .round();
      final price1kg = (base100g * MasalaPackTier.tiers[4].priceMultiplier)
          .round();

      expect(price100g, 70);
      expect(price250g, 161);
      expect(price500g, 301);
      expect(price750g, 434);
      expect(price1kg, 546);

      // Verify per-gram cost decreases with larger pack size
      final perGram100 = price100g / 100;
      final perGram1kg = price1kg / 1000;
      expect(perGram1kg < perGram100, true);
    });

    testWidgets(
      'RecipeCatalogScreen renders in Masala Grid mode with packet sizes',
      (tester) async {
        final localStorageService = LocalStorageService();
        final affiliateService = AffiliateService();
        const marketPackEngine = MarketPackEngine(bufferPercentage: 0.15);

        final recipeRepo = RecipeRepository();
        final recipeVm = RecipeViewModel(recipeRepository: recipeRepo);
        final mealPlanRepo = MealPlanRepository(
          localStorageService: localStorageService,
        );
        final shoppingRepo = ShoppingRepository(
          affiliateService: affiliateService,
          engine: marketPackEngine,
        );
        final shoppingVm = ShoppingListViewModel(
          shoppingRepository: shoppingRepo,
          mealPlanRepository: mealPlanRepo,
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RecipeViewModel>.value(value: recipeVm),
              ChangeNotifierProvider<ShoppingListViewModel>.value(
                value: shoppingVm,
              ),
            ],
            child: const MaterialApp(home: RecipeCatalogScreen()),
          ),
        );
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Check for grid container tab and search bar
        expect(find.text('MASALAS & SPICES (GRID)'), findsOneWidget);
        expect(find.text('DISH PROTOCOLS'), findsOneWidget);

        // Verify packet sizes appear in the grid
        expect(find.text('100g'), findsWidgets);
        expect(find.text('250g'), findsWidgets);
        expect(find.text('500g'), findsWidgets);
        expect(find.text('750g'), findsWidgets);
        expect(find.text('1kg'), findsWidgets);

        // Verify "ADD 100G" button appears
        expect(find.text('ADD 100G'), findsWidgets);

        // Tap on 250g chip on first card
        final first250gChip = find.text('250g').first;
        await tester.tap(first250gChip);
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pumpAndSettle();

        // Button updates to "ADD 250G"
        expect(find.text('ADD 250G'), findsWidgets);

        // Tap the ADD button
        final add250gButton = find.text('ADD 250G').first;
        await tester.tap(add250gButton);
        await tester.pumpAndSettle();

        // Verify item was added to the cart in ShoppingListViewModel
        expect(shoppingVm.items.length, 1);
        final addedItem = shoppingVm.items.first;
        expect(addedItem.category, IngredientCategory.spices);
        expect(addedItem.rawQuantity, 250.0);
        expect(addedItem.unit, 'g');
        expect(addedItem.name, contains('250g'));
        expect(addedItem.estimatedPrice > 0, true);
      },
    );

    testWidgets(
      'RecipeCatalogScreen does not overflow on small height / landscape viewport (height=252.1px)',
      (tester) async {
        final localStorageService = LocalStorageService();
        final affiliateService = AffiliateService();
        const marketPackEngine = MarketPackEngine(bufferPercentage: 0.15);

        final recipeRepo = RecipeRepository();
        final recipeVm = RecipeViewModel(recipeRepository: recipeRepo);
        final mealPlanRepo = MealPlanRepository(
          localStorageService: localStorageService,
        );
        final shoppingRepo = ShoppingRepository(
          affiliateService: affiliateService,
          engine: marketPackEngine,
        );
        final shoppingVm = ShoppingListViewModel(
          shoppingRepository: shoppingRepo,
          mealPlanRepository: mealPlanRepo,
        );

        // Constrain physical size exactly to the error condition: 800.7 x 252.1
        tester.view.physicalSize = const Size(800.7, 252.1);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<RecipeViewModel>.value(value: recipeVm),
              ChangeNotifierProvider<ShoppingListViewModel>.value(
                value: shoppingVm,
              ),
            ],
            child: const MaterialApp(home: RecipeCatalogScreen()),
          ),
        );

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // Must render cleanly without throwing RenderFlex overflow
        expect(find.byType(RecipeCatalogScreen), findsOneWidget);
        expect(find.byType(CustomScrollView), findsOneWidget);
      },
    );
  });
}
