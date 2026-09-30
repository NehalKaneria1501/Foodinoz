// ignore_for_file: use_null_aware_elements
import 'package:flutter/foundation.dart';
import 'firebase_analytics_service.dart';

/// Search Ads 360 (SA360) Attribution Model
class Sa360AttributionData {
  final String? gclid;
  final String? gclsrc; // e.g. 'aw.ds', 'ds' (identifies Search Ads 360 click)
  final String? gbraid; // iOS app attribution ID
  final String? wbraid; // Web-to-app attribution ID
  final String? searchEngine; // Google, Bing, Yahoo, Baidu
  final String? campaign;
  final String? keyword;

  const Sa360AttributionData({
    this.gclid,
    this.gclsrc,
    this.gbraid,
    this.wbraid,
    this.searchEngine,
    this.campaign,
    this.keyword,
  });

  bool get isSa360Click => gclsrc != null && (gclsrc!.contains('ds') || gclsrc!.contains('sa360'));

  Map<String, Object> toParameterMap() => {
        if (gclid != null) 'gclid': gclid!,
        if (gclsrc != null) 'gclsrc': gclsrc!,
        if (gbraid != null) 'gbraid': gbraid!,
        if (wbraid != null) 'wbraid': wbraid!,
        if (searchEngine != null) 'engine_account': searchEngine!,
        if (campaign != null) 'sa360_campaign': campaign!,
        if (keyword != null) 'sa360_keyword': keyword!,
      };
}

/// Search Ads 360 (SA360) Integration Service
///
/// Connects Search Ads 360 enterprise multi-engine search campaigns (Google, Bing, Yahoo)
/// with Google Analytics 4 (GA4) telemetry, auction-time bidding signals, and search intent.
class SearchAds360Service {
  SearchAds360Service._();
  static final SearchAds360Service instance = SearchAds360Service._();

  Sa360AttributionData? _activeAttribution;
  Sa360AttributionData? get activeAttribution => _activeAttribution;

  /// Handles and parses deep link attribution parameters originating from SA360 search ads
  Future<void> handleIncomingSearchAdReferral(Map<String, String> queryParameters) async {
    final gclid = queryParameters['gclid'];
    final gclsrc = queryParameters['gclsrc'];
    final gbraid = queryParameters['gbraid'];
    final wbraid = queryParameters['wbraid'];
    final utmSource = queryParameters['utm_source'] ?? 'google_search';
    final utmCampaign = queryParameters['utm_campaign'];
    final utmTerm = queryParameters['utm_term']; // Search keyword

    if (gclsrc != null || gclid != null || gbraid != null) {
      _activeAttribution = Sa360AttributionData(
        gclid: gclid,
        gclsrc: gclsrc,
        gbraid: gbraid,
        wbraid: wbraid,
        searchEngine: utmSource,
        campaign: utmCampaign,
        keyword: utmTerm,
      );

      debugPrint('🔍 [SA360] Attributed Search Ads 360 click: gclsrc=$gclsrc, engine=$utmSource, kw=$utmTerm');

      // Set global attribution parameters on all subsequent GA4 events
      await FirebaseAnalyticsService.instance.setDefaultEventParameters({
        'traffic_medium': 'cpc',
        'traffic_source': utmSource,
        if (gclsrc != null) 'gclsrc': gclsrc,
        if (gclid != null) 'gclid': gclid,
        if (utmCampaign != null) 'campaign': utmCampaign,
      });

      // Log the landing event to GA4
      FirebaseAnalyticsService.instance.logCustomEvent(
        name: 'sa360_ad_landing',
        parameters: _activeAttribution!.toParameterMap(),
      );
    }
  }

  /// Tracks in-app search queries to feed keyword discovery in SA360
  void trackSearchIntent({
    required String query,
    int? resultCount,
    String? categoryFilter,
  }) {
    debugPrint('🔎 [SA360 Intent] Search keyword queried: "$query" ($resultCount results)');
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'search',
      parameters: {
        'search_term': query,
        if (resultCount != null) 'results_count': resultCount,
        if (categoryFilter != null) 'category': categoryFilter,
      },
    );
  }

  /// Decorates e-commerce conversion events with SA360 attribution IDs for auction-time smart bidding
  Map<String, Object> decorateConversionParameters(Map<String, Object> baseParameters) {
    if (_activeAttribution != null) {
      return {
        ...baseParameters,
        ..._activeAttribution!.toParameterMap(),
      };
    }
    return baseParameters;
  }
}
