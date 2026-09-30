import 'recipe_model.dart' show RecipeLanguage;

enum IngredientCategory {
  fastFood,
  pastry,
  cake,
  biscuit,
  bakery,
  beverages,
  sweets,
  faraliSpecial,
  namkeenFarshan,
  vegetables,
  dairy,
  grains,
  spices,
  meat,
  pantry,
}

extension IngredientCategoryExt on IngredientCategory {
  String get displayName {
    switch (this) {
      case IngredientCategory.fastFood:
        return 'Fast Foods & Snacks';
      case IngredientCategory.pastry:
        return 'Pastries & Desserts';
      case IngredientCategory.cake:
        return 'Cakes';
      case IngredientCategory.biscuit:
        return 'Biscuits & Cookies';
      case IngredientCategory.bakery:
        return 'Bakery Essentials';
      case IngredientCategory.beverages:
        return 'Beverages & Drinks';
      case IngredientCategory.sweets:
        return 'Mithai & Sweets';
      case IngredientCategory.faraliSpecial:
        return 'Farali & Vrat Special';
      case IngredientCategory.namkeenFarshan:
        return 'Namkeen & Farsan';
      case IngredientCategory.vegetables:
        return 'Vegetables & Fresh Produce';
      case IngredientCategory.dairy:
        return 'Dairy & Refrigerated';
      case IngredientCategory.grains:
        return 'Grains & Pulses';
      case IngredientCategory.spices:
        return 'Spices & Seasonings';
      case IngredientCategory.meat:
        return 'Meat & Seafood';
      case IngredientCategory.pantry:
        return 'Oils & Pantry Staples';
    }
  }

  String getDisplayName(RecipeLanguage lang) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        switch (this) {
          case IngredientCategory.fastFood:
            return 'ફાસ્ટ ફૂડ અને નાસ્તો';
          case IngredientCategory.pastry:
            return 'પેસ્ટ્રી અને ડેઝર્ટ';
          case IngredientCategory.cake:
            return 'કેક';
          case IngredientCategory.biscuit:
            return 'બિસ્કિટ અને કુકીઝ';
          case IngredientCategory.bakery:
            return 'બેકરી ઉત્પાદનો';
          case IngredientCategory.beverages:
            return 'પીણાં અને શરબત';
          case IngredientCategory.sweets:
            return 'મીઠાઈ';
          case IngredientCategory.faraliSpecial:
            return 'ફરાળી સ્પેશિયલ';
          case IngredientCategory.namkeenFarshan:
            return 'નમકીન અને ફરસાણ';
          case IngredientCategory.vegetables:
            return 'શાકભાજી અને તાજા ઉત્પાદનો';
          case IngredientCategory.dairy:
            return 'ડેરી અને દૂધની બનાવટો';
          case IngredientCategory.grains:
            return 'અનાજ અને કઠોળ';
          case IngredientCategory.spices:
            return 'મસાલા અને તેજાના';
          case IngredientCategory.meat:
            return 'નોન-વેજ પ્રોડક્ટ્સ';
          case IngredientCategory.pantry:
            return 'તેલ અને રસોડાની સામગ્રી';
        }
      case RecipeLanguage.hindi:
        switch (this) {
          case IngredientCategory.fastFood:
            return 'फास्ट फूड और नाश्ता';
          case IngredientCategory.pastry:
            return 'पेस्ट्री और डेसर्ट';
          case IngredientCategory.cake:
            return 'केक';
          case IngredientCategory.biscuit:
            return 'बिस्कुट और कुकीज़';
          case IngredientCategory.bakery:
            return 'बेकरी उत्पाद';
          case IngredientCategory.beverages:
            return 'पेय और शरबत';
          case IngredientCategory.sweets:
            return 'मिठाई';
          case IngredientCategory.faraliSpecial:
            return 'फराली स्पेशल';
          case IngredientCategory.namkeenFarshan:
            return 'नमकीन और फरसाण';
          case IngredientCategory.vegetables:
            return 'सब्जियां और ताज़ा उपज';
          case IngredientCategory.dairy:
            return 'डेयरी उत्पाद';
          case IngredientCategory.grains:
            return 'अनाज और दालें';
          case IngredientCategory.spices:
            return 'मसाले और सामग्री';
          case IngredientCategory.meat:
            return 'मांस व सीफूड';
          case IngredientCategory.pantry:
            return 'तेल और रसोई का सामान';
        }
      case RecipeLanguage.english:
        return displayName;
    }
  }
}

class IngredientModel {
  final String id;
  final String name;
  final double quantity;
  final String unit; // g, ml, pcs, tbsp, etc.
  final IngredientCategory category;
  final double marketPackSize; // e.g. 500 (for 500g)
  final String marketPackUnit; // e.g. 'g', 'kg', 'ml', 'pcs'
  final bool isAvailableInKitchen; // Checkbox state for user's pantry

  // Multilingual Names
  final String? nameGujarati;
  final String? nameHindi;

  const IngredientModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    this.marketPackSize = 500.0,
    this.marketPackUnit = 'g',
    this.isAvailableInKitchen = false,
    this.nameGujarati,
    this.nameHindi,
  });

  String getName([RecipeLanguage lang = RecipeLanguage.english]) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        return (nameGujarati != null && nameGujarati!.isNotEmpty) ? nameGujarati! : name;
      case RecipeLanguage.hindi:
        return (nameHindi != null && nameHindi!.isNotEmpty) ? nameHindi! : name;
      case RecipeLanguage.english:
        return name;
    }
  }

  String getUnit([RecipeLanguage lang = RecipeLanguage.english]) {
    switch (lang) {
      case RecipeLanguage.gujarati:
        switch (unit.toLowerCase()) {
          case 'g':
            return 'ગ્રા.';
          case 'kg':
            return 'કિગ્રા.';
          case 'ml':
            return 'મિલી.';
          case 'l':
          case 'liter':
            return 'લિટર';
          case 'pcs':
          case 'pc':
            return 'નંગ';
          case 'tbsp':
            return 'મોટી ચમચી';
          case 'tsp':
            return 'નાની ચમચી';
          case 'pouch':
            return 'પાઉચ';
          default:
            return unit;
        }
      case RecipeLanguage.hindi:
        switch (unit.toLowerCase()) {
          case 'g':
            return 'ग्रा.';
          case 'kg':
            return 'किग्रा.';
          case 'ml':
            return 'मिली.';
          case 'l':
          case 'liter':
            return 'लीटर';
          case 'pcs':
          case 'pc':
            return 'नग';
          case 'tbsp':
            return 'बड़ा चम्मच';
          case 'tsp':
            return 'छोटा चम्मच';
          case 'pouch':
            return 'पाउच';
          default:
            return unit;
        }
      case RecipeLanguage.english:
        return unit;
    }
  }

  IngredientModel copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    IngredientCategory? category,
    double? marketPackSize,
    String? marketPackUnit,
    bool? isAvailableInKitchen,
    String? nameGujarati,
    String? nameHindi,
  }) {
    return IngredientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      marketPackSize: marketPackSize ?? this.marketPackSize,
      marketPackUnit: marketPackUnit ?? this.marketPackUnit,
      isAvailableInKitchen: isAvailableInKitchen ?? this.isAvailableInKitchen,
      nameGujarati: nameGujarati ?? this.nameGujarati,
      nameHindi: nameHindi ?? this.nameHindi,
    );
  }
}
