import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  User? call() {
    return _repository.currentUser;
  }
}
