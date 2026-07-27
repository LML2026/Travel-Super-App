import '../entities/auth_user.dart';
import '../repositories/authentication_repository.dart';

class WatchAuthState {
  const WatchAuthState(this._repository);

  final AuthenticationRepository _repository;

  Stream<AuthUser?> call() => _repository.authStateChanges();
}
