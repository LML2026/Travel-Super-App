class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.preferredLanguage = 'en',
    this.preferredCurrency = 'GBP',
    this.homeCity = '',
    this.dietaryPreferences = const <String>[],
    this.travelPreferences = const <Object>[],
  });

  final String uid;
  final String displayName;
  final String email;
  final String preferredLanguage;
  final String preferredCurrency;
  final String homeCity;
  final List<String> dietaryPreferences;
  final List<Object> travelPreferences;
}
