// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_params_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FlightSearchParams _$FlightSearchParamsFromJson(Map<String, dynamic> json) {
  return _FlightSearchParams.fromJson(json);
}

/// @nodoc
mixin _$FlightSearchParams {
  String get departure => throw _privateConstructorUsedError;
  String get arrival => throw _privateConstructorUsedError;
  DateTime get departureDate => throw _privateConstructorUsedError;
  DateTime? get returnDate => throw _privateConstructorUsedError;
  int get passengers => throw _privateConstructorUsedError;
  String get tripType => throw _privateConstructorUsedError;

  /// Serializes this FlightSearchParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FlightSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FlightSearchParamsCopyWith<FlightSearchParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FlightSearchParamsCopyWith<$Res> {
  factory $FlightSearchParamsCopyWith(
    FlightSearchParams value,
    $Res Function(FlightSearchParams) then,
  ) = _$FlightSearchParamsCopyWithImpl<$Res, FlightSearchParams>;
  @useResult
  $Res call({
    String departure,
    String arrival,
    DateTime departureDate,
    DateTime? returnDate,
    int passengers,
    String tripType,
  });
}

/// @nodoc
class _$FlightSearchParamsCopyWithImpl<$Res, $Val extends FlightSearchParams>
    implements $FlightSearchParamsCopyWith<$Res> {
  _$FlightSearchParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FlightSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = null,
    Object? arrival = null,
    Object? departureDate = null,
    Object? returnDate = freezed,
    Object? passengers = null,
    Object? tripType = null,
  }) {
    return _then(
      _value.copyWith(
            departure: null == departure
                ? _value.departure
                : departure // ignore: cast_nullable_to_non_nullable
                      as String,
            arrival: null == arrival
                ? _value.arrival
                : arrival // ignore: cast_nullable_to_non_nullable
                      as String,
            departureDate: null == departureDate
                ? _value.departureDate
                : departureDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            returnDate: freezed == returnDate
                ? _value.returnDate
                : returnDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            passengers: null == passengers
                ? _value.passengers
                : passengers // ignore: cast_nullable_to_non_nullable
                      as int,
            tripType: null == tripType
                ? _value.tripType
                : tripType // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FlightSearchParamsImplCopyWith<$Res>
    implements $FlightSearchParamsCopyWith<$Res> {
  factory _$$FlightSearchParamsImplCopyWith(
    _$FlightSearchParamsImpl value,
    $Res Function(_$FlightSearchParamsImpl) then,
  ) = __$$FlightSearchParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String departure,
    String arrival,
    DateTime departureDate,
    DateTime? returnDate,
    int passengers,
    String tripType,
  });
}

/// @nodoc
class __$$FlightSearchParamsImplCopyWithImpl<$Res>
    extends _$FlightSearchParamsCopyWithImpl<$Res, _$FlightSearchParamsImpl>
    implements _$$FlightSearchParamsImplCopyWith<$Res> {
  __$$FlightSearchParamsImplCopyWithImpl(
    _$FlightSearchParamsImpl _value,
    $Res Function(_$FlightSearchParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FlightSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? departure = null,
    Object? arrival = null,
    Object? departureDate = null,
    Object? returnDate = freezed,
    Object? passengers = null,
    Object? tripType = null,
  }) {
    return _then(
      _$FlightSearchParamsImpl(
        departure: null == departure
            ? _value.departure
            : departure // ignore: cast_nullable_to_non_nullable
                  as String,
        arrival: null == arrival
            ? _value.arrival
            : arrival // ignore: cast_nullable_to_non_nullable
                  as String,
        departureDate: null == departureDate
            ? _value.departureDate
            : departureDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        returnDate: freezed == returnDate
            ? _value.returnDate
            : returnDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        passengers: null == passengers
            ? _value.passengers
            : passengers // ignore: cast_nullable_to_non_nullable
                  as int,
        tripType: null == tripType
            ? _value.tripType
            : tripType // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FlightSearchParamsImpl implements _FlightSearchParams {
  const _$FlightSearchParamsImpl({
    required this.departure,
    required this.arrival,
    required this.departureDate,
    this.returnDate,
    required this.passengers,
    required this.tripType,
  });

  factory _$FlightSearchParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FlightSearchParamsImplFromJson(json);

  @override
  final String departure;
  @override
  final String arrival;
  @override
  final DateTime departureDate;
  @override
  final DateTime? returnDate;
  @override
  final int passengers;
  @override
  final String tripType;

  @override
  String toString() {
    return 'FlightSearchParams(departure: $departure, arrival: $arrival, departureDate: $departureDate, returnDate: $returnDate, passengers: $passengers, tripType: $tripType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FlightSearchParamsImpl &&
            (identical(other.departure, departure) ||
                other.departure == departure) &&
            (identical(other.arrival, arrival) || other.arrival == arrival) &&
            (identical(other.departureDate, departureDate) ||
                other.departureDate == departureDate) &&
            (identical(other.returnDate, returnDate) ||
                other.returnDate == returnDate) &&
            (identical(other.passengers, passengers) ||
                other.passengers == passengers) &&
            (identical(other.tripType, tripType) ||
                other.tripType == tripType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    departure,
    arrival,
    departureDate,
    returnDate,
    passengers,
    tripType,
  );

  /// Create a copy of FlightSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FlightSearchParamsImplCopyWith<_$FlightSearchParamsImpl> get copyWith =>
      __$$FlightSearchParamsImplCopyWithImpl<_$FlightSearchParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FlightSearchParamsImplToJson(this);
  }
}

abstract class _FlightSearchParams implements FlightSearchParams {
  const factory _FlightSearchParams({
    required final String departure,
    required final String arrival,
    required final DateTime departureDate,
    final DateTime? returnDate,
    required final int passengers,
    required final String tripType,
  }) = _$FlightSearchParamsImpl;

  factory _FlightSearchParams.fromJson(Map<String, dynamic> json) =
      _$FlightSearchParamsImpl.fromJson;

  @override
  String get departure;
  @override
  String get arrival;
  @override
  DateTime get departureDate;
  @override
  DateTime? get returnDate;
  @override
  int get passengers;
  @override
  String get tripType;

  /// Create a copy of FlightSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FlightSearchParamsImplCopyWith<_$FlightSearchParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HotelSearchParams _$HotelSearchParamsFromJson(Map<String, dynamic> json) {
  return _HotelSearchParams.fromJson(json);
}

/// @nodoc
mixin _$HotelSearchParams {
  String get city => throw _privateConstructorUsedError;
  DateTime get checkInDate => throw _privateConstructorUsedError;
  DateTime get checkOutDate => throw _privateConstructorUsedError;
  int get guests => throw _privateConstructorUsedError;
  int get rooms => throw _privateConstructorUsedError;

  /// Serializes this HotelSearchParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HotelSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HotelSearchParamsCopyWith<HotelSearchParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HotelSearchParamsCopyWith<$Res> {
  factory $HotelSearchParamsCopyWith(
    HotelSearchParams value,
    $Res Function(HotelSearchParams) then,
  ) = _$HotelSearchParamsCopyWithImpl<$Res, HotelSearchParams>;
  @useResult
  $Res call({
    String city,
    DateTime checkInDate,
    DateTime checkOutDate,
    int guests,
    int rooms,
  });
}

/// @nodoc
class _$HotelSearchParamsCopyWithImpl<$Res, $Val extends HotelSearchParams>
    implements $HotelSearchParamsCopyWith<$Res> {
  _$HotelSearchParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HotelSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = null,
    Object? checkInDate = null,
    Object? checkOutDate = null,
    Object? guests = null,
    Object? rooms = null,
  }) {
    return _then(
      _value.copyWith(
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            checkInDate: null == checkInDate
                ? _value.checkInDate
                : checkInDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            checkOutDate: null == checkOutDate
                ? _value.checkOutDate
                : checkOutDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            guests: null == guests
                ? _value.guests
                : guests // ignore: cast_nullable_to_non_nullable
                      as int,
            rooms: null == rooms
                ? _value.rooms
                : rooms // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HotelSearchParamsImplCopyWith<$Res>
    implements $HotelSearchParamsCopyWith<$Res> {
  factory _$$HotelSearchParamsImplCopyWith(
    _$HotelSearchParamsImpl value,
    $Res Function(_$HotelSearchParamsImpl) then,
  ) = __$$HotelSearchParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String city,
    DateTime checkInDate,
    DateTime checkOutDate,
    int guests,
    int rooms,
  });
}

/// @nodoc
class __$$HotelSearchParamsImplCopyWithImpl<$Res>
    extends _$HotelSearchParamsCopyWithImpl<$Res, _$HotelSearchParamsImpl>
    implements _$$HotelSearchParamsImplCopyWith<$Res> {
  __$$HotelSearchParamsImplCopyWithImpl(
    _$HotelSearchParamsImpl _value,
    $Res Function(_$HotelSearchParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HotelSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? city = null,
    Object? checkInDate = null,
    Object? checkOutDate = null,
    Object? guests = null,
    Object? rooms = null,
  }) {
    return _then(
      _$HotelSearchParamsImpl(
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        checkInDate: null == checkInDate
            ? _value.checkInDate
            : checkInDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        checkOutDate: null == checkOutDate
            ? _value.checkOutDate
            : checkOutDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        guests: null == guests
            ? _value.guests
            : guests // ignore: cast_nullable_to_non_nullable
                  as int,
        rooms: null == rooms
            ? _value.rooms
            : rooms // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HotelSearchParamsImpl implements _HotelSearchParams {
  const _$HotelSearchParamsImpl({
    required this.city,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.rooms,
  });

  factory _$HotelSearchParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$HotelSearchParamsImplFromJson(json);

  @override
  final String city;
  @override
  final DateTime checkInDate;
  @override
  final DateTime checkOutDate;
  @override
  final int guests;
  @override
  final int rooms;

  @override
  String toString() {
    return 'HotelSearchParams(city: $city, checkInDate: $checkInDate, checkOutDate: $checkOutDate, guests: $guests, rooms: $rooms)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HotelSearchParamsImpl &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.checkInDate, checkInDate) ||
                other.checkInDate == checkInDate) &&
            (identical(other.checkOutDate, checkOutDate) ||
                other.checkOutDate == checkOutDate) &&
            (identical(other.guests, guests) || other.guests == guests) &&
            (identical(other.rooms, rooms) || other.rooms == rooms));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, city, checkInDate, checkOutDate, guests, rooms);

  /// Create a copy of HotelSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HotelSearchParamsImplCopyWith<_$HotelSearchParamsImpl> get copyWith =>
      __$$HotelSearchParamsImplCopyWithImpl<_$HotelSearchParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HotelSearchParamsImplToJson(this);
  }
}

abstract class _HotelSearchParams implements HotelSearchParams {
  const factory _HotelSearchParams({
    required final String city,
    required final DateTime checkInDate,
    required final DateTime checkOutDate,
    required final int guests,
    required final int rooms,
  }) = _$HotelSearchParamsImpl;

  factory _HotelSearchParams.fromJson(Map<String, dynamic> json) =
      _$HotelSearchParamsImpl.fromJson;

  @override
  String get city;
  @override
  DateTime get checkInDate;
  @override
  DateTime get checkOutDate;
  @override
  int get guests;
  @override
  int get rooms;

  /// Create a copy of HotelSearchParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HotelSearchParamsImplCopyWith<_$HotelSearchParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
