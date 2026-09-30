import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/data/services/razorpay_payment_service.dart';

void main() {
  testWidgets('RazorpayCheckoutModal does not overflow on small height constraints (h <= 360.7)', (tester) async {
    // Set small screen size matching the error constraint: w: 600, h: 360.7
    tester.view.physicalSize = const Size(600.0, 360.7);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  RazorpayPaymentService.openRazorpayCheckout(
                    context: context,
                    amountInRupees: 299.0,
                    orderId: 'order_test_123',
                    customerName: 'Nehal Patel',
                    customerContact: '9265754161',
                    customerEmail: 'nehalkaneria12345@gmail.com',
                  );
                },
                child: const Text('PAY'),
              );
            },
          ),
        ),
      ),
    );

    // Tap Pay button to open Razorpay modal bottom sheet
    await tester.tap(find.text('PAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify modal is open and header & payment options are rendered
    expect(find.text('Razorpay'), findsOneWidget);
    expect(find.text('SELECT PAYMENT METHOD'), findsOneWidget);
    expect(find.text('UPI - Google Pay, PhonePe, Paytm'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });
}
