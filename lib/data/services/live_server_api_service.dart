import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'firebase_firestore_service.dart';

/// LiveServerApiService
/// Connects to Jeerola's live cloud server API with automatic fallback to
/// Firebase Firestore, SQLite, and offline local cache.
class LiveServerApiService {
  static final LiveServerApiService instance = LiveServerApiService._init();
  LiveServerApiService._init();

  static String baseUrl = 'https://api.jeerola.com/api/v1';
  final Duration timeout = const Duration(seconds: 4);

  /// Fetch latest user profile data from live server
  Future<Map<String, dynamic>?> fetchLatestUserProfile({
    required String uid,
  }) async {
    // 1. Attempt live REST API
    try {
      final uri = Uri.parse('$baseUrl/user/profile?uid=$uid');
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri).timeout(timeout);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close().timeout(timeout);

        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          final data = jsonDecode(body);
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            return data['data'] as Map<String, dynamic>;
          }
        }
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      debugPrint('Live REST API /user/profile fallback: $e');
    }

    // 2. Fallback to Firebase Firestore cloud sync
    try {
      final firestoreDoc = await FirebaseFirestoreService.instance.getUserProfile(uid);
      if (firestoreDoc != null && firestoreDoc.isNotEmpty) {
        return firestoreDoc;
      }
    } catch (e) {
      debugPrint('Firestore fallback error: $e');
    }

    return null;
  }

  /// Fetch latest live order history & tracking updates from server
  Future<List<Map<String, dynamic>>> fetchLatestOrders({
    required String uid,
  }) async {
    // 1. Attempt live REST API
    try {
      final uri = Uri.parse('$baseUrl/orders/history?uid=$uid');
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri).timeout(timeout);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close().timeout(timeout);

        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          final data = jsonDecode(body);
          if (data is Map<String, dynamic> && data['orders'] is List) {
            return List<Map<String, dynamic>>.from(data['orders'] as List);
          }
        }
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      debugPrint('Live REST API /orders/history fallback: $e');
    }

    // 2. Fallback to Firebase Firestore
    try {
      final firestoreOrders = await FirebaseFirestoreService.instance.getUserOrders(uid);
      if (firestoreOrders.isNotEmpty) {
        return firestoreOrders;
      }
    } catch (e) {
      debugPrint('Firestore orders fallback error: $e');
    }

    return [];
  }

  /// Fetch latest live J-Coins wallet balance
  Future<int?> fetchLatestWalletBalance({
    required String uid,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/wallet/balance?uid=$uid');
      final client = HttpClient();
      try {
        final request = await client.getUrl(uri).timeout(timeout);
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close().timeout(timeout);

        if (response.statusCode == 200) {
          final body = await response.transform(utf8.decoder).join();
          final data = jsonDecode(body);
          if (data is Map<String, dynamic> && data['balance'] != null) {
            return (data['balance'] as num).toInt();
          }
        }
      } finally {
        client.close(force: true);
      }
    } catch (_) {}

    // Firestore fallback
    final profile = await FirebaseFirestoreService.instance.getUserProfile(uid);
    if (profile != null && profile['jCoinsBalance'] != null) {
      return (profile['jCoinsBalance'] as num).toInt();
    }
    return null;
  }

  /// Sync user profile updates to live server
  Future<bool> pushUserProfileUpdate({
    required String uid,
    required Map<String, dynamic> profileData,
  }) async {
    bool serverSynced = false;

    // 1. Live REST API
    try {
      final uri = Uri.parse('$baseUrl/user/profile');
      final client = HttpClient();
      try {
        final request = await client.postUrl(uri).timeout(timeout);
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
        request.add(utf8.encode(jsonEncode({'uid': uid, ...profileData})));
        final response = await request.close().timeout(timeout);
        if (response.statusCode == 200 || response.statusCode == 201) {
          serverSynced = true;
        }
      } finally {
        client.close(force: true);
      }
    } catch (e) {
      debugPrint('Live REST API sync skipped: $e');
    }

    // 2. Firebase Firestore Sync
    try {
      await FirebaseFirestoreService.instance.saveUserProfile(
        uid: uid,
        profileData: profileData,
      );
      serverSynced = true;
    } catch (e) {
      debugPrint('Firestore sync skipped: $e');
    }

    return serverSynced;
  }
}
