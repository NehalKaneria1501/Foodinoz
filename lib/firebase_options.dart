// File generated for project: jeerola-eefba
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBv_JeerolaWebKey2026eefba',
    appId: '1:1082648291034:web:9182371928472918472918',
    messagingSenderId: '1082648291034',
    projectId: 'jeerola-eefba',
    authDomain: 'jeerola-eefba.firebaseapp.com',
    storageBucket: 'jeerola-eefba.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCv_JeerolaAndroidKey2026eefba',
    appId: '1:678980676298:android:6542c17fcdc786bd3fe233',
    messagingSenderId: '678980676298',
    projectId: 'jeerola-eefba',
    storageBucket: 'jeerola-eefba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDv_JeerolaIosKey2026eefba',
    appId: '1:1082648291034:ios:7361928471928374619283',
    messagingSenderId: '1082648291034',
    projectId: 'jeerola-eefba',
    storageBucket: 'jeerola-eefba.appspot.com',
    iosBundleId: 'com.example.jeerola',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDv_JeerolaIosKey2026eefba',
    appId: '1:1082648291034:ios:7361928471928374619283',
    messagingSenderId: '1082648291034',
    projectId: 'jeerola-eefba',
    storageBucket: 'jeerola-eefba.appspot.com',
    iosBundleId: 'com.example.jeerola',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBv_JeerolaWebKey2026eefba',
    appId: '1:1082648291034:web:9182371928472918472918',
    messagingSenderId: '1082648291034',
    projectId: 'jeerola-eefba',
    authDomain: 'jeerola-eefba.firebaseapp.com',
    storageBucket: 'jeerola-eefba.appspot.com',
  );
}
