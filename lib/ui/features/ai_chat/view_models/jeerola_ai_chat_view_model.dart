import 'package:flutter/foundation.dart';
import '../../../../data/models/jeerola_order_model.dart';
import '../../../../data/services/firebase_ai_logic_service.dart';
import '../../../../data/services/firebase_firestore_service.dart';

class JeerolaAiChatViewModel extends ChangeNotifier {
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _syncStatusMessage;

  List<ChatMessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get syncStatusMessage => _syncStatusMessage;

  Future<void> loadHistory(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      final history = await FirebaseAiLogicService.instance.loadChatHistory(uid);
      _messages.clear();
      _messages.addAll(history);
    } catch (e) {
      debugPrint('Error loading chat history from Firestore: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String prompt,
    required String uid,
    JeerolaOrderModel? activeOrder,
  }) async {
    if (prompt.trim().isEmpty) return;

    final userMsg = ChatMessageModel(
      id: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
      text: prompt.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isLoading = true;
    notifyListeners();

    try {
      final aiResponse = await FirebaseAiLogicService.instance.sendMessage(
        prompt: prompt.trim(),
        uid: uid,
        activeOrder: activeOrder,
      );
      _messages.add(aiResponse);
    } catch (e) {
      _messages.add(
        ChatMessageModel(
          id: 'err_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Apologies, I encountered a temporary connection glitch. Please try again!',
          isUser: false,
          timestamp: DateTime.now(),
          suggestedFollowUps: ['Try again', 'Ask about active order'],
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Triggers full synchronization of all app data (Profile, Orders, Recipes,
  /// Products, Wishlist, Chat) to Cloud Firestore in project jeerola-eefba.
  Future<bool> syncAllDataToFirestore({required String uid}) async {
    _isSyncing = true;
    _syncStatusMessage = 'Syncing app data to Cloud Firestore (jeerola-eefba)...';
    notifyListeners();

    final success = await FirebaseFirestoreService.instance.syncAllAppDataToFirestore(uid: uid);

    _isSyncing = false;
    _syncStatusMessage = success
        ? 'All data synchronized to Cloud Firestore successfully!'
        : 'Sync completed with local fallback.';
    notifyListeners();

    return success;
  }
}
