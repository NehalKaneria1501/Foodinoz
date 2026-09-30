import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Distinctive Terracotta Pouch Badge (e.g. P-08, P-14)
/// Serves as the physical-to-digital bridge for the Masala Kit system.
class PouchBadge extends StatefulWidget {
  final String pouchNumber; // e.g. "P-08"
  final String? pouchName;
  final bool isLarge;

  const PouchBadge({
    super.key,
    required this.pouchNumber,
    this.pouchName,
    this.isLarge = false,
  });

  @override
  State<PouchBadge> createState() => _PouchBadgeState();
}

class _PouchBadgeState extends State<PouchBadge> {
  @override
  Widget build(BuildContext context) {
    final isLarge = widget.isLarge;
    final pouchNumber = widget.pouchNumber;
    final pouchName = widget.pouchName;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.terracotta,
        borderRadius: BorderRadius.zero, // Brutalist sharp angle
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            pouchNumber,
            style: isLarge
                ? AppTypography.labelPouch.copyWith(fontSize: 16)
                : AppTypography.labelPouch.copyWith(fontSize: 12),
          ),
          if (pouchName != null && pouchName.isNotEmpty) ...[
            const SizedBox(width: 6),
            Container(width: 1, height: 12, color: Colors.white30),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                pouchName,
                style: AppTypography.metadata.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
