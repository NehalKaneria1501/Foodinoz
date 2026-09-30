import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../../../../core/utils/invoice_download_helper.dart';
import '../../../../data/models/jeerola_order_model.dart';
import '../view_models/jeerola_delivery_view_model.dart';

class JeerolaOrderTrackingScreen extends StatefulWidget {
  final String? initialOrderId;

  const JeerolaOrderTrackingScreen({super.key, this.initialOrderId});

  @override
  State<JeerolaOrderTrackingScreen> createState() =>
      _JeerolaOrderTrackingScreenState();
}

class _JeerolaOrderTrackingScreenState extends State<JeerolaOrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  JeerolaDeliveryViewModel? _deliveryVm;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vm = Provider.of<JeerolaDeliveryViewModel>(context, listen: false);
    if (_deliveryVm != vm) {
      _deliveryVm = vm;
      // Auto-start live tracking engine automatically when viewing tracking screen
      if (vm.hasActiveDelivery && !vm.isAutoTracking) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _deliveryVm?.startAutoTracking();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _deliveryVm?.stopAutoTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deliveryVm = context.watch<JeerolaDeliveryViewModel>();
    final order = deliveryVm.activeOrder;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (order == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'JEEROLA ORDER TRACKING',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delivery_dining_outlined,
                size: 64,
                color: AppColors.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No Active Deliveries',
                style: AppTypography.headlineMd.copyWith(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your hot meals and spice orders will appear here.',
                style: AppTypography.bodySm.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariant
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20),
              BrutalistButton(
                text: 'Order from Kitchen',
                variant: BrutalistButtonVariant.primary,
                onPressed: () {
                  deliveryVm.resetOrder();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVE ORDER TRACKING',
              style: AppTypography.metadata.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              order.orderId,
              style: AppTypography.headlineSm.copyWith(
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Download Tax Invoice (PDF)',
            icon: const Icon(
              Icons.receipt_long,
              size: 20,
              color: AppColors.primary,
            ),
            onPressed: () {
              InvoiceDownloadHelper.downloadInvoice(
                context: context,
                orderId: order.orderId,
                items: order.items
                    .map(
                      (it) => {
                        'name': it.name,
                        'qty': it.quantity,
                        'price': it.unitPrice,
                      },
                    )
                    .toList(),
                totalAmount: order.totalAmount,
                deliveryAddress: order.deliveryAddress,
                isDark: isDark,
              );
            },
          ),
          Center(
            child: InkWell(
              onTap: () => deliveryVm.toggleAutoTracking(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: deliveryVm.isAutoTracking
                      ? AppColors.sproutGreen.withValues(alpha: 0.15)
                      : (isDark
                            ? AppColors.surfaceContainerHigh
                            : AppColors.lightSurfaceWarm),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: deliveryVm.isAutoTracking
                        ? AppColors.sproutGreen
                        : (isDark ? AppColors.outline : AppColors.lightBorder),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: deliveryVm.isAutoTracking
                              ? AppColors.sproutGreen
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      deliveryVm.isAutoTracking ? 'AUTO-TRACK' : 'PAUSED',
                      style: TextStyle(
                        color: deliveryVm.isAutoTracking
                            ? AppColors.sproutGreen
                            : Colors.orange,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: ElevatedButton.icon(
              onPressed: () => deliveryVm.advanceStatus(),
              icon: Icon(
                Icons.fast_forward,
                size: 12,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
              label: Text(
                'SIMULATE STEP',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.surfaceContainerHigh
                    : AppColors.lightSurfaceWarm,
                foregroundColor: isDark
                    ? Colors.white
                    : AppColors.lightTextPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
                text: 'Call Kitchen Support',
                variant: BrutalistButtonVariant.outline,
                icon: const Icon(Icons.phone, size: 16),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Connecting to Jeerola Kitchen Helpdesk (+91 80 4099 2200)...',
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BrutalistButton(
                text: 'Done / Dashboard',
                variant: BrutalistButtonVariant.primary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 0. Automatic Live Tracking Banner
          _buildAutoTrackingBanner(deliveryVm, order),
          const SizedBox(height: 16),

          // 1. Live Hero Card with ETA
          _buildEtaHeroCard(order),
          const SizedBox(height: 16),

          // 2. Animated Live Delivery Map Simulation
          _buildMapSimulationCard(order),
          const SizedBox(height: 16),

          // 3. 4-Stage Preparation & Delivery Stepper
          _buildStatusStepperCard(order),
          const SizedBox(height: 16),

          // 4. Delivery Captain Contact Card
          _buildCaptainCard(order),
          const SizedBox(height: 16),

          // 5. Handover PIN Pass
          _buildHandoverPinCard(order),
          const SizedBox(height: 16),

          // 6. Itemized Order Details & Bill
          _buildOrderSummaryCard(order),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAutoTrackingBanner(
    JeerolaDeliveryViewModel deliveryVm,
    JeerolaOrderModel order,
  ) {
    if (order.status == JeerolaOrderStatus.delivered) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.sproutGreen.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.sproutGreen.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.sproutGreen,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORDER DELIVERED SUCCESSFULLY',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.sproutGreen,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Your royal meal was safely received. Automatic tracking completed.',
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: deliveryVm.isAutoTracking
              ? AppColors.sproutGreen.withValues(alpha: 0.5)
              : (isDark ? AppColors.outline : AppColors.lightBorder),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: deliveryVm.isAutoTracking
                        ? AppColors.sproutGreen
                        : Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: deliveryVm.isAutoTracking
                            ? AppColors.sproutGreen
                            : Colors.orange,
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  deliveryVm.isAutoTracking
                      ? 'AUTOMATIC REAL-TIME TRACKING'
                      : 'AUTO-TRACKING PAUSED',
                  style: AppTypography.metadata.copyWith(
                    color: deliveryVm.isAutoTracking
                        ? AppColors.sproutGreen
                        : Colors.orange,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    fontSize: 11,
                  ),
                ),
              ),
              Text(
                '${(order.progressPercent * 100).toInt()}% COMPLETED',
                style: AppTypography.numericData.copyWith(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: order.progressPercent,
              backgroundColor: isDark
                  ? AppColors.surfaceBlack
                  : AppColors.lightSurfaceWarm,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.sproutGreen,
              ),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  order.formattedDistanceRemaining,
                  style: AppTypography.metadata.copyWith(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => deliveryVm.toggleAutoTracking(),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        deliveryVm.isAutoTracking
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        deliveryVm.isAutoTracking
                            ? 'Pause Tracking'
                            : 'Resume Auto-Track',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEtaHeroCard(JeerolaOrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
            AppColors.secondary.withValues(alpha: isDark ? 0.15 : 0.08),
            isDark ? AppColors.surfaceContainerHigh : Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: AppColors.sproutGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sproutGreen,
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  order.status.displayName.toUpperCase(),
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.sproutGreen,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceBlack
                      : AppColors.lightSurfaceWarm,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.estimatedMinutesRemaining > 0
                          ? '~${order.estimatedMinutesRemaining} MINS'
                          : 'ARRIVED',
                      style: AppTypography.numericData.copyWith(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.estimatedMinutesRemaining > 0
                ? 'Arriving in ~${order.estimatedMinutesRemaining} Minutes'
                : 'Captain Has Arrived at Your Gate!',
            style: AppTypography.headlineMd.copyWith(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            order.kitchenNote,
            style: AppTypography.bodySm.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariant
                  : AppColors.lightTextSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSimulationCard(JeerolaOrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BrutalistCard(
      borderColor: AppColors.primary.withValues(alpha: 0.4),
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'LIVE ROUTE TELEMETRY',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.sproutGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.sproutGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  order.formattedDistanceRemaining.toUpperCase(),
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.sproutGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Visual Map Track
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceBlack : const Color(0xFFF2ECE1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.gridLine : AppColors.lightBorder,
              ),
            ),
            child: CustomPaint(
              painter: _DeliveryRoutePainter(
                progress: order.progressPercent,
                primaryColor: AppColors.primary,
                secondaryColor: AppColors.secondary,
                greenColor: AppColors.sproutGreen,
                trackColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceBlack
                  : AppColors.lightSurfaceWarm,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.gridLine : AppColors.lightBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.two_wheeler,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.status == JeerolaOrderStatus.outForDelivery
                              ? 'En Route • 24 km/h'
                              : order.status.displayName,
                          style: AppTypography.metadata.copyWith(
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Auto-Sync Active',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.sproutGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLocationLabel(
                  title: 'Jeerola Kitchen Hub',
                  subtitle: 'Indiranagar Central',
                  icon: Icons.soup_kitchen,
                  color: AppColors.secondary,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.outline,
                ),
              ),
              Expanded(
                child: _buildLocationLabel(
                  title: 'Your Destination',
                  subtitle: order.deliveryAddress.split(',').first,
                  icon: Icons.home,
                  color: AppColors.sproutGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationLabel({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.metadata.copyWith(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: AppTypography.metadata.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariant
                      : AppColors.lightTextSecondary,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusStepperCard(JeerolaOrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stages = [
      {
        'title': 'Order Placed & Confirmed',
        'subtitle': 'Kitchen accepted your order for immediate prep',
        'status': JeerolaOrderStatus.confirmed,
        'icon': Icons.check_circle_outline,
      },
      {
        'title': 'Simmering in Kitchen',
        'subtitle': 'Chef is preparing curries with fresh roasted cumin',
        'status': JeerolaOrderStatus.preparingInKitchen,
        'icon': Icons.soup_kitchen_outlined,
      },
      {
        'title': 'Out for Delivery',
        'subtitle': 'Sealed in thermal carrier bag & dispatched',
        'status': JeerolaOrderStatus.outForDelivery,
        'icon': Icons.delivery_dining_outlined,
      },
      {
        'title': 'Arrived & Handover',
        'subtitle': 'Captain arrives with your hot meal',
        'status': JeerolaOrderStatus.arrived,
        'icon': Icons.pin_drop_outlined,
      },
    ];

    final currentIdx = order.status.index;

    return BrutalistCard(
      borderColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KITCHEN & LOGISTICS TIMELINE',
            style: AppTypography.metadata.copyWith(
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...stages.asMap().entries.map((entry) {
            final idx = entry.key;
            final data = entry.value;
            final isPassed = currentIdx >= idx;
            final isCurrent = currentIdx == idx;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isPassed
                            ? (isCurrent
                                  ? AppColors.primary
                                  : AppColors.sproutGreen)
                            : (isDark
                                  ? AppColors.surfaceContainerHigh
                                  : AppColors.lightSurfaceWarm),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPassed
                              ? (isDark ? Colors.white : AppColors.sproutGreen)
                              : (isDark
                                    ? AppColors.outline
                                    : AppColors.lightBorder),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          isPassed ? Icons.check : (data['icon'] as IconData),
                          size: 14,
                          color: isPassed
                              ? AppColors.surfaceBlack
                              : AppColors.outline,
                        ),
                      ),
                    ),
                    if (idx < stages.length - 1)
                      Container(
                        width: 2,
                        height: 36,
                        color: currentIdx > idx
                            ? AppColors.sproutGreen
                            : (isDark
                                  ? AppColors.gridLine
                                  : AppColors.lightBorder),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] as String,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 13,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isPassed
                              ? (isDark
                                    ? Colors.white
                                    : AppColors.lightTextPrimary)
                              : AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data['subtitle'] as String,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: isPassed
                              ? (isDark
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.lightTextSecondary)
                              : AppColors.outline,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCaptainCard(JeerolaOrderModel order) {
    final rider = order.rider;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrutalistCard(
      borderColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
      backgroundColor: isDark ? AppColors.surfaceContainerHigh : Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondary, width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.sports_motorsports,
                color: AppColors.secondary,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        rider.name,
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.saffronYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 11,
                            color: AppColors.saffronYellow,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rider.rating.toString(),
                            style: AppTypography.metadata.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.saffronYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${rider.badge} • ${rider.vehicleNumber}',
                  style: AppTypography.metadata.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariant
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.sproutGreen),
            tooltip: 'Call Captain',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Calling Captain ${rider.name} at ${rider.phone}...',
                  ),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.secondary,
            ),
            tooltip: 'Message Captain',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Messaging Captain ${rider.name}...'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverPinCard(JeerolaOrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceBlack : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.secondary.withValues(alpha: 0.6)
              : AppColors.primary,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.lock_outline,
                  color: AppColors.secondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HANDOVER VERIFICATION PIN',
                        style: AppTypography.metadata.copyWith(
                          color: AppColors.secondary,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share with captain upon delivery',
                        style: AppTypography.bodySm.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariant
                              : AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceContainerHigh
                  : AppColors.lightSurfaceWarm,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary),
            ),
            child: Text(
              order.handoverOtp,
              style: AppTypography.numericData.copyWith(
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(JeerolaOrderModel order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BrutalistCard(
      borderColor: isDark ? AppColors.gridLine : AppColors.lightBorder,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'ORDER ITEMS (${order.items.length})',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.deliveryAddress.split(',').first,
                  style: AppTypography.metadata.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariant
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...order.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.sproutGreen,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 8,
                      color: AppColors.sproutGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.name} x${item.quantity}',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark
                            ? Colors.white
                            : AppColors.lightTextPrimary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    '₹${item.totalPrice.toInt()}',
                    style: AppTypography.numericData.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
          Divider(
            color: isDark ? AppColors.gridLine : AppColors.lightBorder,
            height: 24,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Packaging & Insulated Thermal Bag',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FREE (₹0)',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.sproutGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Jeerola Express Delivery Fee',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FREE (₹0)',
                style: AppTypography.metadata.copyWith(
                  color: AppColors.sproutGreen,
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.gridLine, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL PAID',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${order.totalAmount.toInt()}',
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                InvoiceDownloadHelper.downloadInvoice(
                  context: context,
                  orderId: order.orderId,
                  items: order.items
                      .map(
                        (it) => {
                          'name': it.name,
                          'qty': it.quantity,
                          'price': it.unitPrice,
                        },
                      )
                      .toList(),
                  totalAmount: order.totalAmount,
                  deliveryAddress: order.deliveryAddress,
                  isDark: isDark,
                );
              },
              icon: const Icon(
                Icons.picture_as_pdf_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              label: const Text(
                'DOWNLOAD OFFICIAL TAX INVOICE (PDF)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryRoutePainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;
  final Color greenColor;
  final Color trackColor;
  final bool isDark;

  _DeliveryRoutePainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
    required this.greenColor,
    required this.trackColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(30, size.height / 2);
    final end = Offset(size.width - 30, size.height / 2);

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, trackPaint);

    // Active progress track
    final currentX = start.dx + (end.dx - start.dx) * progress.clamp(0.0, 1.0);
    final progressPaint = Paint()
      ..shader = LinearGradient(colors: [secondaryColor, primaryColor])
          .createShader(Rect.fromPoints(start, end))
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, Offset(currentX, size.height / 2), progressPaint);

    // Origin Node (Jeerola Kitchen)
    final originPaint = Paint()..color = secondaryColor;
    canvas.drawCircle(start, 8, originPaint);
    canvas.drawCircle(start, 4, Paint()..color = isDark ? Colors.black : Colors.white);

    // Destination Node (Customer Home)
    final destPaint = Paint()..color = greenColor;
    canvas.drawCircle(end, 8, destPaint);
    canvas.drawCircle(end, 4, Paint()..color = isDark ? Colors.black : Colors.white);

    // Rider Scooter Moving Node
    final riderOffset = Offset(currentX, size.height / 2);
    final riderGlow = Paint()
      ..color = primaryColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(riderOffset, 16, riderGlow);

    final riderPaint = Paint()..color = primaryColor;
    canvas.drawCircle(riderOffset, 10, riderPaint);
    canvas.drawCircle(riderOffset, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _DeliveryRoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
