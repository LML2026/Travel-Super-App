import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorMapper {
  const AuthErrorMapper._();

  static String messageFor(Object error) {
    if (error is FirebaseAuthException) {
      return _firebaseMessage(error);
    }

    final raw = error.toString();
    const exceptionPrefix = 'Exception: ';
    if (raw.startsWith(exceptionPrefix)) {
      return raw.substring(exceptionPrefix.length);
    }

    return 'Authentication failed. Please try again.';
  }

  static String _firebaseMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
