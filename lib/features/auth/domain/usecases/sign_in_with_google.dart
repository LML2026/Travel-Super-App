import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<UserCredential> call() {
    return _repository.signInWithGoogle();
  }
}
