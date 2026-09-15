class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.isAnonymous = false,
  });

  final String uid;
  final String? email;
  final bool emailVerified;
  final bool isAnonymous;
}
