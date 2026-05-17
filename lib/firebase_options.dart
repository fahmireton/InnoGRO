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
    apiKey: 'AIzaSyCGGNFA9pmkTZ1Fd_JUes5jLodk6ZxIPuQ',
    appId: '1:895560396348:ios:4d4c2dd1d97cb7a0f65d39',
    messagingSenderId: '895560396348',
    projectId: 'sekodlah',
    storageBucket: 'sekodlah.firebasestorage.app',
    iosBundleId: 'com.ukm.innogro',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCGGNFA9pmkTZ1Fd_JUes5jLodk6ZxIPuQ',
    appId: '1:895560396348:ios:4d4c2dd1d97cb7a0f65d39',
    messagingSenderId: '895560396348',
    projectId: 'sekodlah',
    storageBucket: 'sekodlah.firebasestorage.app',
    authDomain: 'sekodlah.firebaseapp.com',
  );
}
