import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  final String id;
  final String destination;
  final DateTime departureDate;
  final DateTime returnDate;
  final int travellers;
  final String notes;
  final double budget;
  final String currency;
  final String? selectedFlightId;
  final String? selectedHotelId;
  final Map<String, dynamic>? weatherSnapshot;
  final DateTime? weatherSnapshotCapturedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  const Trip({
    required this.id,
    required this.destination,
    DateTime? departureDate,
    DateTime? returnDate,
    DateTime? startDate,
    DateTime? endDate,
    this.travellers = 1,
    this.notes = '',
    required this.budget,
    required this.currency,
    this.selectedFlightId,
    this.selectedHotelId,
    this.weatherSnapshot,
    this.weatherSnapshotCapturedAt,
    required this.createdAt,
    DateTime? updatedAt,
    this.status = 'planned',
  })  : departureDate = departureDate ?? startDate ?? createdAt,
        returnDate = returnDate ?? endDate ?? createdAt,
        updatedAt = updatedAt ?? createdAt;

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id']?.toString() ?? '',
      destination: json['destination']?.toString() ?? '',
      departureDate: DateTime.parse(
        json['departureDate']?.toString() ??
            json['startDate']?.toString() ??
            DateTime.now().toIso8601String(),
      ),
      returnDate: DateTime.parse(
        json['returnDate']?.toString() ??
            json['endDate']?.toString() ??
            DateTime.now().toIso8601String(),
      ),
      travellers: int.tryParse(json['travellers']?.toString() ?? '') ?? 1,
      notes: json['notes']?.toString() ?? '',
      budget: double.tryParse(json['budget']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'GBP',
      selectedFlightId:
          json['selectedFlightId']?.toString() ?? json['flightId']?.toString(),
      selectedHotelId:
          json['selectedHotelId']?.toString() ?? json['hotelId']?.toString(),
      weatherSnapshot: json['weatherSnapshot'] is Map<String, dynamic>
          ? json['weatherSnapshot'] as Map<String, dynamic>
          : (json['weather'] is Map<String, dynamic>
              ? json['weather'] as Map<String, dynamic>
              : null),
      weatherSnapshotCapturedAt: json['weatherSnapshotCapturedAt'] == null
          ? null
          : DateTime.parse(json['weatherSnapshotCapturedAt'].toString()),
      createdAt: DateTime.parse(
        json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt']?.toString() ??
            json['createdAt']?.toString() ??
            DateTime.now().toIso8601String(),
      ),
      status: json['status']?.toString() ?? 'planned',
    );
  }

  factory Trip.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Trip(
      id: doc.id,
      destination: data['destination'] ?? '',
      departureDate: (data['departureDate'] as Timestamp).toDate(),
      returnDate: (data['returnDate'] as Timestamp).toDate(),
      budget: (data['budget'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'GBP',
      travellers: data['travellers'] ?? 1,
      notes: data['notes'] ?? '',
      selectedFlightId: data['selectedFlightId']?.toString(),
      selectedHotelId: data['selectedHotelId']?.toString(),
      weatherSnapshot: data['weather'] is Map<String, dynamic>
          ? data['weather'] as Map<String, dynamic>
          : (data['weatherSnapshot'] is Map<String, dynamic>
              ? data['weatherSnapshot'] as Map<String, dynamic>
              : null),
      weatherSnapshotCapturedAt: data['weatherSnapshotCapturedAt'] is Timestamp
          ? (data['weatherSnapshotCapturedAt'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] is Timestamp
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      status: data['status']?.toString() ?? 'planned',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destination': destination,
      'departureDate': departureDate.toIso8601String(),
      'returnDate': returnDate.toIso8601String(),
      'startDate': departureDate.toIso8601String(),
      'endDate': returnDate.toIso8601String(),
      'travellers': travellers,
      'notes': notes,
      'budget': budget,
      'currency': currency,
      'selectedFlightId': selectedFlightId,
      'selectedHotelId': selectedHotelId,
      'flightId': selectedFlightId,
      'hotelId': selectedHotelId,
      'weather': weatherSnapshot,
      'weatherSnapshot': weatherSnapshot,
      'weatherSnapshotCapturedAt': weatherSnapshotCapturedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  Map<String, dynamic> toCreateMap() {
    return {
      'destination': destination,
      'departureDate': departureDate,
      'returnDate': returnDate,
      'budget': budget,
      'currency': currency,
      'travellers': travellers,
      'notes': notes,
      'selectedFlightId': selectedFlightId,
      'selectedHotelId': selectedHotelId,
      'weatherSnapshot': weatherSnapshot,
      'weatherSnapshotCapturedAt': weatherSnapshotCapturedAt,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'destination': destination,
      'departureDate': departureDate,
      'returnDate': returnDate,
      'budget': budget,
      'currency': currency,
      'travellers': travellers,
      'notes': notes,
      'selectedFlightId': selectedFlightId,
      'selectedHotelId': selectedHotelId,
      'weatherSnapshot': weatherSnapshot,
      'weatherSnapshotCapturedAt': weatherSnapshotCapturedAt,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Trip copyWith({
    String? id,
    String? destination,
    DateTime? departureDate,
    DateTime? returnDate,
    DateTime? startDate,
    DateTime? endDate,
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
      destination: destination ?? this.destination,
      departureDate: departureDate ?? startDate ?? this.departureDate,
      returnDate: returnDate ?? endDate ?? this.returnDate,
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

  DateTime get startDate => departureDate;

  DateTime get endDate => returnDate;

  int get nights => returnDate.difference(departureDate).inDays;

  @override
  String toString() {
    return 'Trip('
        'id: $id, '
        'destination: $destination, '
        'departure: $departureDate, '
        'return: $returnDate'
        ')';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trip && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
