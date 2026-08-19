enum DiscoveryCategory {
  flights,
  hotels,
  transport,
  activities,
  restaurants,
}

class TravelDiscoveryQuery {
  const TravelDiscoveryQuery({
    required this.destination,
    required this.startDate,
    required this.endDate,
    this.origin = '',
    this.travellers = 1,
    this.rooms = 1,
    this.cabinClass = 'economy',
    this.interest = 'culture',
    this.cuisine = 'local',
  });

  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String origin;
  final int travellers;
  final int rooms;
  final String cabinClass;
  final String interest;
  final String cuisine;
}

class TravelDiscoveryResult {
  const TravelDiscoveryResult({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.provider,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.currency,
    required this.rating,
    required this.details,
    this.metadata = const {},
  });

  final String id;
  final DiscoveryCategory category;
  final String title;
  final String subtitle;
  final String provider;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String duration;
  final double price;
  final String currency;
  final double rating;
  final String details;
  final Map<String, Object?> metadata;

  bool get isBookable =>
      category == DiscoveryCategory.flights ||
      category == DiscoveryCategory.hotels ||
      category == DiscoveryCategory.transport;

  bool get isTripActivity =>
      category == DiscoveryCategory.activities ||
      category == DiscoveryCategory.restaurants;
}

class TravelDiscoveryState {
  const TravelDiscoveryState({
    this.results = const [],
    this.savedIds = const {},
    this.compareIds = const {},
    this.selectedTripId,
  });

  final List<TravelDiscoveryResult> results;
  final Set<String> savedIds;
  final Set<String> compareIds;
  final String? selectedTripId;

  TravelDiscoveryState copyWith({
    List<TravelDiscoveryResult>? results,
    Set<String>? savedIds,
    Set<String>? compareIds,
    String? selectedTripId,
  }) {
    return TravelDiscoveryState(
      results: results ?? this.results,
      savedIds: savedIds ?? this.savedIds,
      compareIds: compareIds ?? this.compareIds,
      selectedTripId: selectedTripId ?? this.selectedTripId,
    );
  }
}
