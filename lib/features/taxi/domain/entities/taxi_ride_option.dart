class TaxiRideOption {
  const TaxiRideOption({
    required this.providerName,
    required this.estimatedFare,
    required this.currency,
    required this.estimatedPickupMinutes,
    required this.description,
  });

  final String providerName;
  final double estimatedFare;
  final String currency;
  final int estimatedPickupMinutes;
  final String description;
}
