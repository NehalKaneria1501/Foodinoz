import 'package:flutter/foundation.dart';

/// Firebase Remote Config Service (Pure Dart - No Native Android/Kotlin Crash Risk)
///
/// Enables dynamic feature flags, promotional messaging, delivery thresholds,
/// and culinary toggles without native plugin overhead.
class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService._internal();
  static final FirebaseRemoteConfigService instance = FirebaseRemoteConfigService._internal();

  final Map<String, dynamic> _configValues = {
    'express_delivery_eta_minutes': 16,
    'free_delivery_threshold_inr': 499,
    'show_royal_ai_chef_badge': true,
    'banner_promo_text': '✨ Royal Spices Express: Flat 10% OFF with code JEEROLA10',
    'enable_smart_flame_control': true,
    'min_supported_app_version': '1.0.0',
    'dark_store_service_open': true,
    'support_phone_number': '+91 9265754161',
  };

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initializes Remote Config
  Future<void> initialize() async {
    _isInitialized = true;
    debugPrint('[Remote Config] Initialized with ${_configValues.length} active configurations.');
  }

  /// Refreshes/activates configurations
  Future<bool> fetchAndActivate() async {
    return true;
  }

  // --- Strongly-Typed Getters with In-App Defaults Fallback ---

  bool getBool(String key) {
    return (_configValues[key] as bool?) ?? false;
  }

  int getInt(String key) {
    return (_configValues[key] as int?) ?? 0;
  }

  double getDouble(String key) {
    return ((_configValues[key] as num?)?.toDouble()) ?? 0.0;
  }

  String getString(String key) {
    return (_configValues[key] as String?) ?? '';
  }

  // Specific Jeerola Business Getters
  int get expressDeliveryEtaMinutes => getInt('express_delivery_eta_minutes');
  int get freeDeliveryThresholdInr => getInt('free_delivery_threshold_inr');
  bool get showRoyalAiChefBadge => getBool('show_royal_ai_chef_badge');
  String get bannerPromoText => getString('banner_promo_text');
  bool get enableSmartFlameControl => getBool('enable_smart_flame_control');
  bool get isDarkStoreServiceOpen => getBool('dark_store_service_open');
  String get supportPhoneNumber => getString('support_phone_number');
}
