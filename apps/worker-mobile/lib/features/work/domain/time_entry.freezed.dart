// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'time_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TimeEntry {

 String get id; String get taskId; TimeEntryKind get kind; DateTime get startedAt; DateTime? get endedAt; String? get startLocationCheckId;
/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimeEntryCopyWith<TimeEntry> get copyWith => _$TimeEntryCopyWithImpl<TimeEntry>(this as TimeEntry, _$identity);

  /// Serializes this TimeEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TimeEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimeEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.startedAt, _this.startedAt) || other.startedAt == _this.startedAt)&&(identical(other.endedAt, _this.endedAt) || other.endedAt == _this.endedAt)&&(identical(other.startLocationCheckId, _this.startLocationCheckId) || other.startLocationCheckId == _this.startLocationCheckId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TimeEntry;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.kind,_this.startedAt,_this.endedAt,_this.startLocationCheckId);
}

@override
String toString() {
  final _this = this as TimeEntry;
  return 'TimeEntry(id: ${_this.id}, taskId: ${_this.taskId}, kind: ${_this.kind}, startedAt: ${_this.startedAt}, endedAt: ${_this.endedAt}, startLocationCheckId: ${_this.startLocationCheckId})';
}


}

/// @nodoc
abstract mixin class $TimeEntryCopyWith<$Res>  {
  factory $TimeEntryCopyWith(TimeEntry value, $Res Function(TimeEntry) _then) = _$TimeEntryCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, TimeEntryKind kind, DateTime startedAt, DateTime? endedAt, String? startLocationCheckId
});




}
/// @nodoc
class _$TimeEntryCopyWithImpl<$Res>
    implements $TimeEntryCopyWith<$Res> {
  _$TimeEntryCopyWithImpl(this._self, this._then);

  final TimeEntry _self;
  final $Res Function(TimeEntry) _then;

/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? kind = null,Object? startedAt = null,Object? endedAt = freezed,Object? startLocationCheckId = freezed,}) {
  return _then(TimeEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TimeEntryKind,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startLocationCheckId: freezed == startLocationCheckId ? _self.startLocationCheckId : startLocationCheckId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TimeEntry].
extension TimeEntryPatterns on TimeEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TimeEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TimeEntry value)  $default,){
final _that = this;
switch (_that) {
case _TimeEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TimeEntry value)?  $default,){
final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  TimeEntryKind kind,  DateTime startedAt,  DateTime? endedAt,  String? startLocationCheckId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
return $default(_that.id,_that.taskId,_that.kind,_that.startedAt,_that.endedAt,_that.startLocationCheckId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  TimeEntryKind kind,  DateTime startedAt,  DateTime? endedAt,  String? startLocationCheckId)  $default,) {final _that = this;
switch (_that) {
case _TimeEntry():
return $default(_that.id,_that.taskId,_that.kind,_that.startedAt,_that.endedAt,_that.startLocationCheckId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  TimeEntryKind kind,  DateTime startedAt,  DateTime? endedAt,  String? startLocationCheckId)?  $default,) {final _that = this;
switch (_that) {
case _TimeEntry() when $default != null:
return $default(_that.id,_that.taskId,_that.kind,_that.startedAt,_that.endedAt,_that.startLocationCheckId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TimeEntry extends TimeEntry {
  const _TimeEntry({required this.id, required this.taskId, required this.kind, required this.startedAt, this.endedAt, this.startLocationCheckId}): super._();
  factory _TimeEntry.fromJson(Map<String, dynamic> json) => _$TimeEntryFromJson(json);

@override final  String id;
@override final  String taskId;
@override final  TimeEntryKind kind;
@override final  DateTime startedAt;
@override final  DateTime? endedAt;
@override final  String? startLocationCheckId;

/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TimeEntryCopyWith<_TimeEntry> get copyWith => __$TimeEntryCopyWithImpl<_TimeEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TimeEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TimeEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.endedAt, endedAt) || other.endedAt == endedAt)&&(identical(other.startLocationCheckId, startLocationCheckId) || other.startLocationCheckId == startLocationCheckId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,kind,startedAt,endedAt,startLocationCheckId);
}

@override
String toString() {
    return 'TimeEntry(id: $id, taskId: $taskId, kind: $kind, startedAt: $startedAt, endedAt: $endedAt, startLocationCheckId: $startLocationCheckId)';
}


}

/// @nodoc
abstract mixin class _$TimeEntryCopyWith<$Res> implements $TimeEntryCopyWith<$Res> {
  factory _$TimeEntryCopyWith(_TimeEntry value, $Res Function(_TimeEntry) _then) = __$TimeEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, TimeEntryKind kind, DateTime startedAt, DateTime? endedAt, String? startLocationCheckId
});




}
/// @nodoc
class __$TimeEntryCopyWithImpl<$Res>
    implements _$TimeEntryCopyWith<$Res> {
  __$TimeEntryCopyWithImpl(this._self, this._then);

  final _TimeEntry _self;
  final $Res Function(_TimeEntry) _then;

/// Create a copy of TimeEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? kind = null,Object? startedAt = null,Object? endedAt = freezed,Object? startLocationCheckId = freezed,}) {
  return _then(_TimeEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as TimeEntryKind,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,endedAt: freezed == endedAt ? _self.endedAt : endedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,startLocationCheckId: freezed == startLocationCheckId ? _self.startLocationCheckId : startLocationCheckId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
