import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/jeerola_order_model.dart';
import 'firebase_firestore_service.dart';
import 'firebase_crashlytics_service.dart';
import 'firebase_performance_service.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> suggestedFollowUps;
  final String? relatedRecipeId;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedFollowUps = const [],
    this.relatedRecipeId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'suggestedFollowUps': suggestedFollowUps,
        'relatedRecipeId': relatedRecipeId,
      };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
        id: json['id'] as String? ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: json['text'] as String? ?? '',
        isUser: json['isUser'] as bool? ?? false,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
            : DateTime.now(),
        suggestedFollowUps: (json['suggestedFollowUps'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        relatedRecipeId: json['relatedRecipeId'] as String?,
      );
}

class FirebaseAiLogicService {
  static final FirebaseAiLogicService instance = FirebaseAiLogicService._init();
  FirebaseAiLogicService._init();

  GenerativeModel? _model;
  ChatSession? _chatSession;
  String? _apiKey;

  bool get isReady => true;
  bool get hasLiveModel => _chatSession != null;

  static const String _defaultSystemPrompt =
      'You are the Jeerola Royal AI Chef & Culinary Concierge for Jeerola - India\'s premier artisan cumin and royal spice brand.\n'
      'You have master-level knowledge of:\n'
      '1. Artisan stone-ground roasted jeera and whole royal cumin tempering (tadka).\n'
      '2. Signature royal dishes: Royal Jeera Murgh Dum Handi, Cumin Spice Biryani, Jeera Aloo, Shahi Paneer.\n'
      '3. Pure vegetarian, Jain, and Swaminarayan (no onion, no garlic, hing-free) cuisines.\n'
      '4. Food preparation steps, spice ratios, oil smoking points, and health benefits of cumin.\n'
      '5. Jeerola Express kitchen deliveries, captain tracking, and food temperature preservation.\n'
      'Respond with warm Indian hospitality, gastronomic passion, and structured markdown (bullet points, bold text). Keep responses concise, vivid, and appetizing.';

