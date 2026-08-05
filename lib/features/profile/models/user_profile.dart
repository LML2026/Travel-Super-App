import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.preferredLanguage,
    required this.preferredCurrency,
    this.homeCity,
    this.dietaryPreferences = const [],
    this.travelPreferences = const [],
    this.avatarUrl,
  });

  final String uid;
  final String displayName;
  final String email;
  final String preferredLanguage;
  final String preferredCurrency;
  final String? homeCity;
  final List<String> dietaryPreferences;
  final List<String> travelPreferences;
  final String? avatarUrl;

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        preferredLanguage,
        preferredCurrency,
        homeCity,
        dietaryPreferences,
        travelPreferences,
        avatarUrl,
      ];
}
