import 'package:freezed_annotation/freezed_annotation.dart';

part 'hotel_model.freezed.dart';
part 'hotel_model.g.dart';

@freezed
class Hotel with _$Hotel {
  const factory Hotel({
    required String id,
    required String name,
    required String city,
    required String address,
    required double pricePerNight,
    required double rating,
    required int reviewCount,
    required String imageUrl,
    required List<String> amenities,
    required List<String> roomTypes,
    required int availableRooms,
    required String checkInTime,
    required String checkOutTime,
    required bool hasWifi,
    required bool hasPool,
    required bool hasGym,
  }) = _Hotel;

  factory Hotel.fromJson(Map<String, dynamic> json) => _$HotelFromJson(json);
}
