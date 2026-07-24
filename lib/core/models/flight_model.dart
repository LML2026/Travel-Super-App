import 'package:freezed_annotation/freezed_annotation.dart';

part 'flight_model.freezed.dart';
part 'flight_model.g.dart';

@freezed
class Flight with _$Flight {
  const factory Flight({
    required String id,
    required String airline,
    required String flightNumber,
    required String departure,
    required String arrival,
    required DateTime departureTime,
    required DateTime arrivalTime,
    required int duration,
    required double price,
    required int stops,
    required int seats,
    required String aircraft,
    required double rating,
  }) = _Flight;

  factory Flight.fromJson(Map<String, dynamic> json) => _$FlightFromJson(json);
}
