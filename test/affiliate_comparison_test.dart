import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/data/models/ingredient_model.dart';
import 'package:jeerola/data/models/shopping_item_model.dart';
import 'package:jeerola/data/services/affiliate_service.dart';
import 'package:jeerola/ui/features/shopping_list/views/affiliate_comparison_dialog.dart';

void main() {
  group('Affiliate Integration Tests', () {
    final List<ShoppingItemModel> sampleItems = [
      const ShoppingItemModel(
        id: 'item_1',
        name: 'Onions',
        category: IngredientCategory.vegetables,
        rawQuantity: 500.0,
        bufferedQuantity: 575.0,
        bufferPercent: 15,
        unit: 'g',
        packCount: 1,
        packSize: 1000.0,
        packUnit: 'g',
        estimatedPrice: 40.0,
      ),
      const ShoppingItemModel(
        id: 'item_2',
        name: 'Paneer Block',
        category: IngredientCategory.dairy,
        rawQuantity: 200.0,
        bufferedQuantity: 230.0,
        bufferPercent: 15,
        unit: 'g',
        packCount: 1,
        packSize: 200.0,
        packUnit: 'g',
        estimatedPrice: 90.0,
      ),
    ];

    test('AffiliateService returns all 6 quick commerce providers including Swiggy Instamart', () {
      final service = AffiliateService();
      final options = service.compareProviders(sampleItems);

      expect(options.length, 6);

      final names = options.map((o) => o.name).toList();
      expect(names, contains('Zepto'));
      expect(names, contains('Blinkit'));
      expect(names, contains('Swiggy Instamart'));
      expect(names, contains('BigBasket BBNow'));
      expect(names, contains('JioMart'));
      expect(names, contains('DMart Ready'));

      final swiggy = options.firstWhere((o) => o.providerId == 'swiggy_instamart');
      expect(swiggy.redirectUrl, 'https://www.swiggy.com/instamart');
      expect(swiggy.deliveryTimeMinutes, 15);
      expect(swiggy.accentColorValue, 0xFFFC8019);

      final dmart = options.firstWhere((o) => o.providerId == 'dmart');
      expect(dmart.redirectUrl, 'https://www.dmart.in');
      expect(dmart.badgeText, contains('BEST VALUE'));

      final jioMart = options.firstWhere((o) => o.providerId == 'jiomart');
      expect(jioMart.redirectUrl, 'https://www.jiomart.com');

      final blinkit = options.firstWhere((o) => o.providerId == 'blinkit');
      expect(blinkit.redirectUrl, 'https://blinkit.com');

      final bigBasket = options.firstWhere((o) => o.providerId == 'bigbasket');
      expect(bigBasket.redirectUrl, 'https://www.bigbasket.com');
    });

    testWidgets('AffiliateComparisonDialog renders all 5 partners without overflow', (tester) async {
      final service = AffiliateService();
      final options = service.compareProviders(sampleItems);

      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AffiliateComparisonDialog(
              options: options,
              items: sampleItems,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AFFILIATE QUICK COMMERCE'), findsOneWidget);
      expect(find.text('Compare & Access Store'), findsOneWidget);
      expect(find.text('COPY LIST'), findsOneWidget);

      // Verify first visible providers
      expect(find.text('Zepto'), findsOneWidget);
      expect(find.text('Blinkit'), findsOneWidget);

      // Scroll to Swiggy Instamart and verify
      await tester.scrollUntilVisible(
        find.text('Swiggy Instamart'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Swiggy Instamart'), findsOneWidget);

      // Scroll to BigBasket and verify
      await tester.scrollUntilVisible(
        find.text('BigBasket BBNow'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('BigBasket BBNow'), findsOneWidget);

      // Scroll to JioMart and verify
      await tester.scrollUntilVisible(
        find.text('JioMart'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('JioMart'), findsOneWidget);

      // Scroll to DMart Ready and verify
      await tester.scrollUntilVisible(
        find.text('DMart Ready'),
        150.0,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('DMart Ready'), findsOneWidget);
      expect(find.text('ORDER ON DMART READY'), findsOneWidget);
    });
  });
}
