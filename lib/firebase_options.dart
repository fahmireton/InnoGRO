// This is a placeholder Firebase configuration
// To use real Firebase, you need to:
// 1. Create a Firebase project at https://console.firebase.google.com
// 2. Add your app to the project (Android/iOS/Web)
// 3. Run: flutterfire configure
// 4. Replace this file with the generated firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAGXez1DMomO7oqQA8NKL95iUT6InovjQA',
    appId: '1:1076614809317:web:6f2d2eb357c4da39c0360c',
    messagingSenderId: '1076614809317',
    projectId: 'innogro',
    authDomain: 'innogro.firebaseapp.com',
    storageBucket: 'innogro.firebasestorage.app',
    measurementId: 'G-3LNEG1KJZR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDaWtSyHiK5-woDD4Ab9wOuWyReVYtZXG0',
    appId: '1:1076614809317:android:072fcd6b0fdc2e75c0360c',
    messagingSenderId: '1076614809317',
    projectId: 'innogro',
    storageBucket: 'innogro.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBPJlYUSKmq-9XhjS7UVTwRiJanOOGW_vc',
    appId: '1:1076614809317:ios:01ee48896c3d7ca7c0360c',
    messagingSenderId: '1076614809317',
    projectId: 'innogro',
    storageBucket: 'innogro.firebasestorage.app',
    iosClientId: '1076614809317-rt1brhnu5373l609lsfl89ovu1vdgnr7.apps.googleusercontent.com',
    iosBundleId: 'com.example.demoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBPJlYUSKmq-9XhjS7UVTwRiJanOOGW_vc',
    appId: '1:1076614809317:ios:01ee48896c3d7ca7c0360c',
    messagingSenderId: '1076614809317',
    projectId: 'innogro',
    storageBucket: 'innogro.firebasestorage.app',
    iosClientId: '1076614809317-rt1brhnu5373l609lsfl89ovu1vdgnr7.apps.googleusercontent.com',
    iosBundleId: 'com.example.demoApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAGXez1DMomO7oqQA8NKL95iUT6InovjQA',
    appId: '1:1076614809317:web:4380f9787c461da7c0360c',
    messagingSenderId: '1076614809317',
    projectId: 'innogro',
    authDomain: 'innogro.firebaseapp.com',
    storageBucket: 'innogro.firebasestorage.app',
    measurementId: 'G-CMFGQQJHES',
  );

}