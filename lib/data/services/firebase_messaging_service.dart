import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_firestore_service.dart';
import 'firebase_auth_service.dart';
import 'firebase_analytics_service.dart';

/// Top-level background message handler required by Firebase Cloud Messaging.
/// Must be annotated with @pragma('vm:entry-point') to survive tree shaking.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 [FCM Background Handler] Message ID: ${message.messageId}');
  debugPrint('📬 [FCM Background Handler] Data: ${message.data}');
  if (message.notification != null) {
    debugPrint(
        '📬 [FCM Background Handler] Notification: ${message.notification!.title} - ${message.notification!.body}');
  }
}

/// Firebase Cloud Messaging (FCM) Service
///
/// Handles push notification onboarding, campaign messaging, topic subscriptions,
/// live order dispatch notifications, recipe drops, and FCM token synchronization.
class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService instance = FirebaseMessagingService._internal();

  final Set<String> _subscribedTopics = {};
  String? _fcmToken;
  bool _isInitialized = false;

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  final StreamController<RemoteMessage> _notificationClickController =
      StreamController<RemoteMessage>.broadcast();

  bool get isInitialized => _isInitialized;
  String? get fcmToken => _fcmToken;
  Set<String> get subscribedTopics => Set.unmodifiable(_subscribedTopics);
  Stream<RemoteMessage> get onMessageStream => _messageStreamController.stream;
  Stream<RemoteMessage> get onNotificationClickStream =>
      _notificationClickController.stream;

  /// Initializes messaging service, registers listeners, requests permissions,
  /// and syncs the registration token for campaign onboarding.
  Future<void> initialize() async {
    try {
      debugPrint('🔔 [FCM] Initializing Firebase Cloud Messaging for project jeerola-eefba...');

      // 1. Register top-level background handler (not supported on web)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      }

      final messaging = FirebaseMessaging.instance;

      // 2. Request user notification permissions (Android 13+, iOS, Web)
      final settings = await messaging
          .requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          )
          .timeout(const Duration(seconds: 3));

      debugPrint('🔔 [FCM] Notification authorization status: ${settings.authorizationStatus}');

      // 3. Configure foreground presentation options (displays heads-up alerts while app is open)
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // 4. Retrieve FCM Registration Token for Onboarding & Campaign Testing
      await _retrieveAndStoreToken();

      // 5. Listen for token refreshes
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 [FCM] FCM Token rotated: $newToken');
        _fcmToken = newToken;
        _syncTokenToFirestore(newToken);
      });

      // 6. Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📩 [FCM Foreground] Received: ${message.notification?.title ?? message.data['title']}');
        _messageStreamController.add(message);

        // Log campaign message open / receipt to Firebase Analytics
        FirebaseAnalyticsService.instance.logCustomEvent(
          name: 'notification_received',
          parameters: {
            'message_id': message.messageId ?? 'unknown',
            'campaign_name': message.data['campaign'] ?? 'generic',
            if (message.from != null) 'from_topic': message.from!,
          },
        );
      });

      // 7. Background message opened listener (when user taps on notification bar)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('📲 [FCM Clicked] User opened app from notification: ${message.messageId}');
        _notificationClickController.add(message);

        FirebaseAnalyticsService.instance.logCustomEvent(
          name: 'notification_open',
          parameters: {
            'message_id': message.messageId ?? 'unknown',
            'campaign_name': message.data['campaign'] ?? 'generic',
          },
        );
      });

      // 8. Cold-start initial message (app launched from terminated state via notification)
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 [FCM Cold Start] App launched from notification: ${initialMessage.messageId}');
        _notificationClickController.add(initialMessage);
      }

      // 9. Subscribe to default onboarding broadcast topics
      await subscribeToTopic('jeerola_all_users');
      await subscribeToTopic('jeerola_express_orders');
      await subscribeToTopic('jeerola_offers');
      await subscribeToTopic('daily_recipes');

      _isInitialized = true;
      debugPrint('✅ [FCM] Firebase Cloud Messaging initialized successfully.');
    } catch (e) {
      debugPrint('⚠️ [FCM] Notification initialization fallback: $e');
      _fcmToken = 'fallback_token_${DateTime.now().millisecondsSinceEpoch}';
      _isInitialized = true;
    }
  }

  /// Retrieves the active FCM registration token and records it to Firestore
  Future<String?> _retrieveAndStoreToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      _fcmToken = await messaging.getToken().timeout(const Duration(seconds: 3));
      debugPrint('🔑 [FCM Token for Campaign Onboarding / Test]: $_fcmToken');

      if (_fcmToken != null) {
        await _syncTokenToFirestore(_fcmToken!);
      }
      return _fcmToken;
    } catch (e) {
      debugPrint('⚠️ [FCM] Could not retrieve FCM token: $e');
      return null;
    }
  }

  /// Syncs the FCM token to Firestore so targeted campaigns can be dispatched
  Future<void> _syncTokenToFirestore(String token) async {
    final uid = FirebaseAuthService.instance.currentUser?.uid ??
        FirebaseFirestoreService.defaultTargetUid;

    await FirebaseFirestoreService.instance.saveUserFcmToken(
      uid: uid,
      fcmToken: token,
      platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
    );
  }

  /// Subscribes to a broadcast campaign topic (e.g. 'jeerola_offers', 'flash_deals')
  Future<void> subscribeToTopic(String topic) async {
    try {
      if (!kIsWeb) {
        await FirebaseMessaging.instance
            .subscribeToTopic(topic)
            .timeout(const Duration(seconds: 2));
      }
      _subscribedTopics.add(topic);
      debugPrint('📡 [FCM] Subscribed to topic: $topic');
    } catch (e) {
      _subscribedTopics.add(topic);
      debugPrint('⚠️ [FCM] Topic subscription fallback for $topic: $e');
    }
  }

  /// Unsubscribes from a broadcast topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      if (!kIsWeb) {
        await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
      _subscribedTopics.remove(topic);
      debugPrint('📡 [FCM] Unsubscribed from topic: $topic');
    } catch (e) {
      _subscribedTopics.remove(topic);
      debugPrint('⚠️ [FCM] Unsubscribe fallback for $topic: $e');
    }
  }

  /// Manually syncs active token when user logs in or switches account
  Future<void> syncUserTokenOnLogin(String uid) async {
    if (_fcmToken != null) {
      await FirebaseFirestoreService.instance.saveUserFcmToken(
        uid: uid,
        fcmToken: _fcmToken!,
        platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
      );
    }
  }

  /// Dispatches an in-app push notification purely within Flutter (Zero native Android Java/Kotlin)
  void emitInAppNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    final message = RemoteMessage(
      notification: RemoteNotification(title: title, body: body),
      data: data != null ? Map<String, String>.from(data.map((k, v) => MapEntry(k, v.toString()))) : {},
      messageId: 'in_app_${DateTime.now().millisecondsSinceEpoch}',
    );
    _messageStreamController.add(message);
    debugPrint('🔔 [FCM Flutter In-App] Emitted notification: $title - $body');
  }

  /// Cleans up streams
  void dispose() {
    _messageStreamController.close();
    _notificationClickController.close();
  }
}
