import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/authentication_repository.dart';
import '../models/auth_user_model.dart';
import '../datasources/firebase_auth_datasource.dart';

class FirebaseAuthenticationRepository implements AuthenticationRepository {
  FirebaseAuthenticationRepository({FirebaseAuthDataSource? dataSource})
      : _dataSource = dataSource ?? FirebaseAuthDataSource();

  final FirebaseAuthDataSource _dataSource;

  @override
  AuthUser? get currentUser {
    final user = _dataSource.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _dataSource.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AuthUserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<AuthUser?> signIn({
    required String email,
    required String password,
  }) async {
    final credential =
        await _dataSource.signIn(email: email, password: password);
    final user = credential.user;
    if (user == null) {
      return null;
    }
    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _dataSource.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Registration completed without a Firebase user.');
    }
    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    final credential = await _dataSource.signInWithGoogle();
    final user = credential.user;
    if (user == null) {
      return null;
    }
    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    final credential = await _dataSource.signInWithApple();
    final user = credential.user;
    if (user == null) {
      return null;
    }
    return AuthUserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _dataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendEmailVerification() => _dataSource.sendEmailVerification();

  @override
  Future<void> reloadCurrentUser() => _dataSource.reloadCurrentUser();

  @override
  Future<void> signOut() => _dataSource.signOut();
}
