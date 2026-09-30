import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeerola/core/widgets/quick_commerce_cart_bottom_bar.dart';
import 'package:jeerola/data/models/ingredient_model.dart';
import 'package:jeerola/ui/features/shopping_list/view_models/shopping_list_view_model.dart';
import 'all_screens_render_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('QuickCommerceCartBottomBar renders cleanly without 2.6px overflow on compact 300px width', (tester) async {
    final app = createTestApp(
      const Scaffold(
        body: Center(
          child: SizedBox(
            width: 300,
            child: QuickCommerceCartBottomBar(),
          ),
        ),
      ),
      size: const Size(320, 600),
    );

    await tester.pumpWidget(app);

    // Populate cart outside build phase
    final BuildContext context = tester.element(find.byType(Scaffold));
    final shoppingVm = Provider.of<ShoppingListViewModel>(context, listen: false);
    shoppingVm.addOrIncrementItem(
      id: 'PRD-001',
      name: 'Royal Jeera Powder',
      category: IngredientCategory.spices,
      price: 1250.0,
    );
    shoppingVm.addOrIncrementItem(
      id: 'PRD-002',
      name: 'Kashmiri Mirch',
      category: IngredientCategory.spices,
      price: 1499.0,
    );

    await tester.pumpAndSettle();

    // Verify zero overflow exceptions
    expect(tester.takeException(), isNull);
    expect(find.text('STORES'), findsOneWidget);
    expect(find.text('VIEW CART'), findsOneWidget);
    expect(find.text('2 ITEMS'), findsOneWidget);
  });
}
