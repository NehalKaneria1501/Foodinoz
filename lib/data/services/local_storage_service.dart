import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'mock_data_service.dart';

/// LocalStorageService
/// Manages persistent storage using SharedPreferences with synchronous in-memory caching.
class LocalStorageService {
  static const String _userKey = 'jeerola_current_user';
  static const String _isLoggedInKey = 'jeerola_is_logged_in';
  static const String _planDaysKey = 'jeerola_active_plan_days';
  static const String _lastServerSyncKey = 'jeerola_last_server_sync';
  static const String _themeModeKey = 'jeerola_theme_mode';

  UserModel _currentUser = MockDataService.defaultUser;
  int _activePlanDays = 7;
  bool _isLoggedIn = true;
  DateTime? _lastServerSync;

  UserModel get currentUser => _currentUser;
  int get activePlanDays => _activePlanDays;
  bool get isLoggedIn => _isLoggedIn;
  DateTime? get lastServerSync => _lastServerSync;

  SharedPreferences? _prefs;

  /// Initialize and load saved state from SharedPreferences
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Load user
      final userJsonStr = _prefs?.getString(_userKey);
      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        final Map<String, dynamic> userMap = jsonDecode(userJsonStr);
        _currentUser = UserModel.fromJson(userMap);
      }

      // Load login status
      _isLoggedIn = _prefs?.getBool(_isLoggedInKey) ?? true;

      // Load active plan days
      _activePlanDays = _prefs?.getInt(_planDaysKey) ?? 7;

      // Load sync timestamp
      final syncStr = _prefs?.getString(_lastServerSyncKey);
      if (syncStr != null) {
        _lastServerSync = DateTime.tryParse(syncStr);
      }

      // Load theme override if present
      final savedTheme = _prefs?.getString(_themeModeKey);
      if (savedTheme != null && savedTheme.isNotEmpty) {
        _currentUser = _currentUser.copyWith(themeMode: savedTheme);
      }

      debugPrint('LocalStorageService initialized via SharedPreferences (User: ${_currentUser.name})');
    } catch (e) {
      debugPrint('LocalStorageService init fallback: $e');
    }
  }

  void saveUser(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    _persistUser(user);
  }

  Future<void> _persistUser(UserModel user) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_themeModeKey, user.themeMode);
    } catch (e) {
      debugPrint('Error persisting user to SharedPreferences: $e');
    }
  }

  void updatePlanDays(int days) {
    _activePlanDays = days;
    _persistPlanDays(days);
  }

  Future<void> _persistPlanDays(int days) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setInt(_planDaysKey, days);
    } catch (e) {
      debugPrint('Error persisting plan days: $e');
    }
  }

  void updateThemeMode(String mode) {
    _currentUser = _currentUser.copyWith(themeMode: mode);
    _persistTheme(mode);
  }

  Future<void> _persistTheme(String mode) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode);
    } catch (e) {
      debugPrint('Error persisting theme mode: $e');
    }
  }

  void markServerSynced() {
    _lastServerSync = DateTime.now();
    _persistSyncTime(_lastServerSync!);
  }

  Future<void> _persistSyncTime(DateTime time) async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setString(_lastServerSyncKey, time.toIso8601String());
    } catch (e) {
      debugPrint('Error persisting sync time: $e');
    }
  }

  void logout() {
    _isLoggedIn = false;
    _persistLogout();
  }

  Future<void> _persistLogout() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_userKey);
    } catch (e) {
      debugPrint('Error persisting logout: $e');
    }
  }
}
