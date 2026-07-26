class SavedFlight {
  final String id;
  final String flightId;
  final String airline;
  final String airlineLogo;
  final String flightNumber;
  final String origin;
  final String destination;
  final String departureAt;
  final String arrivalAt;
  final String duration;
  final int stops;
  final double amount;
  final String currency;
  final String cabinClass;
  final DateTime savedAt;

  const SavedFlight({
    required this.id,
    required this.flightId,
    required this.airline,
    required this.airlineLogo,
    required this.flightNumber,
    required this.origin,
    required this.destination,
    required this.departureAt,
    required this.arrivalAt,
    required this.duration,
    required this.stops,
    required this.amount,
    required this.currency,
    required this.cabinClass,
    required this.savedAt,
  });

  factory SavedFlight.fromJson(Map<String, dynamic> json) {
    return SavedFlight(
      id: json['id'] as String? ?? '',
      flightId: json['flightId'] as String? ?? '',
      airline: json['airline'] as String? ?? '',
      airlineLogo: json['airlineLogo'] as String? ?? '',
      flightNumber: json['flightNumber'] as String? ?? '',
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      departureAt: json['departureAt'] as String? ?? '',
      arrivalAt: json['arrivalAt'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      stops: json['stops'] as int? ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      currency: json['currency'] as String? ?? 'GBP',
      cabinClass: json['cabinClass'] as String? ?? 'economy',
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'flightId': flightId,
    'airline': airline,
    'airlineLogo': airlineLogo,
    'flightNumber': flightNumber,
    'origin': origin,
    'destination': destination,
    'departureAt': departureAt,
    'arrivalAt': arrivalAt,
    'duration': duration,
    'stops': stops,
    'amount': amount,
    'currency': currency,
    'cabinClass': cabinClass,
    'savedAt': savedAt.toIso8601String(),
  };
}
