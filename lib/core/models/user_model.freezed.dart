// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;
  List<String> get favoriteDestinations => throw _privateConstructorUsedError;
  int get tripsCompleted => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastLogin => throw _privateConstructorUsedError;
  bool get emailVerified => throw _privateConstructorUsedError;

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    String? country,
    List<String> favoriteDestinations,
    int tripsCompleted,
    DateTime createdAt,
    DateTime? lastLogin,
    bool emailVerified,
  });
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? country = freezed,
    Object? favoriteDestinations = null,
    Object? tripsCompleted = null,
    Object? createdAt = null,
    Object? lastLogin = freezed,
    Object? emailVerified = null,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            photoUrl: freezed == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            phoneNumber: freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            country: freezed == country
                ? _value.country
                : country // ignore: cast_nullable_to_non_nullable
                      as String?,
            favoriteDestinations: null == favoriteDestinations
                ? _value.favoriteDestinations
                : favoriteDestinations // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            tripsCompleted: null == tripsCompleted
                ? _value.tripsCompleted
                : tripsCompleted // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastLogin: freezed == lastLogin
                ? _value.lastLogin
                : lastLogin // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            emailVerified: null == emailVerified
                ? _value.emailVerified
                : emailVerified // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    String? country,
    List<String> favoriteDestinations,
    int tripsCompleted,
    DateTime createdAt,
    DateTime? lastLogin,
    bool emailVerified,
  });
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? photoUrl = freezed,
    Object? phoneNumber = freezed,
    Object? bio = freezed,
    Object? country = freezed,
    Object? favoriteDestinations = null,
    Object? tripsCompleted = null,
    Object? createdAt = null,
    Object? lastLogin = freezed,
    Object? emailVerified = null,
  }) {
    return _then(
      _$UserProfileImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        photoUrl: freezed == photoUrl
            ? _value.photoUrl
            : photoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        phoneNumber: freezed == phoneNumber
            ? _value.phoneNumber
            : phoneNumber // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        country: freezed == country
            ? _value.country
            : country // ignore: cast_nullable_to_non_nullable
                  as String?,
        favoriteDestinations: null == favoriteDestinations
            ? _value._favoriteDestinations
            : favoriteDestinations // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        tripsCompleted: null == tripsCompleted
            ? _value.tripsCompleted
            : tripsCompleted // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastLogin: freezed == lastLogin
            ? _value.lastLogin
            : lastLogin // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        emailVerified: null == emailVerified
            ? _value.emailVerified
            : emailVerified // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.phoneNumber,
    required this.bio,
    required this.country,
    required final List<String> favoriteDestinations,
    required this.tripsCompleted,
    required this.createdAt,
    required this.lastLogin,
    required this.emailVerified,
  }) : _favoriteDestinations = favoriteDestinations;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? photoUrl;
  @override
  final String? phoneNumber;
  @override
  final String? bio;
  @override
  final String? country;
  final List<String> _favoriteDestinations;
  @override
  List<String> get favoriteDestinations {
    if (_favoriteDestinations is EqualUnmodifiableListView)
      return _favoriteDestinations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteDestinations);
  }

  @override
  final int tripsCompleted;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastLogin;
  @override
  final bool emailVerified;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, bio: $bio, country: $country, favoriteDestinations: $favoriteDestinations, tripsCompleted: $tripsCompleted, createdAt: $createdAt, lastLogin: $lastLogin, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.country, country) || other.country == country) &&
            const DeepCollectionEquality().equals(
              other._favoriteDestinations,
              _favoriteDestinations,
            ) &&
            (identical(other.tripsCompleted, tripsCompleted) ||
                other.tripsCompleted == tripsCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLogin, lastLogin) ||
                other.lastLogin == lastLogin) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    bio,
    country,
    const DeepCollectionEquality().hash(_favoriteDestinations),
    tripsCompleted,
    createdAt,
    lastLogin,
    emailVerified,
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(this);
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final String uid,
    required final String email,
    required final String? displayName,
    required final String? photoUrl,
    required final String? phoneNumber,
    required final String? bio,
    required final String? country,
    required final List<String> favoriteDestinations,
    required final int tripsCompleted,
    required final DateTime createdAt,
    required final DateTime? lastLogin,
    required final bool emailVerified,
  }) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get photoUrl;
  @override
  String? get phoneNumber;
  @override
  String? get bio;
  @override
  String? get country;
  @override
  List<String> get favoriteDestinations;
  @override
  int get tripsCompleted;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastLogin;
  @override
  bool get emailVerified;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
