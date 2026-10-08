// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_check.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LocationCheck {

 String get id; String get taskId; LocationCheckPurpose get purpose; double get latitude; double get longitude; double get accuracyM; bool get isMocked; DateTime get capturedAt; double get distanceM; double get radiusM; bool get verified;
/// Create a copy of LocationCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationCheckCopyWith<LocationCheck> get copyWith => _$LocationCheckCopyWithImpl<LocationCheck>(this as LocationCheck, _$identity);

  /// Serializes this LocationCheck to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LocationCheck;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationCheck&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.purpose, _this.purpose) || other.purpose == _this.purpose)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.accuracyM, _this.accuracyM) || other.accuracyM == _this.accuracyM)&&(identical(other.isMocked, _this.isMocked) || other.isMocked == _this.isMocked)&&(identical(other.capturedAt, _this.capturedAt) || other.capturedAt == _this.capturedAt)&&(identical(other.distanceM, _this.distanceM) || other.distanceM == _this.distanceM)&&(identical(other.radiusM, _this.radiusM) || other.radiusM == _this.radiusM)&&(identical(other.verified, _this.verified) || other.verified == _this.verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LocationCheck;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.purpose,_this.latitude,_this.longitude,_this.accuracyM,_this.isMocked,_this.capturedAt,_this.distanceM,_this.radiusM,_this.verified);
}

@override
String toString() {
  final _this = this as LocationCheck;
  return 'LocationCheck(id: ${_this.id}, taskId: ${_this.taskId}, purpose: ${_this.purpose}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, accuracyM: ${_this.accuracyM}, isMocked: ${_this.isMocked}, capturedAt: ${_this.capturedAt}, distanceM: ${_this.distanceM}, radiusM: ${_this.radiusM}, verified: ${_this.verified})';
}


}

