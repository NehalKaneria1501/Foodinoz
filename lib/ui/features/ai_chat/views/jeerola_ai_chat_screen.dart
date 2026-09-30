import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../data/services/firebase_firestore_service.dart';
import '../../../../data/services/firebase_free_services.dart';
import '../../delivery/view_models/jeerola_delivery_view_model.dart';
import '../view_models/jeerola_ai_chat_view_model.dart';

class JeerolaAiChatScreen extends StatefulWidget {
  final String? initialPrompt;

  const JeerolaAiChatScreen({super.key, this.initialPrompt});

  @override
  State<JeerolaAiChatScreen> createState() => _JeerolaAiChatScreenState();
}

class _JeerolaAiChatScreenState extends State<JeerolaAiChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      final authUser = FirebaseAuthService.instance.currentUser;
      final targetUid = authUser?.uid ?? FirebaseFirestoreService.defaultTargetUid;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final chatVm = Provider.of<JeerolaAiChatViewModel>(context, listen: false);
        chatVm.loadHistory(targetUid);

        if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
          _handleSend(widget.initialPrompt!);
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();

    final authUser = FirebaseAuthService.instance.currentUser;
    final targetUid = authUser?.uid ?? FirebaseFirestoreService.defaultTargetUid;
    final deliveryVm = Provider.of<JeerolaDeliveryViewModel>(context, listen: false);
    final chatVm = Provider.of<JeerolaAiChatViewModel>(context, listen: false);

    chatVm.sendMessage(
      prompt: text,
      uid: targetUid,
      activeOrder: deliveryVm.activeOrder,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatVm = context.watch<JeerolaAiChatViewModel>();
    final authUser = FirebaseAuthService.instance.currentUser;
    final targetUid = authUser?.uid ?? FirebaseFirestoreService.defaultTargetUid;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'JEEROLA ROYAL AI CHEF',
                    style: AppTypography.headlineSm.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: AppColors.sproutGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.sproutGreen.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    'AI LOGIC',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.sproutGreen,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Firebase AI Logic • Powered by Gemini',
              style: AppTypography.metadata.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Firebase Spark Free Services',
            icon: const Icon(Icons.bolt, color: AppColors.sproutGreen, size: 22),
            onPressed: () => _showFirebaseServicesModal(context),
          ),
          IconButton(
            tooltip: 'Sync All App Data to Firestore',
            icon: chatVm.isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                  )
                : const Icon(Icons.cloud_upload_outlined, color: AppColors.secondary),
            onPressed: chatVm.isSyncing
                ? null
                : () async {
                    final success = await chatVm.syncAllDataToFirestore(uid: targetUid);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'All data successfully stored in Cloud Firestore (jeerola-eefba)!'
                                : 'Sync finished.',
                          ),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Firestore Connection & Target Path Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceContainerHigh : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder)),
            ),
            child: Row(
              children: [
                const Icon(Icons.storage, size: 14, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Firestore: /users/$targetUid',
                    style: AppTypography.metadata.copyWith(
                      color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => chatVm.syncAllDataToFirestore(uid: targetUid),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync, size: 11, color: AppColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'SYNC ALL',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.secondary,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Message List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: chatVm.messages.length + (chatVm.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatVm.messages.length) {
                  return _buildTypingIndicator(context);
                }
                final msg = chatVm.messages[index];
                return _buildMessageBubble(context, msg, onChipTap: (chip) => _handleSend(chip));
              },
            ),
          ),

          // Quick Suggestion Chips
          _buildQuickChipsCarousel(context, onChipTap: (chip) => _handleSend(chip)),

          // Input Bar
          _buildInputBar(context),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary),
            ),
            child: const Icon(Icons.soup_kitchen, size: 16, color: AppColors.secondary),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainerHigh : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Royal AI Chef is formulating advice...',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, dynamic msg, {required Function(String) onChipTap}) {
    final isUser = msg.isUser as bool;
    final text = msg.text as String;
    final followUps = (msg.suggestedFollowUps as List<String>?) ?? [];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isUser) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: AppTypography.bodyMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                shape: BoxShape.circle,
                border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
              ),
              child: Icon(
                Icons.person,
                size: 16,
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // AI Message
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondary),
                ),
                child: const Icon(Icons.soup_kitchen, size: 16, color: AppColors.secondary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BrutalistCard(
                  borderColor: AppColors.secondary.withValues(alpha: isDark ? 0.3 : 0.5),
                  backgroundColor: isDark ? AppColors.surfaceContainerHigh : Colors.white,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'JEEROLA AI CHEF',
                              style: AppTypography.metadata.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '☁️ Firestore',
                            style: AppTypography.metadata.copyWith(
                              color: AppColors.sproutGreen,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        text,
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Follow-up suggestion chips
          if (followUps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 42.0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: followUps.map((chipText) {
                  return ActionChip(
                    label: Text(
                      chipText,
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.secondary,
                        fontSize: 11,
                      ),
                    ),
                    backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                    onPressed: () => onChipTap(chipText),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickChipsCarousel(BuildContext context, {required Function(String) onChipTap}) {
    final quickPrompts = [
      '🥘 How to dry roast cumin seeds?',
      '📍 Where is my active order right now?',
      '✨ Royal Cumin Biryani Recipe',
      '🌿 Swaminarayan Hing-Free spices',
      '🍛 Suggest 20-min dinner',
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: quickPrompts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = quickPrompts[index];
          return ActionChip(
            label: Text(
              prompt,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
              ),
            ),
            backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
            side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
            onPressed: () => onChipTap(prompt.replaceFirst(RegExp(r'^[^\w]+'), '').trim()),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceBlack : AppColors.lightSurfaceWarm,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppColors.outline : AppColors.lightBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _textController,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontSize: 13,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about cumin, recipes, or live orders...',
                    hintStyle: TextStyle(
                      color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextTertiary,
                      fontSize: 12,
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _handleSend,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.secondary, AppColors.primary],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                onPressed: () => _handleSend(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFirebaseServicesModal(BuildContext context) {
    final status = FirebaseFreeServices.instance.getFreeServicesStatus();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, String>> services = [
      {
        'title': 'Firebase Authentication',
        'subtitle': 'Email/Pass, Anonymous & 10k phone/mo free',
        'status': (status['auth_ready'] as bool) ? 'Active' : 'Fallback',
        'quota': '100% Free Tier (Spark)',
        'icon': '🔐',
      },
      {
        'title': 'Cloud Firestore',
        'subtitle': '1 GiB storage, 50k reads/day, 20k writes/day',
        'status': (status['firestore_ready'] as bool) ? 'Active' : 'Ready',
        'quota': '100% Free Tier (Spark)',
        'icon': '🗄️',
      },
      {
        'title': 'Google Analytics for Firebase',
        'subtitle': 'Unlimited custom event tracking & audiences',
        'status': (status['analytics_ready'] as bool) ? 'Active' : 'Ready',
        'quota': 'Unlimited Free',
        'icon': '📊',
      },
      {
        'title': 'Firebase Crashlytics',
        'subtitle': 'Real-time fatal crash & non-fatal error logging',
        'status': (status['crashlytics_ready'] as bool) ? 'Active' : 'Ready',
        'quota': 'Unlimited Free',
        'icon': '🛡️',
      },
      {
        'title': 'Firebase Remote Config',
        'subtitle': 'Dynamic feature flags, delivery ETA & banners',
        'status': (status['remote_config_ready'] as bool) ? 'Active' : 'Ready',
        'quota': 'Unlimited Free',
        'icon': '🎛️',
      },
      {
        'title': 'Firebase Cloud Messaging (FCM)',
        'subtitle': 'Unlimited push notifications for order delivery',
        'status': (status['messaging_ready'] as bool) ? 'Active' : 'Ready',
        'quota': 'Unlimited Free',
        'icon': '🔔',
      },
      {
        'title': 'Firebase Performance Monitoring',
        'subtitle': 'Automated network tracing & custom AI latency',
        'status': (status['performance_ready'] as bool) ? 'Active' : 'Ready',
        'quota': 'Unlimited Free',
        'icon': '⚡',
      },
      {
        'title': 'Firebase AI Logic (Gemini)',
        'subtitle': 'Culinary intelligence & royal recipe generator',
        'status': (status['ai_logic_ready'] as bool) ? 'Active' : 'Ready',
        'quota': 'Google Generative AI Free',
        'icon': '🧠',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceContainerHigh : Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt, color: AppColors.sproutGreen, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FIREBASE SPARK PLAN SERVICES',
                              style: AppTypography.headlineSm.copyWith(
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Project: jeerola-eefba • Cost: \$0.00 / month',
                              style: AppTypography.metadata.copyWith(
                                color: AppColors.sproutGreen,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sproutGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.sproutGreen),
                        ),
                        child: Text(
                          '100% FREE',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.sproutGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: services.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceBlack : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Text(s['icon']!, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s['title']!,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    s['subtitle']!,
                                    style: TextStyle(
                                      color: isDark ? Colors.white60 : AppColors.lightTextSecondary,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.sproutGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    s['status']!,
                                    style: const TextStyle(
                                      color: AppColors.sproutGreen,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  s['quota']!,
                                  style: const TextStyle(
                                    color: AppColors.secondary,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
