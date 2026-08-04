// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hotel_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Hotel _$HotelFromJson(Map<String, dynamic> json) {
  return _Hotel.fromJson(json);
}

/// @nodoc
mixin _$Hotel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  double get pricePerNight => throw _privateConstructorUsedError;
  double get rating => throw _privateConstructorUsedError;
  int get reviewCount => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  List<String> get amenities => throw _privateConstructorUsedError;
  List<String> get roomTypes => throw _privateConstructorUsedError;
  int get availableRooms => throw _privateConstructorUsedError;
  String get checkInTime => throw _privateConstructorUsedError;
  String get checkOutTime => throw _privateConstructorUsedError;
  bool get hasWifi => throw _privateConstructorUsedError;
  bool get hasPool => throw _privateConstructorUsedError;
  bool get hasGym => throw _privateConstructorUsedError;

  /// Serializes this Hotel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Hotel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HotelCopyWith<Hotel> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HotelCopyWith<$Res> {
  factory $HotelCopyWith(Hotel value, $Res Function(Hotel) then) =
      _$HotelCopyWithImpl<$Res, Hotel>;
  @useResult
  $Res call({
    String id,
    String name,
    String city,
    String address,
    double pricePerNight,
    double rating,
    int reviewCount,
    String imageUrl,
    List<String> amenities,
    List<String> roomTypes,
    int availableRooms,
    String checkInTime,
    String checkOutTime,
    bool hasWifi,
    bool hasPool,
    bool hasGym,
  });
}

/// @nodoc
class _$HotelCopyWithImpl<$Res, $Val extends Hotel>
    implements $HotelCopyWith<$Res> {
  _$HotelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Hotel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? city = null,
    Object? address = null,
    Object? pricePerNight = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? imageUrl = null,
    Object? amenities = null,
    Object? roomTypes = null,
    Object? availableRooms = null,
    Object? checkInTime = null,
    Object? checkOutTime = null,
    Object? hasWifi = null,
    Object? hasPool = null,
    Object? hasGym = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            city: null == city
                ? _value.city
                : city // ignore: cast_nullable_to_non_nullable
                      as String,
            address: null == address
                ? _value.address
                : address // ignore: cast_nullable_to_non_nullable
                      as String,
            pricePerNight: null == pricePerNight
                ? _value.pricePerNight
                : pricePerNight // ignore: cast_nullable_to_non_nullable
                      as double,
            rating: null == rating
                ? _value.rating
                : rating // ignore: cast_nullable_to_non_nullable
                      as double,
            reviewCount: null == reviewCount
                ? _value.reviewCount
                : reviewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            amenities: null == amenities
                ? _value.amenities
                : amenities // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            roomTypes: null == roomTypes
                ? _value.roomTypes
                : roomTypes // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            availableRooms: null == availableRooms
                ? _value.availableRooms
                : availableRooms // ignore: cast_nullable_to_non_nullable
                      as int,
            checkInTime: null == checkInTime
                ? _value.checkInTime
                : checkInTime // ignore: cast_nullable_to_non_nullable
                      as String,
            checkOutTime: null == checkOutTime
                ? _value.checkOutTime
                : checkOutTime // ignore: cast_nullable_to_non_nullable
                      as String,
            hasWifi: null == hasWifi
                ? _value.hasWifi
                : hasWifi // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasPool: null == hasPool
                ? _value.hasPool
                : hasPool // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasGym: null == hasGym
                ? _value.hasGym
                : hasGym // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HotelImplCopyWith<$Res> implements $HotelCopyWith<$Res> {
  factory _$$HotelImplCopyWith(
    _$HotelImpl value,
    $Res Function(_$HotelImpl) then,
  ) = __$$HotelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String city,
    String address,
    double pricePerNight,
    double rating,
    int reviewCount,
    String imageUrl,
    List<String> amenities,
    List<String> roomTypes,
    int availableRooms,
    String checkInTime,
    String checkOutTime,
    bool hasWifi,
    bool hasPool,
    bool hasGym,
  });
}

