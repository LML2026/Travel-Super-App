import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.homeCountry,
    required this.homeCurrency,
    required this.preferredLanguage,
  });

  final String displayName;
  final String email;
  final String? photoUrl;
  final String homeCountry;
  final String homeCurrency;
  final String preferredLanguage;

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      displayName: profile.displayName,
      email: profile.email,
      photoUrl: profile.photoUrl,
      homeCountry: profile.homeCountry,
      homeCurrency: profile.homeCurrency,
      preferredLanguage: profile.preferredLanguage,
    );
  }
}
