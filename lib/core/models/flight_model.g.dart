// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FlightImpl _$$FlightImplFromJson(Map<String, dynamic> json) => _$FlightImpl(
  id: json['id'] as String,
  airline: json['airline'] as String,
  flightNumber: json['flightNumber'] as String,
  departure: json['departure'] as String,
  arrival: json['arrival'] as String,
  departureTime: DateTime.parse(json['departureTime'] as String),
  arrivalTime: DateTime.parse(json['arrivalTime'] as String),
  duration: (json['duration'] as num).toInt(),
  price: (json['price'] as num).toDouble(),
  stops: (json['stops'] as num).toInt(),
  seats: (json['seats'] as num).toInt(),
  aircraft: json['aircraft'] as String,
  rating: (json['rating'] as num).toDouble(),
);

Map<String, dynamic> _$$FlightImplToJson(_$FlightImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'airline': instance.airline,
      'flightNumber': instance.flightNumber,
      'departure': instance.departure,
      'arrival': instance.arrival,
      'departureTime': instance.departureTime.toIso8601String(),
      'arrivalTime': instance.arrivalTime.toIso8601String(),
      'duration': instance.duration,
      'price': instance.price,
      'stops': instance.stops,
      'seats': instance.seats,
      'aircraft': instance.aircraft,
      'rating': instance.rating,
    };
