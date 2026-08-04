// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_params_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlightSearchParamsImpl _$$FlightSearchParamsImplFromJson(
  Map<String, dynamic> json,
) => _$FlightSearchParamsImpl(
  departure: json['departure'] as String,
  arrival: json['arrival'] as String,
  departureDate: DateTime.parse(json['departureDate'] as String),
  returnDate: json['returnDate'] == null
      ? null
      : DateTime.parse(json['returnDate'] as String),
  passengers: (json['passengers'] as num).toInt(),
  tripType: json['tripType'] as String,
);

Map<String, dynamic> _$$FlightSearchParamsImplToJson(
  _$FlightSearchParamsImpl instance,
) => <String, dynamic>{
  'departure': instance.departure,
  'arrival': instance.arrival,
  'departureDate': instance.departureDate.toIso8601String(),
  'returnDate': instance.returnDate?.toIso8601String(),
  'passengers': instance.passengers,
  'tripType': instance.tripType,
};

_$HotelSearchParamsImpl _$$HotelSearchParamsImplFromJson(
  Map<String, dynamic> json,
) => _$HotelSearchParamsImpl(
  city: json['city'] as String,
  checkInDate: DateTime.parse(json['checkInDate'] as String),
  checkOutDate: DateTime.parse(json['checkOutDate'] as String),
  guests: (json['guests'] as num).toInt(),
  rooms: (json['rooms'] as num).toInt(),
);

Map<String, dynamic> _$$HotelSearchParamsImplToJson(
  _$HotelSearchParamsImpl instance,
) => <String, dynamic>{
  'city': instance.city,
  'checkInDate': instance.checkInDate.toIso8601String(),
  'checkOutDate': instance.checkOutDate.toIso8601String(),
  'guests': instance.guests,
  'rooms': instance.rooms,
};
