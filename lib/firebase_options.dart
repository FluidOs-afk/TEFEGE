import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no está configurado para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQRoDby4OQBrEG-JwP348sDxjEM3HHdNw',
    appId: '1:275606187408:web:972dd50943cf8154a69715',
    messagingSenderId: '275606187408',
    projectId: 'outfy-81a2c',
    authDomain: 'outfy-81a2c.firebaseapp.com',
    storageBucket: 'outfy-81a2c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGsRlQa8XLF_nrRt3zPeLo9QIEn3S3TaE',
    appId: '1:275606187408:android:a79f0f96f759000ba69715',
    messagingSenderId: '275606187408',
    projectId: 'outfy-81a2c',
    storageBucket: 'outfy-81a2c.firebasestorage.app',
  );
}
