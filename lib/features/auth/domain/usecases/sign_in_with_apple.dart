import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class SignInWithApple {
  const SignInWithApple(this._repository);

  final AuthRepository _repository;

  Future<UserCredential> call() {
    return _repository.signInWithApple();
  }
}
