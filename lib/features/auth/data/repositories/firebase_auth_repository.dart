import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  final AuthService _authService;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Stream<User?> authStateChanges() {
    return _authService.authStateChanges;
  }

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(email: email, password: password);
  }

  @override
  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _authService.register(email: email, password: password);
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _authService.sendPasswordReset(email: email);
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }
}
