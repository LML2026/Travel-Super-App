import '../entities/user_profile.dart';
import '../repositories/user_profile_repository.dart';

class EnsureUserProfile {
  const EnsureUserProfile(this._repository);

  final UserProfileRepository _repository;

  Future<void> call({required String uid, required UserProfile profile}) {
    return _repository.ensureProfile(uid: uid, profile: profile);
  }
}
