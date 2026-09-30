import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../view_models/auth_view_model.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import '../../../navigation/main_navigation_shell.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: 'nehalkaneria12345@gmail.com');
  final _passwordController = TextEditingController(text: 'Apc@2026');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signIn(
      identifier: _identifierController.text,
      password: _passwordController.text,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Welcome back, ${authVm.user?.name ?? 'Chef'}!',
                style: AppTypography.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signInWithGoogle();

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Connected with Google: ${authVm.user?.name ?? 'Chef'}!',
                style: AppTypography.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationShell()),
      );
    }
  }

  void _showPhoneOtpSheet() {
    final phoneController = TextEditingController(text: '+91 9265754161');
    final otpController = TextEditingController(text: '123456');
    bool isOtpSent = false;
    String verificationId = 'ver_${DateTime.now().millisecondsSinceEpoch}';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceContainer : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder, width: 1.5),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final authVm = context.watch<AuthViewModel>();
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.phone_android, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'PHONE AUTHENTICATION',
                            style: AppTypography.headlineSm.copyWith(fontSize: 15, letterSpacing: 1),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20, color: AppColors.outline),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Instant SMS verification backed by Firebase Auth & Firestore',
                    style: AppTypography.bodySm.copyWith(
                      color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!isOtpSent) ...[
                    Text(
                      'ENTER MOBILE NUMBER',
                      style: AppTypography.metadata.copyWith(color: AppColors.secondary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: phoneController,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
                        hintText: '+91 9265754161',
                        fillColor: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (phoneController.text.trim().length >= 10) {
                          setSheetState(() {
                            isOtpSent = true;
                            verificationId = 'ver_${DateTime.now().millisecondsSinceEpoch}';
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        'SEND FIREBASE SMS OTP',
                        style: AppTypography.labelButton.copyWith(color: Colors.white),
                      ),
                    ),
                  ] else ...[
                    Text(
                      'ENTER 6-DIGIT OTP CODE',
                      style: AppTypography.metadata.copyWith(color: AppColors.secondary),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: otpController,
                      style: AppTypography.bodyMd.copyWith(
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.sms_outlined, color: AppColors.primary),
                        hintText: '123456',
                        fillColor: isDark ? AppColors.surfaceContainerHigh : AppColors.lightSurfaceWarm,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: authVm.isLoading
                          ? null
                          : () async {
                              final nav = Navigator.of(context);
                              final rootNav = Navigator.of(ctx);
                              final success = await authVm.signInWithPhoneOtp(
                                verificationId: verificationId,
                                smsCode: otpController.text.trim(),
                                phoneNumber: phoneController.text.trim(),
                              );
                              if (success) {
                                rootNav.pop();
                                nav.pushReplacement(
                                  MaterialPageRoute(builder: (_) => const MainNavigationShell()),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.sproutGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: authVm.isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              'VERIFY & SIGN IN',
                              style: AppTypography.labelButton.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Hero Restaurant Logo
                  const Center(
                    child: AppLogo(
                      size: AppLogoSize.large,
                      isVertical: true,
                      customSubtitle: 'GOURMET KITCHEN & SPICES',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Header greeting
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineLg.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to order freshly prepared meals & spices',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(
                      color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Error notice if live server responds with error
                  if (authVm.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authVm.errorMessage!,
                              style: AppTypography.bodySm.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email or Mobile Input
                  Text(
                    'EMAIL OR PHONE NUMBER',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _identifierController,
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email or phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                      hintText: 'e.g. nehal@jeerola.com or 9265754161',
                      fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Password Input
                  Text(
                    'PASSWORD',
                    style: AppTypography.metadata.copyWith(
                      color: AppColors.secondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    style: AppTypography.bodyMd.copyWith(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return 'Password must be at least 4 characters';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextTertiary,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      hintText: 'Enter your password',
                      fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remember Me & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: authVm.rememberMe,
                              onChanged: (val) => authVm.setRememberMe(val ?? true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Remember Me',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          authVm.clearError();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign In Action Button
                  ElevatedButton(
                    onPressed: authVm.isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      backgroundColor: AppColors.primary,
                    ),
                    child: authVm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'SIGN IN WITH LIVE SERVER',
                            style: AppTypography.labelButton.copyWith(
                              color: Colors.white,
                              letterSpacing: 1.5,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Divider with "OR"
                  Row(
                    children: [
                      Expanded(child: Divider(color: isDark ? AppColors.gridLine : AppColors.lightBorder)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'OR CONNECT WITH',
                          style: AppTypography.metadata.copyWith(
                            color: isDark ? AppColors.onSurfaceVariant.withValues(alpha: 0.7) : AppColors.lightTextSecondary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: isDark ? AppColors.gridLine : AppColors.lightBorder)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Social & Phone Sign-In Buttons (Firebase Auth Backend)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: authVm.isLoading ? null : _handleGoogleSignIn,
                          icon: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? Colors.white12 : Colors.grey.shade100,
                              border: Border.all(
                                color: isDark ? Colors.white24 : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'G',
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          label: Text(
                            'Google',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.surfaceContainerHigh : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: authVm.isLoading ? null : _showPhoneOtpSheet,
                          icon: const Icon(Icons.phone_android, size: 20, color: AppColors.sproutGreen),
                          label: Text(
                            'Phone OTP',
                            style: AppTypography.bodySm.copyWith(
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isDark ? AppColors.surfaceContainerHigh : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Footer: Don't have an account? Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have a Jeerola account? ",
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          authVm.clearError();
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignUpScreen()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
