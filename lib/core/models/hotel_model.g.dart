// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotel_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HotelImpl _$$HotelImplFromJson(Map<String, dynamic> json) => _$HotelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  city: json['city'] as String,
  address: json['address'] as String,
  pricePerNight: (json['pricePerNight'] as num).toDouble(),
  rating: (json['rating'] as num).toDouble(),
  reviewCount: (json['reviewCount'] as num).toInt(),
  imageUrl: json['imageUrl'] as String,
  amenities: (json['amenities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  roomTypes: (json['roomTypes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  availableRooms: (json['availableRooms'] as num).toInt(),
  checkInTime: json['checkInTime'] as String,
  checkOutTime: json['checkOutTime'] as String,
  hasWifi: json['hasWifi'] as bool,
  hasPool: json['hasPool'] as bool,
  hasGym: json['hasGym'] as bool,
);

Map<String, dynamic> _$$HotelImplToJson(_$HotelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'address': instance.address,
      'pricePerNight': instance.pricePerNight,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'imageUrl': instance.imageUrl,
      'amenities': instance.amenities,
      'roomTypes': instance.roomTypes,
      'availableRooms': instance.availableRooms,
      'checkInTime': instance.checkInTime,
      'checkOutTime': instance.checkOutTime,
      'hasWifi': instance.hasWifi,
      'hasPool': instance.hasPool,
      'hasGym': instance.hasGym,
    };
