import '../repositories/authentication_repository.dart';

class ReloadCurrentUser {
  const ReloadCurrentUser(this._repository);

  final AuthenticationRepository _repository;

  Future<void> call() => _repository.reloadCurrentUser();
}
