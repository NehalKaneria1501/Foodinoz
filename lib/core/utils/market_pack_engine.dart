import 'dart:math';
import '../../data/models/ingredient_model.dart';
import '../../data/models/shopping_item_model.dart';

/// MarketPackEngine
/// Encapsulates the algorithmic calculation for:
/// 1. Consolidating identical ingredients across a 7/15/30-day meal plan.
/// 2. Adding a smart buffer (10% - 20%, default 15%) to avoid kitchen shortfalls.
/// 3. Mapping continuous fractional recipe amounts to commercial market pack sizes
///    (e.g., 650g onions + 15% buffer = 747.5g -> 2 x 500g packs = 1000g).
class MarketPackEngine {
  final double bufferPercentage;

  const MarketPackEngine({this.bufferPercentage = 0.15});

  /// Consolidates raw ingredients and computes buffered quantities & nearest commercial packs
  List<ShoppingItemModel> generateShoppingList(List<IngredientModel> rawIngredients) {
    // 1. Group by ingredient name (normalized lowercase)
    final Map<String, List<IngredientModel>> grouped = {};
    for (final ing in rawIngredients) {
      final key = ing.name.trim().toLowerCase();
      grouped.putIfAbsent(key, () => []).add(ing);
    }

    final List<ShoppingItemModel> results = [];

    for (final entry in grouped.entries) {
      final list = entry.value;
      final template = list.first;

      // Sum quantities
      double rawTotal = 0;
      for (final item in list) {
        rawTotal += item.quantity;
      }

      // Add buffer (10%-20%)
      final bufferedTotal = rawTotal * (1.0 + bufferPercentage);

      // Map to nearest market pack
      final packInfo = calculatePacks(
        bufferedAmount: bufferedTotal,
        unit: template.unit,
        standardPackSize: template.marketPackSize,
        marketPackUnit: template.marketPackUnit,
      );

      results.add(
        ShoppingItemModel(
          id: entry.key,
          name: template.name,
          category: template.category,
          rawQuantity: rawTotal,
          bufferedQuantity: bufferedTotal,
          bufferPercent: (bufferPercentage * 100).round(),
          unit: template.unit,
          packCount: packInfo.packCount,
          packSize: packInfo.packSize,
          packUnit: packInfo.packUnit,
          estimatedPrice: packInfo.estimatedPrice,
          isChecked: false,
        ),
      );
    }

    // Sort by category, then by name
    results.sort((a, b) {
      final catComp = a.category.index.compareTo(b.category.index);
      if (catComp != 0) return catComp;
      return a.name.compareTo(b.name);
    });

    return results;
  }

  /// Calculates number of market packs needed
  static MarketPackCalculation calculatePacks({
    required double bufferedAmount,
    required String unit,
    required double standardPackSize,
    required String marketPackUnit,
  }) {
    // If standardPackSize is zero or unit is count/piece
    if (standardPackSize <= 0 || unit.toLowerCase() == 'pcs' || unit.toLowerCase() == 'items') {
      final count = bufferedAmount.ceil();
      return MarketPackCalculation(
        packCount: max(1, count),
        packSize: 1,
        packUnit: unit,
        totalPurchased: max(1, count).toDouble(),
        estimatedPrice: max(1, count) * 15.0,
      );
    }

    // Number of packs = ceil(bufferedAmount / standardPackSize)
    final packCount = max(1, (bufferedAmount / standardPackSize).ceil());
    final totalPurchased = packCount * standardPackSize;

    // Approximate cost estimation per pack (₹40 - ₹120 baseline)
    final estimatedPrice = packCount * 45.0;

    return MarketPackCalculation(
      packCount: packCount,
      packSize: standardPackSize,
      packUnit: marketPackUnit,
      totalPurchased: totalPurchased,
      estimatedPrice: estimatedPrice,
    );
  }
}

class MarketPackCalculation {
  final int packCount;
  final double packSize;
  final String packUnit;
  final double totalPurchased;
  final double estimatedPrice;

  MarketPackCalculation({
    required this.packCount,
    required this.packSize,
    required this.packUnit,
    required this.totalPurchased,
    required this.estimatedPrice,
  });
}
