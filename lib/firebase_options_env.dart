import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseOptionsFromEnv {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: const String.fromEnvironment('FIREBASE_API_KEY_WEB'),
        appId: const String.fromEnvironment('FIREBASE_APP_ID_WEB'),
        messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
        projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
        authDomain: const String.fromEnvironment('FIREBASE_AUTH_DOMAIN'),
        storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
        databaseURL: const String.fromEnvironment('FIREBASE_DATABASE_URL'),
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: const String.fromEnvironment('FIREBASE_API_KEY_ANDROID'),
          appId: const String.fromEnvironment('FIREBASE_APP_ID_ANDROID'),
          messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
          storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
          databaseURL: const String.fromEnvironment('FIREBASE_DATABASE_URL'),
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: const String.fromEnvironment('FIREBASE_API_KEY_IOS'),
          appId: const String.fromEnvironment('FIREBASE_APP_ID_IOS'),
          messagingSenderId: const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
          projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
          storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
          databaseURL: const String.fromEnvironment('FIREBASE_DATABASE_URL'),
          iosBundleId: 'com.example.flutterWebNicknameApp',
        );
      default:
        throw UnsupportedError('Unsupported platform.');
    }
  }
}
