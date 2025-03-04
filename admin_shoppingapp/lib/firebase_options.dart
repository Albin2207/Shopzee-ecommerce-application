// File generated by FlutterFire CLI.
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCaAyjbYp7V3fL1s-1qY_NjF-7DmP_-2U8',
    appId: '1:27359421590:android:e645b9e21be63d8c9f8eb7',
    messagingSenderId: '27359421590',
    projectId: 'shopzee-d1596',
    storageBucket: 'shopzee-d1596.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB27o9fIsctfYLXWJ68Tu_41JBGcE-5P_E',
    appId: '1:27359421590:ios:10d273b3f804b2dd9f8eb7',
    messagingSenderId: '27359421590',
    projectId: 'shopzee-d1596',
    storageBucket: 'shopzee-d1596.firebasestorage.app',
    androidClientId: '27359421590-at5ed4q0uqg2n0qb54vu2l6hvpg79m63.apps.googleusercontent.com',
    iosClientId: '27359421590-b7ghfi1v463er47gjt0vg5ntr6tie8de.apps.googleusercontent.com',
    iosBundleId: 'com.example.adminShoppingapp',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSzt75DewiJS5YYPja8qdxAhtlL7c90Pk',
    appId: '1:27359421590:web:411490d80ed97a2b9f8eb7',
    messagingSenderId: '27359421590',
    projectId: 'shopzee-d1596',
    authDomain: 'shopzee-d1596.firebaseapp.com',
    storageBucket: 'shopzee-d1596.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB27o9fIsctfYLXWJ68Tu_41JBGcE-5P_E',
    appId: '1:27359421590:ios:10d273b3f804b2dd9f8eb7',
    messagingSenderId: '27359421590',
    projectId: 'shopzee-d1596',
    storageBucket: 'shopzee-d1596.firebasestorage.app',
    androidClientId: '27359421590-at5ed4q0uqg2n0qb54vu2l6hvpg79m63.apps.googleusercontent.com',
    iosClientId: '27359421590-b7ghfi1v463er47gjt0vg5ntr6tie8de.apps.googleusercontent.com',
    iosBundleId: 'com.example.adminShoppingapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCSzt75DewiJS5YYPja8qdxAhtlL7c90Pk',
    appId: '1:27359421590:web:de6fe3a7e61caca79f8eb7',
    messagingSenderId: '27359421590',
    projectId: 'shopzee-d1596',
    authDomain: 'shopzee-d1596.firebaseapp.com',
    storageBucket: 'shopzee-d1596.firebasestorage.app',
  );

}