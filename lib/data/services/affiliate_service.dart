import '../models/affiliate_model.dart';
import '../models/shopping_item_model.dart';

class AffiliateService {
  /// Compares grocery delivery platforms based on the current shopping list items
  List<AffiliateOptionModel> compareProviders(List<ShoppingItemModel> items) {
    if (items.isEmpty) return [];

    double subtotal = 0;
    for (final it in items) {
      subtotal += it.estimatedPrice;
    }

    // 1. Zepto: ultra-fast 10 min, highest coverage
    final zepto = AffiliateOptionModel(
      providerId: 'zepto',
      name: 'Zepto',
      logoUrl: 'https://cdn.worldvectorlogo.com/logos/zepto.svg',
      coveragePercentage: 99.0,
      missingItemCount: 0,
      totalCost: (subtotal * 1.02).roundToDouble(),
      deliveryTimeMinutes: 10,
      isRecommended: true,
      redirectUrl: 'https://zeptonow.com',
      deliveryFeeText: 'FREE Delivery (Above ₹199)',
      tagline: 'Lightning fast 10-minute door-to-door delivery',
      badgeText: 'LOGIC CHOICE // FASTEST',
      accentColorValue: 0xFF9C27B0,
    );

    // 2. Blinkit: 12 min quick commerce
    final blinkit = AffiliateOptionModel(
      providerId: 'blinkit',
      name: 'Blinkit',
      logoUrl: 'https://cdn.worldvectorlogo.com/logos/blinkit.svg',
      coveragePercentage: 98.0,
      missingItemCount: 1,
      totalCost: (subtotal * 0.98).roundToDouble(),
      deliveryTimeMinutes: 12,
      isRecommended: false,
      redirectUrl: 'https://blinkit.com',
      deliveryFeeText: '₹15 Handling Fee',
      tagline: 'Rapid 12-min delivery with trusted fresh stock',
      badgeText: 'POPULAR CHOICE',
      accentColorValue: 0xFFF8CB46,
    );

    // 3. Swiggy Instamart: 15 min lightning grocery & pantry drop
    final swiggyInstamart = AffiliateOptionModel(
      providerId: 'swiggy_instamart',
      name: 'Swiggy Instamart',
      logoUrl: 'https://cdn.worldvectorlogo.com/logos/swiggy-1.svg',
      coveragePercentage: 98.0,
      missingItemCount: 0,
      totalCost: (subtotal * 0.97).roundToDouble(),
      deliveryTimeMinutes: 15,
      isRecommended: false,
      redirectUrl: 'https://www.swiggy.com/instamart',
      deliveryFeeText: 'FREE Delivery (Above ₹149)',
      tagline: 'Instant groceries & kitchen staples in 15 mins',
      badgeText: 'HOT 15-MIN DROP',
      accentColorValue: 0xFFFC8019,
    );

    // 4. BigBasket BBNow: wide supermarket variety
    final bigBasket = AffiliateOptionModel(
      providerId: 'bigbasket',
      name: 'BigBasket BBNow',
      logoUrl: 'https://cdn.worldvectorlogo.com/logos/bigbasket.svg',
      coveragePercentage: 96.0,
      missingItemCount: 1,
      totalCost: (subtotal * 0.94).roundToDouble(),
      deliveryTimeMinutes: 25,
      isRecommended: false,
      redirectUrl: 'https://www.bigbasket.com',
      deliveryFeeText: 'FREE Delivery',
      tagline: 'Comprehensive supermarket & fresh farm produce',
      badgeText: 'COMPLETE PANTRY',
      accentColorValue: 0xFF84C225,
    );

    // 5. JioMart: high savings on daily essentials
    final jioMart = AffiliateOptionModel(
      providerId: 'jiomart',
      name: 'JioMart',
      logoUrl: 'https://www.jiomart.com/assets/version1/images/jiomart-logo.svg',
      coveragePercentage: 95.0,
      missingItemCount: 2,
      totalCost: (subtotal * 0.90).roundToDouble(),
      deliveryTimeMinutes: 35,
      isRecommended: false,
      redirectUrl: 'https://www.jiomart.com',
      deliveryFeeText: 'FREE Delivery (Above ₹250)',
      tagline: 'Best bulk grocery savings & daily staples',
      badgeText: 'BULK SAVINGS',
      accentColorValue: 0xFF0078AD,
    );

    // 6. DMart Ready: lowest market price leader
    final dmartReady = AffiliateOptionModel(
      providerId: 'dmart',
      name: 'DMart Ready',
      logoUrl: 'https://www.dmart.in/assets/images/dmart-logo.svg',
      coveragePercentage: 97.0,
      missingItemCount: 1,
      totalCost: (subtotal * 0.86).roundToDouble(),
      deliveryTimeMinutes: 60,
      isRecommended: false,
      redirectUrl: 'https://www.dmart.in',
      deliveryFeeText: 'Pick-up FREE / ₹49 Delivery',
      tagline: 'Guaranteed lowest wholesale prices on staples',
      badgeText: 'BEST VALUE GUARANTEED',
      accentColorValue: 0xFF008848,
    );

    return [zepto, blinkit, swiggyInstamart, bigBasket, jioMart, dmartReady];
  }
}
