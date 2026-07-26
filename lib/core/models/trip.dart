class Trip {
  final String from;
  final String destination;
  final DateTime departure;
  final DateTime returning;
  final int travellers;
  final double budget;
  final String? id;

  Trip({
    required this.from,
    required this.destination,
    required this.departure,
    required this.returning,
    required this.travellers,
    required this.budget,
    this.id,
  });

  factory Trip.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) {
        return value;
      }
      if (value is String) {
        return DateTime.parse(value);
      }
      return (value as dynamic).toDate() as DateTime;
    }

    return Trip(
      from: map['from'] as String,
      destination: map['destination'] as String,
      departure: parseDate(map['departure']),
      returning: parseDate(map['returning']),
      travellers: (map['travellers'] as num).toInt(),
      budget: (map['budget'] as num).toDouble(),
      id: id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'from': from,
      'destination': destination,
      'departure': departure,
      'returning': returning,
      'travellers': travellers,
      'budget': budget,
    };
  }
}
