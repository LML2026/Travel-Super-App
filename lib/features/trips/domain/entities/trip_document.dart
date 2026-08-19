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

  TripDocument copyWith({
    String? id,
    String? tripId,
    String? title,
    String? type,
    String? reference,
    String? notes,
    DateTime? createdAt,
  }) {
    return TripDocument(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      type: type ?? this.type,
      reference: reference ?? this.reference,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
