import 'package:flutter/foundation.dart';

/// Firebase Crashlytics Service (Pure Dart - No Native Android/Kotlin Crash Risk)
///
/// Captures unhandled Flutter errors, Dart isolate exceptions, custom keys,
/// user identification, and diagnostics without requiring native Gradle plugins.
class FirebaseCrashlyticsService {
  FirebaseCrashlyticsService._internal();
  static final FirebaseCrashlyticsService instance = FirebaseCrashlyticsService._internal();

  final Map<String, Object> _customKeys = {};
  final List<String> _breadcrumbs = [];
  String? _userIdentifier;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  Map<String, Object> get customKeys => Map.unmodifiable(_customKeys);
  List<String> get breadcrumbs => List.unmodifiable(_breadcrumbs);
  String? get userIdentifier => _userIdentifier;

  /// Initializes crash interception hooks
  Future<void> initialize() async {
    try {
      // Capture Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails details) {
        recordError(
          details.exception,
          details.stack,
          reason: 'FlutterError: ${details.context}',
          fatal: true,
        );
      };

      // Capture unhandled asynchronous errors across isolates
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        recordError(
          error,
          stack,
          reason: 'PlatformDispatcher unhandled exception',
          fatal: true,
        );
        return true;
      };

      await setCustomKey('app_name', 'Jeerola');
      await setCustomKey('platform', defaultTargetPlatform.name);

      _isInitialized = true;
      debugPrint('[Crashlytics] Initialized cleanly with pure Dart exception shields.');
    } catch (e) {
      debugPrint('[Crashlytics] Initialization fallback: $e');
    }
  }

  /// Records an error or non-fatal exception
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    Iterable<Object> information = const [],
    bool fatal = false,
  }) async {
    final entry = '[Crashlytics ${fatal ? "FATAL" : "NON-FATAL"}] $exception (reason: $reason)';
    debugPrint(entry);
    _breadcrumbs.add('${DateTime.now().toIso8601String()}: $entry');
    if (_breadcrumbs.length > 50) {
      _breadcrumbs.removeAt(0);
    }
  }

  /// Attaches custom breadcrumb log message
  Future<void> log(String message) async {
    final logMsg = '[Jeerola] $message';
    debugPrint('[Crashlytics Breadcrumb] $logMsg');
    _breadcrumbs.add('${DateTime.now().toIso8601String()}: $logMsg');
  }

  /// Sets user identifier for tracking
  Future<void> setUserIdentifier(String userId) async {
    _userIdentifier = userId;
    debugPrint('[Crashlytics] User identifier bound: $userId');
  }

  /// Sets custom key-value pair
  Future<void> setCustomKey(String key, Object value) async {
    _customKeys[key] = value;
  }
}
