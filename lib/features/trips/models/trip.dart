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

  Trip copyWith({
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    int? travellers,
    String? notes,
    double? budget,
    String? currency,
  }) {
    return Trip(
      id: id,
      destination: destination ?? this.destination,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      travellers: travellers ?? this.travellers,
      notes: notes ?? this.notes,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
    );
  }
}
