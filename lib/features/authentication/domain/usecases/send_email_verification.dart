import '../repositories/authentication_repository.dart';

class SendEmailVerification {
  const SendEmailVerification(this._repository);

  final AuthenticationRepository _repository;

  Future<void> call() => _repository.sendEmailVerification();
}
