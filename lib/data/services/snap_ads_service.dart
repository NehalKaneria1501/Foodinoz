// ignore_for_file: use_null_aware_elements
import 'package:flutter/foundation.dart';
import 'firebase_analytics_service.dart';

/// Snapchat (Snap Ads) Attribution Model
class SnapAttributionData {
  final String? scClickId; // Snapchat Click ID (sc_click_id / sclid)
  final String? campaign; // Snap campaign name
  final String? adSquadId; // Snap Ad Squad (Ad Set) ID
  final String? creativeId; // Snap Creative / Ad ID

  const SnapAttributionData({
    this.scClickId,
    this.campaign,
    this.adSquadId,
    this.creativeId,
  });

  bool get isSnapClick => scClickId != null || (campaign != null && campaign!.isNotEmpty);

  Map<String, Object> toParameterMap() => {
        if (scClickId != null) 'sc_click_id': scClickId!,
        if (campaign != null) 'snap_campaign': campaign!,
        if (adSquadId != null) 'snap_adsquad_id': adSquadId!,
        if (creativeId != null) 'snap_creative_id': creativeId!,
        'traffic_source': 'snapchat',
        'traffic_medium': 'cpc',
      };
}

/// Snapchat Ads (Snap) Integration Service
///
/// Connects Snapchat Ads (Story Ads, Spotlight, AR Lenses, Collection Ads)
/// with Google Analytics 4 (GA4) cross-channel attribution and e-commerce telemetry.
class SnapAdsService {
  SnapAdsService._();
  static final SnapAdsService instance = SnapAdsService._();

  SnapAttributionData? _activeAttribution;
  SnapAttributionData? get activeAttribution => _activeAttribution;

  /// Handles incoming deep links or referral parameters originating from Snapchat Ads
  Future<void> handleIncomingSnapReferral(Map<String, String> queryParameters) async {
    final scClickId = queryParameters['sc_click_id'] ?? queryParameters['sclid'];
    final utmSource = (queryParameters['utm_source'] ?? '').toLowerCase();
    final utmCampaign = queryParameters['utm_campaign'];
    final utmContent = queryParameters['utm_content']; // Creative ID
    final utmTerm = queryParameters['utm_term']; // Ad Squad ID

    final isFromSnap = scClickId != null || utmSource.contains('snapchat') || utmSource.contains('snap');

    if (isFromSnap) {
      _activeAttribution = SnapAttributionData(
        scClickId: scClickId,
        campaign: utmCampaign,
        adSquadId: utmTerm,
        creativeId: utmContent,
      );

      debugPrint('👻 [Snap Ads] Attributed click: sc_click_id=$scClickId, campaign=$utmCampaign');

      // Attach Snap attribution parameters across all subsequent GA4 events
      await FirebaseAnalyticsService.instance.setDefaultEventParameters({
        'traffic_medium': 'cpc',
        'traffic_source': 'snapchat',
        if (scClickId != null) 'sc_click_id': scClickId,
        if (utmCampaign != null) 'campaign': utmCampaign,
      });

      // Log the landing event to GA4
      FirebaseAnalyticsService.instance.logCustomEvent(
        name: 'snap_ad_landing',
        parameters: _activeAttribution!.toParameterMap(),
      );
    }
  }

  /// Maps and tracks standard Snapchat conversion events in GA4
  void trackSnapStandardEvent({
    required String eventName, // VIEW_CONTENT, ADD_CART, START_CHECKOUT, PURCHASE, SIGN_UP
    Map<String, Object>? parameters,
  }) {
    debugPrint('📊 [Snap Event] Standard event logged: $eventName');
    final combined = <String, Object>{
      'snap_event_name': eventName,
      ...?parameters,
      if (_activeAttribution != null) ..._activeAttribution!.toParameterMap(),
    };

    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'snap_${eventName.toLowerCase()}',
      parameters: combined,
    );
  }

  /// Decorates e-commerce conversion events with Snapchat Click ID (sc_click_id)
  Map<String, Object> decorateWithSnapAttribution(Map<String, Object> baseParameters) {
    if (_activeAttribution != null) {
      return {
        ...baseParameters,
        ..._activeAttribution!.toParameterMap(),
      };
    }
    return baseParameters;
  }
}
