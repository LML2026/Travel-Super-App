// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingImpl _$$BookingImplFromJson(Map<String, dynamic> json) =>
    _$BookingImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      userId: json['userId'] as String,
      type: $enumDecode(_$BookingTypeEnumMap, json['type']),
      status: $enumDecode(_$BookingStatusEnumMap, json['status']),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$$BookingImplToJson(_$BookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'userId': instance.userId,
      'type': _$BookingTypeEnumMap[instance.type]!,
      'status': _$BookingStatusEnumMap[instance.status]!,
      'amount': instance.amount,
      'currency': instance.currency,
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

const _$BookingTypeEnumMap = {
  BookingType.flight: 'flight',
  BookingType.hotel: 'hotel',
  BookingType.transport: 'transport',
};

const _$BookingStatusEnumMap = {
  BookingStatus.pending: 'pending',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.completed: 'completed',
  BookingStatus.failed: 'failed',
};
