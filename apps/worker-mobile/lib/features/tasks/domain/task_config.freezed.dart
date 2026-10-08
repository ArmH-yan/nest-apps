// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskConfig {

 double get defaultGeofenceRadiusM; double get maxLocationAccuracyM; int get minCompletionPhotos; int get startWindowMinutesBefore; String get minSupportedAppVersion;
/// Create a copy of TaskConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskConfigCopyWith<TaskConfig> get copyWith => _$TaskConfigCopyWithImpl<TaskConfig>(this as TaskConfig, _$identity);

  /// Serializes this TaskConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TaskConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskConfig&&(identical(other.defaultGeofenceRadiusM, _this.defaultGeofenceRadiusM) || other.defaultGeofenceRadiusM == _this.defaultGeofenceRadiusM)&&(identical(other.maxLocationAccuracyM, _this.maxLocationAccuracyM) || other.maxLocationAccuracyM == _this.maxLocationAccuracyM)&&(identical(other.minCompletionPhotos, _this.minCompletionPhotos) || other.minCompletionPhotos == _this.minCompletionPhotos)&&(identical(other.startWindowMinutesBefore, _this.startWindowMinutesBefore) || other.startWindowMinutesBefore == _this.startWindowMinutesBefore)&&(identical(other.minSupportedAppVersion, _this.minSupportedAppVersion) || other.minSupportedAppVersion == _this.minSupportedAppVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TaskConfig;
  return Object.hash(runtimeType,_this.defaultGeofenceRadiusM,_this.maxLocationAccuracyM,_this.minCompletionPhotos,_this.startWindowMinutesBefore,_this.minSupportedAppVersion);
}

@override
String toString() {
  final _this = this as TaskConfig;
  return 'TaskConfig(defaultGeofenceRadiusM: ${_this.defaultGeofenceRadiusM}, maxLocationAccuracyM: ${_this.maxLocationAccuracyM}, minCompletionPhotos: ${_this.minCompletionPhotos}, startWindowMinutesBefore: ${_this.startWindowMinutesBefore}, minSupportedAppVersion: ${_this.minSupportedAppVersion})';
}


}