/// @nodoc
class __$$HotelImplCopyWithImpl<$Res>
    extends _$HotelCopyWithImpl<$Res, _$HotelImpl>
    implements _$$HotelImplCopyWith<$Res> {
  __$$HotelImplCopyWithImpl(
    _$HotelImpl _value,
    $Res Function(_$HotelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Hotel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? city = null,
    Object? address = null,
    Object? pricePerNight = null,
    Object? rating = null,
    Object? reviewCount = null,
    Object? imageUrl = null,
    Object? amenities = null,
    Object? roomTypes = null,
    Object? availableRooms = null,
    Object? checkInTime = null,
    Object? checkOutTime = null,
    Object? hasWifi = null,
    Object? hasPool = null,
    Object? hasGym = null,
  }) {
    return _then(
      _$HotelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        city: null == city
            ? _value.city
            : city // ignore: cast_nullable_to_non_nullable
                  as String,
        address: null == address
            ? _value.address
            : address // ignore: cast_nullable_to_non_nullable
                  as String,
        pricePerNight: null == pricePerNight
            ? _value.pricePerNight
            : pricePerNight // ignore: cast_nullable_to_non_nullable
                  as double,
        rating: null == rating
            ? _value.rating
            : rating // ignore: cast_nullable_to_non_nullable
                  as double,
        reviewCount: null == reviewCount
            ? _value.reviewCount
            : reviewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        amenities: null == amenities
            ? _value._amenities
            : amenities // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        roomTypes: null == roomTypes
            ? _value._roomTypes
            : roomTypes // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        availableRooms: null == availableRooms
            ? _value.availableRooms
            : availableRooms // ignore: cast_nullable_to_non_nullable
                  as int,
        checkInTime: null == checkInTime
            ? _value.checkInTime
            : checkInTime // ignore: cast_nullable_to_non_nullable
                  as String,
        checkOutTime: null == checkOutTime
            ? _value.checkOutTime
            : checkOutTime // ignore: cast_nullable_to_non_nullable
                  as String,
        hasWifi: null == hasWifi
            ? _value.hasWifi
            : hasWifi // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasPool: null == hasPool
            ? _value.hasPool
            : hasPool // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasGym: null == hasGym
            ? _value.hasGym
            : hasGym // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$HotelImpl implements _Hotel {
  const _$HotelImpl({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.pricePerNight,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required final List<String> amenities,
    required final List<String> roomTypes,
    required this.availableRooms,
    required this.checkInTime,
    required this.checkOutTime,
    required this.hasWifi,
    required this.hasPool,
    required this.hasGym,
  }) : _amenities = amenities,
       _roomTypes = roomTypes;

  factory _$HotelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HotelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String city;
  @override
  final String address;
  @override
  final double pricePerNight;
  @override
  final double rating;
  @override
  final int reviewCount;
  @override
  final String imageUrl;
  final List<String> _amenities;
  @override
  List<String> get amenities {
    if (_amenities is EqualUnmodifiableListView) return _amenities;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_amenities);
  }

  final List<String> _roomTypes;
  @override
  List<String> get roomTypes {
    if (_roomTypes is EqualUnmodifiableListView) return _roomTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_roomTypes);
  }

  @override
  final int availableRooms;
  @override
  final String checkInTime;
  @override
  final String checkOutTime;
  @override
  final bool hasWifi;
  @override
  final bool hasPool;
  @override
  final bool hasGym;

  @override
  String toString() {
    return 'Hotel(id: $id, name: $name, city: $city, address: $address, pricePerNight: $pricePerNight, rating: $rating, reviewCount: $reviewCount, imageUrl: $imageUrl, amenities: $amenities, roomTypes: $roomTypes, availableRooms: $availableRooms, checkInTime: $checkInTime, checkOutTime: $checkOutTime, hasWifi: $hasWifi, hasPool: $hasPool, hasGym: $hasGym)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HotelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.pricePerNight, pricePerNight) ||
                other.pricePerNight == pricePerNight) &&
            (identical(other.rating, rating) || other.rating == rating) &&
            (identical(other.reviewCount, reviewCount) ||
                other.reviewCount == reviewCount) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            const DeepCollectionEquality().equals(
              other._amenities,
              _amenities,
            ) &&
            const DeepCollectionEquality().equals(
              other._roomTypes,
              _roomTypes,
            ) &&
            (identical(other.availableRooms, availableRooms) ||
                other.availableRooms == availableRooms) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime) &&
            (identical(other.checkOutTime, checkOutTime) ||
                other.checkOutTime == checkOutTime) &&
            (identical(other.hasWifi, hasWifi) || other.hasWifi == hasWifi) &&
            (identical(other.hasPool, hasPool) || other.hasPool == hasPool) &&
            (identical(other.hasGym, hasGym) || other.hasGym == hasGym));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    city,
    address,
    pricePerNight,
    rating,
    reviewCount,
    imageUrl,
    const DeepCollectionEquality().hash(_amenities),
    const DeepCollectionEquality().hash(_roomTypes),
    availableRooms,
    checkInTime,
    checkOutTime,
    hasWifi,
    hasPool,
    hasGym,
  );

  /// Create a copy of Hotel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HotelImplCopyWith<_$HotelImpl> get copyWith =>
      __$$HotelImplCopyWithImpl<_$HotelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HotelImplToJson(this);
  }
}

abstract class _Hotel implements Hotel {
  const factory _Hotel({
    required final String id,
    required final String name,
    required final String city,
    required final String address,
    required final double pricePerNight,
    required final double rating,
    required final int reviewCount,
    required final String imageUrl,
    required final List<String> amenities,
    required final List<String> roomTypes,
    required final int availableRooms,
    required final String checkInTime,
    required final String checkOutTime,
    required final bool hasWifi,
    required final bool hasPool,
    required final bool hasGym,
  }) = _$HotelImpl;

  factory _Hotel.fromJson(Map<String, dynamic> json) = _$HotelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get city;
  @override
  String get address;
  @override
  double get pricePerNight;
  @override
  double get rating;
  @override
  int get reviewCount;
  @override
  String get imageUrl;
  @override
  List<String> get amenities;
  @override
  List<String> get roomTypes;
  @override
  int get availableRooms;
  @override
  String get checkInTime;
  @override
  String get checkOutTime;
  @override
  bool get hasWifi;
  @override
  bool get hasPool;
  @override
  bool get hasGym;

  /// Create a copy of Hotel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HotelImplCopyWith<_$HotelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
