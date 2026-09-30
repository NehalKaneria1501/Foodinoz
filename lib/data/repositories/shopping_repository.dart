import '../models/affiliate_model.dart';
import '../models/ingredient_model.dart';
import '../models/recipe_model.dart';
import '../models/shopping_item_model.dart';
import '../services/affiliate_service.dart';
import '../../core/utils/market_pack_engine.dart';

class ShoppingRepository {
  final AffiliateService _affiliateService;
  final MarketPackEngine _engine;
  List<ShoppingItemModel> _items = [];

  ShoppingRepository({
    required this._affiliateService,
    MarketPackEngine? engine,
  })  : _engine = engine ?? const MarketPackEngine(bufferPercentage: 0.15);

  List<ShoppingItemModel> get currentItems => List.unmodifiable(_items);

  /// Generates the smart shopping list from a list of planned recipes
  Future<List<ShoppingItemModel>> generateFromRecipes(List<RecipeModel> recipes) async {
    final List<IngredientModel> allIngredients = [];
    for (final r in recipes) {
      // Exclude items already available in kitchen or Masala Kit pouches if user already has them
      for (final ing in r.ingredients) {
        if (!ing.isAvailableInKitchen) {
          allIngredients.add(ing);
        }
      }
    }

    _items = _engine.generateShoppingList(allIngredients);
    return List.unmodifiable(_items);
  }

  void updatePackCount(String itemId, int newCount) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final existing = _items[idx];
      if (newCount <= 0) {
        _items.removeAt(idx);
      } else {
        final unitPrice = existing.packCount > 0 ? (existing.estimatedPrice / existing.packCount) : 45.0;
        _items[idx] = existing.copyWith(
          packCount: newCount,
          estimatedPrice: newCount * unitPrice,
        );
      }
    }
  }

  int getItemQuantity(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    return idx != -1 ? _items[idx].packCount : 0;
  }

  void addOrIncrementItem({
    required String id,
    required String name,
    required IngredientCategory category,
    required double price,
    String unit = 'pc',
    double packSize = 1,
    String packUnit = 'pc',
  }) {
    final idx = _items.indexWhere((i) => i.id == id);
    if (idx != -1) {
      final existing = _items[idx];
      final unitPrice = existing.packCount > 0 ? (existing.estimatedPrice / existing.packCount) : price;
      _items[idx] = existing.copyWith(
        packCount: existing.packCount + 1,
        estimatedPrice: (existing.packCount + 1) * unitPrice,
      );
    } else {
      _items.add(ShoppingItemModel(
        id: id,
        name: name,
        category: category,
        rawQuantity: packSize,
        bufferedQuantity: packSize * 1.15,
        bufferPercent: 15,
        unit: unit,
        packCount: 1,
        packSize: packSize,
        packUnit: packUnit,
        estimatedPrice: price,
        isChecked: false,
      ));
    }
  }

  void decrementOrRemoveItem(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final existing = _items[idx];
      if (existing.packCount <= 1) {
        _items.removeAt(idx);
      } else {
        final unitPrice = existing.estimatedPrice / existing.packCount;
        _items[idx] = existing.copyWith(
          packCount: existing.packCount - 1,
          estimatedPrice: (existing.packCount - 1) * unitPrice,
        );
      }
    }
  }

  void toggleItemCheck(String itemId) {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx != -1) {
      final existing = _items[idx];
      _items[idx] = existing.copyWith(isChecked: !existing.isChecked);
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((i) => i.id == itemId);
  }

  void clearCart() {
    _items.clear();
  }

  void addCustomItem(ShoppingItemModel item) {
    _items.add(item);
  }

  /// Adds a single missing ingredient (from Recipe Detail screen) directly to the cart
  void addMissingIngredient(IngredientModel ingredient) {
    final existingIdx = _items.indexWhere((i) => i.id == ingredient.name.toLowerCase().trim());
    if (existingIdx != -1) {
      final existing = _items[existingIdx];
      _items[existingIdx] = existing.copyWith(packCount: existing.packCount + 1);
    } else {
      final list = _engine.generateShoppingList([ingredient]);
      if (list.isNotEmpty) {
        _items.add(list.first);
      }
    }
  }

  List<AffiliateOptionModel> getAffiliateComparison() {
    return _affiliateService.compareProviders(_items);
  }

  double getTotalCartCost() {
    double sum = 0;
    for (final it in _items) {
      sum += it.estimatedPrice;
    }
    return sum;
  }
}
