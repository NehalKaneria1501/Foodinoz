import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceBlack,
      canvasColor: AppColors.surface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.gridLine,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.gridLine,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceBlack,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMd,
        shape: const Border(
          bottom: BorderSide(color: AppColors.gridLine, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gridLine, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          textStyle: AppTypography.labelButton.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          side: const BorderSide(color: AppColors.outlineVariant, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTypography.labelButton.copyWith(color: AppColors.onSurface),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
        labelStyle: AppTypography.bodyMd,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gridLine, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gridLine, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceBlack,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.outline, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        contentTextStyle: AppTypography.bodySm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.gridLine, width: 1),
        ),
        elevation: 6,
      ),
    );
  }

  static ThemeData get lightTheme {
    const textPrimary = AppColors.lightTextPrimary;
    const textSecondary = AppColors.lightTextSecondary;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      canvasColor: AppColors.lightSurface,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFFFECE5),
        onPrimaryContainer: Color(0xFFBF360C),
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFFF3E0),
        onSecondaryContainer: Color(0xFFE65100),
        surface: AppColors.lightSurface,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightBorderSubtle,
        error: AppColors.error,
        onError: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: AppTypography.headlineMd.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 2,
        shadowColor: const Color(0x14E65100),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2.5,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          textStyle: AppTypography.labelButton.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: AppTypography.labelButton.copyWith(color: textPrimary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: AppTypography.bodySm.copyWith(color: AppColors.lightTextTertiary),
        labelStyle: AppTypography.bodyMd.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightSurface,
        contentTextStyle: AppTypography.bodySm.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.2),
        ),
        elevation: 6,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLg.copyWith(color: textPrimary),
        displayMedium: AppTypography.headlineLg.copyWith(color: textPrimary),
        displaySmall: AppTypography.headlineMd.copyWith(color: textPrimary),
        headlineLarge: AppTypography.headlineLg.copyWith(color: textPrimary),
        headlineMedium: AppTypography.headlineMd.copyWith(color: textPrimary),
        headlineSmall: AppTypography.headlineSm.copyWith(color: textPrimary),
        titleLarge: AppTypography.headlineSm.copyWith(color: textPrimary),
        titleMedium: AppTypography.labelMd.copyWith(color: textPrimary),
        titleSmall: AppTypography.metadata.copyWith(color: textSecondary),
        bodyLarge: AppTypography.bodyLg.copyWith(color: textPrimary),
        bodyMedium: AppTypography.bodyMd.copyWith(color: textPrimary),
        bodySmall: AppTypography.bodySm.copyWith(color: textSecondary),
        labelLarge: AppTypography.labelButton.copyWith(color: textPrimary),
        labelMedium: AppTypography.labelMd.copyWith(color: textPrimary),
        labelSmall: AppTypography.metadata.copyWith(color: textSecondary),
      ),
    );
  }
}