/// @nodoc
abstract mixin class $TaskConfigCopyWith<$Res>  {
  factory $TaskConfigCopyWith(TaskConfig value, $Res Function(TaskConfig) _then) = _$TaskConfigCopyWithImpl;
@useResult
$Res call({
 double defaultGeofenceRadiusM, double maxLocationAccuracyM, int minCompletionPhotos, int startWindowMinutesBefore, String minSupportedAppVersion
});




}
/// @nodoc
class _$TaskConfigCopyWithImpl<$Res>
    implements $TaskConfigCopyWith<$Res> {
  _$TaskConfigCopyWithImpl(this._self, this._then);

  final TaskConfig _self;
  final $Res Function(TaskConfig) _then;

/// Create a copy of TaskConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? defaultGeofenceRadiusM = null,Object? maxLocationAccuracyM = null,Object? minCompletionPhotos = null,Object? startWindowMinutesBefore = null,Object? minSupportedAppVersion = null,}) {
  return _then(TaskConfig(
defaultGeofenceRadiusM: null == defaultGeofenceRadiusM ? _self.defaultGeofenceRadiusM : defaultGeofenceRadiusM // ignore: cast_nullable_to_non_nullable
as double,maxLocationAccuracyM: null == maxLocationAccuracyM ? _self.maxLocationAccuracyM : maxLocationAccuracyM // ignore: cast_nullable_to_non_nullable
as double,minCompletionPhotos: null == minCompletionPhotos ? _self.minCompletionPhotos : minCompletionPhotos // ignore: cast_nullable_to_non_nullable
as int,startWindowMinutesBefore: null == startWindowMinutesBefore ? _self.startWindowMinutesBefore : startWindowMinutesBefore // ignore: cast_nullable_to_non_nullable
as int,minSupportedAppVersion: null == minSupportedAppVersion ? _self.minSupportedAppVersion : minSupportedAppVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskConfig].
extension TaskConfigPatterns on TaskConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskConfig value)  $default,){
final _that = this;
switch (_that) {
case _TaskConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskConfig value)?  $default,){
final _that = this;
switch (_that) {
case _TaskConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double defaultGeofenceRadiusM,  double maxLocationAccuracyM,  int minCompletionPhotos,  int startWindowMinutesBefore,  String minSupportedAppVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskConfig() when $default != null:
return $default(_that.defaultGeofenceRadiusM,_that.maxLocationAccuracyM,_that.minCompletionPhotos,_that.startWindowMinutesBefore,_that.minSupportedAppVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double defaultGeofenceRadiusM,  double maxLocationAccuracyM,  int minCompletionPhotos,  int startWindowMinutesBefore,  String minSupportedAppVersion)  $default,) {final _that = this;
switch (_that) {
case _TaskConfig():
return $default(_that.defaultGeofenceRadiusM,_that.maxLocationAccuracyM,_that.minCompletionPhotos,_that.startWindowMinutesBefore,_that.minSupportedAppVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double defaultGeofenceRadiusM,  double maxLocationAccuracyM,  int minCompletionPhotos,  int startWindowMinutesBefore,  String minSupportedAppVersion)?  $default,) {final _that = this;
switch (_that) {
case _TaskConfig() when $default != null:
return $default(_that.defaultGeofenceRadiusM,_that.maxLocationAccuracyM,_that.minCompletionPhotos,_that.startWindowMinutesBefore,_that.minSupportedAppVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskConfig implements TaskConfig {
  const _TaskConfig({this.defaultGeofenceRadiusM = 150, this.maxLocationAccuracyM = 100, this.minCompletionPhotos = 1, this.startWindowMinutesBefore = 120, this.minSupportedAppVersion = '1.0.0'});
  factory _TaskConfig.fromJson(Map<String, dynamic> json) => _$TaskConfigFromJson(json);

@override@JsonKey() final  double defaultGeofenceRadiusM;
@override@JsonKey() final  double maxLocationAccuracyM;
@override@JsonKey() final  int minCompletionPhotos;
@override@JsonKey() final  int startWindowMinutesBefore;
@override@JsonKey() final  String minSupportedAppVersion;

/// Create a copy of TaskConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskConfigCopyWith<_TaskConfig> get copyWith => __$TaskConfigCopyWithImpl<_TaskConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskConfigToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskConfig&&(identical(other.defaultGeofenceRadiusM, defaultGeofenceRadiusM) || other.defaultGeofenceRadiusM == defaultGeofenceRadiusM)&&(identical(other.maxLocationAccuracyM, maxLocationAccuracyM) || other.maxLocationAccuracyM == maxLocationAccuracyM)&&(identical(other.minCompletionPhotos, minCompletionPhotos) || other.minCompletionPhotos == minCompletionPhotos)&&(identical(other.startWindowMinutesBefore, startWindowMinutesBefore) || other.startWindowMinutesBefore == startWindowMinutesBefore)&&(identical(other.minSupportedAppVersion, minSupportedAppVersion) || other.minSupportedAppVersion == minSupportedAppVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,defaultGeofenceRadiusM,maxLocationAccuracyM,minCompletionPhotos,startWindowMinutesBefore,minSupportedAppVersion);
}

@override
String toString() {
    return 'TaskConfig(defaultGeofenceRadiusM: $defaultGeofenceRadiusM, maxLocationAccuracyM: $maxLocationAccuracyM, minCompletionPhotos: $minCompletionPhotos, startWindowMinutesBefore: $startWindowMinutesBefore, minSupportedAppVersion: $minSupportedAppVersion)';
}


}

/// @nodoc
abstract mixin class _$TaskConfigCopyWith<$Res> implements $TaskConfigCopyWith<$Res> {
  factory _$TaskConfigCopyWith(_TaskConfig value, $Res Function(_TaskConfig) _then) = __$TaskConfigCopyWithImpl;
@override @useResult
$Res call({
 double defaultGeofenceRadiusM, double maxLocationAccuracyM, int minCompletionPhotos, int startWindowMinutesBefore, String minSupportedAppVersion
});




}
/// @nodoc
class __$TaskConfigCopyWithImpl<$Res>
    implements _$TaskConfigCopyWith<$Res> {
  __$TaskConfigCopyWithImpl(this._self, this._then);

  final _TaskConfig _self;
  final $Res Function(_TaskConfig) _then;

/// Create a copy of TaskConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? defaultGeofenceRadiusM = null,Object? maxLocationAccuracyM = null,Object? minCompletionPhotos = null,Object? startWindowMinutesBefore = null,Object? minSupportedAppVersion = null,}) {
  return _then(_TaskConfig(
defaultGeofenceRadiusM: null == defaultGeofenceRadiusM ? _self.defaultGeofenceRadiusM : defaultGeofenceRadiusM // ignore: cast_nullable_to_non_nullable
as double,maxLocationAccuracyM: null == maxLocationAccuracyM ? _self.maxLocationAccuracyM : maxLocationAccuracyM // ignore: cast_nullable_to_non_nullable
as double,minCompletionPhotos: null == minCompletionPhotos ? _self.minCompletionPhotos : minCompletionPhotos // ignore: cast_nullable_to_non_nullable
as int,startWindowMinutesBefore: null == startWindowMinutesBefore ? _self.startWindowMinutesBefore : startWindowMinutesBefore // ignore: cast_nullable_to_non_nullable
as int,minSupportedAppVersion: null == minSupportedAppVersion ? _self.minSupportedAppVersion : minSupportedAppVersion // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
