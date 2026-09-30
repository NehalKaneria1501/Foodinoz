import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class DeliveryAddressSheet extends StatefulWidget {
  final String currentAddress;
  final ValueChanged<String>? onAddressSelected;

  const DeliveryAddressSheet({
    super.key,
    required this.currentAddress,
    this.onAddressSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required String currentAddress,
    ValueChanged<String>? onAddressSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface : Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DeliveryAddressSheet(
        currentAddress: currentAddress,
        onAddressSelected: onAddressSelected,
      ),
    );
  }

  @override
  State<DeliveryAddressSheet> createState() => _DeliveryAddressSheetState();
}

class _DeliveryAddressSheetState extends State<DeliveryAddressSheet> {
  late String _selectedAddress;

  final List<Map<String, dynamic>> _savedAddresses = [
    {
      'label': 'Home',
      'icon': Icons.home,
      'address': '24 Gourmet Walk, Suite 402, Powai, Mumbai',
      'eta': '10 mins',
      'hub': 'Powai Dark Store (0.8 km)',
    },
    {
      'label': 'Office',
      'icon': Icons.business,
      'address': 'Tower B, WeWork Chromium, JVLR, Andheri East, Mumbai',
      'eta': '12 mins',
      'hub': 'Andheri Hub (1.2 km)',
    },
    {
      'label': 'Parents',
      'icon': Icons.favorite,
      'address': 'Flat 301, Tulsi Villa, Ghatkopar East, Mumbai',
      'eta': '15 mins',
      'hub': 'Ghatkopar Central (2.1 km)',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedAddress = widget.currentAddress;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.outline : AppColors.lightBorder).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CHOOSE DELIVERY LOCATION',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Express Delivery In 10-15 Mins',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: isDark ? AppColors.outline : AppColors.lightTextTertiary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current GPS Button
          InkWell(
            onTap: () {
              const currentGps = 'Current Location • Near Hiranandani Gardens, Mumbai';
              setState(() => _selectedAddress = currentGps);
              if (widget.onAddressSelected != null) {
                widget.onAddressSelected!(currentGps);
              }
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceContainer : AppColors.lightSurfaceWarm,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.sproutGreen.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.sproutGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.my_location, color: AppColors.sproutGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Use Current Location',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.sproutGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Detects nearest Zepto & Blinkit instant dark store',
                          style: AppTypography.metadata.copyWith(
                            color: AppColors.outline,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.outline),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text('SAVED ADDRESSES', style: AppTypography.metadata.copyWith(color: AppColors.secondary)),
          const SizedBox(height: 10),

          // Saved Address List
          ..._savedAddresses.map((addr) {
            final isSelected = _selectedAddress.contains(addr['label'] as String) ||
                _selectedAddress == addr['address'];

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () {
                  final full = '${addr['label']}: ${addr['address']}';
                  setState(() => _selectedAddress = full);
                  if (widget.onAddressSelected != null) {
                    widget.onAddressSelected!(full);
                  }
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.surfaceContainerHigh : const Color(0xFFFFECE5))
                        : (isDark ? AppColors.surfaceContainer : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : (isDark ? AppColors.gridLine : AppColors.lightBorder),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        addr['icon'] as IconData,
                        color: isSelected ? AppColors.primary : AppColors.secondary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  addr['label'] as String,
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.black.withValues(alpha: 0.6) : const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    '⚡ ${addr['eta']}',
                                    style: AppTypography.metadata.copyWith(
                                      color: isDark ? AppColors.saffronYellow : const Color(0xFFB45309),
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              addr['address'] as String,
                              style: AppTypography.bodySm.copyWith(
                                color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Near ${addr['hub']}',
                              style: AppTypography.metadata.copyWith(
                                color: isDark ? AppColors.outline : AppColors.lightTextTertiary,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
