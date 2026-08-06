import '../entities/auth_user.dart';
import '../repositories/authentication_repository.dart';

class RegisterWithEmail {
  const RegisterWithEmail(this._repository);

  final AuthenticationRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}
