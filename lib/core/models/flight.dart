class Flight {
  final String id;
  final String airline;
  final String flightNumber;
  final String departure;
  final String arrival;
  final DateTime departureTime;
  final DateTime arrivalTime;
  final String duration;
  final double price;
  final int stops;
  final int availableSeats;
  final String aircraft;
  final double rating;

  Flight({
    required this.id,
    required this.airline,
    required this.flightNumber,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.stops,
    required this.availableSeats,
    required this.aircraft,
    required this.rating,
  });

  factory Flight.fromJson(Map<String, dynamic> json) {
    return Flight(
      id: json['id'] as String,
      airline: json['airline'] as String,
      flightNumber: json['flightNumber'] as String,
      departure: json['departure'] as String,
      arrival: json['arrival'] as String,
      departureTime: DateTime.parse(json['departureTime'] as String),
      arrivalTime: DateTime.parse(json['arrivalTime'] as String),
      duration: json['duration'] as String,
      price: (json['price'] as num).toDouble(),
      stops: json['stops'] as int,
      availableSeats: json['availableSeats'] as int,
      aircraft: json['aircraft'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'flightNumber': flightNumber,
      'departure': departure,
      'arrival': arrival,
      'departureTime': departureTime.toIso8601String(),
      'arrivalTime': arrivalTime.toIso8601String(),
      'duration': duration,
      'price': price,
      'stops': stops,
      'availableSeats': availableSeats,
      'aircraft': aircraft,
      'rating': rating,
    };
  }
}
