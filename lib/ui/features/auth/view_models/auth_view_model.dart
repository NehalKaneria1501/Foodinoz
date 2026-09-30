import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthViewModel({required this.authRepository}) {
    _user = authRepository.getCurrentUser();
    _isLoggedIn = authRepository.isLoggedIn();
  }

  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOtpSent = false;
  bool _rememberMe = true;
  String _pendingAuthTarget = '';

  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOtpSent => _isOtpSent;
  bool get rememberMe => _rememberMe;
  String get pendingAuthTarget => _pendingAuthTarget;

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setPendingTarget(String target) {
    _pendingAuthTarget = target;
    notifyListeners();
  }

  /// Sign In with Email / Phone and Password (Live Server)
  Future<bool> signIn({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await authRepository.loginWithPassword(
        identifier: identifier.trim(),
        password: password,
      );
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign In with Google (Firebase Auth)
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await authRepository.signInWithGoogle();
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign In with Phone & SMS OTP (Firebase Auth)
  Future<bool> signInWithPhoneOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await authRepository.signInWithPhoneOtp(
        verificationId: verificationId,
        smsCode: smsCode,
        phoneNumber: phoneNumber,
      );
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Sign Up with Full Name, Email, Phone, Password (Live Server)
  Future<bool> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await authRepository.registerUser(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        password: password,
      );
      _pendingAuthTarget = phone.trim().isNotEmpty ? phone.trim() : email.trim();
      _isOtpSent = true;
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request Password Reset OTP (Live Server)
  Future<bool> forgotPassword(String emailOrPhone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final ok = await authRepository.sendForgotPasswordOtp(emailOrPhone.trim());
      if (ok) {
        _pendingAuthTarget = emailOrPhone.trim();
        _isOtpSent = true;
      }
      return ok;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dispatch OTP to phone
  Future<bool> sendOtp(String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await authRepository.sendOtp(phone.trim());
      _pendingAuthTarget = phone.trim();
      _isOtpSent = success;
      return success;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Verify OTP code (Live Server)
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    String purpose = 'login',
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await authRepository.verifyOtp(
        phoneNumber: phone.trim(),
        otp: otp.trim(),
        purpose: purpose,
      );
      _isLoggedIn = true;
      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resend OTP
  Future<bool> resendOtp(String target) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await authRepository.resendOtp(target.trim());
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePreferences({
    required DietaryPreference preference,
    required List<String> cuisines,
    required List<String> meals,
    required int familyCount,
    AsafoetidaPreference asafoetida = AsafoetidaPreference.withAsafoetida,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await authRepository.updatePreferences(
        dietaryPreference: preference,
        asafoetidaPreference: asafoetida,
        preferredCuisines: cuisines,
        mealPreferences: meals,
        familyMembersCount: familyCount,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    authRepository.logout();
    _isLoggedIn = false;
    _isOtpSent = false;
    _pendingAuthTarget = '';
    notifyListeners();
  }

  String _cleanErrorMessage(String msg) {
    if (msg.startsWith('Exception: ')) {
      return msg.substring(11);
    }
    if (msg.startsWith('HttpException: ')) {
      return msg.substring(15);
    }
    return msg;
  }
}
