import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'firebase_analytics_service.dart';

/// Google Play In-App Product / Subscription Type
enum PlayProductType { inApp, subscription }

/// Google Play Catalog Item
class PlayProductItem {
  final String sku;
  final String title;
  final String description;
  final double price;
  final String currency;
  final PlayProductType type;

  const PlayProductItem({
    required this.sku,
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'INR',
    this.type = PlayProductType.inApp,
  });
}

/// Google Play & Play Billing Integration Service
///
/// Handles Google Play Store product tracking, in-app billing telemetry,
/// subscription lifecycle reporting, and Play Store review intents for GA4.
class GooglePlayService {
  GooglePlayService._();
  static final GooglePlayService instance = GooglePlayService._();

  static const String packageName = 'com.example.jeerola';

  /// Standard Google Play In-App Catalog Products
  final List<PlayProductItem> catalog = const [
    PlayProductItem(
      sku: 'jcoins_pack_100',
      title: '100 Jeerola J-Coins',
      description: 'In-app spice rewards & instant discount coins',
      price: 99.0,
      type: PlayProductType.inApp,
    ),
    PlayProductItem(
      sku: 'jcoins_pack_500',
      title: '500 Jeerola J-Coins',
      description: 'Mega spice saver pack with bonus spices',
      price: 399.0,
      type: PlayProductType.inApp,
    ),
    PlayProductItem(
      sku: 'jeerola_vip_membership_monthly',
      title: 'Jeerola Chef Club VIP (Monthly)',
      description: 'Free express dark store delivery + exclusive royal recipes',
      price: 199.0,
      type: PlayProductType.subscription,
    ),
    PlayProductItem(
      sku: 'spice_box_quarterly_sub',
      title: 'Quarterly Artisan Spice Box Subscription',
      description: 'Curated 6 freshly roasted spice pouches delivered every 3 months',
      price: 699.0,
      type: PlayProductType.subscription,
    ),
  ];

  /// Tracks a completed Google Play in-app purchase (IAP) in GA4
  void trackPlayPurchase({
    required String orderId, // Format: GPA.1234-5678-9012-34567
    required PlayProductItem product,
    int quantity = 1,
  }) {
    debugPrint('🎮 [Google Play] In-app purchase tracked: ${product.sku} (Order: $orderId)');
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'in_app_purchase',
      parameters: {
        'product_id': product.sku,
        'product_name': product.title,
        'value': product.price * quantity,
        'currency': product.currency,
        'quantity': quantity,
        'order_id': orderId,
        'payment_platform': 'google_play_billing',
      },
    );
  }

  /// Tracks when a customer converts into a paid Google Play subscription
  void trackSubscriptionConvert({
    required PlayProductItem subscription,
    required String orderId,
  }) {
    debugPrint('🎟️ [Google Play] Subscription converted: ${subscription.sku}');
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'app_store_subscription_convert',
      parameters: {
        'subscription_id': subscription.sku,
        'subscription_name': subscription.title,
        'value': subscription.price,
        'currency': subscription.currency,
        'order_id': orderId,
        'platform': 'google_play',
      },
    );
  }

  /// Tracks when a recurring Google Play subscription renews
  void trackSubscriptionRenew({
    required PlayProductItem subscription,
    required int renewalCount,
  }) {
    debugPrint('🔄 [Google Play] Subscription renewed: ${subscription.sku} (#$renewalCount)');
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'app_store_subscription_renew',
      parameters: {
        'subscription_id': subscription.sku,
        'renewal_count': renewalCount,
        'value': subscription.price,
        'currency': subscription.currency,
        'platform': 'google_play',
      },
    );
  }

  /// Tracks when a customer cancels a Google Play subscription
  void trackSubscriptionCancel({
    required PlayProductItem subscription,
    String reason = 'user_cancelled',
  }) {
    debugPrint('⚠️ [Google Play] Subscription cancelled: ${subscription.sku}');
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'app_store_subscription_cancel',
      parameters: {
        'subscription_id': subscription.sku,
        'cancellation_reason': reason,
        'platform': 'google_play',
      },
    );
  }

  /// Opens the Google Play Store listing for rating and reviews
  Future<void> openPlayStoreListing() async {
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'open_play_store_listing',
      parameters: {'package_name': packageName},
    );

    final marketUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  /// Tracks Google Play Install Referrer attribution parameters
  Future<void> trackPlayInstallReferrer({
    required String utmSource,
    required String utmMedium,
    required String utmCampaign,
    String? gclid,
  }) async {
    debugPrint('📲 [Google Play] Install referrer tracked: $utmSource / $utmCampaign');
    await FirebaseAnalyticsService.instance.setDefaultEventParameters({
      'install_source': utmSource,
      'install_campaign': utmCampaign,
    });

    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'play_install_referrer',
      parameters: {
        'utm_source': utmSource,
        'utm_medium': utmMedium,
        'utm_campaign': utmCampaign,
        // ignore: use_null_aware_elements
        if (gclid != null) 'gclid': gclid,
      },
    );
  }
}
