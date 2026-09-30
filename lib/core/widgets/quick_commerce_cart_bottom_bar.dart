import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../ui/features/shopping_list/view_models/shopping_list_view_model.dart';
import '../../ui/features/shopping_list/views/affiliate_comparison_dialog.dart';

class QuickCommerceCartBottomBar extends StatelessWidget {
  final VoidCallback? onViewCartPressed;

  const QuickCommerceCartBottomBar({
    super.key,
    this.onViewCartPressed,
  });

  @override
  Widget build(BuildContext context) {
    final shoppingVm = context.watch<ShoppingListViewModel>();
    final items = shoppingVm.items;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCost = shoppingVm.totalCartCost.toInt();
    final itemCount = shoppingVm.totalItemCount;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32), // Dark Emerald Quick-Commerce Green
            Color(0xFF1B5E20),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B5E20).withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cart Icon & Item Count
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),

          // Total Items & Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$itemCount ${itemCount == 1 ? 'ITEM' : 'ITEMS'}',
                        style: AppTypography.metadata.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          color: Colors.white70,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '₹$totalCost',
                        style: AppTypography.headlineSm.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '⚡ 10-15 Mins Delivery Guaranteed',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.saffronYellow,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Compare & Checkout Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Compare Providers Button
              InkWell(
                onTap: () {
                  final options = shoppingVm.affiliateOptions;
                  if (options.isNotEmpty) {
                    showDialog(
                      context: context,
                      builder: (_) => AffiliateComparisonDialog(
                        options: options,
                        items: items,
                      ),
                    );
                  } else if (onViewCartPressed != null) {
                    onViewCartPressed!();
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.compare_arrows, size: 13, color: Colors.white),
                      const SizedBox(width: 3),
                      Text(
                        'STORES',
                        style: AppTypography.metadata.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // View Cart Button
              ElevatedButton(
                onPressed: onViewCartPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1B5E20),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VIEW CART',
                      style: AppTypography.metadata.copyWith(
                        color: const Color(0xFF1B5E20),
                        fontWeight: FontWeight.w900,
                        fontSize: 9.5,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.arrow_forward_ios, size: 9, color: Color(0xFF1B5E20)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
