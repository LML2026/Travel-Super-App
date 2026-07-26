class Trip {
  final String id;
  final String from;
  final String to;
  final DateTime departure;
  final DateTime? returning;
  final int travellers;
  final double budget;

  Trip({
    required this.id,
    required this.from,
    required this.to,
    required this.departure,
    this.returning,
    required this.travellers,
    required this.budget,
  });
}
