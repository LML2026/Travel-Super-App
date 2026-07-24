import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String email,
    required String? displayName,
    required String? photoUrl,
    required String? phoneNumber,
    required String? bio,
    required String? country,
    required List<String> favoriteDestinations,
    required int tripsCompleted,
    required DateTime createdAt,
    required DateTime? lastLogin,
    required bool emailVerified,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
