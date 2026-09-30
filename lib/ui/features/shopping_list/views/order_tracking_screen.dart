import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/utils/invoice_download_helper.dart';
import '../../../../data/models/affiliate_model.dart';
import '../../../../data/models/shopping_item_model.dart';

class OrderTrackingScreen extends StatefulWidget {
  final AffiliateOptionModel option;
  final List<ShoppingItemModel> items;

  const OrderTrackingScreen({
    super.key,
    required this.option,
    required this.items,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _currentTrackingStep = 1; // 0: Received, 1: Assembling, 2: In Transit, 3: Delivered

  @override
  Widget build(BuildContext context) {
    final option = widget.option;
    final brandColor = Color(option.accentColorValue);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'ORDER CONFIRMATION & TRACKING',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: 'Simulate Next Logistics Node',
            onPressed: () {
              setState(() {
                _currentTrackingStep = (_currentTrackingStep + 1) % 4;
              });
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
            ),
            child: Text(
              'TXN-9982-A',
              style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surface : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.gridLine : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: BrutalistButton(
                text: 'Launch ${option.name}',
                variant: BrutalistButtonVariant.primary,
                icon: const Icon(Icons.launch, size: 16, color: Colors.white),
                onPressed: () async {
                  final uri = Uri.parse(option.redirectUrl);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Opening ${option.name} web checkout...')),
                      );
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BrutalistButton(
                text: 'Back to Dashboard',
                variant: BrutalistButtonVariant.outline,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Order Header / System Optimized Banner
          BrutalistCard(
            borderColor: brandColor,
            borderWidth: 2,
            backgroundColor: isDark ? AppColors.surfaceContainerLow : Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      color: brandColor,
                      child: const Center(
                        child: Icon(Icons.check, color: AppColors.surfaceBlack, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORDER TRANSMITTED // OPTIMIZED',
                            style: AppTypography.metadata.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dispatched to ${option.name}',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 16,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ESTIMATED ARRIVAL',
                            style: AppTypography.metadata.copyWith(
                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            option.estimatedDeliveryTime,
                            style: AppTypography.numericData.copyWith(
                              color: AppColors.secondaryOrange,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL BILLED',
                            style: AppTypography.metadata.copyWith(
                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${option.totalCost.toInt()}',
                            style: AppTypography.headlineSm.copyWith(color: AppColors.sproutGreen),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logistics Sequence Stepper
          BrutalistCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOGISTICS SEQUENCE (REAL-TIME)',
                  style: AppTypography.headlineSm.copyWith(
                    fontSize: 13,
                    letterSpacing: 1,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimelineStep(
                  stepIndex: 0,
                  title: 'DATA TRANSMISSION RECEIVED',
                  subtitle: 'Direct API handshake confirmed with ${option.name} Dark Store node.',
                  timeText: 'Just now',
                  isCompleted: _currentTrackingStep >= 0,
                  isActive: _currentTrackingStep == 0,
                ),
                _buildTimelineStep(
                  stepIndex: 1,
                  title: 'ASSEMBLING INGREDIENT PACKS',
                  subtitle: 'Automated picker boxing ${widget.items.length} market packs with +15% buffer.',
                  timeText: 'In Progress',
                  isCompleted: _currentTrackingStep > 1,
                  isActive: _currentTrackingStep == 1,
                ),
                _buildTimelineStep(
                  stepIndex: 2,
                  title: 'TRANSIT DISPATCH NODE',
                  subtitle: 'Courier partner assigned for rapid kitchen delivery.',
                  timeText: 'Pending',
                  isCompleted: _currentTrackingStep > 2,
                  isActive: _currentTrackingStep == 2,
                ),
                _buildTimelineStep(
                  stepIndex: 3,
                  title: 'DELIVERED TO KITCHEN',
                  subtitle: 'Ingredients placed in pantry. Ready for Masala Kit Cooking Protocol.',
                  timeText: 'Est. in ${option.estimatedDeliveryTime}',
                  isCompleted: _currentTrackingStep >= 3,
                  isActive: _currentTrackingStep == 3,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Order Manifest Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CONSOLIDATED ORDER MANIFEST',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 13,
                  letterSpacing: 1,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                '${widget.items.length} PACKS',
                style: AppTypography.metadata.copyWith(color: AppColors.sproutGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Manifest Item Rows
          ...widget.items.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainer : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: AppTypography.bodyMd.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${item.packCount} × ${item.packDescription}',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.sproutGreen,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.estimatedPrice.toInt()}',
                    style: AppTypography.numericData.copyWith(
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              final total = widget.items.fold<double>(0, (sum, it) => sum + it.estimatedPrice);
              InvoiceDownloadHelper.downloadInvoice(
                context: context,
                orderId: 'TXN-9982-A',
                items: widget.items.map((it) => {
                  'name': it.name,
                  'qty': it.packCount,
                  'price': it.estimatedPrice / (it.packCount > 0 ? it.packCount : 1),
                }).toList(),
                totalAmount: total,
                storeName: widget.option.name,
                isDark: isDark,
              );
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, size: 16, color: AppColors.primary),
            label: const Text(
              'DOWNLOAD STORE TAX INVOICE (PDF)',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required int stepIndex,
    required String title,
    required String subtitle,
    required String timeText,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color dotColor = isDark ? AppColors.outline : AppColors.lightBorder;
    if (isCompleted) dotColor = AppColors.primary;
    if (isActive) dotColor = AppColors.secondaryOrange;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isActive
                      ? dotColor
                      : (isCompleted
                          ? dotColor
                          : (isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm)),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 12, color: AppColors.surfaceBlack)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? AppColors.primary
                        : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 13,
                            color: isActive
                                ? AppColors.secondaryOrange
                                : (isDark ? AppColors.onSurface : AppColors.lightTextPrimary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeText,
                        style: AppTypography.metadata.copyWith(
                          color: isActive ? AppColors.secondaryOrange : AppColors.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 12,
                      color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
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
}
