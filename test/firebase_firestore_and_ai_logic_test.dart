import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeerola/core/theme/app_theme.dart';
import 'package:jeerola/data/models/jeerola_order_model.dart';
import 'package:jeerola/data/services/firebase_ai_logic_service.dart';
import 'package:jeerola/data/services/firebase_firestore_service.dart';
import 'package:jeerola/data/services/jeerola_delivery_service.dart';
import 'package:jeerola/ui/features/ai_chat/view_models/jeerola_ai_chat_view_model.dart';
import 'package:jeerola/ui/features/ai_chat/views/jeerola_ai_chat_screen.dart';
import 'package:jeerola/ui/features/delivery/view_models/jeerola_delivery_view_model.dart';

void main() {
  group('Cloud Firestore & Firebase AI Logic Integration Tests', () {
    const testUid = 'google_usr_981723461234';

    test('syncAllAppDataToFirestore commits all app data for google_usr_981723461234', () async {
      final success = await FirebaseFirestoreService.instance.syncAllAppDataToFirestore(
        uid: testUid,
      );
      expect(success, isTrue);

      // Verify user profile stored in Firestore
      final profile = await FirebaseFirestoreService.instance.getUserProfile(testUid);
      expect(profile, isNotNull);
      expect(profile!['name'], 'Nehal Patel');
      expect(profile['phone'], '+91 9265754161');
      expect(profile['email'], 'nehalkaneria12345@gmail.com');
      expect(profile['address'], contains('Shahpur, Amdavad'));
      expect(profile['vegMode'], contains('Pure Veg'));

      // Verify orders stored in Firestore
      final orders = await FirebaseFirestoreService.instance.getUserOrders(testUid);
      expect(orders.isNotEmpty, isTrue);
      expect(orders.any((o) => o['orderId'] == 'JRL-8942-EXPRESS'), isTrue);

      // Verify recipes stored in Firestore
      final recipes = await FirebaseFirestoreService.instance.getRecipes();
      expect(recipes.length, greaterThanOrEqualTo(5));

      // Verify products stored in Firestore
      final products = await FirebaseFirestoreService.instance.getProducts();
      expect(products.length, greaterThanOrEqualTo(5));

      // Verify initial AI chat messages stored in Firestore
      final chatHistory = await FirebaseFirestoreService.instance.getChatMessages(testUid);
      expect(chatHistory.isNotEmpty, isTrue);
    });

    test('FirebaseAiLogicService generates culinary intelligence response and stores in Firestore', () async {
      final testOrder = JeerolaOrderModel(
        orderId: 'JRL-8942-EXPRESS',
        status: JeerolaOrderStatus.preparingInKitchen,
        items: const [],
        subtotal: 868.0,
        totalAmount: 868.0,
        deliveryAddress: 'Shahpur, Ahmedabad',
        placedAt: DateTime.now(),
        estimatedMinutesRemaining: 16,
        rider: const JeerolaRider(
          name: 'Vikram Singh',
          phone: '+91 9265754161',
          vehicleNumber: 'KA-03-JR-9901',
        ),
        handoverOtp: '4829',
        kitchenNote: 'Simmering royal spices.',
        progressPercent: 0.50,
      );

      // 1. Query about roasting cumin
      final response1 = await FirebaseAiLogicService.instance.sendMessage(
        prompt: 'How do I roast cumin seeds?',
        uid: testUid,
      );
      expect(response1.text, contains('Cumin Roasting'));
      expect(response1.isUser, isFalse);
      expect(response1.suggestedFollowUps.isNotEmpty, isTrue);

      // 2. Query about order tracking
      final response2 = await FirebaseAiLogicService.instance.sendMessage(
        prompt: 'Where is my active order status?',
        uid: testUid,
        activeOrder: testOrder,
      );
      expect(response2.text, contains('JRL-8942-EXPRESS'));
      expect(response2.text, contains('Vikram Singh'));
      expect(response2.text, contains('4829'));

      // Verify saved in Firestore
      final history = await FirebaseFirestoreService.instance.getChatMessages(testUid);
      expect(history.length, greaterThanOrEqualTo(2));
    });

    testWidgets('JeerolaAiChatScreen renders with AI Logic branding and quick prompts', (tester) async {
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

      expect(find.text('JEEROLA ROYAL AI CHEF'), findsOneWidget);
      expect(find.text('AI LOGIC'), findsOneWidget);
      expect(find.textContaining('google_usr_981723461234'), findsOneWidget);
      expect(find.text('SYNC ALL'), findsOneWidget);

      deliveryService.stopAutoTracking();
    });
  });
}
