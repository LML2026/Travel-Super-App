class TripDocument {
  const TripDocument({
    required this.id,
    required this.tripId,
    required this.title,
    required this.type,
    required this.reference,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String tripId;
  final String title;
  final String type;
  final String reference;
  final String? notes;
  final DateTime? createdAt;
}
