import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeerola/core/theme/app_theme.dart';
import 'package:jeerola/data/services/firebase_crashlytics_service.dart';
import 'package:jeerola/data/services/firebase_free_services.dart';
import 'package:jeerola/data/services/firebase_messaging_service.dart';
import 'package:jeerola/data/services/firebase_performance_service.dart';
import 'package:jeerola/data/services/firebase_remote_config_service.dart';
import 'package:jeerola/data/services/jeerola_delivery_service.dart';
import 'package:jeerola/ui/features/ai_chat/view_models/jeerola_ai_chat_view_model.dart';
import 'package:jeerola/ui/features/ai_chat/views/jeerola_ai_chat_screen.dart';
import 'package:jeerola/ui/features/delivery/view_models/jeerola_delivery_view_model.dart';

void main() {
  group('Firebase Free Services (Spark Plan - No Cost) Tests', () {
    test('FirebaseFreeServices coordinator status reports all 8 free services', () {
      final status = FirebaseFreeServices.instance.getFreeServicesStatus();

      expect(status, isNotNull);
      expect(status['spark_plan_cost'], contains('0.00 USD'));
      expect(status['target_user_uid'], isNotEmpty);
      expect(status.containsKey('auth_ready'), isTrue);
      expect(status.containsKey('firestore_ready'), isTrue);
      expect(status.containsKey('analytics_ready'), isTrue);
      expect(status.containsKey('crashlytics_ready'), isTrue);
      expect(status.containsKey('remote_config_ready'), isTrue);
      expect(status.containsKey('messaging_ready'), isTrue);
      expect(status.containsKey('performance_ready'), isTrue);
      expect(status.containsKey('ai_logic_ready'), isTrue);
    });

    test('FirebaseRemoteConfigService provides in-app defaults and typed getters', () {
      final rc = FirebaseRemoteConfigService.instance;

      expect(rc.expressDeliveryEtaMinutes, 16);
      expect(rc.freeDeliveryThresholdInr, 499);
      expect(rc.showRoyalAiChefBadge, isTrue);
      expect(rc.enableSmartFlameControl, isTrue);
      expect(rc.bannerPromoText, contains('JEEROLA10'));
      expect(rc.supportPhoneNumber, '+91 9265754161');

      // Test fallback getters for custom keys
      expect(rc.getInt('non_existent_int'), 0);
      expect(rc.getBool('non_existent_bool'), isFalse);
      expect(rc.getString('non_existent_str'), '');
      expect(rc.getDouble('non_existent_double'), 0.0);
    });

    test('FirebaseCrashlyticsService records breadcrumbs, keys, and non-fatal errors safely', () async {
      final crashlytics = FirebaseCrashlyticsService.instance;

      await crashlytics.setUserIdentifier('google_usr_981723461234');
      await crashlytics.setCustomKey('membership_tier', 'Royal Gold');
      await crashlytics.log('User browsing Cumin Spices catalog');
      await crashlytics.recordError(
        Exception('Network timeout simulated'),
        StackTrace.current,
        reason: 'Testing crashlytics safety net',
      );

      // Verify no uncaught exceptions thrown during calls
      expect(true, isTrue);
    });

    test('FirebasePerformanceService measures asynchronous duration trace safely', () async {
      final perf = FirebasePerformanceService.instance;

      final measuredResult = await perf.traceOperation<String>(
        'test_cooking_speed_metric',
        () async {
          await Future.delayed(const Duration(milliseconds: 10));
          return 'tempered_cumin_ready';
        },
        attributes: {'cuisine': 'Royal Dum Biryani'},
        metrics: {'spices_count': 5},
      );

      expect(measuredResult, 'tempered_cumin_ready');
    });

    test('FirebaseMessagingService handles topic subscription safely', () async {
      final fcm = FirebaseMessagingService.instance;

      await fcm.subscribeToTopic('jeerola_express_orders');
      await fcm.subscribeToTopic('daily_recipes');
      await fcm.unsubscribeFromTopic('daily_recipes');

      expect(true, isTrue);
    });

    testWidgets('JeerolaAiChatScreen shows Firebase Spark Services bottom modal on tap', (tester) async {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final deliveryService = JeerolaDeliveryService();
      final deliveryVm = JeerolaDeliveryViewModel(deliveryService: deliveryService);
      final chatVm = JeerolaAiChatViewModel();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<JeerolaDeliveryViewModel>.value(value: deliveryVm),
            ChangeNotifierProvider<JeerolaAiChatViewModel>.value(value: chatVm),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const JeerolaAiChatScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Find the lightning bolt icon in the AppBar
      final boltIcon = find.byIcon(Icons.bolt);
      expect(boltIcon, findsOneWidget);

      // Tap the bolt icon to open the modal
      await tester.tap(boltIcon);
      await tester.pumpAndSettle();

      // Verify modal content
      expect(find.text('FIREBASE SPARK PLAN SERVICES'), findsOneWidget);
      expect(find.text('100% FREE'), findsOneWidget);
      expect(find.text('Firebase Authentication'), findsOneWidget);
      expect(find.text('Cloud Firestore'), findsOneWidget);
      expect(find.text('Google Analytics for Firebase'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Firebase AI Logic (Gemini)'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Firebase AI Logic (Gemini)'), findsOneWidget);

      deliveryService.stopAutoTracking();
    });
  });
}
