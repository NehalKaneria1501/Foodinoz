// ignore_for_file: deprecated_member_use, use_null_aware_elements
import 'package:flutter/material.dart';
import 'firebase_analytics_service.dart';

/// Pure Flutter Ad & Monetization Service (Zero Android Java/Kotlin native dependencies)
///
/// Implements royal restaurant sponsorship banners, flash deal promotion cards,
/// and interstitial dialogs rendered purely with Flutter widgets and animated containers.
/// Emits standard GA4 e-commerce & ad monetization telemetry events.
class AdMobService {
  AdMobService._();
  static final AdMobService instance = AdMobService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  int _totalImpressions = 0;
  int _totalClicks = 0;
  double _estimatedRevenueInr = 0.0;

  int get totalImpressions => _totalImpressions;
  int get totalClicks => _totalClicks;
  double get estimatedRevenueInr => _estimatedRevenueInr;

  /// Initializes the Pure Flutter Ad engine
  Future<void> initialize() async {
    _isInitialized = true;
    debugPrint('✅ [AdMob / Monetization] Pure Flutter Ad engine initialized (0 native dependencies).');
  }

  /// Records an ad impression to GA4
  void recordImpression({
    required String adUnitId,
    required String adFormat,
    String? sponsorName,
  }) {
    _totalImpressions++;
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'ad_impression',
      parameters: {
        'ad_platform': 'Flutter_InApp_Sponsor',
        'ad_source': sponsorName ?? 'Jeerola_Royal_Spice',
        'ad_unit_name': adUnitId,
        'ad_format': adFormat,
        'currency': 'INR',
        'value': 0.15, // 0.15 INR estimated eCPM
      },
    );
  }

  /// Records an ad click to GA4
  void recordClick({
    required String adUnitId,
    required String adFormat,
    String? targetUrl,
  }) {
    _totalClicks++;
    _estimatedRevenueInr += 1.25;
    FirebaseAnalyticsService.instance.logCustomEvent(
      name: 'ad_click',
      parameters: {
        'ad_platform': 'Flutter_InApp_Sponsor',
        'ad_unit_name': adUnitId,
        'ad_format': adFormat,
        if (targetUrl != null) 'target_url': targetUrl,
      },
    );
  }

  /// Shows a pure Flutter interstitial dialog overlay (no native activity transitions)
  Future<void> showInterstitialModal({
    required BuildContext context,
    required String title,
    required String description,
    required String ctaText,
    VoidCallback? onCtaPressed,
  }) async {
    recordImpression(
      adUnitId: 'interstitial_modal_royal',
      adFormat: 'INTERSTITIAL',
    );

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2C2416), Color(0xFF1A1610)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FEATURED SPONSOR',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Icon(
                  Icons.restaurant_menu,
                  color: Color(0xFFD4AF37),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: const Color(0xFF1A1610),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      recordClick(
                        adUnitId: 'interstitial_modal_royal',
                        adFormat: 'INTERSTITIAL',
                      );
                      Navigator.of(ctx).pop();
                      onCtaPressed?.call();
                    },
                    child: Text(
                      ctaText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pure Flutter Banner Ad Widget that fits into any ListView / Column
class FlutterAdBannerWidget extends StatefulWidget {
  final String adUnitId;
  final String sponsorTitle;
  final String subtitle;
  final VoidCallback? onTap;

  const FlutterAdBannerWidget({
    super.key,
    this.adUnitId = 'home_banner_top',
    this.sponsorTitle = 'Jeerola Premium Royal Saffron',
    this.subtitle = 'Get 25% OFF on pure Kashmiri saffron & whole spices',
    this.onTap,
  });

  @override
  State<FlutterAdBannerWidget> createState() => _FlutterAdBannerWidgetState();
}

class _FlutterAdBannerWidgetState extends State<FlutterAdBannerWidget> {
  @override
  void initState() {
    super.initState();
    AdMobService.instance.recordImpression(
      adUnitId: widget.adUnitId,
      adFormat: 'BANNER',
      sponsorName: widget.sponsorTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          AdMobService.instance.recordClick(
            adUnitId: widget.adUnitId,
            adFormat: 'BANNER',
          );
          widget.onTap?.call();
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.local_offer,
                color: Color(0xFFD4AF37),
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.sponsorTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'AD',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFD4AF37),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
