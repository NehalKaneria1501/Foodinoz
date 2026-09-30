import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../view_models/auth_view_model.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = context.read<AuthViewModel>();
    final target = _inputController.text.trim();
    final success = await authVm.forgotPassword(target);

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('OTP sent to $target. Demo code: 1234'),
          backgroundColor: AppColors.secondaryContainer,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            target: target,
            purpose: 'reset_password',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : AppColors.lightTextPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Forgot Password',
          style: TextStyle(color: isDark ? Colors.white : AppColors.lightTextPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                // Lock / Key culinary badge
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryContainer.withValues(alpha: isDark ? 0.4 : 0.15),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Password Recovery',
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineLg.copyWith(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter the email address or phone number linked with your Jeerola account. We will send a secure verification code.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySm.copyWith(
                    color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Error Banner
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
                  const SizedBox(height: 20),
                ],

                // Input Field
                Text(
                  'EMAIL OR MOBILE NUMBER',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.secondary,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _inputController,
                  style: AppTypography.bodyMd,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your registered email or phone';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    prefixIcon: const Icon(Icons.contact_mail_outlined, color: AppColors.primary),
                    hintText: 'e.g. nehal@jeerola.com or 9265754161',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? AppColors.gridLine : AppColors.lightBorder),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                ElevatedButton(
                  onPressed: authVm.isLoading ? null : _handleSendResetOtp,
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
                          'SEND VERIFICATION CODE',
                          style: AppTypography.labelButton.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 15,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Return to Sign In
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                      size: 18,
                    ),
                    label: Text(
                      'Back to Sign In',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
