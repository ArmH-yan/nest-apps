// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiErrorEnvelope {

 ApiErrorBody get error;
/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorEnvelopeCopyWith<ApiErrorEnvelope> get copyWith => _$ApiErrorEnvelopeCopyWithImpl<ApiErrorEnvelope>(this as ApiErrorEnvelope, _$identity);

  /// Serializes this ApiErrorEnvelope to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApiErrorEnvelope;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiErrorEnvelope&&(identical(other.error, _this.error) || other.error == _this.error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiErrorEnvelope;
  return Object.hash(runtimeType,_this.error);
}

@override
String toString() {
  final _this = this as ApiErrorEnvelope;
  return 'ApiErrorEnvelope(error: ${_this.error})';
}


}

/// @nodoc
abstract mixin class $ApiErrorEnvelopeCopyWith<$Res>  {
  factory $ApiErrorEnvelopeCopyWith(ApiErrorEnvelope value, $Res Function(ApiErrorEnvelope) _then) = _$ApiErrorEnvelopeCopyWithImpl;
@useResult
$Res call({
 ApiErrorBody error
});


$ApiErrorBodyCopyWith<$Res> get error;

}
/// @nodoc
class _$ApiErrorEnvelopeCopyWithImpl<$Res>
    implements $ApiErrorEnvelopeCopyWith<$Res> {
  _$ApiErrorEnvelopeCopyWithImpl(this._self, this._then);

  final ApiErrorEnvelope _self;
  final $Res Function(ApiErrorEnvelope) _then;

/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? error = null,}) {
  return _then(ApiErrorEnvelope(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiErrorBody,
  ));
}
/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorBodyCopyWith<$Res> get error {
  
  return $ApiErrorBodyCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [ApiErrorEnvelope].
extension ApiErrorEnvelopePatterns on ApiErrorEnvelope {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiErrorEnvelope value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiErrorEnvelope value)  $default,){
final _that = this;
switch (_that) {
case _ApiErrorEnvelope():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiErrorEnvelope value)?  $default,){
final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ApiErrorBody error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
return $default(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ApiErrorBody error)  $default,) {final _that = this;
switch (_that) {
case _ApiErrorEnvelope():
return $default(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ApiErrorBody error)?  $default,) {final _that = this;
switch (_that) {
case _ApiErrorEnvelope() when $default != null:
return $default(_that.error);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiErrorEnvelope implements ApiErrorEnvelope {
  const _ApiErrorEnvelope({required this.error});
  factory _ApiErrorEnvelope.fromJson(Map<String, dynamic> json) => _$ApiErrorEnvelopeFromJson(json);

@override final  ApiErrorBody error;

/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorEnvelopeCopyWith<_ApiErrorEnvelope> get copyWith => __$ApiErrorEnvelopeCopyWithImpl<_ApiErrorEnvelope>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiErrorEnvelopeToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiErrorEnvelope&&(identical(other.error, error) || other.error == error));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,error);
}

@override
String toString() {
    return 'ApiErrorEnvelope(error: $error)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorEnvelopeCopyWith<$Res> implements $ApiErrorEnvelopeCopyWith<$Res> {
  factory _$ApiErrorEnvelopeCopyWith(_ApiErrorEnvelope value, $Res Function(_ApiErrorEnvelope) _then) = __$ApiErrorEnvelopeCopyWithImpl;
@override @useResult
$Res call({
 ApiErrorBody error
});


@override $ApiErrorBodyCopyWith<$Res> get error;

}
/// @nodoc
class __$ApiErrorEnvelopeCopyWithImpl<$Res>
    implements _$ApiErrorEnvelopeCopyWith<$Res> {
  __$ApiErrorEnvelopeCopyWithImpl(this._self, this._then);

  final _ApiErrorEnvelope _self;
  final $Res Function(_ApiErrorEnvelope) _then;

/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(_ApiErrorEnvelope(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as ApiErrorBody,
  ));
}

/// Create a copy of ApiErrorEnvelope
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ApiErrorBodyCopyWith<$Res> get error {
  
  return $ApiErrorBodyCopyWith<$Res>(_self.error, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// @nodoc
mixin _$ApiErrorBody {

 String get code; String get message; Map<String, dynamic> get details;
/// Create a copy of ApiErrorBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorBodyCopyWith<ApiErrorBody> get copyWith => _$ApiErrorBodyCopyWithImpl<ApiErrorBody>(this as ApiErrorBody, _$identity);

  /// Serializes this ApiErrorBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ApiErrorBody;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiErrorBody&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.message, _this.message) || other.message == _this.message)&&const DeepCollectionEquality().equals(other.details, _this.details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ApiErrorBody;
  return Object.hash(runtimeType,_this.code,_this.message,const DeepCollectionEquality().hash(_this.details));
}

@override
String toString() {
  final _this = this as ApiErrorBody;
  return 'ApiErrorBody(code: ${_this.code}, message: ${_this.message}, details: ${_this.details})';
}


}

/// @nodoc
abstract mixin class $ApiErrorBodyCopyWith<$Res>  {
  factory $ApiErrorBodyCopyWith(ApiErrorBody value, $Res Function(ApiErrorBody) _then) = _$ApiErrorBodyCopyWithImpl;
@useResult
$Res call({
 String code, String message, Map<String, dynamic> details
});




}
/// @nodoc
class _$ApiErrorBodyCopyWithImpl<$Res>
    implements $ApiErrorBodyCopyWith<$Res> {
  _$ApiErrorBodyCopyWithImpl(this._self, this._then);

  final ApiErrorBody _self;
  final $Res Function(ApiErrorBody) _then;

/// Create a copy of ApiErrorBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? details = null,}) {
  return _then(ApiErrorBody(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiErrorBody].
extension ApiErrorBodyPatterns on ApiErrorBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiErrorBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiErrorBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiErrorBody value)  $default,){
final _that = this;
switch (_that) {
case _ApiErrorBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiErrorBody value)?  $default,){
final _that = this;
switch (_that) {
case _ApiErrorBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String message,  Map<String, dynamic> details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiErrorBody() when $default != null:
return $default(_that.code,_that.message,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String message,  Map<String, dynamic> details)  $default,) {final _that = this;
switch (_that) {
case _ApiErrorBody():
return $default(_that.code,_that.message,_that.details);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String message,  Map<String, dynamic> details)?  $default,) {final _that = this;
switch (_that) {
case _ApiErrorBody() when $default != null:
return $default(_that.code,_that.message,_that.details);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiErrorBody implements ApiErrorBody {
  const _ApiErrorBody({required this.code, required this.message,  Map<String, dynamic> details = const <String, dynamic>{}}): _details = details;
  factory _ApiErrorBody.fromJson(Map<String, dynamic> json) => _$ApiErrorBodyFromJson(json);

@override final  String code;
@override final  String message;
 final  Map<String, dynamic> _details;
@override@JsonKey() Map<String, dynamic> get details {
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_details);
}


/// Create a copy of ApiErrorBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorBodyCopyWith<_ApiErrorBody> get copyWith => __$ApiErrorBodyCopyWithImpl<_ApiErrorBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiErrorBodyToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiErrorBody&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.details, _details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(_details));
}

@override
String toString() {
    return 'ApiErrorBody(code: $code, message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorBodyCopyWith<$Res> implements $ApiErrorBodyCopyWith<$Res> {
  factory _$ApiErrorBodyCopyWith(_ApiErrorBody value, $Res Function(_ApiErrorBody) _then) = __$ApiErrorBodyCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, Map<String, dynamic> details
});




}
/// @nodoc
class __$ApiErrorBodyCopyWithImpl<$Res>
    implements _$ApiErrorBodyCopyWith<$Res> {
  __$ApiErrorBodyCopyWithImpl(this._self, this._then);

  final _ApiErrorBody _self;
  final $Res Function(_ApiErrorBody) _then;

/// Create a copy of ApiErrorBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? details = null,}) {
  return _then(_ApiErrorBody(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
