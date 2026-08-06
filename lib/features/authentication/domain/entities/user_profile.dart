class UserProfile {
  const UserProfile({
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
}
