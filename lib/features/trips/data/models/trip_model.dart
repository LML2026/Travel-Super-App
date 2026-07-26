import '../../domain/entities/trip.dart';

class TripModel extends Trip {
  TripModel({
    required super.id,
    required super.title,
    required super.destination,
    required super.startDate,
    required super.endDate,
    required super.budget,
    super.currency = 'GBP',
    super.travellers = 1,
    super.notes = '',
    super.selectedFlightId,
    super.selectedHotelId,
    super.weatherSnapshot,
    super.weatherSnapshotCapturedAt,
    required super.createdAt,
    required super.updatedAt,
    super.status = 'planned',
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final title = (json['title']?.toString().trim().isNotEmpty ?? false)
        ? json['title'].toString().trim()
        : (json['destination']?.toString() ?? 'Untitled Trip');
    final createdAt = _readDate(json['createdAt']) ?? DateTime.now();
    final startDate =
        _readDate(json['startDate']) ?? _readDate(json['departureDate']) ?? createdAt;
    final endDate =
        _readDate(json['endDate']) ?? _readDate(json['returnDate']) ?? startDate;

    return TripModel(
      id: json['id']?.toString() ?? '',
      title: title,
      destination: json['destination']?.toString() ?? '',
      startDate: startDate,
      endDate: endDate,
      budget: (json['budget'] as num?)?.toDouble() ??
          double.tryParse(json['budget']?.toString() ?? '') ??
          0,
      currency: json['currency']?.toString() ?? 'GBP',
      travellers: (json['travellers'] as num?)?.toInt() ??
          int.tryParse(json['travellers']?.toString() ?? '') ??
          1,
      notes: json['notes']?.toString() ?? '',
      selectedFlightId:
          json['selectedFlightId']?.toString() ?? json['flightId']?.toString(),
      selectedHotelId:
          json['selectedHotelId']?.toString() ?? json['hotelId']?.toString(),
      weatherSnapshot: json['weatherSnapshot'] is Map<String, dynamic>
          ? json['weatherSnapshot'] as Map<String, dynamic>
          : (json['weather'] is Map<String, dynamic>
              ? json['weather'] as Map<String, dynamic>
              : null),
      weatherSnapshotCapturedAt: _readDate(json['weatherSnapshotCapturedAt']),
      createdAt: createdAt,
      updatedAt: _readDate(json['updatedAt']) ?? createdAt,
      status: json['status']?.toString() ?? 'planned',
    );
  }

  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      id: trip.id,
      title: trip.title,
      destination: trip.destination,
      startDate: trip.startDate,
      endDate: trip.endDate,
      budget: trip.budget,
      currency: trip.currency,
      travellers: trip.travellers,
      notes: trip.notes,
      selectedFlightId: trip.selectedFlightId,
      selectedHotelId: trip.selectedHotelId,
      weatherSnapshot: trip.weatherSnapshot,
      weatherSnapshotCapturedAt: trip.weatherSnapshotCapturedAt,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
      status: trip.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'destination': destination,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'departureDate': startDate.toIso8601String(),
      'returnDate': endDate.toIso8601String(),
      'budget': budget,
      'currency': currency,
      'travellers': travellers,
      'notes': notes,
      'selectedFlightId': selectedFlightId,
      'selectedHotelId': selectedHotelId,
      'flightId': selectedFlightId,
      'hotelId': selectedHotelId,
      'weatherSnapshot': weatherSnapshot,
      'weather': weatherSnapshot,
      'weatherSnapshotCapturedAt': weatherSnapshotCapturedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'status': status,
    };
  }

  static DateTime? _readDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.tryParse(value.toString());
  }
}
