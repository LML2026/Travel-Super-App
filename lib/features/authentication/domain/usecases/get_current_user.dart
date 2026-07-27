import '../entities/auth_user.dart';
import '../repositories/authentication_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthenticationRepository _repository;

  AuthUser? call() => _repository.currentUser;
}
