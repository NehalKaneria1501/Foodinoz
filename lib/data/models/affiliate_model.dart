class AffiliateOptionModel {
  final String providerId; // zepto, blinkit, bigbasket, jiomart, dmart
  final String name; // Zepto, Blinkit, BigBasket BBNow, JioMart, DMart Ready
  final String logoUrl;
  final double coveragePercentage; // e.g. 98.5%
  final int missingItemCount;
  final double totalCost;
  final int deliveryTimeMinutes; // e.g. 10 mins, 12 mins, 45 mins
  final bool isRecommended; // "LOGIC CHOICE"
  final String redirectUrl;
  final String deliveryFeeText;
  final String tagline;
  final String badgeText;
  final int accentColorValue;

  const AffiliateOptionModel({
    required this.providerId,
    required this.name,
    required this.logoUrl,
    required this.coveragePercentage,
    required this.missingItemCount,
    required this.totalCost,
    required this.deliveryTimeMinutes,
    required this.isRecommended,
    required this.redirectUrl,
    this.deliveryFeeText = 'FREE Delivery',
    this.tagline = '',
    this.badgeText = '',
    this.accentColorValue = 0xFF2D5A27,
  });

  String get estimatedDeliveryTime => deliveryTimeMinutes >= 60
      ? '${(deliveryTimeMinutes / 60).toStringAsFixed(0)} hrs'
      : '$deliveryTimeMinutes mins';
}
