import 'package:equatable/equatable.dart';

class Trip extends Equatable {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final String? notes;
  final String? imageUrl;
  final String currency;
  final int travellers;
  final String? selectedFlightId;
  final String? selectedHotelId;
  final Map<String, dynamic>? weatherSnapshot;
  final DateTime? weatherSnapshotCapturedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? status;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? departureDate,
    DateTime? returnDate,
    required this.budget,
    this.notes,
    this.imageUrl,
    String? currency,
    int? travellers,
    this.selectedFlightId,
    this.selectedHotelId,
    this.weatherSnapshot,
    this.weatherSnapshotCapturedAt,
    this.createdAt,
    this.updatedAt,
    this.status,
  })  : startDate = _resolveStartDate(startDate, departureDate),
        endDate =
            _resolveEndDate(endDate, returnDate, startDate, departureDate),
        currency = currency ?? 'GBP',
        travellers = travellers ?? 1;

  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? departureDate,
    DateTime? returnDate,
    double? budget,
    String? notes,
    String? imageUrl,
    String? currency,
    int? travellers,
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
      budget: budget ?? this.budget,
      notes: notes ?? this.notes,
      imageUrl: imageUrl ?? this.imageUrl,
      currency: currency ?? this.currency,
      travellers: travellers ?? this.travellers,
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

  @Deprecated('Use startDate instead')
  DateTime get departureDate => startDate;

  @Deprecated('Use endDate instead')
  DateTime get returnDate => endDate;

  @Deprecated('Use the budget field and format explicitly')
  String get currencyOrDefault => currency;

  @Deprecated('Use a feature-specific count instead')
  int get travellerCount => travellers;

  @Deprecated('Use selectedFlightId instead')
  String? get flightId => selectedFlightId;

  @Deprecated('Use selectedHotelId instead')
  String? get hotelId => selectedHotelId;

  @Deprecated('Use endDate.difference(startDate).inDays instead')
  int get nights => endDate.difference(startDate).inDays;

  static DateTime _resolveStartDate(
      DateTime? startDate, DateTime? departureDate) {
    final resolved = startDate ?? departureDate;
    if (resolved != null) {
      return resolved;
    }
    throw ArgumentError('Trip requires a startDate or departureDate.');
  }

  static DateTime _resolveEndDate(
    DateTime? endDate,
    DateTime? returnDate,
    DateTime? startDate,
    DateTime? departureDate,
  ) {
    final resolved = endDate ?? returnDate;
    if (resolved != null) {
      return resolved;
    }
    final fallback = startDate ?? departureDate;
    if (fallback != null) {
      return fallback;
    }
    throw ArgumentError('Trip requires an endDate or returnDate.');
  }

  @override
  List<Object?> get props => [
        id,
        title,
        destination,
        startDate,
        endDate,
        budget,
        notes,
        imageUrl,
        currency,
        travellers,
        selectedFlightId,
        selectedHotelId,
        weatherSnapshot,
        weatherSnapshotCapturedAt,
        createdAt,
        updatedAt,
        status,
      ];
}
