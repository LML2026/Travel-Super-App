import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

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
    return web;
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
