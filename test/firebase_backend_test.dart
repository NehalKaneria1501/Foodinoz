import 'package:flutter_test/flutter_test.dart';
import 'package:jeerola/data/services/firebase_auth_service.dart';
import 'package:jeerola/data/services/firebase_firestore_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Backend & Auth Tests (Project: jeerola-eefba)', () {
    test('Email/Password registration and sign-in creates auth state', () async {
      final auth = FirebaseAuthService.instance;

      final registeredUser = await auth.registerWithEmailPassword(
        email: 'nehalkaneria12345@gmail.com',
        password: 'SecurePassword123!',
        displayName: 'Nehal Patel',
      );

      expect(registeredUser, isNotNull);
      expect(registeredUser?.email, 'nehalkaneria12345@gmail.com');
      expect(registeredUser?.displayName, 'Nehal Patel');
      expect(registeredUser?.providerId, 'password');

      final signedInUser = await auth.signInWithEmailPassword(
        email: 'nehalkaneria12345@gmail.com',
        password: 'SecurePassword123!',
      );

      expect(signedInUser, isNotNull);
      expect(signedInUser?.email, 'nehalkaneria12345@gmail.com');
    });

    test('Google Sign-In integrates with FirebaseAuthService', () async {
      final auth = FirebaseAuthService.instance;
      final googleUser = await auth.signInWithGoogle();

      expect(googleUser, isNotNull);
      expect(googleUser?.providerId, 'google.com');
      expect(googleUser?.displayName, 'Nehal Patel');
    });

    test('Phone Authentication verifies SMS code and creates phone user', () async {
      final auth = FirebaseAuthService.instance;
      String? sentVerificationId;

      await auth.verifyPhoneNumber(
        phoneNumber: '+91 9265754161',
        onCodeSent: (vId) => sentVerificationId = vId,
        onError: (err) => fail(err),
      );

      expect(sentVerificationId, isNotNull);

      final phoneUser = await auth.signInWithPhoneOtp(
        verificationId: sentVerificationId!,
        smsCode: '123456',
        phoneNumber: '+91 9265754161',
      );

      expect(phoneUser, isNotNull);
      expect(phoneUser?.providerId, 'phone');
      expect(phoneUser?.phoneNumber, '+91 9265754161');
    });

    test('Cloud Firestore persists user profile and orders', () async {
      final firestore = FirebaseFirestoreService.instance;
      const testUid = 'usr_test_jeerola_99';

      await firestore.saveUserProfile(
        uid: testUid,
        profileData: {
          'name': 'Nehal Patel',
          'phone': '+91 9265754161',
          'email': 'nehalkaneria12345@gmail.com',
          'vegMode': 'jain',
          'jCoinsBalance': 750,
        },
      );

      final profile = await firestore.getUserProfile(testUid);
      expect(profile, isNotNull);
      expect(profile?['name'], 'Nehal Patel');
      expect(profile?['vegMode'], 'jain');
      expect(profile?['jCoinsBalance'], 750);

      // Save order to Firestore
      const testOrderId = 'ODR-TEST-001';
      await firestore.saveOrder(
        uid: testUid,
        orderId: testOrderId,
        orderData: {
          'orderId': testOrderId,
          'storeName': 'Indiranagar Jeerola Dark Store',
          'totalAmount': 420.00,
          'status': 'Simmering Live in Kitchen',
          'items': ['P-01 Lucknowi Biryani Masala', 'Organic Bay Leaves'],
        },
      );

      final orders = await firestore.getUserOrders(testUid);
      expect(orders.isNotEmpty, isTrue);
      expect(orders.any((o) => o['orderId'] == testOrderId), isTrue);
    });
  });
}
