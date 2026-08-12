class Trip {
  final String id;
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int travellers;
  final String notes;
  final double budget;
  final String currency;

  const Trip({
    required this.id,
    required this.destination,
    required this.departureDate,
    required this.returnDate,
    required this.travellers,
    required this.notes,
    required this.budget,
    required this.currency,
  });
}
