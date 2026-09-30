import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppLogoSize {
  small(32, 14, 9),
  medium(54, 20, 11),
  large(84, 28, 12),
  splash(110, 36, 14);

  final double iconBoxSize;
  final double titleFontSize;
  final double subtitleFontSize;

  const AppLogoSize(this.iconBoxSize, this.titleFontSize, this.subtitleFontSize);
}

/// Rich vector-crafted Restaurant & Spice E-Commerce brand logo for JEEROLA
class AppLogo extends StatelessWidget {
  final AppLogoSize size;
  final bool showText;
  final bool isVertical;
  final String? customSubtitle;
  final Color? textColor;

  const AppLogo({
    super.key,
    this.size = AppLogoSize.medium,
    this.showText = true,
    this.isVertical = false,
    this.customSubtitle,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedTextColor = textColor ?? (isDark ? Colors.white : AppColors.lightTextPrimary);

    final iconWidget = Container(
      width: size.iconBoxSize,
      height: size.iconBoxSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.2, -0.3),
          radius: 0.9,
          colors: [
            Color(0xFFFF7043), // Light Paprika
            Color(0xFFE64A19), // Deep Paprika
            Color(0xFFBF360C), // Dark Roast Amber
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: size.iconBoxSize * 0.35,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: AppColors.secondary.withValues(alpha: 0.2),
            blurRadius: size.iconBoxSize * 0.2,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.8),
          width: math.max(1.5, size.iconBoxSize * 0.035),
        ),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size.iconBoxSize * 0.65, size.iconBoxSize * 0.65),
          painter: _JeerolaLogoPainter(),
        ),
      ),
    );

    if (!showText) return iconWidget;

    final textColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isVertical ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'JEEROLA',
              style: AppTypography.displayXl.copyWith(
                fontSize: size.titleFontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                color: resolvedTextColor,
                shadows: [
                  Shadow(
                    color: AppColors.primary.withValues(alpha: isDark ? 0.5 : 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: size.titleFontSize * 0.3,
              height: size.titleFontSize * 0.3,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: size.iconBoxSize * 0.05),
        Text(
          customSubtitle ?? 'RESTAURANT & SPICE KITCHEN',
          style: AppTypography.metadata.copyWith(
            fontSize: size.subtitleFontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
            color: isDark ? AppColors.secondary : AppColors.primary,
          ),
        ),
      ],
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 16),
          textColumn,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        const SizedBox(width: 14),
        textColumn,
      ],
    );
  }
}

/// Custom Vector Painter drawing the gourmet Cloche + Rising Cumin / Flame Motif
class _JeerolaLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Cloche Platter Base (gold metallic plate)
    final platePaint = Paint()
      ..color = AppColors.gold
      ..style = PaintingStyle.fill;

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.08, h * 0.78, w * 0.84, h * 0.1),
      Radius.circular(h * 0.05),
    );
    canvas.drawRRect(baseRect, platePaint);

    // 2. Cloche Dome (restaurant serving cover)
    final domePath = Path();
    domePath.moveTo(w * 0.14, h * 0.75);
    domePath.cubicTo(
      w * 0.14,
      h * 0.45,
      w * 0.32,
      h * 0.32,
      w * 0.5,
      h * 0.32,
    );
    domePath.cubicTo(
      w * 0.68,
      h * 0.32,
      w * 0.86,
      h * 0.45,
      w * 0.86,
      h * 0.75,
    );
    domePath.close();

    final domePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white,
          Color(0xFFFFECB3), // Golden amber highlight
          Color(0xFFFFB300),
        ],
      ).createShader(Rect.fromLTWH(0, h * 0.3, w, h * 0.5))
      ..style = PaintingStyle.fill;

    canvas.drawPath(domePath, domePaint);

    // 3. Cloche Top Handle (sphere)
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.29),
      w * 0.08,
      Paint()..color = AppColors.gold,
    );

    // 4. Gourmet Flame / Cumin Sprout rising from the cloche
    final flamePath = Path();
    flamePath.moveTo(w * 0.5, h * 0.22);
    flamePath.cubicTo(
      w * 0.42,
      h * 0.14,
      w * 0.46,
      h * 0.04,
      w * 0.50,
      0,
    );
    flamePath.cubicTo(
      w * 0.62,
      h * 0.07,
      w * 0.58,
      h * 0.16,
      w * 0.50,
      h * 0.22,
    );
    flamePath.close();

    final flamePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          Color(0xFFFFB300),
          Color(0xFFFF3D00),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.25))
      ..style = PaintingStyle.fill;

    canvas.drawPath(flamePath, flamePaint);

    // 5. Delicate decorative steam / aroma swirl lines
    final aromaPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.2, w * 0.04);

    final leftAroma = Path();
    leftAroma.moveTo(w * 0.35, h * 0.22);
    leftAroma.cubicTo(w * 0.30, h * 0.16, w * 0.38, h * 0.10, w * 0.34, h * 0.05);
    canvas.drawPath(leftAroma, aromaPaint);

    final rightAroma = Path();
    rightAroma.moveTo(w * 0.65, h * 0.22);
    rightAroma.cubicTo(w * 0.70, h * 0.16, w * 0.62, h * 0.10, w * 0.66, h * 0.05);
    canvas.drawPath(rightAroma, aromaPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
