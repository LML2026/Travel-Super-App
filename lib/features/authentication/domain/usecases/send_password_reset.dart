import '../repositories/authentication_repository.dart';

class SendPasswordReset {
  const SendPasswordReset(this._repository);

  final AuthenticationRepository _repository;

  Future<void> call(String email) {
    return _repository.sendPasswordResetEmail(email);
  }
}
