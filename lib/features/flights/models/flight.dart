class Flight {
  final String id;
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

  const Flight({
    required this.id,
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
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id']?.toString() ?? '',
      airline: json['airline']?.toString() ?? 'Unknown airline',
      airlineLogo: json['airlineLogo']?.toString() ?? '',
      flightNumber: json['flightNumber']?.toString() ?? '',
      origin: json['origin']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      departureAt: json['departureAt']?.toString() ?? '',
      arrivalAt: json['arrivalAt']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      stops: (json['stops'] as num?)?.toInt() ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      currency: json['currency']?.toString() ?? 'GBP',
    );
  }
}
