// ignore_for_file: use_null_aware_elements
import 'package:flutter/foundation.dart';
import 'firebase_analytics_service.dart';

/// Meta (Facebook & Instagram Ads) Attribution Data
class MetaAttributionData {
  final String? fbclid; // Facebook Click Identifier
  final String? fbp; // Facebook Browser ID (_fbp)
  final String? fbc; // Facebook Click ID (_fbc)
  final String platform; // facebook, instagram, messenger, whatsapp
  final String? campaign;
  final String? adset;
  final String? ad;

  const MetaAttributionData({
    this.fbclid,
    this.fbp,
    this.fbc,
    this.platform = 'facebook',
    this.campaign,
    this.adset,
    this.ad,
  });

  bool get isMetaClick => fbclid != null || platform.contains('facebook') || platform.contains('instagram');

  Map<String, Object> toParameterMap() => {
        if (fbclid != null) 'fbclid': fbclid!,
        if (fbp != null) 'fbp': fbp!,
        if (fbc != null) 'fbc': fbc!,
        'meta_platform': platform,
        if (campaign != null) 'meta_campaign': campaign!,
        if (adset != null) 'meta_adset': adset!,
        if (ad != null) 'meta_ad': ad!,
      };
}

/// Meta Ads (Facebook & Instagram) Integration Service
///
/// Connects Meta Ads acquisition campaigns (Facebook Feed, Instagram Reels, Stories)
/// with Google Analytics 4 (GA4) cross-channel attribution and e-commerce telemetry.
class MetaAdsService {
  MetaAdsService._();
  static final MetaAdsService instance = MetaAdsService._();

  MetaAttributionData? _activeAttribution;
  MetaAttributionData? get activeAttribution => _activeAttribution;

  /// Handles incoming deep links or referral parameters from Facebook & Instagram ads
  Future<void> handleIncomingMetaReferral(Map<String, String> queryParameters) async {
    final fbclid = queryParameters['fbclid'];
    final utmSource = (queryParameters['utm_source'] ?? '').toLowerCase();
    final utmCampaign = queryParameters['utm_campaign'];
    final utmContent = queryParameters['utm_content']; // Ad creative
    final utmTerm = queryParameters['utm_term']; // Ad set

    final isFromMeta = fbclid != null ||
        utmSource.contains('facebook') ||
        utmSource.contains('instagram') ||
        utmSource.contains('meta');

    if (isFromMeta) {
      final platform = utmSource.contains('instagram') ? 'instagram' : 'facebook';

      _activeAttribution = MetaAttributionData(
        fbclid: fbclid,
        platform: platform,
        campaign: utmCampaign,
        adset: utmTerm,
        ad: utmContent,
      );

      debugPrint('📲 [Meta Ads] Attributed click: platform=$platform, fbclid=$fbclid, campaign=$utmCampaign');

      // Attach Meta attribution parameters across all subsequent GA4 events
      await FirebaseAnalyticsService.instance.setDefaultEventParameters({
        'traffic_medium': 'cpc',
        'traffic_source': platform,
        if (fbclid != null) 'fbclid': fbclid,
        if (utmCampaign != null) 'campaign': utmCampaign,
      });

      // Log the landing event to GA4
      FirebaseAnalyticsService.instance.logCustomEvent(
        name: 'meta_ad_landing',
        parameters: _activeAttribution!.toParameterMap(),
      );
    }
  }

  /// Maps and tracks a standard Meta E-Commerce event in GA4
  void trackMetaStandardEvent({
    required String eventName, // ViewContent, AddToCart, InitiateCheckout, Purchase
    Map<String, Object>? parameters,
  }) {
    debugPrint('📊 [Meta Event] Standard event logged: $eventName');
    final combined = <String, Object>{
      'meta_event_name': eventName,
      ...?parameters,
      if (_activeAttribution != null) ..._activeAttribution!.toParameterMap(),
    };

    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'meta_${eventName.toLowerCase()}',
      parameters: combined,
    );
  }

  /// Decorates e-commerce conversion events with Meta Click ID (fbclid) for cross-channel attribution
  Map<String, Object> decorateWithMetaAttribution(Map<String, Object> baseParameters) {
    if (_activeAttribution != null) {
      return {
        ...baseParameters,
        ..._activeAttribution!.toParameterMap(),
      };
    }
    return baseParameters;
  }
}
