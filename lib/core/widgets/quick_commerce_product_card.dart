import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/quick_commerce_product_model.dart';
import '../../ui/features/shopping_list/view_models/shopping_list_view_model.dart';

import '../../data/services/sqlite_database_service.dart';

class QuickCommerceProductCard extends StatefulWidget {
  final QuickCommerceProductModel product;
  final VoidCallback? onTap;

  const QuickCommerceProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  State<QuickCommerceProductCard> createState() => _QuickCommerceProductCardState();
}

class _QuickCommerceProductCardState extends State<QuickCommerceProductCard> {
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _checkWishlist();
  }

  Future<void> _checkWishlist() async {
    final status = await SQLiteDatabaseService.instance.isInWishlist(widget.product.title) ||
        await SQLiteDatabaseService.instance.isInWishlist(widget.product.id);
    if (mounted && status != _isWishlisted) {
      setState(() => _isWishlisted = status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shoppingVm = context.watch<ShoppingListViewModel>();
    final quantity = shoppingVm.getItemQuantity(widget.product.id);
    final store = widget.product.store;
    final storeColor = Color(store.brandColorHex);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 176,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceContainer : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: quantity > 0
                ? AppColors.primary
                : (isDark ? AppColors.gridLine.withValues(alpha: 0.8) : AppColors.lightBorder),
            width: quantity > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0x0E8A4B08),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Image Container with Badges & Wishlist Button
            Stack(
              children: [
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: isDark ? AppColors.surfaceContainerHigh : const Color(0xFFF2ECE1),
                      child: Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 32,
                          color: AppColors.outline.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                ),
                // Delivery Time Badge (Top Left)
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.82),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: storeColor.withValues(alpha: 0.7), width: 0.8),
                    ),
                    child: Text(
                      store.deliveryTimeText,
                      style: AppTypography.metadata.copyWith(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Wishlist Button (Top Right)
                Positioned(
                  top: 5,
                  right: 5,
                  child: InkWell(
                    onTap: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final added = await SQLiteDatabaseService.instance.toggleWishlist(
                        id: widget.product.id,
                        title: widget.product.title,
                        subtitle: widget.product.packSize,
                        price: widget.product.discountPrice,
                        imageUrl: widget.product.imageUrl,
                        category: widget.product.category.name,
                      );
                      if (!mounted) return;
                      setState(() => _isWishlisted = added);
                      messenger.hideCurrentSnackBar();
                      messenger.showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  added ? Icons.favorite : Icons.favorite_border,
                                  color: added ? AppColors.error : Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    added
                                        ? 'Saved to SQLite Wishlist: ${widget.product.title}'
                                        : 'Removed from Wishlist: ${widget.product.title}',
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: added ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isWishlisted ? AppColors.error : Colors.white30,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _isWishlisted ? Icons.favorite : Icons.favorite_border,
                        size: 14,
                        color: _isWishlisted ? AppColors.error : Colors.white,
                      ),
                    ),
                  ),
                ),
                // Store Origin Chip (Bottom Right of Image)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: storeColor,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      store.displayName.split(' ').first,
                      style: AppTypography.metadata.copyWith(
                        color: store == QuickCommerceStore.blinkit ? Colors.black : Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Discount Tag (Bottom Left of Image)
                if (widget.product.discountPercentage > 0)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.sproutGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${widget.product.discountPercentage}% OFF',
                        style: AppTypography.metadata.copyWith(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Weight / Pack size
                  Text(
                    widget.product.packSize,
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Title
                  SizedBox(
                    height: 28,
                    child: Text(
                      widget.product.title,
                      style: AppTypography.bodySm.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Product Description below all products
                  SizedBox(
                    height: 22,
                    child: Text(
                      widget.product.description,
                      style: AppTypography.metadata.copyWith(
                        color: isDark ? AppColors.outline.withValues(alpha: 0.9) : AppColors.lightTextSecondary,
                        fontSize: 8.5,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Rating and Reviews
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withValues(alpha: 0.6) : const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.gold.withValues(alpha: isDark ? 0.5 : 0.9)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 9, color: AppColors.gold),
                            const SizedBox(width: 2),
                            Text(
                              widget.product.rating.toString(),
                              style: AppTypography.metadata.copyWith(
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '(${widget.product.reviewsCount})',
                          style: AppTypography.metadata.copyWith(
                            color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                            fontSize: 8.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Price and Add Button Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Prices
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
                                    '₹${widget.product.discountPrice.toInt()}',
                                    style: AppTypography.bodySm.copyWith(
                                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (widget.product.mrp > widget.product.discountPrice) ...[
                                    const SizedBox(width: 3),
                                    Text(
                                      '₹${widget.product.mrp.toInt()}',
                                      style: AppTypography.metadata.copyWith(
                                        color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                                        fontSize: 9,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (widget.product.savingsAmount > 0)
                              Text(
                                'Save ₹${widget.product.savingsAmount.toInt()}',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.sproutGreen,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),

                      // + ADD / [ - 1 + ] Stepper Button
                      _buildAddButton(context, shoppingVm, quantity),
                    ],
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    ShoppingListViewModel shoppingVm,
    int quantity,
  ) {
    if (quantity == 0) {
      return InkWell(
        onTap: () {
          shoppingVm.addOrIncrementItem(
            id: widget.product.id,
            name: widget.product.title,
            category: widget.product.category,
            price: widget.product.discountPrice,
            unit: widget.product.packSize,
            packSize: 1,
            packUnit: widget.product.packSize,
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: AppColors.sproutGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Added ${widget.product.title} to cart',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySm.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.surfaceContainerHigh,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.sproutGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.sproutGreen, width: 1.2),
          ),
          child: Text(
            'ADD',
            style: AppTypography.metadata.copyWith(
              color: AppColors.sproutGreen,
              fontWeight: FontWeight.w900,
              fontSize: 10.5,
              letterSpacing: 0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => shoppingVm.decrementOrRemoveItem(widget.product.id),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: Icon(Icons.remove, size: 13, color: Colors.white),
            ),
          ),
          Text(
            '$quantity',
            style: AppTypography.metadata.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10.5,
            ),
          ),
          InkWell(
            onTap: () {
              shoppingVm.addOrIncrementItem(
                id: widget.product.id,
                name: widget.product.title,
                category: widget.product.category,
                price: widget.product.discountPrice,
                unit: widget.product.packSize,
                packSize: 1,
                packUnit: widget.product.packSize,
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              child: Icon(Icons.add, size: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );

  }
}
