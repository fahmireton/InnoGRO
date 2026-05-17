import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      default:
        return ios;
    }
  }

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgHlH1en0Zdh5ofU1SSDfpry7lLtr-PhA',
    appId: '1:63839259246:ios:d965a6285d399ff65d747f',
    messagingSenderId: '63839259246',
    projectId: 'innogro-4ee6e',
    storageBucket: 'innogro-4ee6e.firebasestorage.app',
    iosBundleId: 'com.innogro.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgHlH1en0Zdh5ofU1SSDfpry7lLtr-PhA',
    appId: '1:63839259246:ios:d965a6285d399ff65d747f',
    messagingSenderId: '63839259246',
    projectId: 'innogro-4ee6e',
    storageBucket: 'innogro-4ee6e.firebasestorage.app',
    authDomain: 'innogro-4ee6e.firebaseapp.com',
  );
}
