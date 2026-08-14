import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';
import 'auth_state.dart';
import 'auth_user.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;

  FirebaseAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Stream<AuthState> get authStateChanges => _auth.authStateChanges().map(
    (user) => user == null
        ? const AuthState.signedOut()
        : AuthState.signedIn(_mapUser(user)),
  );

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapErrorCode(error.code));
    } catch (_) {
      throw const AuthException('signInFailed');
    }
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapErrorCode(error.code));
    } catch (_) {
      throw const AuthException('signUpFailed');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapErrorCode(error.code));
    } catch (_) {
      throw const AuthException('signOutFailed');
    }
  }

  @override
  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }

  static AuthUser _mapUser(User user) =>
      AuthUser(uid: user.uid, email: user.email);

  static String _mapErrorCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'invalidEmail';
      case 'wrong-password':
      case 'invalid-credential':
      case 'user-not-found':
        return 'invalidCredentials';
      case 'email-already-in-use':
        return 'emailAlreadyInUse';
      case 'weak-password':
        return 'weakPassword';
      case 'network-request-failed':
        return 'networkUnavailable';
      case 'too-many-requests':
        return 'tooManyRequests';
      default:
        return 'authFailed';
    }
  }
}

class UnavailableAuthService implements AuthService {
  const UnavailableAuthService();

  @override
  AuthUser? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges =>
      Stream.value(const AuthState.unavailable('authUnavailable'));

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) => _unavailable();

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) => _unavailable();

  @override
  Future<void> signOut() =>
      Future.error(const AuthException('authUnavailable'));

  @override
  Future<String?> getIdToken() => Future.value(null);

  Future<AuthUser> _unavailable() =>
      Future.error(const AuthException('authUnavailable'));
}
