import 'package:flutter/material.dart';

/// Design tokens derived from Stitch Project: Smart Masala Cooking Planner
/// Aesthetic: Experimental Brutalist Dark Mode
class AppColors {
  AppColors._();

  // Backgrounds & Surfaces (Warm Charcoal Velvet for Dark)
  static const Color surfaceBlack = Color(0xFF0E0E11);
  static const Color background = Color(0xFF141418);
  static const Color surface = Color(0xFF18181D);
  static const Color surfaceDim = Color(0xFF121215);
  static const Color surfaceContainerLow = Color(0xFF1E1E24);
  static const Color surfaceContainer = Color(0xFF24242C);
  static const Color surfaceContainerHigh = Color(0xFF2E2E38);
  static const Color surfaceContainerHighest = Color(0xFF383844);

  // Dividers & Borders (Dark)
  static const Color gridLine = Color(0xFF282832);
  static const Color outline = Color(0xFF5A5A6A);
  static const Color outlineVariant = Color(0xFF383846);

  // Light Mode Gourmet Palette (Warm Masala Alabaster & Roasted Espresso)
  static const Color lightBackground = Color(0xFFFBF9F5); // Warm Alabaster / Culinary Ivory
  static const Color lightSurface = Color(0xFFFFFFFF); // Crisp Elevated Pure White
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceWarm = Color(0xFFF6F1EA); // Warm parchment for chips & badges
  static const Color lightSurfaceSubtle = Color(0xFFF0EAE1);
  static const Color lightBorder = Color(0xFFE8DFD1); // Warm masala parchment border
  static const Color lightBorderSubtle = Color(0xFFF2ECE1);
  static const Color lightTextPrimary = Color(0xFF1A1412); // Deep roasted masala espresso
  static const Color lightTextSecondary = Color(0xFF5E5248); // Warm roasted spice brown
  static const Color lightTextTertiary = Color(0xFF948579); // Muted spice tan
  static const Color lightShadow = Color(0x0C8A4B08); // Subtle amber glow shadow

  // Restaurant & Culinary Primary (Paprika Crimson & Flame Orange)
  static const Color primary = Color(0xFFFF5722); // Vibrant Paprika
  static const Color primaryDark = Color(0xFFD84315);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF4E1D13);
  static const Color onPrimaryContainer = Color(0xFFFFCCBC);
  static const Color sproutGreen = Color(0xFF2E7D32); // Deep pure veg green

  // Culinary Secondary (Warm Saffron Amber & Golden Honey)
  static const Color secondary = Color(0xFFFFA000); // Saffron Gold
  static const Color secondaryOrange = Color(0xFFFF8A50);
  static const Color onSecondary = Color(0xFF261600);
  static const Color secondaryContainer = Color(0xFF4D3000);
  static const Color onSecondaryContainer = Color(0xFFFFECB3);

  // Gourmet Accents & Badges
  static const Color saffronYellow = Color(0xFFFFB300);
  static const Color gold = Color(0xFFFFD54F);
  static const Color terracotta = Color(0xFFE2725B);
  static const Color burntSienna = Color(0xFFC85A32); // Deep roasted sienna for high-contrast light accents
  static const Color chefSpecial = Color(0xFFE91E63);
  static const Color starRating = Color(0xFFFFB300);

  // Typography & On-Surface
  static const Color onSurface = Color(0xFFF5F5F7);
  static const Color onSurfaceVariant = Color(0xFFA0A0B0);
  static const Color inverseSurface = Color(0xFFF5F5F7);
  static const Color inverseOnSurface = Color(0xFF1E1E24);

  // Dynamic Theme Helpers
  static Color textPrimaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? onSurface : lightTextPrimary;
  }

  static Color textSecondaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? onSurfaceVariant : lightTextSecondary;
  }

  static Color textTertiaryOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? outline : lightTextTertiary;
  }

  static Color surfaceOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surface : lightSurface;
  }

  static Color surfaceContainerOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceContainer : lightSurfaceWarm;
  }

  static Color cardBgOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceContainer : lightSurface;
  }

  static Color dialogBgOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceContainer : Colors.white;
  }

  static Color chipBgOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceContainerHigh : lightSurfaceWarm;
  }

  static Color inputFillOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? surfaceContainerHigh : Colors.white;
  }

  static Color borderOf(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? gridLine : lightBorder;
  }

  // Feedback & Status
  static const Color error = Color(0xFFFF5252);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFF4A1010);
  static const Color success = Color(0xFF4CAF50);
  static const Color discountBadge = Color(0xFF2E7D32);
}
