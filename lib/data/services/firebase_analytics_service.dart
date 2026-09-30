import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:flutter/foundation.dart';

/// Firebase Analytics & Installations Service.
///
/// Handles comprehensive analytics event logging, e-commerce funnel tracking,
/// user properties, custom screen views, and Firebase Installation IDs (FID).
class FirebaseAnalyticsService {
  static final FirebaseAnalyticsService instance = FirebaseAnalyticsService._();
  FirebaseAnalyticsService._();

  FirebaseAnalytics? _analytics;
  bool _initialized = false;

  /// Returns the underlying [FirebaseAnalytics] instance if available.
  FirebaseAnalytics? get analytics => _analytics;

  /// Initializes Firebase Analytics event listener pipeline.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _analytics = FirebaseAnalytics.instance;
      await _analytics?.setAnalyticsCollectionEnabled(true);
      _initialized = true;
      debugPrint('Firebase Analytics pipeline initialized successfully.');
    } catch (e) {
      debugPrint('Firebase Analytics fallback mode (headless/test): $e');
    }
  }

  // ===========================================================================
  // 1. FIREBASE INSTALLATION ID (FID) & APP INSTANCE ID
  // ===========================================================================

  /// Retrieves the Firebase Installation ID (FID) using FirebaseInstallations.
  Future<String?> getFirebaseInstallationId() async {
    try {
      final fid = await FirebaseInstallations.instance
          .getId()
          .timeout(const Duration(seconds: 3));
      debugPrint('[Installations] Firebase Installation ID: $fid');
      return fid;
    } catch (e) {
      debugPrint('[Installations] getFirebaseInstallationId notice: $e');
      return null;
    }
  }

  /// Retrieves the Firebase Analytics App Instance ID (used for DebugView and Audience export).
  Future<String?> getAppInstanceId() async {
    try {
      final appInstanceId = await _analytics?.appInstanceId
          .timeout(const Duration(seconds: 3));
      debugPrint('[Analytics] App Instance ID: $appInstanceId');
      return appInstanceId;
    } catch (e) {
      debugPrint('[Analytics] getAppInstanceId notice: $e');
      return null;
    }
  }

  /// Retrieves an Auth Installation Token for secure backend communications.
  Future<String?> getInstallationAuthToken() async {
    try {
      final token = await FirebaseInstallations.instance
          .getToken()
          .timeout(const Duration(seconds: 3));
      return token;
    } catch (e) {
      debugPrint('[Installations] getInstallationAuthToken notice: $e');
      return null;
    }
  }

  /// Dispatches a Firebase <-> GA4 linking diagnostic heartbeat event.
  /// Confirms that app instance IDs and Firebase Installation IDs (FID) are
  /// linked to the Google Analytics 4 property (556037135) and Firebase project (jeerola-eefba).
  Future<void> verifyFirebaseGa4Link() async {
    try {
      final appInstId = await getAppInstanceId();
      final fid = await getFirebaseInstallationId();

      await setDefaultEventParameters({
        'firebase_project_id': 'jeerola-eefba',
        'ga4_property_id': '556037135',
        'app_package': 'com.example.jeerola',
      });

      await logCustomEvent(
        name: 'firebase_ga4_handshake',
        parameters: {
          'firebase_project_id': 'jeerola-eefba',
          'ga4_property_id': '556037135',
          'app_instance_id': appInstId ?? 'unavailable',
          'firebase_installation_id': fid ?? 'unavailable',
          'platform': defaultTargetPlatform.name,
        },
      );
      debugPrint('🔗 [Firebase-GA4 Link] Handshake event emitted: appInstanceId=$appInstId, fid=$fid');
    } catch (e) {
      debugPrint('⚠️ [Firebase-GA4 Link] Handshake notice: $e');
    }
  }

  // ===========================================================================
  // 2. CONFIGURATION & USER ATTRIBUTES
  // ===========================================================================

  /// Sets global default event parameters attached to every logged event.
  Future<void> setDefaultEventParameters(Map<String, Object>? defaultParameters) async {
    try {
      await _analytics?.setDefaultEventParameters(defaultParameters);
      debugPrint('[Analytics] Default parameters set: $defaultParameters');
    } catch (e) {
      debugPrint('[Analytics] setDefaultEventParameters notice: $e');
    }
  }

  /// Sets user ID for cross-device reporting in GA4 & GTM.
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics?.setUserId(id: userId);
      debugPrint('[Analytics] User ID set: $userId');
    } catch (e) {
      debugPrint('[Analytics] setUserId notice: $e');
    }
  }

  /// Sets user properties (e.g. favorite_food, vegMode, etc.).
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    try {
      await _analytics?.setUserProperty(name: name, value: value);
      debugPrint('[Analytics] User property: $name = $value');
    } catch (e) {
      debugPrint('[Analytics] setUserProperty notice: $e');
    }
  }

  /// Logs a custom screen view event with custom screen class.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('[Analytics] Screen viewed: $screenName');
    } catch (e) {
      debugPrint('[Analytics] logScreenView notice: $e');
    }
  }

  // ===========================================================================
  // 3. E-COMMERCE FUNNEL TRACKING
  // ===========================================================================

  /// Logs viewing an item list / category catalog.
  Future<void> logViewItemList({
    String? itemListId,
    String? itemListName,
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics?.logViewItemList(
        itemListId: itemListId,
        itemListName: itemListName,
        items: items,
      );
      debugPrint('[Analytics] View item list: $itemListName (ID: $itemListId)');
    } catch (e) {
      debugPrint('[Analytics] logViewItemList notice: $e');
    }
  }

  /// Logs selection of an item from an item list.
  Future<void> logSelectItem({
    String? itemListId,
    String? itemListName,
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics?.logSelectItem(
        itemListId: itemListId,
        itemListName: itemListName,
        items: items,
      );
      debugPrint('[Analytics] Select item from list: $itemListName');
    } catch (e) {
      debugPrint('[Analytics] logSelectItem notice: $e');
    }
  }

  /// Logs viewing details of a specific item/product.
  Future<void> logViewItem({
    required String itemId,
    required String itemName,
    required String itemCategory,
    required double price,
    String currency = 'INR',
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics?.logViewItem(
        currency: currency,
        value: price,
        items: items ?? [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
            price: price,
            currency: currency,
          ),
        ],
      );
      debugPrint('[Analytics] Item viewed: $itemName ($currency $price)');
    } catch (e) {
      debugPrint('[Analytics] logViewItem notice: $e');
    }
  }

  /// Logs adding an item to customer wishlist.
  Future<void> logAddToWishlist({
    required List<AnalyticsEventItem> items,
    double? value,
    String currency = 'INR',
  }) async {
    try {
      await _analytics?.logAddToWishlist(
        items: items,
        value: value,
        currency: currency,
      );
      debugPrint('[Analytics] Added to wishlist: ${items.length} items');
    } catch (e) {
      debugPrint('[Analytics] logAddToWishlist notice: $e');
    }
  }

  /// Logs adding an item to the shopping cart.
  Future<void> logAddToCart({
    required String itemId,
    required String itemName,
    required String itemCategory,
    required double price,
    required int quantity,
    String? store,
    String currency = 'INR',
    List<AnalyticsEventItem>? customItems,
  }) async {
    try {
      await _analytics?.logAddToCart(
        currency: currency,
        value: price * quantity,
        items: customItems ?? [
          AnalyticsEventItem(
            itemId: itemId,
            itemName: itemName,
            itemCategory: itemCategory,
            price: price,
            quantity: quantity,
            currency: currency,
            locationId: store,
          ),
        ],
      );
      debugPrint('[Analytics] Add to cart: $itemName x$quantity');
    } catch (e) {
      debugPrint('[Analytics] logAddToCart notice: $e');
    }
  }

  /// Logs viewing the shopping cart.
  Future<void> logViewCart({
    required List<AnalyticsEventItem> items,
    double? value,
    String currency = 'INR',
  }) async {
    try {
      await _analytics?.logViewCart(
        items: items,
        value: value,
        currency: currency,
      );
      debugPrint('[Analytics] View cart: ${items.length} items, total: $value');
    } catch (e) {
      debugPrint('[Analytics] logViewCart notice: $e');
    }
  }

  /// Logs removing an item from the cart.
  Future<void> logRemoveFromCart({
    required List<AnalyticsEventItem> items,
    double? value,
    String currency = 'INR',
  }) async {
    try {
      await _analytics?.logRemoveFromCart(
        items: items,
        value: value,
        currency: currency,
      );
      debugPrint('[Analytics] Remove from cart: ${items.length} items');
    } catch (e) {
      debugPrint('[Analytics] logRemoveFromCart notice: $e');
    }
  }

  /// Logs checkout initiation (Step 1 of checkout funnel).
  Future<void> logBeginCheckout({
    required List<AnalyticsEventItem> items,
    double? value,
    String? coupon,
    String currency = 'INR',
  }) async {
    try {
      await _analytics?.logBeginCheckout(
        items: items,
        value: value,
        coupon: coupon,
        currency: currency,
      );
      debugPrint('[Analytics] Begin checkout: $value ($currency)');
    } catch (e) {
      debugPrint('[Analytics] logBeginCheckout notice: $e');
    }
  }

  /// Logs adding shipping/delivery details (Step 2 of checkout funnel).
  Future<void> logAddShippingInfo({
    required List<AnalyticsEventItem> items,
    double? value,
    String? coupon,
    String? shippingTier,
    String currency = 'INR',
  }) async {
    try {
      await _analytics?.logAddShippingInfo(
        items: items,
        value: value,
        coupon: coupon,
        shippingTier: shippingTier,
        currency: currency,
      );
      debugPrint('[Analytics] Add shipping info: $shippingTier');
    } catch (e) {
      debugPrint('[Analytics] logAddShippingInfo notice: $e');
    }
  }

  /// Logs selecting payment method (Step 3 of checkout funnel).
  Future<void> logAddPaymentInfo({
    required List<AnalyticsEventItem> items,
    double? value,
    String? coupon,
    String? paymentType,
    String currency = 'INR',
  }) async {
    try {
      await _analytics?.logAddPaymentInfo(
        items: items,
        value: value,
        coupon: coupon,
        paymentType: paymentType,
        currency: currency,
      );
      debugPrint('[Analytics] Add payment info: $paymentType');
    } catch (e) {
      debugPrint('[Analytics] logAddPaymentInfo notice: $e');
    }
  }

  /// Logs completed purchase (Conversion event).
  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required List<AnalyticsEventItem> items,
    String? affiliation = 'Jeerola Kitchen & Spices',
    String? coupon,
    double tax = 0.0,
    double shipping = 0.0,
    String currency = 'INR',
  }) async {
    try {
      await _analytics?.logPurchase(
        transactionId: transactionId,
        affiliation: affiliation,
        currency: currency,
        value: value,
        coupon: coupon,
        tax: tax,
        shipping: shipping,
        items: items,
      );
      debugPrint('[Analytics] Purchase completed: TxID $transactionId, Total: $currency $value');
    } catch (e) {
      debugPrint('[Analytics] logPurchase notice: $e');
    }
  }

  /// Logs refund transaction.
  Future<void> logRefund({
    required String transactionId,
    double? value,
    String? affiliation,
    String currency = 'INR',
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics?.logRefund(
        transactionId: transactionId,
        affiliation: affiliation,
        currency: currency,
        value: value,
        items: items,
      );
      debugPrint('[Analytics] Refund recorded: TxID $transactionId');
    } catch (e) {
      debugPrint('[Analytics] logRefund notice: $e');
    }
  }

  // ===========================================================================
  // 4. PROMOTIONS & MARKETING ENGAGEMENT
  // ===========================================================================

  /// Logs view of in-app promo banner or flash sale banner.
  Future<void> logViewPromotion({
    String? promotionId,
    String? promotionName,
    String? creativeName,
    String? creativeSlot,
    String? locationId,
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics?.logViewPromotion(
        promotionId: promotionId,
        promotionName: promotionName,
        creativeName: creativeName,
        creativeSlot: creativeSlot,
        locationId: locationId,
        items: items,
      );
      debugPrint('[Analytics] View promotion: $promotionName');
    } catch (e) {
      debugPrint('[Analytics] logViewPromotion notice: $e');
    }
  }

  /// Logs user tap on a promo banner.
  Future<void> logSelectPromotion({
    String? promotionId,
    String? promotionName,
    String? creativeName,
    String? creativeSlot,
    String? locationId,
    List<AnalyticsEventItem>? items,
  }) async {
    try {
      await _analytics?.logSelectPromotion(
        promotionId: promotionId,
        promotionName: promotionName,
        creativeName: creativeName,
        creativeSlot: creativeSlot,
        locationId: locationId,
        items: items,
      );
      debugPrint('[Analytics] Select promotion: $promotionName');
    } catch (e) {
      debugPrint('[Analytics] logSelectPromotion notice: $e');
    }
  }

  // ===========================================================================
  // 5. ENGAGEMENT & CUSTOM EVENTS
  // ===========================================================================

  /// Logs content selection (e.g. image, recipe card, story).
  Future<void> logSelectContent({
    required String contentType,
    required String itemId,
  }) async {
    try {
      await _analytics?.logSelectContent(
        contentType: contentType,
        itemId: itemId,
      );
      debugPrint('[Analytics] Select content: $contentType (ID: $itemId)');
    } catch (e) {
      debugPrint('[Analytics] logSelectContent notice: $e');
    }
  }

  /// Logs image or recipe sharing.
  Future<void> logShareImage({
    required String imageName,
    required String fullText,
  }) async {
    try {
      await _analytics?.logEvent(
        name: 'share_image',
        parameters: {
          'image_name': imageName,
          'full_text': fullText,
        },
      );
      debugPrint('[Analytics] Share image: $imageName');
    } catch (e) {
      debugPrint('[Analytics] logShareImage notice: $e');
    }
  }

  /// Logs generic custom event with parameters.
  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );
      debugPrint('[Analytics] Custom event: $name -> $parameters');
    } catch (e) {
      debugPrint('[Analytics] logCustomEvent notice: $e');
    }
  }
}
