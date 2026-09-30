import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/affiliate_model.dart';
import '../../../../data/models/jeerola_order_model.dart';
import '../../../../data/models/shopping_item_model.dart';
import '../../delivery/view_models/jeerola_delivery_view_model.dart';
import '../../delivery/views/jeerola_order_tracking_screen.dart';
import 'order_tracking_screen.dart';

class AffiliateComparisonDialog extends StatefulWidget {
  final List<AffiliateOptionModel> options;
  final List<ShoppingItemModel> items;

  const AffiliateComparisonDialog({
    super.key,
    required this.options,
    this.items = const [],
  });

  @override
  State<AffiliateComparisonDialog> createState() => _AffiliateComparisonDialogState();
}

class _AffiliateComparisonDialogState extends State<AffiliateComparisonDialog> {
  final String? _launchingProviderId = null;

  void _openProvider(AffiliateOptionModel option) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.rocket_launch, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'LAUNCHING SOON ON ${option.name.toUpperCase()}',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 14,
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
                  color: isDark ? AppColors.surfaceContainerLow : AppColors.lightSurfaceWarm,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(option.accentColorValue).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.storefront, color: Color(option.accentColorValue), size: 24),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.name,
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 13,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Blinkit, Big Basket, Zepto, JioMart, DMart Ready Partner Network',
                            style: AppTypography.metadata.copyWith(color: AppColors.outline, fontSize: 9.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'We will launch our products soon on ${option.name}!\nThank you, visit again.',
                style: AppTypography.bodyMd.copyWith(
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.sproutGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.sproutGreen),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.delivery_dining, color: AppColors.sproutGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Instant 10-min Simmering Delivery is active right now on Jeerola!',
                        style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen, fontWeight: FontWeight.bold, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('THANK YOU, VISIT AGAIN', style: TextStyle(color: AppColors.outline, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notified! We will alert you the moment Jeerola launches on ${option.name}.'),
                  backgroundColor: AppColors.sproutGreen,
                ),
              );
            },
            child: const Text('NOTIFY ME', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _copyShoppingListToClipboard() {
    if (widget.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items in shopping list to copy.')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('🛒 JEEROLA SMART SHOPPING LIST');
    buffer.writeln('==============================');
    for (int i = 0; i < widget.items.length; i++) {
      final it = widget.items[i];
      buffer.writeln('${i + 1}. ${it.name} - ${it.packDescription} x ${it.packCount} (~₹${it.estimatedPrice.toInt()})');
    }
    buffer.writeln('==============================');
    buffer.writeln('Total Items: ${widget.items.length}');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Shopping checklist copied! You can paste it into Swiggy Instamart, Blinkit, BigBasket, JioMart or DMart search.'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.90;
    const maxWidth = 540.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surface : Colors.white,
            border: Border.all(color: AppColors.sproutGreen, width: 2),
          ),
          padding: const EdgeInsets.all(14.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AFFILIATE QUICK COMMERCE',
                          style: AppTypography.metadata.copyWith(color: AppColors.primary, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Compare & Access Store',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 18,
                            color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Live comparison across Swiggy Instamart, Blinkit, Zepto, BigBasket, JioMart, and DMart Ready with 1-click access.',
                style: AppTypography.bodySm.copyWith(
                  color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 10),

              // Copy Checklist Action Banner
              if (widget.items.isNotEmpty)
                InkWell(
                  onTap: _copyShoppingListToClipboard,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.copy_all, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Copy ${widget.items.length} items for store search',
                            style: AppTypography.metadata.copyWith(
                              color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary, 
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'COPY LIST',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 10),

              // Direct Jeerola Express Kitchen Delivery Option
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      isDark ? AppColors.surfaceContainerHigh : const Color(0xFFFFF7ED),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.soup_kitchen, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 4,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'DIRECT KITCHEN',
                                  style: AppTypography.metadata.copyWith(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '0% MARKUP',
                                style: AppTypography.metadata.copyWith(
                                  color: AppColors.sproutGreen,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jeerola Express Kitchen Delivery',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            'Fresh spices & pantry dispatched in ~20m with live tracking',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        try {
                          final deliveryVm = Provider.of<JeerolaDeliveryViewModel>(context, listen: false);
                          if (widget.items.isNotEmpty) {
                            final orderItems = widget.items.map((it) {
                              return JeerolaOrderItem(
                                id: it.id,
                                name: it.name,
                                quantity: it.packCount,
                                unitPrice: it.estimatedPrice,
                                category: 'Pantry Grocery',
                              );
                            }).toList();
                            deliveryVm.placeOrder(
                              items: orderItems,
                              deliveryAddress: '24 Gourmet Walk, Suite 402',
                            );
                          }
                        } catch (_) {}
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const JeerolaOrderTrackingScreen(),
                          ),
                        );
                      },
                      child: const Text('ORDER DIRECT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Scrollable Providers list
              Flexible(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: widget.options.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, index) {
                      final option = widget.options[index];
                      final isRec = option.isRecommended;
                      final isLaunching = _launchingProviderId == option.providerId;
                      final brandColor = Color(option.accentColorValue);

                      return BrutalistCard(
                        backgroundColor: isRec 
                            ? (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm) 
                            : (isDark ? AppColors.surfaceContainer : Colors.white),
                        borderColor: isRec ? AppColors.sproutGreen : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                        borderWidth: isRec ? 2.0 : 1.0,
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badge pill row - flexible to prevent overflow
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    color: isRec ? AppColors.primary : brandColor.withValues(alpha: 0.85),
                                    child: Text(
                                      option.badgeText.isNotEmpty
                                          ? option.badgeText
                                          : (isRec ? 'LOGIC CHOICE' : option.name.toUpperCase()),
                                      style: AppTypography.metadata.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${option.coveragePercentage.toStringAsFixed(0)}% IN-STOCK',
                                  style: AppTypography.numericData.copyWith(
                                    color: AppColors.sproutGreen,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Main Store Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Brand Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: brandColor,
                                    border: Border.all(color: Colors.white24, width: 1),
                                  ),
                                  child: Center(
                                    child: Text(
                                      option.name.substring(0, 1),
                                      style: AppTypography.headlineSm.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Title and Tagline
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.name,
                                        style: AppTypography.headlineSm.copyWith(
                                          fontSize: 14,
                                          color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (option.tagline.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2.0),
                                          child: Text(
                                            option.tagline,
                                            style: AppTypography.bodySm.copyWith(
                                              fontSize: 11,
                                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      const SizedBox(height: 3),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 2,
                                        children: [
                                          Text(
                                            '⏱ ${option.deliveryTimeMinutes}m',
                                            style: AppTypography.bodySm.copyWith(
                                              fontSize: 11,
                                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                                            ),
                                          ),
                                          Text(
                                            '• ${option.deliveryFeeText}',
                                            style: AppTypography.bodySm.copyWith(
                                              fontSize: 11,
                                              color: AppColors.sproutGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Price block
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${option.totalCost.toInt()}',
                                      style: AppTypography.headlineSm.copyWith(
                                        color: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (option.missingItemCount > 0)
                                      Text(
                                        '${option.missingItemCount} missing',
                                        style: AppTypography.metadata.copyWith(
                                          color: AppColors.error,
                                          fontSize: 10,
                                        ),
                                      )
                                    else
                                      Text(
                                        '100% In Stock',
                                        style: AppTypography.metadata.copyWith(
                                          color: AppColors.sproutGreen,
                                          fontSize: 10,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Direct Action Buttons: Order & Track
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: BrutalistButton(
                                    text: 'Order on ${option.name}',
                                    isFullWidth: true,
                                    isLoading: isLaunching,
                                    variant: isRec ? BrutalistButtonVariant.primary : BrutalistButtonVariant.outline,
                                    icon: const Icon(Icons.launch, size: 14),
                                    onPressed: () => _openProvider(option),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: BrutalistButton(
                                    text: 'Track',
                                    isFullWidth: true,
                                    variant: BrutalistButtonVariant.secondary,
                                    icon: const Icon(Icons.local_shipping_outlined, size: 14),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => OrderTrackingScreen(
                                            option: option,
                                            items: widget.items,
                                          ),
                                        ),
                                      );
                                    },
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
