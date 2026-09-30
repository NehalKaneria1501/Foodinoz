import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/data/models/ingredient_model.dart';
import 'package:jeerola/data/services/packaged_ingredients_service.dart';
import 'package:jeerola/data/repositories/shopping_repository.dart';
import 'package:jeerola/data/repositories/meal_plan_repository.dart';
import 'package:jeerola/data/services/affiliate_service.dart';
import 'package:jeerola/data/services/local_storage_service.dart';
import 'package:jeerola/core/utils/market_pack_engine.dart';
import 'package:jeerola/ui/features/shopping_list/view_models/shopping_list_view_model.dart';

void main() {
  group('Packaged Ingredients Categorization & Tier Packets Suite', () {
    test(
      'Service contains all 9 distinct categories with 150+ packaged items',
      () {
        final items = PackagedIngredientsService.allItems;
        expect(items.length >= 150, true);

        final categories = items.map((i) => i.category).toSet();
        expect(categories, contains(IngredientCategory.fastFood));
        expect(categories, contains(IngredientCategory.pastry));
        expect(categories, contains(IngredientCategory.cake));
        expect(categories, contains(IngredientCategory.biscuit));
        expect(categories, contains(IngredientCategory.bakery));
        expect(categories, contains(IngredientCategory.beverages));
        expect(categories, contains(IngredientCategory.sweets));
        expect(categories, contains(IngredientCategory.faraliSpecial));
        expect(categories, contains(IngredientCategory.namkeenFarshan));
      },
    );

    test('Fast Foods category contains requested items', () {
      final fastFoods = PackagedIngredientsService.getByCategory(
        IngredientCategory.fastFood,
      );
      expect(fastFoods.length >= 35, true);

      final names = fastFoods.map((i) => i.name.toLowerCase()).toList();
      expect(names, contains('swaminarayan khichadi'));
      expect(names, contains('masala puff'));
      expect(names, contains('aalu mattar sandwich'));
      expect(names, contains('mayoneez sandwich'));
      expect(names, contains('peri peri puff'));
      expect(names, contains('chinese puff'));
      expect(names, contains('cheese chilli sandwich'));
      expect(names, contains('veg cheese sandwich'));
      expect(names, contains('paneer grill sandwich'));
      expect(names, contains('pizza'));
      expect(names, contains('noodles'));
      expect(names, contains('veg manchurian dry'));
      expect(names, contains('veg manchurian gravy'));
      expect(names, contains('dabeli'));
      expect(names, contains('vadapav'));
      expect(names, contains('kachori'));
      expect(names, contains('samosa'));
      expect(names, contains('muthiya'));
      expect(names, contains('idada'));
      expect(names, contains('khaman'));
      expect(names, contains('thepla'));
      expect(names, contains('alu paratha'));
      expect(names, contains('puri shaak'));
      expect(names, contains('sada dosa'));
      expect(names, contains('masala dosa'));
      expect(names, contains('maisure masala dosa'));
      expect(names, contains('idli shambhar'));
      expect(names, contains('chole bhature'));
      expect(names, contains('chole kulcha'));
      expect(names, contains('pav bhaji'));
      expect(names, contains('pulav'));
      expect(names, contains('bhel'));
      expect(names, contains('sev puri'));
      expect(names, contains('dahivada'));
      expect(names, contains('dahi puri'));
      expect(names, contains('dahi papadi'));
      expect(names, contains('panipuri dish'));
      expect(names, contains('dahi'));
    });

    test('Pastry, Cake, Biscuit, Bakery, Beverages categories contain requested items', () {
      final pastries = PackagedIngredientsService.getByCategory(
        IngredientCategory.pastry,
      );
      final pNames = pastries.map((i) => i.name.toLowerCase()).toList();
      expect(pNames, contains('chocolate pastry'));
      expect(pNames, contains('red velvet pastry'));
      expect(pNames, contains('brownie'));

      final cakes = PackagedIngredientsService.getByCategory(
        IngredientCategory.cake,
      );
      final cNames = cakes.map((i) => i.name.toLowerCase()).toList();
      expect(cNames, contains('chocolate cake'));
      expect(cNames, contains('truffle cake'));

      final biscuits = PackagedIngredientsService.getByCategory(
        IngredientCategory.biscuit,
      );
      final bNames = biscuits.map((i) => i.name.toLowerCase()).toList();
      expect(bNames, contains('badam pista biscuit'));
      expect(bNames, contains('choco chip biscuit'));
      expect(bNames, contains('nan khatai'));

      final bakery = PackagedIngredientsService.getByCategory(
        IngredientCategory.bakery,
      );
      final bkNames = bakery.map((i) => i.name.toLowerCase()).toList();
      expect(bkNames, contains('bread'));
      expect(bkNames, contains('brown bread'));
      expect(bkNames, contains('pav'));
      expect(bkNames, contains('pizza base'));
      expect(bkNames, contains('toast'));

      final beverages = PackagedIngredientsService.getByCategory(
        IngredientCategory.beverages,
      );
      final bvNames = beverages.map((i) => i.name.toLowerCase()).toList();
      expect(bvNames, contains('limbu sharbat'));
      expect(bvNames, contains('chass'));
      expect(bvNames, contains('gulab lassi'));
      expect(bvNames, contains('mango lassi'));
      expect(bvNames, contains('sugarcane juice'));
    });

    test('Sweets, Farali Special, and Namkeen/Farshan categories contain requested items', () {
      final sweets = PackagedIngredientsService.getByCategory(
        IngredientCategory.sweets,
      );
      final sNames = sweets.map((i) => i.name.toLowerCase()).toList();
      expect(sNames, contains('mango matho'));
      expect(sNames, contains('mava penda'));
      expect(sNames, contains('mohanthal'));
      expect(sNames, contains('kaju katri'));
      expect(sNames, contains('gulab jamun'));

      final farali = PackagedIngredientsService.getByCategory(
        IngredientCategory.faraliSpecial,
      );
      final fNames = farali.map((i) => i.name.toLowerCase()).toList();
      expect(fNames, contains('sabudana khichadi'));
      expect(fNames, contains('sabudana vada'));
      expect(fNames, contains('moraiya khichadi'));
      expect(fNames, contains('farali chevada'));
      expect(fNames, contains('farali handvo lot'));

      final namkeen = PackagedIngredientsService.getByCategory(
        IngredientCategory.namkeenFarshan,
      );
      final nNames = namkeen.map((i) => i.name.toLowerCase()).toList();
      expect(nNames, contains('bataka wafer'));
      expect(nNames, contains('kela wafer'));
      expect(nNames, contains('ratlami sev'));
      expect(nNames, contains('gathiya'));
      expect(nNames, contains('pani puri packet'));
      expect(nNames, contains('khakhara'));
    });

    test('Adding custom packaged packet to ShoppingListViewModel categorizes properly', () {
      final localStorageService = LocalStorageService();
      final affiliateService = AffiliateService();
      const marketPackEngine = MarketPackEngine(bufferPercentage: 0.15);

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

      // Add Farali Chevada 500g packet
      shoppingVm.addCustomItem(
        name: 'Farali Chevada (500g)',
        category: IngredientCategory.faraliSpecial,
        quantity: 500.0,
        unit: 'g',
        estimatedPrice: 215.0,
        packCount: 1,
      );

      // Add Kaju Katri 1kg packet
      shoppingVm.addCustomItem(
        name: 'Kaju Katri (1kg)',
        category: IngredientCategory.sweets,
        quantity: 1000.0,
        unit: 'g',
        estimatedPrice: 750.0,
        packCount: 1,
      );

      expect(shoppingVm.items.length, 2);
      final grouped = shoppingVm.groupedItems;
      expect(grouped.containsKey(IngredientCategory.faraliSpecial), true);
      expect(grouped.containsKey(IngredientCategory.sweets), true);

      final faraliItem = grouped[IngredientCategory.faraliSpecial]!.first;
      expect(faraliItem.name, 'Farali Chevada (500g)');
      expect(faraliItem.rawQuantity, 500.0);
      expect(faraliItem.estimatedPrice, 215.0);

      final sweetItem = grouped[IngredientCategory.sweets]!.first;
      expect(sweetItem.name, 'Kaju Katri (1kg)');
      expect(sweetItem.rawQuantity, 1000.0);
      expect(sweetItem.estimatedPrice, 750.0);
    });
  });
}
