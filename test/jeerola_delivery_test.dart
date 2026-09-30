import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeerola/core/theme/app_theme.dart';
import 'package:jeerola/data/models/jeerola_order_model.dart';
import 'package:jeerola/data/services/jeerola_delivery_service.dart';
import 'package:jeerola/ui/features/delivery/view_models/jeerola_delivery_view_model.dart';
import 'package:jeerola/ui/features/delivery/views/jeerola_order_tracking_screen.dart';

void main() {
  group('Jeerola Express Delivery System Tests', () {
    late JeerolaDeliveryService deliveryService;
    late JeerolaDeliveryViewModel deliveryVm;

    setUp(() {
      deliveryService = JeerolaDeliveryService();
      deliveryVm = JeerolaDeliveryViewModel(deliveryService: deliveryService);
    });

    tearDown(() {
      deliveryService.stopAutoTracking();
    });

    test('Initializes with default active express order and items', () {
      expect(deliveryService.hasActiveDelivery, isTrue);
      final activeOrder = deliveryService.activeOrder;
      expect(activeOrder, isNotNull);
      expect(activeOrder!.orderId, contains('JRL-8942-EXPRESS'));
      expect(activeOrder.status, JeerolaOrderStatus.preparingInKitchen);
      expect(activeOrder.items.length, 3);
      expect(activeOrder.rider.name, 'Vikram Singh');
      expect(activeOrder.handoverOtp, '4829');
      expect(activeOrder.totalAmount, 868.0);
    });

    test('advanceStatus cycles through delivery lifecycle nodes', () {
      // Currently preparingInKitchen -> outForDelivery
      deliveryService.advanceStatus();
      expect(deliveryService.activeOrder!.status, JeerolaOrderStatus.outForDelivery);
      expect(deliveryService.activeOrder!.estimatedMinutesRemaining, 8);
      expect(deliveryService.activeOrder!.progressPercent, 0.85);

      // outForDelivery -> arrived
      deliveryService.advanceStatus();
      expect(deliveryService.activeOrder!.status, JeerolaOrderStatus.arrived);
      expect(deliveryService.activeOrder!.estimatedMinutesRemaining, 1);
      expect(deliveryService.activeOrder!.progressPercent, 0.98);

      // arrived -> delivered
      deliveryService.advanceStatus();
      expect(deliveryService.activeOrder!.status, JeerolaOrderStatus.delivered);
      expect(deliveryService.activeOrder!.estimatedMinutesRemaining, 0);
      expect(deliveryService.orderHistory.length, greaterThanOrEqualTo(1));
    });

    test('startAutoTracking automatically advances progress and updates status', () async {
      // Place a fresh order starting at confirmed status
      deliveryService.placeOrder(
        items: const [
          JeerolaOrderItem(id: 'dish_test', name: 'Jeera Rice', quantity: 1, unitPrice: 150),
        ],
        deliveryAddress: 'Indiranagar 12th Main',
      );
      expect(deliveryService.activeOrder!.status, JeerolaOrderStatus.confirmed);
      final initialProgress = deliveryService.activeOrder!.progressPercent;

      // Start rapid automatic tracking for unit test
      deliveryService.startAutoTracking(
        tickInterval: const Duration(milliseconds: 50),
        progressStep: 0.15,
      );
      expect(deliveryService.isAutoTracking, isTrue);

      // Allow ticks to advance progress (0.15 + 0.15 = 0.30 -> preparingInKitchen threshold >= 0.25)
      await Future.delayed(const Duration(milliseconds: 130));

      expect(deliveryService.activeOrder!.progressPercent, greaterThan(initialProgress));
      expect(deliveryService.activeOrder!.status, JeerolaOrderStatus.preparingInKitchen);

      deliveryService.stopAutoTracking();
      expect(deliveryService.isAutoTracking, isFalse);
    });

    test('placeOrder creates new custom order with 0% delivery fee', () {
      final items = [
        const JeerolaOrderItem(
          id: 'dish_test',
          name: 'Butter Naan Basket',
          quantity: 2,
          unitPrice: 45.0,
        ),
      ];

      final newOrder = deliveryService.placeOrder(
        items: items,
        deliveryAddress: 'Indiranagar 12th Main',
      );

      expect(newOrder.orderId, startsWith('JRL-'));
      expect(newOrder.items.length, 1);
      expect(newOrder.totalAmount, 90.0);
      expect(newOrder.packagingFee, 0.0);
      expect(newOrder.deliveryFee, 0.0);
      expect(newOrder.status, JeerolaOrderStatus.confirmed);
      expect(deliveryService.activeOrder!.orderId, newOrder.orderId);
    });

    testWidgets('JeerolaOrderTrackingScreen renders ETA, captain, PIN pass, and automatic tracking controls',
        (tester) async {
      tester.view.physicalSize = const Size(400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        deliveryService.stopAutoTracking();
      });

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<JeerolaDeliveryViewModel>.value(value: deliveryVm),
          ],
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: const JeerolaOrderTrackingScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Header and order info
      expect(find.text('LIVE ORDER TRACKING'), findsOneWidget);
      expect(find.text('JRL-8942-EXPRESS'), findsOneWidget);
      expect(find.text('SIMULATE STEP'), findsOneWidget);
      expect(find.text('AUTO-TRACK'), findsOneWidget);

      // Live banner
      expect(find.text('AUTOMATIC REAL-TIME TRACKING'), findsOneWidget);

      // ETA and status
      expect(find.text('SIMMERING IN KITCHEN'), findsWidgets);
      expect(find.text('Arriving in ~16 Minutes'), findsOneWidget);

      // Captain Card
      expect(find.text('Vikram Singh'), findsOneWidget);
      expect(find.text('4.95'), findsOneWidget);

      // Handover PIN pass
      expect(find.text('HANDOVER VERIFICATION PIN'), findsOneWidget);
      expect(find.text('4829'), findsOneWidget);

      // Stepper stages
      expect(find.text('Order Placed & Confirmed'), findsOneWidget);
      expect(find.text('Out for Delivery'), findsOneWidget);
      expect(find.text('Arrived & Handover'), findsOneWidget);

      // Tap Simulate Step button to test interaction
      await tester.tap(find.text('SIMULATE STEP'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(deliveryVm.activeOrder!.status, JeerolaOrderStatus.outForDelivery);
      expect(find.text('OUT FOR DELIVERY'), findsWidgets);
    });
  });
}
