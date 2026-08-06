class TaxiRideRequest {
  const TaxiRideRequest({
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.destinationLatitude,
    required this.destinationLongitude,
    required this.destinationAddress,
    this.pickupTime,
    this.passengers = 1,
    this.luggage = 0,
  });

  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;

  final double destinationLatitude;
  final double destinationLongitude;
  final String destinationAddress;

  final DateTime? pickupTime;
  final int passengers;
  final int luggage;
}
