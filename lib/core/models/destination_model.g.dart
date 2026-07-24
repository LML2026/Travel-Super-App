// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'destination_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DestinationImpl _$$DestinationImplFromJson(Map<String, dynamic> json) =>
    _$DestinationImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      country: json['country'] as String,
      countryCode: json['countryCode'] as String,
      flag: json['flag'] as String,
      description: json['description'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      temperature: (json['temperature'] as num).toDouble(),
      weather: json['weather'] as String,
      attractions: (json['attractions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      bestTimeToVisit: (json['bestTimeToVisit'] as num).toInt(),
    );

Map<String, dynamic> _$$DestinationImplToJson(_$DestinationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'country': instance.country,
      'countryCode': instance.countryCode,
      'flag': instance.flag,
      'description': instance.description,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'imageUrl': instance.imageUrl,
      'temperature': instance.temperature,
      'weather': instance.weather,
      'attractions': instance.attractions,
      'bestTimeToVisit': instance.bestTimeToVisit,
    };
