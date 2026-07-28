class TaxiSavedRide {
  const TaxiSavedRide({
    required this.id,
    required this.tripId,
    required this.provider,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.status,
    required this.estimatedFare,
    required this.currency,
    required this.passengers,
    required this.luggage,
    this.scheduledAt,
    this.bookingReference,
    this.createdAt,
  });

  final String id;
  final String tripId;
  final String provider;
  final String pickupAddress;
  final String destinationAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final double destinationLatitude;
  final double destinationLongitude;
  final DateTime? scheduledAt;
  final String status;
  final double estimatedFare;
  final String currency;
  final String? bookingReference;
  final int passengers;
  final int luggage;
  final DateTime? createdAt;
}
