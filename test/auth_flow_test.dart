import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:jeerola/core/widgets/app_logo.dart';
import 'package:jeerola/core/theme/app_theme.dart';
import 'package:jeerola/data/repositories/auth_repository.dart';
import 'package:jeerola/data/services/auth_api_service.dart';
import 'package:jeerola/data/services/local_storage_service.dart';
import 'package:jeerola/ui/features/auth/view_models/auth_view_model.dart';
import 'package:jeerola/ui/features/auth/views/sign_in_screen.dart';
import 'package:jeerola/ui/features/auth/views/sign_up_screen.dart';
import 'package:jeerola/ui/features/auth/views/forgot_password_screen.dart';
import 'package:jeerola/ui/features/auth/views/otp_verification_screen.dart';

void main() {
  group('Restaurant E-Commerce Auth Suite Tests', () {
    late LocalStorageService localStorage;
    late AuthApiService apiService;
    late AuthRepository authRepo;
    late AuthViewModel authVm;

    setUp(() {
      localStorage = LocalStorageService();
      apiService = AuthApiService();
      authRepo = AuthRepository(
        localStorageService: localStorage,
        authApiService: apiService,
      );
      authVm = AuthViewModel(authRepository: authRepo);
    });

    Widget createTestApp(Widget child) {
      return MultiProvider(
        providers: [
          Provider<AuthRepository>.value(value: authRepo),
          ChangeNotifierProvider<AuthViewModel>.value(value: authVm),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: child,
        ),
      );
    }

    testWidgets('AppLogo renders title and custom subtitle correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: AppLogo(
              size: AppLogoSize.large,
              showText: true,
              isVertical: true,
            ),
          ),
        ),
      );

      expect(find.text('JEEROLA'), findsOneWidget);
      expect(find.text('RESTAURANT & SPICE KITCHEN'), findsOneWidget);
    });

    testWidgets('SignInScreen renders brand, inputs and buttons', (tester) async {
      await tester.pumpWidget(createTestApp(const SignInScreen()));
      await tester.pumpAndSettle();

      expect(find.text('JEEROLA'), findsWidgets);
      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.text('SIGN IN WITH LIVE SERVER'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('Phone OTP'), findsOneWidget);
    });

    testWidgets('SignUpScreen renders all registration form fields', (tester) async {
      await tester.pumpWidget(createTestApp(const SignUpScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Join Jeerola Dining'), findsOneWidget);
      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('PHONE NUMBER'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
      expect(find.text('REGISTER & VERIFY OTP'), findsOneWidget);
    });

    testWidgets('ForgotPasswordScreen renders instructions and input', (tester) async {
      await tester.pumpWidget(createTestApp(const ForgotPasswordScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Password Recovery'), findsOneWidget);
      expect(find.text('SEND VERIFICATION CODE'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen renders 4 PIN boxes and verify button', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const OtpVerificationScreen(target: '+91 9265754161'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify Your Identity'), findsOneWidget);
      expect(find.text('+91 9265754161'), findsOneWidget);
      expect(find.text('AUTHENTICATE & ENTER'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(4));
    });

    test('AuthApiService simulates live server response gracefully when offline', () async {
      final loginResult = await apiService.login(
        identifier: 'nehalkaneria12345@gmail.com',
        password: 'Password123',
      );

      expect(loginResult['token'], isNotNull);
      expect(loginResult['user'], isNotNull);
      expect(loginResult['user'].name, isNotEmpty);
    });
  });
}
