import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract interface class BackendAuth {
  Future<String?> idToken();
}

class FirebaseBackendAuth implements BackendAuth {
  FirebaseBackendAuth({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth;

  final FirebaseAuth? _firebaseAuth;

  @override
  Future<String?> idToken() async {
    try {
      final firebaseAuth = _firebaseAuth ?? FirebaseAuth.instance;
      final currentUser = firebaseAuth.currentUser;
      if (kDebugMode) {
        debugPrint(
          '[TranslatorDiagnostics] Firebase current user present: ${currentUser != null}; anonymous: ${currentUser?.isAnonymous}',
        );
      }

      final user = currentUser ?? (await firebaseAuth.signInAnonymously()).user;
      if (kDebugMode) {
        debugPrint(
          '[TranslatorDiagnostics] Firebase ID token acquisition starting; user present: ${user != null}; anonymous: ${user?.isAnonymous}',
        );
      }

      final token = await user?.getIdToken();
      if (kDebugMode) {
        debugPrint(
          '[TranslatorDiagnostics] Firebase ID token acquisition succeeded; token present: ${token != null && token.isNotEmpty}',
        );
      }
      return token;
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          '[TranslatorDiagnostics] Firebase ID token acquisition failed: $error',
        );
      }
      rethrow;
    }
  }
}
