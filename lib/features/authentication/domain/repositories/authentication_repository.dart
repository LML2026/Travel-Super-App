import '../entities/auth_user.dart';

abstract interface class AuthenticationRepository {
  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<AuthUser?> signIn({
    required String email,
    required String password,
  });

  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AuthUser?> signInWithGoogle();

  Future<AuthUser?> signInWithApple();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> reloadCurrentUser();

  Future<void> signOut();
}
