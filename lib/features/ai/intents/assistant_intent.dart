enum AssistantIntentType {
  showTodayJourney,
  showActiveJourney,
  openTrips,
  openWallet,
  openTravelCoin,
  showBudget,
  showWalletBalance,
  showCoinBalance,
  openProfile,
  updateProfile,
  planTrip,
  translate,
  findNearbyToilet,
  findNearbyAtm,
  findPlaces,
  recommendRestaurant,
  recommendActivity,
  findNearbyPharmacy,
  findNearbyHospital,
  addPlaceToItinerary,
  unknown,
}

class AssistantIntent {
  const AssistantIntent({
    required this.type,
    this.parameters = const {},
    required this.confidence,
  });

  final AssistantIntentType type;
  final Map<String, Object?> parameters;
  final double confidence;
}
