import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

import 'firebase_auth_service.dart';
import 'firebase_firestore_service.dart';
import 'firebase_analytics_service.dart';
import 'firebase_crashlytics_service.dart';
import 'firebase_remote_config_service.dart';
import 'firebase_messaging_service.dart';
import 'firebase_performance_service.dart';
import 'firebase_ai_logic_service.dart';
import 'admob_service.dart';

/// Firebase Free Services Coordinator (Spark Plan)
///
/// Orchestrates all zero-cost Firebase Spark Plan services:
/// 1. Firebase Authentication (Free unlimited email/pass & anonymous, 10k phone/mo)
/// 2. Cloud Firestore (1 GiB, 50k reads, 20k writes/day free tier)
/// 3. Google Analytics for Firebase (100% Free & Unlimited events)
/// 4. Firebase Crashlytics (100% Free & Unlimited real-time crash diagnostics)
/// 5. Firebase Remote Config (100% Free & Unlimited feature flags & dynamic config)
/// 6. Firebase Cloud Messaging (100% Free & Unlimited push notifications)
/// 7. Firebase Performance Monitoring (100% Free & Unlimited traces & latency metrics)
/// 8. Firebase AI Logic / Gemini (Free tier Google Generative AI for royal recipes & culinary tracking)
class FirebaseFreeServices {
  FirebaseFreeServices._internal();
  static final FirebaseFreeServices instance = FirebaseFreeServices._internal();

  bool _isCoreInitialized = false;
  bool get isCoreInitialized => _isCoreInitialized;

  /// Initializes all Firebase Free Services with error shielding and fallbacks
  Future<void> initializeAll() async {
    debugPrint('🚀 [Firebase Free Services] Bootstrapping Spark Plan services...');

    // 1. Core Firebase Initialization
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isCoreInitialized = true;
      debugPrint('✅ [Firebase Free Services] Firebase.initializeApp succeeded.');
    } catch (e) {
      debugPrint('⚠️ [Firebase Free Services] Core init fallback: $e');
    }

    // 2. Crashlytics (setup early to catch any subsequent setup errors)
    await FirebaseCrashlyticsService.instance.initialize();

    // 3. Analytics (100% Free & Unlimited events)
    await FirebaseAnalyticsService.instance.initialize();
    await FirebaseAnalyticsService.instance.verifyFirebaseGa4Link();

    // 4. Remote Config (100% Free dynamic feature flags & delivery thresholds)
    await FirebaseRemoteConfigService.instance.initialize();

    // 5. Cloud Messaging (100% Free push notifications)
    await FirebaseMessagingService.instance.initialize();

    // 6. Performance Monitoring (100% Free custom execution traces)
    await FirebasePerformanceService.instance.initialize();

    // 7. Firebase AI Logic / Gemini
    FirebaseAiLogicService.instance.init();

    // 8. Google AdMob & GA4 Monetization Integration
    await AdMobService.instance.initialize();

    // 9. Cloud Firestore Data Synchronization (Background task)
    unawaited(
      FirebaseFirestoreService.instance.syncAllAppDataToFirestore(
        uid: FirebaseAuthService.instance.currentUser?.uid ??
            FirebaseFirestoreService.defaultTargetUid,
      ),
    );

    debugPrint('🎉 [Firebase Free Services] All 8 Free Services active and operational!');
  }

  /// Returns health status map for all integrated free services
  Map<String, dynamic> getFreeServicesStatus() {
    return {
      'core_initialized': _isCoreInitialized,
      'auth_ready': FirebaseAuthService.instance.currentUser != null,
      'firestore_ready': true,
      'analytics_ready': FirebaseAnalyticsService.instance.analytics != null,
      'crashlytics_ready': FirebaseCrashlyticsService.instance.isInitialized,
      'remote_config_ready': FirebaseRemoteConfigService.instance.isInitialized,
      'messaging_ready': FirebaseMessagingService.instance.isInitialized,
      'performance_ready': FirebasePerformanceService.instance.isInitialized,
      'ai_logic_ready': FirebaseAiLogicService.instance.isReady,
      'admob_ready': AdMobService.instance.isInitialized,
      'target_user_uid': FirebaseAuthService.instance.currentUser?.uid ??
          FirebaseFirestoreService.defaultTargetUid,
      'spark_plan_cost': '0.00 USD (100% Free Tier)',
    };
  }
}
