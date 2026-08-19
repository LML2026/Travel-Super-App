class TripActivity {
  const TripActivity({
    required this.id,
    required this.tripId,
    required this.title,
    this.location,
    this.notes,
    this.scheduledAt,
    this.cost,
    this.currency,
    this.status,
    this.createdAt,
  });

  final String id;
  final String tripId;
  final String title;
  final String? location;
  final String? notes;
  final DateTime? scheduledAt;
  final double? cost;
  final String? currency;
  final String? status;
  final DateTime? createdAt;

  TripActivity copyWith({
    String? id,
    String? tripId,
    String? title,
    String? location,
    String? notes,
    DateTime? scheduledAt,
    double? cost,
    String? currency,
    String? status,
    DateTime? createdAt,
  }) {
    return TripActivity(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
