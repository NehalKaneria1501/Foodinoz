import 'package:flutter/material.dart';
import '../../../../data/models/affiliate_model.dart';
import '../../../../data/models/ingredient_model.dart';
import '../../../../data/models/shopping_item_model.dart';
import '../../../../data/repositories/meal_plan_repository.dart';
import '../../../../data/repositories/shopping_repository.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final ShoppingRepository _shoppingRepository;
  final MealPlanRepository _mealPlanRepository;

  ShoppingListViewModel({
    required this._shoppingRepository,
    required this._mealPlanRepository,
  }) {
    _initShoppingList();
  }

  List<ShoppingItemModel> _items = [];
  List<AffiliateOptionModel> _affiliateOptions = [];
  bool _isLoading = false;

  List<ShoppingItemModel> get items => _items;
  List<AffiliateOptionModel> get affiliateOptions => _affiliateOptions;
  bool get isLoading => _isLoading;

  /// Returns items grouped by category
  Map<IngredientCategory, List<ShoppingItemModel>> get groupedItems {
    final Map<IngredientCategory, List<ShoppingItemModel>> map = {};
    for (final item in _items) {
      map.putIfAbsent(item.category, () => []).add(item);
    }
    return map;
  }

  double get totalCartCost => _shoppingRepository.getTotalCartCost();

  int get totalItemCount => _items.length;

  int get completedItemCount => _items.where((i) => i.isChecked).length;

  Future<void> _initShoppingList() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = _shoppingRepository.currentItems;
      _affiliateOptions = _items.isEmpty ? [] : _shoppingRepository.getAffiliateComparison();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearCart() {
    _shoppingRepository.clearCart();
    _items = [];
    _affiliateOptions = [];
    notifyListeners();
  }

  Future<void> regenerateFromActivePlan() async {
    _isLoading = true;
    notifyListeners();

    try {
      final recipes = _mealPlanRepository.getAllPlannedRecipes();
      _items = await _shoppingRepository.generateFromRecipes(recipes);
      _affiliateOptions = _shoppingRepository.getAffiliateComparison();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updatePackCount(String itemId, int count) {
    _shoppingRepository.updatePackCount(itemId, count);
    _items = _shoppingRepository.currentItems;
    _affiliateOptions = _shoppingRepository.getAffiliateComparison();
    notifyListeners();
  }

  int getItemQuantity(String itemId) {
    return _shoppingRepository.getItemQuantity(itemId);
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
    _shoppingRepository.addOrIncrementItem(
      id: id,
      name: name,
      category: category,
      price: price,
      unit: unit,
      packSize: packSize,
      packUnit: packUnit,
    );
    _items = _shoppingRepository.currentItems;
    _affiliateOptions = _shoppingRepository.getAffiliateComparison();
    notifyListeners();
  }

  void decrementOrRemoveItem(String itemId) {
    _shoppingRepository.decrementOrRemoveItem(itemId);
    _items = _shoppingRepository.currentItems;
    _affiliateOptions = _shoppingRepository.getAffiliateComparison();
    notifyListeners();
  }

  void toggleItemCheck(String itemId) {
    _shoppingRepository.toggleItemCheck(itemId);
    _items = _shoppingRepository.currentItems;
    notifyListeners();
  }

  void removeItem(String itemId) {
    _shoppingRepository.removeItem(itemId);
    _items = _shoppingRepository.currentItems;
    _affiliateOptions = _shoppingRepository.getAffiliateComparison();
    notifyListeners();
  }

  void addMissingIngredient(IngredientModel ingredient) {
    _shoppingRepository.addMissingIngredient(ingredient);
    _items = _shoppingRepository.currentItems;
    _affiliateOptions = _shoppingRepository.getAffiliateComparison();
    notifyListeners();
  }

  void addCustomItem({
    required String name,
    required IngredientCategory category,
    required double quantity,
    required String unit,
    required double estimatedPrice,
    int packCount = 1,
  }) {
    final newItem = ShoppingItemModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      category: category,
      rawQuantity: quantity,
      bufferedQuantity: quantity * 1.15,
      bufferPercent: 15,
      unit: unit,
      packCount: packCount,
      packSize: quantity,
      packUnit: unit,
      estimatedPrice: estimatedPrice,
      isChecked: false,
    );
    _shoppingRepository.addCustomItem(newItem);
    _items = _shoppingRepository.currentItems;
    _affiliateOptions = _shoppingRepository.getAffiliateComparison();
    notifyListeners();
  }
}
