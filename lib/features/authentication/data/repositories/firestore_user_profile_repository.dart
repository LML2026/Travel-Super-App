import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/firestore_profile_datasource.dart';
import '../models/user_profile_model.dart';

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({FirestoreProfileDataSource? dataSource})
    : _dataSource = dataSource ?? FirestoreProfileDataSource();

  final FirestoreProfileDataSource _dataSource;

  @override
  Future<void> ensureProfile({
    required String uid,
    required UserProfile profile,
  }) {
    return _dataSource.ensureProfile(
      uid: uid,
      profile: UserProfileModel.fromEntity(profile),
    );
  }
}
