import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../data/models/ingredient_model.dart';
import '../../../../data/models/jeerola_order_model.dart';
import '../../../../data/models/shopping_item_model.dart';
import '../../../../data/services/razorpay_payment_service.dart';
import '../../../../data/services/sqlite_database_service.dart';
import '../../delivery/view_models/jeerola_delivery_view_model.dart';
import '../../delivery/views/jeerola_order_tracking_screen.dart';
import '../view_models/shopping_list_view_model.dart';
import 'affiliate_comparison_dialog.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  Widget build(BuildContext context) {
    final shoppingVm = context.watch<ShoppingListViewModel>();
    final grouped = shoppingVm.groupedItems;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('SMART SHOPPING CART'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            tooltip: 'Add Custom Item',
            onPressed: () => _showAddCustomItemDialog(context, shoppingVm),
          ),
          if (shoppingVm.items.isNotEmpty)
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: isDark ? AppColors.outline : AppColors.lightTextTertiary),
              tooltip: 'Clear Cart',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: isDark ? AppColors.surface : Colors.white,
                    title: const Text('CLEAR CART?'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                      ElevatedButton(
                        onPressed: () {
                          shoppingVm.clearCart();
                          Navigator.pop(ctx);
                        },
                        child: const Text('CLEAR'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          border: Border(top: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder, width: 1)),
          boxShadow: isDark
              ? null
              : [
                  const BoxShadow(
                    color: Color(0x0C8A4B08),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ESTIMATED CART TOTAL', style: AppTypography.metadata),
                    Text(
                      '₹${shoppingVm.totalCartCost.toInt()}',
                      style: AppTypography.headlineMd.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    '${shoppingVm.completedItemCount}/${shoppingVm.totalItemCount} ITEMS CHECKED',
                    style: AppTypography.numericData.copyWith(
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: shoppingVm.items.isEmpty
                        ? null
                        : () => _confirmAndCompare(context, shoppingVm),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'COMPARE 6 STORES',
                      style: AppTypography.metadata.copyWith(
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: BrutalistButton(
                    text: 'CHECKOUT & SIMMER ⚡',
                    isFullWidth: true,
                    icon: const Icon(Icons.soup_kitchen, size: 18, color: Colors.white),
                    onPressed: shoppingVm.items.isEmpty
                        ? null
                        : () => _proceedToSimmeringDelivery(context, shoppingVm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: shoppingVm.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : shoppingVm.items.isEmpty
              ? _buildEmptyState(context, shoppingVm)
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Instant Dark Stores & Supermarket Comparison Section
                    _buildDarkStoresComparisonSection(context, shoppingVm),

                    // Smart Buffer Explainer Banner
                    BrutalistCard(
                      backgroundColor: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
                      borderColor: AppColors.saffronYellow.withValues(alpha: 0.5),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.saffronYellow, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SMART BUFFER (+15%) & MARKET PACKS ACTIVE',
                                  style: AppTypography.metadata.copyWith(color: AppColors.saffronYellow),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Continuous recipe grams are rounded up to commercial retail packs to prevent mid-cooking shortfalls.',
                                  style: AppTypography.bodySm,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Categories and Items
                    ...grouped.entries.map((entry) {
                      final category = entry.key;
                      final items = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category.displayName.toUpperCase(),
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 13,
                                    letterSpacing: 1.2,
                                    color: AppColors.sproutGreen,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                                  style: AppTypography.metadata,
                                ),
                              ],
                            ),
                          ),
                          ...items.map((item) => _ShoppingRow(item: item, vm: shoppingVm)),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ShoppingListViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: isDark ? AppColors.outline : AppColors.lightBorder,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Cart is Empty',
              style: AppTypography.headlineMd.copyWith(
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Products are never auto-added. Add missing ingredients directly from any recipe or add custom grocery items.',
              style: AppTypography.bodySm.copyWith(
                color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            BrutalistButton(
              text: 'Add Custom Grocery Item',
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              onPressed: () => _showAddCustomItemDialog(context, vm),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // INSTANT DARK STORES & SUPERMARKET LIVE PRICE DIFFERENCE COMPARISON
  // =========================================================================
  Widget _buildDarkStoresComparisonSection(BuildContext context, ShoppingListViewModel shoppingVm) {
    final baseCost = shoppingVm.totalCartCost;
    final stores = [
      {
        'name': 'DMart Ready',
        'badge': 'CHEAPEST (33% OFF)',
        'badgeColor': const Color(0xFF008848),
        'eta': 'Same Day Slot',
        'deliveryFee': 'FREE',
        'cost': (baseCost * 0.76).round(),
        'savings': (baseCost * 0.24).round(),
        'color': const Color(0xFF008848),
        'icon': Icons.price_check,
      },
      {
        'name': 'Zepto',
        'badge': '10 MINS DROP',
        'badgeColor': const Color(0xFF9C27B0),
        'eta': '10 Mins',
        'deliveryFee': '₹15',
        'cost': (baseCost * 1.02 + 15).round(),
        'savings': 0,
        'color': const Color(0xFF9C27B0),
        'icon': Icons.bolt,
      },
      {
        'name': 'Blinkit',
        'badge': '100% FRESH',
        'badgeColor': const Color(0xFFF8CB46),
        'eta': '12 Mins',
        'deliveryFee': '₹15',
        'cost': (baseCost * 1.0 + 15).round(),
        'savings': 0,
        'color': const Color(0xFFF8CB46),
        'icon': Icons.shopping_basket,
      },
      {
        'name': 'Swiggy Instamart',
        'badge': 'INSTANT DROP',
        'badgeColor': const Color(0xFFFC8019),
        'eta': '15 Mins',
        'deliveryFee': '₹20',
        'cost': (baseCost * 1.03 + 20).round(),
        'savings': 0,
        'color': const Color(0xFFFC8019),
        'icon': Icons.delivery_dining,
      },
      {
        'name': 'BigBasket BBNow',
        'badge': 'ORGANIC FRESH',
        'badgeColor': const Color(0xFF84C225),
        'eta': '25 Mins',
        'deliveryFee': '₹10',
        'cost': (baseCost * 0.95 + 10).round(),
        'savings': (baseCost * 0.05 - 10).round().clamp(0, 9999),
        'color': const Color(0xFF84C225),
        'icon': Icons.eco,
      },
      {
        'name': 'JioMart',
        'badge': 'BULK VALUE',
        'badgeColor': const Color(0xFF0078AD),
        'eta': 'Express Drop',
        'deliveryFee': 'FREE',
        'cost': (baseCost * 0.88).round(),
        'savings': (baseCost * 0.12).round(),
        'color': const Color(0xFF0078AD),
        'icon': Icons.inventory_2,
      },
      {
        'name': 'Jeerola Kitchen',
        'badge': 'CHEF SIMMER KIT',
        'badgeColor': const Color(0xFFE64A19),
        'eta': '18-22 Mins',
        'deliveryFee': 'FREE',
        'cost': (baseCost * 0.90).round(),
        'savings': (baseCost * 0.10).round(),
        'color': const Color(0xFFE64A19),
        'icon': Icons.soup_kitchen,
      },
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerLow : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'STORE PRICE COMPARISON',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondary,
                      fontSize: 10.5,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AffiliateComparisonDialog(
                      options: shoppingVm.affiliateOptions,
                      items: shoppingVm.items,
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'COMPARE ALL ⇗',
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Live price differences across quick-commerce dark stores & supermarkets for your active cart:',
            style: AppTypography.bodySm.copyWith(
              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stores.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final s = stores[index];
                final storeColor = s['color'] as Color;
                final badgeColor = s['badgeColor'] as Color;
                final isCheapest = index == 0;
                final isJeerola = s['name'] == 'Jeerola Kitchen';
                final isDark = Theme.of(context).brightness == Brightness.dark;

                return InkWell(
                  onTap: () {
                    if (isJeerola) {
                      _proceedToSimmeringDelivery(context, shoppingVm);
                    } else {
                      _showStoreComingSoonDialog(context, s['name'] as String, storeColor);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 148,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: isCheapest
                          ? const Color(0xFF008848).withValues(alpha: 0.12)
                          : isJeerola
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : (isDark ? AppColors.surfaceContainer : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCheapest
                            ? const Color(0xFF008848)
                            : isJeerola
                                ? AppColors.primary
                                : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        width: (isCheapest || isJeerola) ? 1.5 : 1.0,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              const BoxShadow(
                                color: Color(0x0A8A4B08),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s['badge'] as String,
                                  style: AppTypography.metadata.copyWith(
                                    color: Colors.white,
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Icon(s['icon'] as IconData, size: 13, color: storeColor),
                          ],
                        ),
                        Text(
                          s['name'] as String,
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${s['cost']}',
                              style: AppTypography.headlineSm.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: isCheapest
                                    ? const Color(0xFF4CAF50)
                                    : isJeerola
                                        ? AppColors.primary
                                        : (isDark ? Colors.white : AppColors.lightTextPrimary),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${s['eta']})',
                              style: AppTypography.metadata.copyWith(
                                fontSize: 8.5,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          (s['savings'] as int) > 0
                              ? 'Save ₹${s['savings']} • Del: ${s['deliveryFee']}'
                              : 'Del: ${s['deliveryFee']} • Fast Dispatch',
                          style: AppTypography.metadata.copyWith(
                            fontSize: 8.5,
                            color: (s['savings'] as int) > 0 ? const Color(0xFF4CAF50) : AppColors.secondary,
                            fontWeight: (s['savings'] as int) > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // SIMMERING LIVE DELIVERY CHECKOUT FLOW
  // =========================================================================
  void _proceedToSimmeringDelivery(BuildContext context, ShoppingListViewModel vm) {
    final orderItems = vm.items.map((item) {
      return JeerolaOrderItem(
        id: item.id,
        name: item.name,
        quantity: item.packCount,
        unitPrice: item.estimatedPrice,
        isChefSpecial: item.category == IngredientCategory.spices,
        category: item.category.displayName,
      );
    }).toList();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.soup_kitchen, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'SIMMERING DELIVERY',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flash_on, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CHEF EXPRESS DISPATCH • 18-22 MINS',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.5,
                                ),
                              ),
                              Text(
                                'Fresh stone-ground gravies simmered to order and dispatched hot.',
                                style: AppTypography.bodySm.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('DELIVERY ADDRESS', style: AppTypography.metadata),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceWarm,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '24 Gourmet Walk, Suite 402, Mumbai',
                            style: AppTypography.bodySm.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('ORDER SUMMARY', style: AppTypography.metadata),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${vm.totalItemCount} Cart Items', style: AppTypography.bodySm),
                      Text('₹${vm.totalCartCost.toInt()}', style: AppTypography.numericData),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Simmer Express Delivery',
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text('FREE', style: AppTypography.numericData.copyWith(color: AppColors.sproutGreen)),
                    ],
                  ),
                  Divider(height: 16, color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'FINAL PAYABLE',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 13,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        '₹${vm.totalCartCost.toInt()}',
                        style: AppTypography.headlineSm.copyWith(color: AppColors.primary, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? AppColors.secondary : AppColors.lightTextSecondary,
                      side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);

                      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

                      // Open Razorpay Payment Gateway
                      final paymentResult = await RazorpayPaymentService.openRazorpayCheckout(
                        context: context,
                        amountInRupees: vm.totalCartCost,
                        orderId: orderId,
                        customerName: 'Nehal Patel',
                        customerContact: '+91 9265754161',
                        customerEmail: 'nehalkaneria12345@gmail.com',
                        note: 'Jeerola Gourmet Simmering Kitchen (${vm.totalItemCount} items)',
                      );

                      if (paymentResult != null && paymentResult.isSuccess) {
                        // Save Order to SQLite Database
                        await SQLiteDatabaseService.instance.saveOrder(
                          orderId: orderId,
                          storeName: 'Jeerola Kitchen',
                          totalAmount: vm.totalCartCost,
                          status: 'Simmering Live in Kitchen',
                          dateStr: DateTime.now().toString().split('.')[0],
                          items: orderItems.map((i) => i.name).toList(),
                        );

                        if (!context.mounted) return;
                        final deliveryVm = context.read<JeerolaDeliveryViewModel>();
                        deliveryVm.placeOrder(
                          items: orderItems,
                          deliveryAddress: '24 Gourmet Walk, Suite 402, Mumbai',
                        );
                        vm.clearCart();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const JeerolaOrderTrackingScreen(),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isDark ? AppColors.gridLine : AppColors.lightBorder,
                                width: 1,
                              ),
                            ),
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.sproutGreen, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Payment Successful via Razorpay (${paymentResult.paymentId})! Order saved in SQLite & simmering live 🔥',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurface,
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      } else if (paymentResult != null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              content: Text(
                                'Payment ${paymentResult.errorMessage ?? "failed"}. Order was not placed.',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'PAY & SIMMER WITH RAZORPAY 🔥',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showStoreComingSoonDialog(BuildContext context, String storeName, Color storeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: storeColor.withValues(alpha: 0.5), width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: storeColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.storefront, color: storeColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                storeName,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.35) : AppColors.lightSurfaceWarm,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.gold, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'We will launch our products soon on $storeName! Thank you, visit again.',
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'In the meantime, you can get instant 20-min delivery directly with fresh stone-ground spice kits from Jeerola Kitchen!',
                style: AppTypography.metadata.copyWith(
                  color: isDark ? AppColors.outline : AppColors.lightTextSecondary,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK, VISIT AGAIN', style: TextStyle(color: AppColors.secondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final shoppingVm = context.read<ShoppingListViewModel>();
              _proceedToSimmeringDelivery(context, shoppingVm);
            },
            child: const Text('ORDER VIA JEEROLA ⚡'),
          ),
        ],
      ),
    );
  }

  void _confirmAndCompare(BuildContext context, ShoppingListViewModel vm) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.surface : Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text('FINALIZE SHOPPING LIST?', style: AppTypography.headlineSm),
          content: Text(
            'You have ${vm.totalItemCount} consolidated items totaling ~₹${vm.totalCartCost.toInt()}. Ready to view the best delivery options from Blinkit, BigBasket, JioMart, DMart Ready & Zepto?',
            style: AppTypography.bodyMd,
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('EDIT LIST'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                showDialog(
                  context: context,
                  builder: (_) => AffiliateComparisonDialog(
                    options: vm.affiliateOptions,
                    items: vm.items,
                  ),
                );
              },
              child: const Text('PROCEED TO CHECKOUT'),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomItemDialog(BuildContext context, ShoppingListViewModel vm) {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '45');
    final qtyController = TextEditingController(text: '1');
    IngredientCategory selectedCategory = IngredientCategory.vegetables;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? AppColors.surface : Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              title: Text('ADD CUSTOM GROCERY ITEM', style: AppTypography.headlineSm.copyWith(fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ITEM NAME', style: AppTypography.metadata),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: AppTypography.bodyMd,
                      decoration: InputDecoration(
                        hintText: 'e.g. Fresh Milk, Bread, Lemons',
                        fillColor: isDark ? AppColors.surfaceBlack : AppColors.lightSurfaceWarm,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('CATEGORY', style: AppTypography.metadata),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<IngredientCategory>(
                      initialValue: selectedCategory,
                      dropdownColor: isDark ? AppColors.surfaceContainer : Colors.white,
                      items: IngredientCategory.values.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat.displayName, style: AppTypography.bodySm),
                        );
                      }).toList(),
                      onChanged: (cat) {
                        if (cat != null) {
                          setDialogState(() => selectedCategory = cat);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PACK COUNT', style: AppTypography.metadata),
                              const SizedBox(height: 6),
                              TextField(
                                controller: qtyController,
                                keyboardType: TextInputType.number,
                                style: AppTypography.numericData,
                                decoration: const InputDecoration(hintText: '1'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('EST. PRICE (₹)', style: AppTypography.metadata),
                              const SizedBox(height: 6),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                style: AppTypography.numericData,
                                decoration: const InputDecoration(hintText: '45'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final price = double.tryParse(priceController.text) ?? 45.0;
                      final qty = double.tryParse(qtyController.text) ?? 1.0;
                      vm.addCustomItem(
                        name: name,
                        category: selectedCategory,
                        quantity: qty,
                        unit: 'pack',
                        estimatedPrice: price,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added $name to Smart Shopping Cart')),
                      );
                    }
                  },
                  child: const Text('ADD TO CART'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ShoppingRow extends StatefulWidget {
  final ShoppingItemModel item;
  final ShoppingListViewModel vm;

  const _ShoppingRow({required this.item, required this.vm});

  @override
  State<_ShoppingRow> createState() => _ShoppingRowState();
}

class _ShoppingRowState extends State<_ShoppingRow> {
  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final vm = widget.vm;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: item.isChecked
            ? (isDark ? AppColors.primaryContainer.withValues(alpha: 0.2) : const Color(0xFFFFECE5))
            : (isDark ? AppColors.surfaceContainer : Colors.white),
        border: Border.all(
          color: item.isChecked ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            // Checkbox
            Checkbox(
              value: item.isChecked,
              onChanged: (_) => vm.toggleItemCheck(item.id),
            ),
            const SizedBox(width: 8),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: item.isChecked ? TextDecoration.lineThrough : null,
                            color: item.isChecked
                                ? (isDark ? AppColors.onSurfaceVariant : AppColors.lightTextTertiary)
                                : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Saffron Yellow Buffer Indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: isDark ? AppColors.surfaceBlack : AppColors.lightSurfaceWarm,
                        child: Text(
                          '+${item.bufferPercent}%',
                          style: AppTypography.metadata.copyWith(
                            color: isDark ? AppColors.saffronYellow : const Color(0xFFC85A32),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pack: ${item.packDescription}',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.sproutGreen,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(color: isDark ? AppColors.outlineVariant : AppColors.lightBorder)),
                      const SizedBox(width: 6),
                      Text(
                        '₹${item.estimatedPrice.toInt()}',
                        style: AppTypography.numericData.copyWith(
                          fontSize: 12,
                          color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Stepper
            QuantityStepper(
              value: item.packCount,
              minValue: 0,
              maxValue: 20,
              onChanged: (newCount) => vm.updatePackCount(item.id, newCount),
            ),
            const SizedBox(width: 4),

            // Remove Button
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.outline),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Remove Item',
              onPressed: () => vm.removeItem(item.id),
            ),
          ],
        ),
      ),
    );
  }
}
