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
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'FirebaseOptions have not been configured for this platform. '
          'Run flutterfire configure after native platform files are present.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDjtAieDEVEkgcWhcaGdkN30XBpav9GA_E',
    appId: '1:819113789304:web:879ea9835015f97344ea8d',
    messagingSenderId: '819113789304',
    projectId: 'travelsuperapp-f04a0',
    authDomain: 'travelsuperapp-f04a0.firebaseapp.com',
    storageBucket: 'travelsuperapp-f04a0.firebasestorage.app',
    measurementId: 'G-1CXHFF1JYR',
  );
}
