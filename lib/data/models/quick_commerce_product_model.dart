import 'ingredient_model.dart';

enum QuickCommerceStore {
  zepto,
  blinkit,
  swiggyInstamart,
  bigBasket,
  jioMart,
  dmartReady,
  jeerolaKitchen,
}

extension QuickCommerceStoreExtension on QuickCommerceStore {
  String get displayName {
    switch (this) {
      case QuickCommerceStore.zepto:
        return 'Zepto';
      case QuickCommerceStore.blinkit:
        return 'Blinkit';
      case QuickCommerceStore.swiggyInstamart:
        return 'Swiggy Instamart';
      case QuickCommerceStore.bigBasket:
        return 'BigBasket BBNow';
      case QuickCommerceStore.jioMart:
        return 'JioMart';
      case QuickCommerceStore.dmartReady:
        return 'DMart Ready';
      case QuickCommerceStore.jeerolaKitchen:
        return 'Jeerola Kitchen';
    }
  }

  String get deliveryTimeText {
    switch (this) {
      case QuickCommerceStore.zepto:
        return '⚡ 10 MINS';
      case QuickCommerceStore.blinkit:
        return '⚡ 12 MINS';
      case QuickCommerceStore.swiggyInstamart:
        return '⚡ 15 MINS';
      case QuickCommerceStore.bigBasket:
        return '⚡ 25 MINS';
      case QuickCommerceStore.jioMart:
        return '📦 35 MINS';
      case QuickCommerceStore.dmartReady:
        return '📦 60 MINS';
      case QuickCommerceStore.jeerolaKitchen:
        return '⚡ 20 MINS';
    }
  }

  int get brandColorHex {
    switch (this) {
      case QuickCommerceStore.zepto:
        return 0xFF9C27B0; // Zepto Purple
      case QuickCommerceStore.blinkit:
        return 0xFFF8CB46; // Blinkit Yellow
      case QuickCommerceStore.swiggyInstamart:
        return 0xFFFC8019; // Swiggy Orange
      case QuickCommerceStore.bigBasket:
        return 0xFF84C225; // BigBasket Green
      case QuickCommerceStore.jioMart:
        return 0xFF0078AD; // JioMart Blue
      case QuickCommerceStore.dmartReady:
        return 0xFF008848; // DMart Green
      case QuickCommerceStore.jeerolaKitchen:
        return 0xFFE64A19; // Jeerola Paprika Red
    }
  }
}

class QuickCommerceProductModel {
  final String id;
  final String title;
  final String brand;
  final String packSize;
  final double mrp;
  final double discountPrice;
  final String imageUrl;
  final QuickCommerceStore store;
  final IngredientCategory category;
  final String badgeText;
  final bool isVeg;
  final bool isJainFriendly;
  final double rating;
  final int reviewsCount;
  final String? chefSpecialTag;
  final String description;

  const QuickCommerceProductModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.packSize,
    required this.mrp,
    required this.discountPrice,
    required this.imageUrl,
    required this.store,
    required this.category,
    this.description = 'Farm-fresh premium quality ingredients curated for authentic restaurant taste.',
    this.badgeText = '',
    this.isVeg = true,
    this.isJainFriendly = false,
    this.rating = 4.8,
    this.reviewsCount = 420,
    this.chefSpecialTag,
  });

  int get discountPercentage => mrp > discountPrice
      ? (((mrp - discountPrice) / mrp) * 100).round()
      : 0;

  double get savingsAmount => mrp > discountPrice ? (mrp - discountPrice) : 0;
}
