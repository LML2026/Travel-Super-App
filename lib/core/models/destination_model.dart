import 'package:freezed_annotation/freezed_annotation.dart';

part 'destination_model.freezed.dart';
part 'destination_model.g.dart';

@freezed
class Destination with _$Destination {
  const factory Destination({
    required String id,
    required String name,
    required String country,
    required String countryCode,
    required String flag,
    required String description,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required double temperature,
    required String weather,
    required List<String> attractions,
    required int bestTimeToVisit,
  }) = _Destination;

  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);
}
