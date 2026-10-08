// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'worker.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Worker {

 String get id; String get fullName; String get employeeCode; String get phone; String get companyName; String get locale; bool get mustChangePassword;
/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkerCopyWith<Worker> get copyWith => _$WorkerCopyWithImpl<Worker>(this as Worker, _$identity);

  /// Serializes this Worker to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Worker;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Worker&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.employeeCode, _this.employeeCode) || other.employeeCode == _this.employeeCode)&&(identical(other.phone, _this.phone) || other.phone == _this.phone)&&(identical(other.companyName, _this.companyName) || other.companyName == _this.companyName)&&(identical(other.locale, _this.locale) || other.locale == _this.locale)&&(identical(other.mustChangePassword, _this.mustChangePassword) || other.mustChangePassword == _this.mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Worker;
  return Object.hash(runtimeType,_this.id,_this.fullName,_this.employeeCode,_this.phone,_this.companyName,_this.locale,_this.mustChangePassword);
}

@override
String toString() {
  final _this = this as Worker;
  return 'Worker(id: ${_this.id}, fullName: ${_this.fullName}, employeeCode: ${_this.employeeCode}, phone: ${_this.phone}, companyName: ${_this.companyName}, locale: ${_this.locale}, mustChangePassword: ${_this.mustChangePassword})';
}


}

/// @nodoc
abstract mixin class $WorkerCopyWith<$Res>  {
  factory $WorkerCopyWith(Worker value, $Res Function(Worker) _then) = _$WorkerCopyWithImpl;
@useResult
$Res call({
 String id, String fullName, String employeeCode, String phone, String companyName, String locale, bool mustChangePassword
});




}
/// @nodoc
class _$WorkerCopyWithImpl<$Res>
    implements $WorkerCopyWith<$Res> {
  _$WorkerCopyWithImpl(this._self, this._then);

  final Worker _self;
  final $Res Function(Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullName = null,Object? employeeCode = null,Object? phone = null,Object? companyName = null,Object? locale = null,Object? mustChangePassword = null,}) {
  return _then(Worker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,employeeCode: null == employeeCode ? _self.employeeCode : employeeCode // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Worker].
extension WorkerPatterns on Worker {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Worker value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Worker value)  $default,){
final _that = this;
switch (_that) {
case _Worker():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Worker value)?  $default,){
final _that = this;
switch (_that) {
case _Worker() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullName,  String employeeCode,  String phone,  String companyName,  String locale,  bool mustChangePassword)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.fullName,_that.employeeCode,_that.phone,_that.companyName,_that.locale,_that.mustChangePassword);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullName,  String employeeCode,  String phone,  String companyName,  String locale,  bool mustChangePassword)  $default,) {final _that = this;
switch (_that) {
case _Worker():
return $default(_that.id,_that.fullName,_that.employeeCode,_that.phone,_that.companyName,_that.locale,_that.mustChangePassword);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullName,  String employeeCode,  String phone,  String companyName,  String locale,  bool mustChangePassword)?  $default,) {final _that = this;
switch (_that) {
case _Worker() when $default != null:
return $default(_that.id,_that.fullName,_that.employeeCode,_that.phone,_that.companyName,_that.locale,_that.mustChangePassword);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Worker implements Worker {
  const _Worker({required this.id, required this.fullName, required this.employeeCode, required this.phone, this.companyName = 'NEST', this.locale = 'hy', this.mustChangePassword = false});
  factory _Worker.fromJson(Map<String, dynamic> json) => _$WorkerFromJson(json);

@override final  String id;
@override final  String fullName;
@override final  String employeeCode;
@override final  String phone;
@override@JsonKey() final  String companyName;
@override@JsonKey() final  String locale;
@override@JsonKey() final  bool mustChangePassword;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkerCopyWith<_Worker> get copyWith => __$WorkerCopyWithImpl<_Worker>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Worker&&(identical(other.id, id) || other.id == id)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.employeeCode, employeeCode) || other.employeeCode == employeeCode)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.companyName, companyName) || other.companyName == companyName)&&(identical(other.locale, locale) || other.locale == locale)&&(identical(other.mustChangePassword, mustChangePassword) || other.mustChangePassword == mustChangePassword));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,fullName,employeeCode,phone,companyName,locale,mustChangePassword);
}

@override
String toString() {
    return 'Worker(id: $id, fullName: $fullName, employeeCode: $employeeCode, phone: $phone, companyName: $companyName, locale: $locale, mustChangePassword: $mustChangePassword)';
}


}

/// @nodoc
abstract mixin class _$WorkerCopyWith<$Res> implements $WorkerCopyWith<$Res> {
  factory _$WorkerCopyWith(_Worker value, $Res Function(_Worker) _then) = __$WorkerCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullName, String employeeCode, String phone, String companyName, String locale, bool mustChangePassword
});




}
/// @nodoc
class __$WorkerCopyWithImpl<$Res>
    implements _$WorkerCopyWith<$Res> {
  __$WorkerCopyWithImpl(this._self, this._then);

  final _Worker _self;
  final $Res Function(_Worker) _then;

/// Create a copy of Worker
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullName = null,Object? employeeCode = null,Object? phone = null,Object? companyName = null,Object? locale = null,Object? mustChangePassword = null,}) {
  return _then(_Worker(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,employeeCode: null == employeeCode ? _self.employeeCode : employeeCode // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,companyName: null == companyName ? _self.companyName : companyName // ignore: cast_nullable_to_non_nullable
as String,locale: null == locale ? _self.locale : locale // ignore: cast_nullable_to_non_nullable
as String,mustChangePassword: null == mustChangePassword ? _self.mustChangePassword : mustChangePassword // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
