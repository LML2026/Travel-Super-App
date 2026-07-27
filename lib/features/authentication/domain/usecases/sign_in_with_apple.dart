import '../entities/auth_user.dart';
import '../repositories/authentication_repository.dart';

class SignInWithApple {
  const SignInWithApple(this._repository);

  final AuthenticationRepository _repository;

  Future<AuthUser?> call() => _repository.signInWithApple();
}