/// @nodoc
abstract mixin class $LocationCheckCopyWith<$Res>  {
  factory $LocationCheckCopyWith(LocationCheck value, $Res Function(LocationCheck) _then) = _$LocationCheckCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, LocationCheckPurpose purpose, double latitude, double longitude, double accuracyM, bool isMocked, DateTime capturedAt, double distanceM, double radiusM, bool verified
});




}
/// @nodoc
class _$LocationCheckCopyWithImpl<$Res>
    implements $LocationCheckCopyWith<$Res> {
  _$LocationCheckCopyWithImpl(this._self, this._then);

  final LocationCheck _self;
  final $Res Function(LocationCheck) _then;

/// Create a copy of LocationCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? purpose = null,Object? latitude = null,Object? longitude = null,Object? accuracyM = null,Object? isMocked = null,Object? capturedAt = null,Object? distanceM = null,Object? radiusM = null,Object? verified = null,}) {
  return _then(LocationCheck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as LocationCheckPurpose,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracyM: null == accuracyM ? _self.accuracyM : accuracyM // ignore: cast_nullable_to_non_nullable
as double,isMocked: null == isMocked ? _self.isMocked : isMocked // ignore: cast_nullable_to_non_nullable
as bool,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as double,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [LocationCheck].
extension LocationCheckPatterns on LocationCheck {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocationCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocationCheck() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocationCheck value)  $default,){
final _that = this;
switch (_that) {
case _LocationCheck():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocationCheck value)?  $default,){
final _that = this;
switch (_that) {
case _LocationCheck() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  LocationCheckPurpose purpose,  double latitude,  double longitude,  double accuracyM,  bool isMocked,  DateTime capturedAt,  double distanceM,  double radiusM,  bool verified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocationCheck() when $default != null:
return $default(_that.id,_that.taskId,_that.purpose,_that.latitude,_that.longitude,_that.accuracyM,_that.isMocked,_that.capturedAt,_that.distanceM,_that.radiusM,_that.verified);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  LocationCheckPurpose purpose,  double latitude,  double longitude,  double accuracyM,  bool isMocked,  DateTime capturedAt,  double distanceM,  double radiusM,  bool verified)  $default,) {final _that = this;
switch (_that) {
case _LocationCheck():
return $default(_that.id,_that.taskId,_that.purpose,_that.latitude,_that.longitude,_that.accuracyM,_that.isMocked,_that.capturedAt,_that.distanceM,_that.radiusM,_that.verified);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  LocationCheckPurpose purpose,  double latitude,  double longitude,  double accuracyM,  bool isMocked,  DateTime capturedAt,  double distanceM,  double radiusM,  bool verified)?  $default,) {final _that = this;
switch (_that) {
case _LocationCheck() when $default != null:
return $default(_that.id,_that.taskId,_that.purpose,_that.latitude,_that.longitude,_that.accuracyM,_that.isMocked,_that.capturedAt,_that.distanceM,_that.radiusM,_that.verified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocationCheck implements LocationCheck {
  const _LocationCheck({required this.id, required this.taskId, required this.purpose, required this.latitude, required this.longitude, required this.accuracyM, required this.isMocked, required this.capturedAt, required this.distanceM, required this.radiusM, required this.verified});
  factory _LocationCheck.fromJson(Map<String, dynamic> json) => _$LocationCheckFromJson(json);

@override final  String id;
@override final  String taskId;
@override final  LocationCheckPurpose purpose;
@override final  double latitude;
@override final  double longitude;
@override final  double accuracyM;
@override final  bool isMocked;
@override final  DateTime capturedAt;
@override final  double distanceM;
@override final  double radiusM;
@override final  bool verified;

/// Create a copy of LocationCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocationCheckCopyWith<_LocationCheck> get copyWith => __$LocationCheckCopyWithImpl<_LocationCheck>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocationCheckToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocationCheck&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracyM, accuracyM) || other.accuracyM == accuracyM)&&(identical(other.isMocked, isMocked) || other.isMocked == isMocked)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.radiusM, radiusM) || other.radiusM == radiusM)&&(identical(other.verified, verified) || other.verified == verified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,purpose,latitude,longitude,accuracyM,isMocked,capturedAt,distanceM,radiusM,verified);
}

@override
String toString() {
    return 'LocationCheck(id: $id, taskId: $taskId, purpose: $purpose, latitude: $latitude, longitude: $longitude, accuracyM: $accuracyM, isMocked: $isMocked, capturedAt: $capturedAt, distanceM: $distanceM, radiusM: $radiusM, verified: $verified)';
}


}

/// @nodoc
abstract mixin class _$LocationCheckCopyWith<$Res> implements $LocationCheckCopyWith<$Res> {
  factory _$LocationCheckCopyWith(_LocationCheck value, $Res Function(_LocationCheck) _then) = __$LocationCheckCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, LocationCheckPurpose purpose, double latitude, double longitude, double accuracyM, bool isMocked, DateTime capturedAt, double distanceM, double radiusM, bool verified
});




}
/// @nodoc
class __$LocationCheckCopyWithImpl<$Res>
    implements _$LocationCheckCopyWith<$Res> {
  __$LocationCheckCopyWithImpl(this._self, this._then);

  final _LocationCheck _self;
  final $Res Function(_LocationCheck) _then;

/// Create a copy of LocationCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? purpose = null,Object? latitude = null,Object? longitude = null,Object? accuracyM = null,Object? isMocked = null,Object? capturedAt = null,Object? distanceM = null,Object? radiusM = null,Object? verified = null,}) {
  return _then(_LocationCheck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,purpose: null == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as LocationCheckPurpose,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracyM: null == accuracyM ? _self.accuracyM : accuracyM // ignore: cast_nullable_to_non_nullable
as double,isMocked: null == isMocked ? _self.isMocked : isMocked // ignore: cast_nullable_to_non_nullable
as bool,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distanceM: null == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as double,radiusM: null == radiusM ? _self.radiusM : radiusM // ignore: cast_nullable_to_non_nullable
as double,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
