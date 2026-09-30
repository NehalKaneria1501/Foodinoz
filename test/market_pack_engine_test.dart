import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/core/utils/market_pack_engine.dart';
import 'package:jeerola/data/models/ingredient_model.dart';

void main() {
  group('MarketPackEngine Tests', () {
    const engine = MarketPackEngine(bufferPercentage: 0.15); // +15% buffer

    test('Consolidates identical ingredients across multiple recipes', () {
      final ingredients = [
        const IngredientModel(
          id: '1',
          name: 'Red Onions',
          quantity: 200,
          unit: 'g',
          category: IngredientCategory.vegetables,
          marketPackSize: 500,
          marketPackUnit: 'g',
        ),
        const IngredientModel(
          id: '2',
          name: 'Red Onions',
          quantity: 300,
          unit: 'g',
          category: IngredientCategory.vegetables,
          marketPackSize: 500,
          marketPackUnit: 'g',
        ),
      ];

      final items = engine.generateShoppingList(ingredients);
      expect(items.length, 1);
      final onion = items.first;
      expect(onion.name, 'Red Onions');
      expect(onion.rawQuantity, 500.0);
      // 500g + 15% buffer = 575g
      expect(onion.bufferedQuantity, closeTo(575.0, 0.1));
      expect(onion.bufferPercent, 15);
      // 575g / 500g pack size = 2 packs (1000g)
      expect(onion.packCount, 2);
      expect(onion.packSize, 500.0);
    });

    test('Calculates market packs correctly for small quantity items', () {
      final calc = MarketPackEngine.calculatePacks(
        bufferedAmount: 180, // e.g. 180g paneer
        unit: 'g',
        standardPackSize: 200, // 200g commercial pack
        marketPackUnit: 'g',
      );

      expect(calc.packCount, 1);
      expect(calc.totalPurchased, 200.0);
    });

    test('Calculates market packs for items exceeding single pack size', () {
      final calc = MarketPackEngine.calculatePacks(
        bufferedAmount: 220, // e.g. 220g paneer
        unit: 'g',
        standardPackSize: 200,
        marketPackUnit: 'g',
      );

      // Should round up to 2 packs (400g)
      expect(calc.packCount, 2);
      expect(calc.totalPurchased, 400.0);
    });
  });
}
