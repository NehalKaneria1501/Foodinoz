import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/brutalist_button.dart';
import '../../../../core/widgets/brutalist_card.dart';
import '../view_models/auth_view_model.dart';
import 'preferences_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController(text: '9265754161');
  final _otpController = TextEditingController(text: '1234');

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Brand Mark
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    color: AppColors.primary,
                    child: const Center(
                      child: Icon(Icons.soup_kitchen, color: Colors.white, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'JEEROLA',
                    style: AppTypography.displayXl.copyWith(
                      fontSize: 22,
                      letterSpacing: 0.1,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'SMART KITCHEN OS // MASALA KIT',
                style: AppTypography.metadata.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 48),

              Text(
                'Sign In',
                style: AppTypography.displayXl.copyWith(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter mobile number for instant OTP verification.',
                style: AppTypography.bodyMd.copyWith(
                  color: isDark ? AppColors.onSurfaceVariant : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 32),

              BrutalistCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MOBILE NUMBER', style: AppTypography.metadata),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppTypography.numericData,
                      decoration: const InputDecoration(
                        prefixText: '+91 ',
                        hintText: 'Enter 10-digit number',
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (!authVm.isOtpSent)
                      BrutalistButton(
                        text: 'Get Verification OTP',
                        isFullWidth: true,
                        isLoading: authVm.isLoading,
                        onPressed: () async {
                          final success = await authVm.sendOtp(_phoneController.text);
                          if (context.mounted && success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('OTP sent: use default 1234 for demo')),
                            );
                          }
                        },
                      )
                    else ...[
                      Text('ENTER 4-DIGIT OTP', style: AppTypography.metadata),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        style: AppTypography.numericData.copyWith(fontSize: 20, letterSpacing: 8),
                        decoration: const InputDecoration(
                          hintText: '• • • •',
                        ),
                      ),
                      const SizedBox(height: 20),
                      BrutalistButton(
                        text: 'Verify & Continue',
                        isFullWidth: true,
                        isLoading: authVm.isLoading,
                        onPressed: () async {
                          final ok = await authVm.verifyOtp(
                            phone: '+91 ${_phoneController.text}',
                            otp: _otpController.text,
                          );
                          if (context.mounted && ok) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const PreferencesScreen()),
                            );
                          }
                        },
                      ),
                    ],

                    if (authVm.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        authVm.errorMessage!,
                        style: AppTypography.bodySm.copyWith(color: AppColors.error),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
