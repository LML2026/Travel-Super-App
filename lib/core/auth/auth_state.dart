import 'auth_user.dart';

enum AuthStateStatus { loading, signedOut, signedIn, unavailable }

class AuthState {
  final AuthStateStatus status;
  final AuthUser? user;
  final String? errorCode;

  const AuthState({required this.status, this.user, this.errorCode});

  const AuthState.loading() : this(status: AuthStateStatus.loading);

  const AuthState.signedOut() : this(status: AuthStateStatus.signedOut);

  const AuthState.signedIn(AuthUser user)
    : this(status: AuthStateStatus.signedIn, user: user);

  const AuthState.unavailable(String errorCode)
    : this(status: AuthStateStatus.unavailable, errorCode: errorCode);
}
