import 'ingredient_model.dart';

class ShoppingItemModel {
  final String id;
  final String name;
  final IngredientCategory category;
  final double rawQuantity;
  final double bufferedQuantity;
  final int bufferPercent; // e.g. 15 for +15%
  final String unit;
  final int packCount;
  final double packSize;
  final String packUnit;
  final double estimatedPrice;
  final bool isChecked;

  const ShoppingItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rawQuantity,
    required this.bufferedQuantity,
    required this.bufferPercent,
    required this.unit,
    required this.packCount,
    required this.packSize,
    required this.packUnit,
    required this.estimatedPrice,
    this.isChecked = false,
  });

  /// Displays human-readable pack description e.g. "2 packs × 500g (1000g)"
  String get packDescription {
    if (packSize <= 1 && (packUnit == 'pcs' || packUnit == 'items')) {
      return '$packCount ${packCount == 1 ? 'pc' : 'pcs'}';
    }
    final totalWeight = packCount * packSize;
    if (totalWeight >= 1000 && packUnit == 'g') {
      return '$packCount × ${(packSize / 1000).toStringAsFixed(1)}kg (${(totalWeight / 1000).toStringAsFixed(1)}kg)';
    }
    return '$packCount × ${packSize.toInt()}$packUnit (${totalWeight.toInt()}$packUnit)';
  }

  ShoppingItemModel copyWith({
    String? id,
    String? name,
    IngredientCategory? category,
    double? rawQuantity,
    double? bufferedQuantity,
    int? bufferPercent,
    String? unit,
    int? packCount,
    double? packSize,
    String? packUnit,
    double? estimatedPrice,
    bool? isChecked,
  }) {
    return ShoppingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      rawQuantity: rawQuantity ?? this.rawQuantity,
      bufferedQuantity: bufferedQuantity ?? this.bufferedQuantity,
      bufferPercent: bufferPercent ?? this.bufferPercent,
      unit: unit ?? this.unit,
      packCount: packCount ?? this.packCount,
      packSize: packSize ?? this.packSize,
      packUnit: packUnit ?? this.packUnit,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}
