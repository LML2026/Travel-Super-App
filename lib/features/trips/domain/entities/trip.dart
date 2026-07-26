class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final int travellers;
  final String currency;
  final String notes;
  final String? selectedFlightId;
  final String? selectedHotelId;
  final Map<String, dynamic>? weatherSnapshot;
  final DateTime? weatherSnapshotCapturedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  Trip({
    required this.id,
    required String title,
    required this.destination,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? departureDate,
    DateTime? returnDate,
    required this.budget,
    this.travellers = 1,
    this.currency = 'GBP',
    this.notes = '',
    this.selectedFlightId,
    this.selectedHotelId,
    this.weatherSnapshot,
    this.weatherSnapshotCapturedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = 'planned',
  })  : title = title.trim().isEmpty ? destination : title,
        startDate = startDate ?? departureDate ?? createdAt ?? DateTime.now(),
        endDate = endDate ?? returnDate ?? startDate ?? departureDate ?? createdAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? createdAt ?? DateTime.now();

  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? departureDate,
    DateTime? returnDate,
    int? travellers,
    String? notes,
    double? budget,
    String? currency,
    String? selectedFlightId,
    String? selectedHotelId,
    Map<String, dynamic>? weatherSnapshot,
    DateTime? weatherSnapshotCapturedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? departureDate ?? this.startDate,
      endDate: endDate ?? returnDate ?? this.endDate,
      travellers: travellers ?? this.travellers,
      notes: notes ?? this.notes,
      budget: budget ?? this.budget,
      currency: currency ?? this.currency,
      selectedFlightId: selectedFlightId ?? this.selectedFlightId,
      selectedHotelId: selectedHotelId ?? this.selectedHotelId,
      weatherSnapshot: weatherSnapshot ?? this.weatherSnapshot,
      weatherSnapshotCapturedAt:
          weatherSnapshotCapturedAt ?? this.weatherSnapshotCapturedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
    );
  }

  String? get flightId => selectedFlightId;

  String? get hotelId => selectedHotelId;

  DateTime get departureDate => startDate;

  DateTime get returnDate => endDate;

  int get nights => endDate.difference(startDate).inDays;

  @override
  String toString() {
    return 'Trip('
        'id: $id, '
        'title: $title, '
        'destination: $destination, '
        'start: $startDate, '
        'end: $endDate'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trip && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
