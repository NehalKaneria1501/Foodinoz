import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../view_models/auth_view_model.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to continue'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.signUp(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      password: _passwordController.text,
    );

    if (mounted && success) {
      final target = _phoneController.text.isNotEmpty
          ? _phoneController.text
          : _emailController.text;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            target: target,
            purpose: 'registration',
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
          'Create Account',
          style: TextStyle(color: isDark ? Colors.white : AppColors.lightTextPrimary),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Brand Logo
                const Center(
                  child: AppLogo(
                    size: AppLogoSize.medium,
                    isVertical: false,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Join Jeerola Dining',
                  style: AppTypography.headlineLg.copyWith(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Create your profile for hand-crafted recipes, fresh spice kits & fast gourmet delivery.',
                  style: AppTypography.bodySm.copyWith(
                    color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),

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
                  const SizedBox(height: 16),
                ],

                // Full Name
                Text('FULL NAME', style: AppTypography.metadata.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: AppTypography.bodyMd,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    hintText: 'Nehal Patel',
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
                const SizedBox(height: 16),

                // Email Address
                Text('EMAIL ADDRESS', style: AppTypography.metadata.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  style: AppTypography.bodyMd,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || !v.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    hintText: 'nehalkaneria12345@gmail.com',
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
                const SizedBox(height: 16),

                // Phone Number
                Text('PHONE NUMBER', style: AppTypography.metadata.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  style: AppTypography.bodyMd,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                    prefixText: '+91 ',
                    hintText: '92657 54161',
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
                const SizedBox(height: 16),

                // Password
                Text('PASSWORD', style: AppTypography.metadata.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  style: AppTypography.bodyMd,
                  obscureText: _obscurePassword,
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    hintText: 'Create a password',
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
                const SizedBox(height: 16),

                // Confirm Password
                Text('CONFIRM PASSWORD', style: AppTypography.metadata.copyWith(color: AppColors.secondary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  style: AppTypography.bodyMd,
                  obscureText: _obscureConfirmPassword,
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                    prefixIcon: const Icon(Icons.lock_reset, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    hintText: 'Repeat password',
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
                const SizedBox(height: 16),

                // Terms Checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'I agree to Jeerola Terms of Service & Privacy Policy',
                        style: AppTypography.bodySm.copyWith(
                          color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: authVm.isLoading ? null : _handleSignUp,
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
                          'REGISTER & VERIFY OTP',
                          style: AppTypography.labelButton.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontSize: 15,
                          ),
                        ),
                ),
                const SizedBox(height: 24),

                // Back to Sign In
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTypography.bodySm.copyWith(
                        color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text(
                        'Sign In',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
