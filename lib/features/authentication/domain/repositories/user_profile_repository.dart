import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<void> ensureProfile({
    required String uid,
    required UserProfile profile,
  });
}
