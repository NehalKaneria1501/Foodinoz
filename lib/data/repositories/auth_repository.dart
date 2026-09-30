import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/firebase_firestore_service.dart';
import '../services/sqlite_database_service.dart';

class AuthRepository {
  final LocalStorageService localStorageService;
  final AuthApiService _authApiService;

  AuthRepository({
    required this.localStorageService,
    AuthApiService? authApiService,
  })  : _authApiService = authApiService ?? AuthApiService();

  UserModel getCurrentUser() {
    return localStorageService.currentUser;
  }

  bool isLoggedIn() {
    return localStorageService.isLoggedIn;
  }

  Future<UserModel> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    final result = await _authApiService.login(
      identifier: identifier,
      password: password,
    );

    final user = result['user'] as UserModel;
    localStorageService.saveUser(user);

    // Sync with Firebase Auth and Firestore
    try {
      if (identifier.contains('@')) {
        await FirebaseAuthService.instance.signInWithEmailPassword(
          email: identifier,
          password: password,
        );
      }
      await FirebaseFirestoreService.instance.saveUserProfile(
        uid: user.id,
        profileData: {
          'name': user.name,
          'email': user.email,
          'phone': user.phoneNumber,
          'vegMode': user.vegMode.name,
          'jCoinsBalance': user.jCoinsBalance,
        },
      );
    } catch (_) {}

    return user;
  }

  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final result = await _authApiService.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );

    final user = result['user'] as UserModel;
    localStorageService.saveUser(user);

    // Register with Firebase Auth & Firestore
    try {
      await FirebaseAuthService.instance.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: name,
      );
      await FirebaseFirestoreService.instance.saveUserProfile(
        uid: user.id,
        profileData: {
          'name': name,
          'email': email,
          'phone': phone,
          'vegMode': user.vegMode.name,
          'jCoinsBalance': user.jCoinsBalance,
        },
      );
    } catch (_) {}

    return user;
  }

  Future<UserModel> signInWithGoogle() async {
    final fbUser = await FirebaseAuthService.instance.signInWithGoogle();
    final current = localStorageService.currentUser;
    final updated = current.copyWith(
      id: fbUser?.uid ?? 'usr_google_guest',
      name: fbUser?.displayName ?? 'Chef Nehal',
      email: fbUser?.email ?? 'nehalkaneria12345@gmail.com',
      photoUrl: fbUser?.photoUrl ?? current.photoUrl,
    );
    localStorageService.saveUser(updated);

    try {
      await FirebaseFirestoreService.instance.saveUserProfile(
        uid: updated.id,
        profileData: {
          'name': updated.name,
          'email': updated.email,
          'photoUrl': updated.photoUrl,
          'provider': 'google.com',
        },
      );
    } catch (_) {}

    return updated;
  }

  Future<UserModel> signInWithPhoneOtp({
    required String verificationId,
    required String smsCode,
    String? phoneNumber,
  }) async {
    final fbUser = await FirebaseAuthService.instance.signInWithPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
      phoneNumber: phoneNumber,
    );
    final current = localStorageService.currentUser;
    final updated = current.copyWith(
      id: fbUser?.uid ?? 'usr_phone_guest',
      name: fbUser?.displayName ?? 'Nehal Patel',
      phoneNumber: fbUser?.phoneNumber ?? phoneNumber ?? '+91 9265754161',
    );
    localStorageService.saveUser(updated);

    try {
      await FirebaseFirestoreService.instance.saveUserProfile(
        uid: updated.id,
        profileData: {
          'name': updated.name,
          'phone': updated.phoneNumber,
          'provider': 'phone',
        },
      );
    } catch (_) {}

    return updated;
  }

  Future<bool> sendForgotPasswordOtp(String emailOrPhone) async {
    return await _authApiService.sendForgotPasswordOtp(emailOrPhone: emailOrPhone);
  }

  Future<bool> sendOtp(String phoneNumber) async {
    return await _authApiService.resendOtp(target: phoneNumber);
  }

  Future<UserModel> verifyOtp({
    required String phoneNumber,
    required String otp,
    String purpose = 'login',
  }) async {
    if (otp.length < 4) {
      throw Exception('Please enter a valid 4-digit OTP');
    }

    final result = await _authApiService.verifyOtp(
      target: phoneNumber,
      otp: otp,
      purpose: purpose,
    );

    final user = result['user'] as UserModel;
    final updated = user.copyWith(phoneNumber: phoneNumber);
    localStorageService.saveUser(updated);

    try {
      await SQLiteDatabaseService.instance.saveProfile(
        id: updated.id,
        name: updated.name,
        phone: phoneNumber,
      );
    } catch (_) {}

    return updated;
  }

  Future<bool> resendOtp(String target) async {
    return await _authApiService.resendOtp(target: target);
  }

  Future<UserModel> updatePreferences({
    required DietaryPreference dietaryPreference,
    required List<String> preferredCuisines,
    required List<String> mealPreferences,
    required int familyMembersCount,
    AsafoetidaPreference asafoetidaPreference = AsafoetidaPreference.withAsafoetida,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final current = localStorageService.currentUser;
    final updated = current.copyWith(
      dietaryPreference: dietaryPreference,
      asafoetidaPreference: asafoetidaPreference,
      preferredCuisines: preferredCuisines,
      mealPreferences: mealPreferences,
      familyMembersCount: familyMembersCount,
    );
    localStorageService.saveUser(updated);
    return updated;
  }

  void logout() {
    FirebaseAuthService.instance.signOut();
    localStorageService.logout();
  }
}

