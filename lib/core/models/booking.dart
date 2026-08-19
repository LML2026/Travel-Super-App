import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus {
  pending,
  confirmed,
  cancelled,
  completed,
  failed,
}

enum BookingType {
  flight,
  hotel,
  transport,
}

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String tripId,
    required String userId,
    required BookingType type,
    required BookingStatus status,
    required double amount,
    required String currency,
    required DateTime createdAt,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);

  // Specialized factories or helpers for Flight, Hotel, and Transport bookings.
  factory Booking.flight({
    required String id,
    required String tripId,
    required String userId,
    required double amount,
    required String currency,
    Map<String, dynamic> metadata = const {},
  }) => Booking(
    id: id,
    tripId: tripId,
    userId: userId,
    type: BookingType.flight,
    status: BookingStatus.pending,
    amount: amount,
    currency: currency,
    createdAt: DateTime.now(),
    metadata: metadata,
  );

  factory Booking.hotel({
    required String id,
    required String tripId,
    required String userId,
    required double amount,
    required String currency,
    Map<String, dynamic> metadata = const {},
  }) => Booking(
    id: id,
    tripId: tripId,
    userId: userId,
    type: BookingType.hotel,
    status: BookingStatus.pending,
    amount: amount,
    currency: currency,
    createdAt: DateTime.now(),
    metadata: metadata,
  );

  factory Booking.transport({
    required String id,
    required String tripId,
    required String userId,
    required double amount,
    required String currency,
    Map<String, dynamic> metadata = const {},
  }) => Booking(
    id: id,
    tripId: tripId,
    userId: userId,
    type: BookingType.transport,
    status: BookingStatus.pending,
    amount: amount,
    currency: currency,
    createdAt: DateTime.now(),
    metadata: metadata,
  );
}
