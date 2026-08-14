import 'auth_state.dart';
import 'auth_user.dart';

abstract interface class AuthService {
  AuthUser? get currentUser;
  Stream<AuthState> get authStateChanges;

  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> createAccount({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<String?> getIdToken();
}

class AuthException implements Exception {
  final String code;

  const AuthException(this.code);
}
