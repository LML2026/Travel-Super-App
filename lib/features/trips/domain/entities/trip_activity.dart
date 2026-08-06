class TripActivity {
  const TripActivity({
    required this.id,
    required this.tripId,
    required this.title,
    this.location,
    this.notes,
    this.scheduledAt,
    this.createdAt,
  });

  final String id;
  final String tripId;
  final String title;
  final String? location;
  final String? notes;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
}
