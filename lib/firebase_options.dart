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
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDjtAieDEVEkgcWhcaGdkN30XBpav9GA_E',
    appId: '1:819113789304:web:879ea9835015f97344ea8d',
    messagingSenderId: '819113789304',
    projectId: 'travelsuperapp-f04a0',
    authDomain: 'travelsuperapp-f04a0.firebaseapp.com',
    databaseURL: 'https://travelsuperapp-f04a0-default-rtdb.firebaseio.com',
    storageBucket: 'travelsuperapp-f04a0.firebasestorage.app',
    measurementId: 'G-1CXHFF1JYR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_GdZ0NBrGep6IlgcgFKWfAqZ3I16iJR4',
    appId: '1:819113789304:android:25b1a3761405aa5344ea8d',
    messagingSenderId: '819113789304',
    projectId: 'travelsuperapp-f04a0',
    databaseURL: 'https://travelsuperapp-f04a0-default-rtdb.firebaseio.com',
    storageBucket: 'travelsuperapp-f04a0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDlT4eFeaMDd3GY9iLc24dRzXxTTTLnMR0',
    appId: '1:819113789304:ios:f3c194e06713a7f444ea8d',
    messagingSenderId: '819113789304',
    projectId: 'travelsuperapp-f04a0',
    databaseURL: 'https://travelsuperapp-f04a0-default-rtdb.firebaseio.com',
    storageBucket: 'travelsuperapp-f04a0.firebasestorage.app',
    iosBundleId: 'com.example.travelSuperApp',
  );
}
