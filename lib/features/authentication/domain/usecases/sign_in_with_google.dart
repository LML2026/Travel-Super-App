import '../entities/auth_user.dart';
import '../repositories/authentication_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthenticationRepository _repository;

  Future<AuthUser?> call() => _repository.signInWithGoogle();
}
