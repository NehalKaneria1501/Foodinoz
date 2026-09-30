import 'package:flutter/material.dart';
import 'package:flutter_toast_notification/flutter_toast_notification.dart';
import '../../main.dart' show rootNavigatorKey, rootScaffoldMessengerKey;
import '../theme/app_colors.dart';

/// Reusable toast notifications powered by flutter_toast_notification supporting both Dark & Light themes.
class AppToast {
  AppToast._();

  static BuildContext? get _defaultContext => rootNavigatorKey.currentContext;

  /// Standard informational toast notification
  static void show(
    String message, {
    BuildContext? context,
    bool isDark = true,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ctx = context ?? _defaultContext;
    if (ctx != null) {
      FlutterToast().show(
        ctx,
        message,
        type: ToastType.info,
        position: position,
        duration: duration,
        backgroundColor: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurface,
        textColor: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
        iconColor: isDark ? AppColors.onSurface : AppColors.lightTextPrimary,
        borderRadius: 8,
        fontSize: 13,
      );
    } else {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: isDark ? Colors.white : AppColors.lightTextPrimary),
          ),
          duration: duration,
          backgroundColor: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurface,
        ),
      );
    }
  }

  /// Success toast notification with signature primary/green accent
  static void success(
    String message, {
    BuildContext? context,
    bool isDark = true,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ctx = context ?? _defaultContext;
    if (ctx != null) {
      FlutterToast().show(
        ctx,
        message,
        type: ToastType.success,
        position: position,
        duration: duration,
        backgroundColor: AppColors.primary,
        textColor: Colors.white,
        iconColor: Colors.white,
        borderRadius: 8,
        fontSize: 13,
      );
    } else {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(color: Colors.white)),
          duration: duration,
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  /// Informational or theme-switch toast with signature saffron/warm accent
  static void info(
    String message, {
    BuildContext? context,
    bool isDark = true,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 2),
  }) {
    final ctx = context ?? _defaultContext;
    if (ctx != null) {
      FlutterToast().show(
        ctx,
        message,
        type: ToastType.info,
        position: position,
        duration: duration,
        backgroundColor: isDark ? const Color(0xFF2C2523) : const Color(0xFFFFF3E0),
        textColor: isDark ? AppColors.saffronYellow : const Color(0xFFE65100),
        iconColor: isDark ? AppColors.saffronYellow : const Color(0xFFE65100),
        borderRadius: 8,
        fontSize: 13,
      );
    } else {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(color: isDark ? AppColors.saffronYellow : const Color(0xFFE65100)),
          ),
          duration: duration,
          backgroundColor: isDark ? const Color(0xFF2C2523) : const Color(0xFFFFF3E0),
        ),
      );
    }
  }

  /// Error or alert toast
  static void error(
    String message, {
    BuildContext? context,
    bool isDark = true,
    ToastPosition position = ToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
  }) {
    final ctx = context ?? _defaultContext;
    if (ctx != null) {
      FlutterToast().show(
        ctx,
        message,
        type: ToastType.error,
        position: position,
        duration: duration,
        backgroundColor: AppColors.error,
        textColor: Colors.white,
        iconColor: Colors.white,
        borderRadius: 8,
        fontSize: 13,
      );
    } else {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration,
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
