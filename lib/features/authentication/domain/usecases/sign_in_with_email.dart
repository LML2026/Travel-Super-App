import '../entities/auth_user.dart';
import '../repositories/authentication_repository.dart';

class SignInWithEmail {
  const SignInWithEmail(this._repository);

  final AuthenticationRepository _repository;

  Future<AuthUser?> call({required String email, required String password}) {
    return _repository.signIn(email: email, password: password);
  }
}
