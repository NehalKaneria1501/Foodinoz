// ignore_for_file: use_null_aware_elements
import 'package:flutter/foundation.dart';
import 'firebase_analytics_service.dart';

/// TikTok Ads Attribution Model
class TikTokAttributionData {
  final String? ttclid; // TikTok Click ID
  final String? campaign; // Campaign name
  final String? adGroupId; // Ad Group ID
  final String? creativeId; // Creative ID

  const TikTokAttributionData({
    this.ttclid,
    this.campaign,
    this.adGroupId,
    this.creativeId,
  });

  bool get isTikTokClick => ttclid != null || (campaign != null && campaign!.isNotEmpty);

  Map<String, Object> toParameterMap() => {
        if (ttclid != null) 'ttclid': ttclid!,
        if (campaign != null) 'tiktok_campaign': campaign!,
        if (adGroupId != null) 'tiktok_adgroup_id': adGroupId!,
        if (creativeId != null) 'tiktok_creative_id': creativeId!,
        'traffic_source': 'tiktok',
        'traffic_medium': 'cpc',
      };
}

/// TikTok Ads Integration Service
///
/// Connects TikTok Ads (TikTok Feed, Spark Ads, Video Shopping Ads)
/// with Google Analytics 4 (GA4) cross-channel attribution and e-commerce telemetry.
class TikTokAdsService {
  TikTokAdsService._();
  static final TikTokAdsService instance = TikTokAdsService._();

  TikTokAttributionData? _activeAttribution;
  TikTokAttributionData? get activeAttribution => _activeAttribution;

  /// Handles incoming deep links or referral parameters originating from TikTok Ads
  Future<void> handleIncomingTikTokReferral(Map<String, String> queryParameters) async {
    final ttclid = queryParameters['ttclid'];
    final utmSource = (queryParameters['utm_source'] ?? '').toLowerCase();
    final utmCampaign = queryParameters['utm_campaign'];
    final utmContent = queryParameters['utm_content']; // Creative ID
    final utmTerm = queryParameters['utm_term']; // Ad Group ID

    final isFromTikTok = ttclid != null || utmSource.contains('tiktok');

    if (isFromTikTok) {
      _activeAttribution = TikTokAttributionData(
        ttclid: ttclid,
        campaign: utmCampaign,
        adGroupId: utmTerm,
        creativeId: utmContent,
      );

      debugPrint('🎵 [TikTok Ads] Attributed click: ttclid=$ttclid, campaign=$utmCampaign');

      // Attach TikTok attribution parameters across all subsequent GA4 events
      await FirebaseAnalyticsService.instance.setDefaultEventParameters({
        'traffic_medium': 'cpc',
        'traffic_source': 'tiktok',
        if (ttclid != null) 'ttclid': ttclid,
        if (utmCampaign != null) 'campaign': utmCampaign,
      });

      // Log the landing event to GA4
      FirebaseAnalyticsService.instance.logCustomEvent(
        name: 'tiktok_ad_landing',
        parameters: _activeAttribution!.toParameterMap(),
      );
    }
  }

  /// Maps and tracks standard TikTok conversion events in GA4
  void trackTikTokStandardEvent({
    required String eventName, // ViewContent, AddToCart, InitiateCheckout, PlaceAnOrder, CompletePayment
    Map<String, Object>? parameters,
  }) {
    debugPrint('📊 [TikTok Event] Standard event logged: $eventName');
    final combined = <String, Object>{
      'tiktok_event_name': eventName,
      ...?parameters,
      if (_activeAttribution != null) ..._activeAttribution!.toParameterMap(),
    };

    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'tiktok_${eventName.toLowerCase()}',
      parameters: combined,
    );
  }

  /// Decorates e-commerce conversion events with TikTok Click ID (ttclid)
  Map<String, Object> decorateWithTikTokAttribution(Map<String, Object> baseParameters) {
    if (_activeAttribution != null) {
      return {
        ...baseParameters,
        ..._activeAttribution!.toParameterMap(),
      };
    }
    return baseParameters;
  }
}
