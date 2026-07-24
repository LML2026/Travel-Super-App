import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_params_model.freezed.dart';
part 'search_params_model.g.dart';

@freezed
class FlightSearchParams with _$FlightSearchParams {
  const factory FlightSearchParams({
    required String departure,
    required String arrival,
    required DateTime departureDate,
    DateTime? returnDate,
    required int passengers,
    required String tripType,
  }) = _FlightSearchParams;

  factory FlightSearchParams.fromJson(Map<String, dynamic> json) =>
      _$FlightSearchParamsFromJson(json);
}

@freezed
class HotelSearchParams with _$HotelSearchParams {
  const factory HotelSearchParams({
    required String city,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guests,
    required int rooms,
  }) = _HotelSearchParams;

  factory HotelSearchParams.fromJson(Map<String, dynamic> json) =>
      _$HotelSearchParamsFromJson(json);
}
