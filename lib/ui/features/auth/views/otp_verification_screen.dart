import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../view_models/auth_view_model.dart';
import 'preferences_screen.dart';
import '../../../navigation/main_navigation_shell.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String target;
  final String purpose; // 'login', 'registration', 'reset_password'

  const OtpVerificationScreen({
    super.key,
    required this.target,
    this.purpose = 'login',
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendCountdown = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Default demo helper
    _controllers[0].text = '1';
    _controllers[1].text = '2';
    _controllers[2].text = '3';
    _controllers[3].text = '4';
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendCountdown = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    final otp = _enteredOtp;
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits of the OTP')),
      );
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.verifyOtp(
      phone: widget.target,
      otp: otp,
      purpose: widget.purpose,
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.verified, color: Colors.white),
              SizedBox(width: 8),
              Text('OTP Verified successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.purpose == 'registration') {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PreferencesScreen()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationShell()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;
    final authVm = context.read<AuthViewModel>();
    final ok = await authVm.resendOtp(widget.target);
    if (mounted && ok) {
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New OTP sent! Demo code: 1234'),
          behavior: SnackBarBehavior.floating,
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
        title: const Text('OTP Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Culinary Icon Header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFF7043),
                        Color(0xFFE64A19),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Verify Your Identity',
                textAlign: TextAlign.center,
                style: AppTypography.headlineLg.copyWith(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have dispatched a 4-digit authentication code from our live server to:',
                textAlign: TextAlign.center,
                style: AppTypography.bodySm.copyWith(
                  color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.target,
                    style: AppTypography.bodyMd.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 16, color: AppColors.onSurfaceVariant),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Error notification
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
                const SizedBox(height: 24),
              ],

              // 4 Digits PIN Box Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 62,
                    height: 68,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: AppTypography.displayXl.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: isDark ? AppColors.surfaceContainer : Colors.white,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.gridLine : AppColors.lightBorder, 
                            width: 1.2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Demo Helper Text
              Center(
                child: Text(
                  'Default live demo code: 1234',
                  style: AppTypography.metadata.copyWith(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Verify & Continue Button
              ElevatedButton(
                onPressed: authVm.isLoading ? null : _handleVerify,
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
                        'AUTHENTICATE & ENTER',
                        style: AppTypography.labelButton.copyWith(
                          color: Colors.white,
                          letterSpacing: 1.5,
                          fontSize: 15,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Resend Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  if (_resendCountdown > 0)
                    Text(
                      'Resend in 0:${_resendCountdown.toString().padLeft(2, '0')}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _handleResend,
                      child: Text(
                        'Resend OTP',
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
    );
  }
}
