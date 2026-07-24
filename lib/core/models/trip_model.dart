import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@freezed
class Trip with _$Trip {
  const factory Trip({
    required String id,
    required String title,
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required double budget,
    required double spent,
    required String status,
    required List<String> activities,
    required String imageUrl,
    required int travelers,
  }) = _Trip;

  factory Trip.fromJson(Map<String, dynamic> json) => _$TripFromJson(json);
}