  /// Initialize Firebase AI Logic with optional Gemini API Key
  void init({String? apiKey}) {
    _apiKey = apiKey;
    final keyToUse = _apiKey ?? const String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (keyToUse.isNotEmpty) {
      try {
        _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: keyToUse,
          systemInstruction: Content.system(_defaultSystemPrompt),
        );
        _chatSession = _model?.startChat();
        debugPrint('Firebase AI Logic initialized with Gemini 1.5 Flash.');
      } catch (e) {
        debugPrint('Firebase AI Logic model init notice: $e');
      }
    }
  }

  /// Sends a message, processes via Gemini API (or Culinary Intelligence fallback),
  /// and automatically commits both user message and AI response to Cloud Firestore.
  Future<ChatMessageModel> sendMessage({
    required String prompt,
    required String uid,
    JeerolaOrderModel? activeOrder,
  }) async {
    final now = DateTime.now();
    final userMsgId = 'user_msg_${now.millisecondsSinceEpoch}';
    final userMsg = ChatMessageModel(
      id: userMsgId,
      text: prompt,
      isUser: true,
      timestamp: now,
    );

    // 1. Immediately persist user message to Cloud Firestore
    await FirebaseFirestoreService.instance.saveChatMessage(
      uid: uid,
      messageId: userMsgId,
      messageData: userMsg.toJson(),
    );

    // Breadcrumb log for Crashlytics
    await FirebaseCrashlyticsService.instance.log('AI Chef Prompt: $prompt (uid: $uid)');

    // 2. Generate AI response via Gemini or Culinary Intelligence Engine with Performance Tracing
    String replyText = '';
    List<String> followUps = [];
    String? recipeId;

    if (_chatSession != null) {
      try {
        final response = await FirebasePerformanceService.instance.traceOperation(
          'gemini_ai_inference',
          () => _chatSession!.sendMessage(Content.text(prompt)),
          attributes: {'prompt_length': prompt.length.toString()},
        );
        replyText = response.text ?? '';
      } catch (e, stack) {
        debugPrint('Gemini live stream error, falling back to Culinary Intelligence Engine: $e');
        await FirebaseCrashlyticsService.instance.recordError(
          e,
          stack,
          reason: 'Gemini AI Logic inference fallback',
        );
      }
    }

    if (replyText.isEmpty) {
      final fallback = _generateCulinaryIntelligenceResponse(
        prompt: prompt,
        activeOrder: activeOrder,
      );
      replyText = fallback.text;
      followUps = fallback.suggestedFollowUps;
      recipeId = fallback.relatedRecipeId;
    }

    final aiMsgId = 'ai_msg_${DateTime.now().millisecondsSinceEpoch}';
    final aiMsg = ChatMessageModel(
      id: aiMsgId,
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedFollowUps: followUps,
      relatedRecipeId: recipeId,
    );

    // 3. Persist AI response to Cloud Firestore
    await FirebaseFirestoreService.instance.saveChatMessage(
      uid: uid,
      messageId: aiMsgId,
      messageData: aiMsg.toJson(),
    );

    return aiMsg;
  }

  /// Loads chat history from Cloud Firestore
  Future<List<ChatMessageModel>> loadChatHistory(String uid) async {
    final storedMessages = await FirebaseFirestoreService.instance.getChatMessages(uid);
    if (storedMessages.isNotEmpty) {
      return storedMessages.map((m) => ChatMessageModel.fromJson(m)).toList();
    }

    // Default seed welcome conversation
    final welcome = ChatMessageModel(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Namaste! 🙏 I am your **Jeerola Royal AI Chef & Culinary Concierge**.\n\n'
          'I am here to guide your culinary journey with authentic cumin recipes, royal spice pairing, pure-veg adjustments, and live kitchen tracking.\n\n'
          'What would you like to explore today?',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedFollowUps: [
        'How do I dry roast cumin seeds perfectly?',
        'Where is my active order right now?',
        'Suggest a 20-min royal dinner recipe',
        'Tell me about Swaminarayan Hing-free spices',
      ],
    );

    await FirebaseFirestoreService.instance.saveChatMessage(
      uid: uid,
      messageId: welcome.id,
      messageData: welcome.toJson(),
    );

    return [welcome];
  }

  /// Culinary Intelligence Fallback Engine
  ChatMessageModel _generateCulinaryIntelligenceResponse({
    required String prompt,
    JeerolaOrderModel? activeOrder,
  }) {
    final lower = prompt.toLowerCase();

    // 1. Order Tracking Query
    if (lower.contains('order') || lower.contains('track') || lower.contains('delivery') || lower.contains('status')) {
      if (activeOrder != null) {
        return ChatMessageModel(
          id: '',
          text: '📦 **Active Order Telemetry — ${activeOrder.orderId}**\n\n'
              '• **Current Status**: ${activeOrder.status.displayName}\n'
              '• **Estimated Arrival**: ~${activeOrder.estimatedMinutesRemaining} minutes\n'
              '• **Distance**: ${activeOrder.formattedDistanceRemaining}\n'
              '• **Delivery Captain**: ${activeOrder.rider.name} (${activeOrder.rider.vehicleNumber})\n'
              '• **Handover PIN**: **${activeOrder.handoverOtp}**\n'
              '• **Kitchen Note**: ${activeOrder.kitchenNote}\n\n'
              'Your meal is being tracked live in real-time with thermal insulation.',
          isUser: false,
          timestamp: DateTime.now(),
          suggestedFollowUps: [
            'What items are in my order?',
            'Call Kitchen Helpdesk',
            'Suggest a dessert to pair with this meal',
          ],
        );
      } else {
        return ChatMessageModel(
          id: '',
          text: 'You currently have no active deliveries. Would you like to order our signature **Royal Jeera Murgh Dum Handi** or freshly roasted whole cumin from the Jeerola Kitchen?',
          isUser: false,
          timestamp: DateTime.now(),
          suggestedFollowUps: [
            'Explore Royal Curries',
            'View Artisan Spice Pouches',
          ],
        );
      }
    }

    // 2. Roasting Cumin / Jeera Science
    if (lower.contains('roast') || lower.contains('cumin') || lower.contains('jeera') || lower.contains('temper')) {
      return ChatMessageModel(
        id: '',
        text: '👑 **The Science of Royal Cumin Roasting (Jeerola Secret)**\n\n'
            '1. **Dry Roasting Temperature**: Heat a heavy iron or clay pan to **160°C – 175°C** (medium-low flame). Never roast on high flame as cumin oils volatilize easily.\n'
            '2. **The Color Shift**: Swirl the seeds continuously for **90 to 120 seconds** until the golden-brown shade deepens to a warm royal amber.\n'
            '3. **Aroma Bloom**: You will detect a warm, earthy, nutty fragrance with faint citrus undertones — that is the **cuminaldehyde** activating!\n'
            '4. **Cooling & Grinding**: Remove immediately onto a flat marble slab. Let cool completely before stone-grinding for that signature coarse gourmet texture.\n\n'
            '*Pro-Tip*: Tempering whole cumin in cold-pressed A2 cow ghee enhances bioavailability and soothes digestive fire (*Agni*).',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: [
          'What spices pair best with roasted cumin?',
          'Give me a recipe for Jeera Rice',
          'How does cumin improve gut health?',
        ],
      );
    }

    // 3. Recipe Suggestions
    if (lower.contains('recipe') || lower.contains('dinner') || lower.contains('lunch') || lower.contains('cook') || lower.contains('biryani') || lower.contains('paneer')) {
      return ChatMessageModel(
        id: '',
        text: '🥘 **Signature Recipe: Royal Cumin Dum Biryani**\n\n'
            '• **Prep Time**: 20 mins | **Cook Time**: 35 mins | **Servings**: 4\n'
            '• **Signature Masala**: Pouch #P-04 (Artisan Stone-Ground Roasted Jeera Blend)\n\n'
            '**Key Steps**:\n'
            '1. **The Tadka**: In warm ghee, crackle 1 tbsp royal cumin seeds with green cardamom and bay leaf until fragrant.\n'
            '2. **Layering**: Layer fragrant aged basmati rice over slow-simmered vegetables/paneer infused with roasted cumin powder and mint.\n'
            '3. **Dum Cooking**: Seal with dough or a heavy lid for 20 minutes on slow heat to infuse every rice grain with cumin aroma.\n\n'
            'Would you like me to add all needed ingredients directly to your Shopping List?',
        isUser: false,
        timestamp: DateTime.now(),
        relatedRecipeId: 'rec_02',
        suggestedFollowUps: [
          'Add ingredients to Shopping List',
          'Show Pure Veg / Jain alternative',
          'What side raita goes best with this?',
        ],
      );
    }

    // 4. Pure Veg / Swaminarayan / Jain
    if (lower.contains('veg') || lower.contains('jain') || lower.contains('swaminarayan') || lower.contains('onion') || lower.contains('garlic') || lower.contains('hing')) {
      return ChatMessageModel(
        id: '',
        text: '🌿 **Pure Veg & Swaminarayan Certified Spice Protocol**\n\n'
            'At Jeerola, we maintain strict pure-vegetarian standards:\n'
            '• **100% Hing-Free Options**: Our royal cumin blends use rock salt, dried ginger, and cold-pressed mustard/ghee instead of compounded asafoetida.\n'
            '• **No Onion, No Garlic**: We prepare rich royal tomato-cashew and melon seed gravies that mimic royal Mughlai silkiness without root alliums.\n'
            '• **Certified Clean Kitchen**: Separate preparation vessels tempered with cold-pressed ghee and pure whole cumin.',
        isUser: false,
        timestamp: DateTime.now(),
        suggestedFollowUps: [
          'Show Swaminarayan Khichadi Recipe',
          'Order Hing-Free Spice Pouch',
        ],
      );
    }

    // 5. Default General Response
    return ChatMessageModel(
      id: '',
      text: 'Thank you for consulting the Jeerola AI Chef! 🌿\n\n'
          'I can assist you with:\n'
          '• **Authentic Recipes**: Step-by-step guidance for Jeera curries, biryanis, & street food.\n'
          '• **Spice Pairing**: How to balance stone-ground roasted jeera with coriander, fennel, & garam masala.\n'
          '• **Dietary Customization**: Tailoring any dish to Pure Veg, Jain, or Swaminarayan standards.\n'
          '• **Live Logistics**: Instant delivery tracking and ETA for your kitchen orders.\n\n'
          'What would you like to prepare or discover?',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedFollowUps: [
        'How do I dry roast cumin seeds?',
        'Recommend a royal cumin curry',
        'Where is my active order?',
      ],
    );
  }
}
