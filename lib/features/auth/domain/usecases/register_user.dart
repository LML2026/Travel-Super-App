import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class RegisterUser {
  const RegisterUser(this._repository);

  final AuthRepository _repository;

  Future<UserCredential> call({
    required String email,
    required String password,
  }) {
    return _repository.register(email: email, password: password);
  }
}
