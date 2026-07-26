class FlightSearchRequest {
  final String from;
  final String to;
  final String departureDate;
  final String? returnDate;
  final int passengers;
  final String cabinClass;

  const FlightSearchRequest({
    required this.from,
    required this.to,
    required this.departureDate,
    this.returnDate,
    this.passengers = 1,
    this.cabinClass = 'economy',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlightSearchRequest &&
          from == other.from &&
          to == other.to &&
          departureDate == other.departureDate &&
          returnDate == other.returnDate &&
          passengers == other.passengers &&
          cabinClass == other.cabinClass;

  @override
  int get hashCode =>
      Object.hash(from, to, departureDate, returnDate, passengers, cabinClass);
}
