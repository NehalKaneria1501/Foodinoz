// ignore_for_file: use_null_aware_elements
import 'package:flutter/foundation.dart';
import 'firebase_analytics_service.dart';

/// Reddit Ads Attribution Model
class RedditAttributionData {
  final String? rdtCid; // Reddit Click Identifier (rdt_cid)
  final String? subreddit; // Subreddit placement (e.g. r/IndianFood)
  final String? campaign; // Reddit campaign name
  final String? adGroupId; // Reddit Ad Group / Audience ID
  final String? adId; // Reddit creative / Promoted Post ID

  const RedditAttributionData({
    this.rdtCid,
    this.subreddit,
    this.campaign,
    this.adGroupId,
    this.adId,
  });

  bool get isRedditClick => rdtCid != null || (subreddit != null && subreddit!.isNotEmpty);

  Map<String, Object> toParameterMap() => {
        if (rdtCid != null) 'rdt_cid': rdtCid!,
        if (subreddit != null) 'reddit_subreddit': subreddit!,
        if (campaign != null) 'reddit_campaign': campaign!,
        if (adGroupId != null) 'reddit_adgroup': adGroupId!,
        if (adId != null) 'reddit_ad_id': adId!,
        'traffic_source': 'reddit',
        'traffic_medium': 'cpc',
      };
}

/// Reddit Ads Integration Service
///
/// Handles Reddit Ads click attribution (rdt_cid), community referral tracking (subreddits),
/// and routes cross-channel e-commerce conversions into Google Analytics 4 (GA4).
class RedditAdsService {
  RedditAdsService._();
  static final RedditAdsService instance = RedditAdsService._();

  RedditAttributionData? _activeAttribution;
  RedditAttributionData? get activeAttribution => _activeAttribution;

  /// Handles incoming deep links or referral parameters originating from Reddit Ads
  Future<void> handleIncomingRedditReferral(Map<String, String> queryParameters) async {
    final rdtCid = queryParameters['rdt_cid'];
    final utmSource = (queryParameters['utm_source'] ?? '').toLowerCase();
    final utmCampaign = queryParameters['utm_campaign'];
    final utmContent = queryParameters['utm_content']; // Ad ID
    final utmTerm = queryParameters['utm_term']; // Subreddit or keyword target

    final isFromReddit = rdtCid != null || utmSource.contains('reddit');

    if (isFromReddit) {
      _activeAttribution = RedditAttributionData(
        rdtCid: rdtCid,
        subreddit: utmTerm,
        campaign: utmCampaign,
        adGroupId: queryParameters['adgroup_id'],
        adId: utmContent,
      );

      debugPrint('🤖 [Reddit Ads] Attributed click: rdt_cid=$rdtCid, subreddit=$utmTerm, campaign=$utmCampaign');

      // Attach Reddit attribution parameters across all subsequent GA4 events
      await FirebaseAnalyticsService.instance.setDefaultEventParameters({
        'traffic_medium': 'cpc',
        'traffic_source': 'reddit',
        if (rdtCid != null) 'rdt_cid': rdtCid,
        if (utmCampaign != null) 'campaign': utmCampaign,
        if (utmTerm != null) 'subreddit': utmTerm,
      });

      // Log the landing event to GA4
      FirebaseAnalyticsService.instance.logCustomEvent(
        name: 'reddit_ad_landing',
        parameters: _activeAttribution!.toParameterMap(),
      );
    }
  }

  /// Maps and tracks standard Reddit conversion events in GA4
  void trackRedditStandardEvent({
    required String eventName, // PageVisit, ViewContent, AddToCart, Purchase, SignUp
    Map<String, Object>? parameters,
  }) {
    debugPrint('📊 [Reddit Event] Standard event logged: $eventName');
    final combined = <String, Object>{
      'reddit_event_name': eventName,
      ...?parameters,
      if (_activeAttribution != null) ..._activeAttribution!.toParameterMap(),
    };

    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'reddit_${eventName.toLowerCase()}',
      parameters: combined,
    );
  }

  /// Decorates e-commerce conversion events with Reddit Click ID (rdt_cid)
  Map<String, Object> decorateWithRedditAttribution(Map<String, Object> baseParameters) {
    if (_activeAttribution != null) {
      return {
        ...baseParameters,
        ..._activeAttribution!.toParameterMap(),
      };
    }
    return baseParameters;
  }
}
