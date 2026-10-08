// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'completion_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskPhoto {

 String get id; String get taskId;/// Local file; null for photos that only exist on the server (history).
 String? get localPath; PhotoKind get kind; DateTime get takenAt; double? get latitude; double? get longitude; PhotoUploadState get uploadState;/// 0.0 – 1.0 while uploading.
 double get progress; String? get lastError;
/// Create a copy of TaskPhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskPhotoCopyWith<TaskPhoto> get copyWith => _$TaskPhotoCopyWithImpl<TaskPhoto>(this as TaskPhoto, _$identity);

  /// Serializes this TaskPhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TaskPhoto;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskPhoto&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.localPath, _this.localPath) || other.localPath == _this.localPath)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.takenAt, _this.takenAt) || other.takenAt == _this.takenAt)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.uploadState, _this.uploadState) || other.uploadState == _this.uploadState)&&(identical(other.progress, _this.progress) || other.progress == _this.progress)&&(identical(other.lastError, _this.lastError) || other.lastError == _this.lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TaskPhoto;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.localPath,_this.kind,_this.takenAt,_this.latitude,_this.longitude,_this.uploadState,_this.progress,_this.lastError);
}

@override
String toString() {
  final _this = this as TaskPhoto;
  return 'TaskPhoto(id: ${_this.id}, taskId: ${_this.taskId}, localPath: ${_this.localPath}, kind: ${_this.kind}, takenAt: ${_this.takenAt}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, uploadState: ${_this.uploadState}, progress: ${_this.progress}, lastError: ${_this.lastError})';
}


}

/// @nodoc
abstract mixin class $TaskPhotoCopyWith<$Res>  {
  factory $TaskPhotoCopyWith(TaskPhoto value, $Res Function(TaskPhoto) _then) = _$TaskPhotoCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, String? localPath, PhotoKind kind, DateTime takenAt, double? latitude, double? longitude, PhotoUploadState uploadState, double progress, String? lastError
});




}
/// @nodoc
class _$TaskPhotoCopyWithImpl<$Res>
    implements $TaskPhotoCopyWith<$Res> {
  _$TaskPhotoCopyWithImpl(this._self, this._then);

  final TaskPhoto _self;
  final $Res Function(TaskPhoto) _then;

/// Create a copy of TaskPhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? localPath = freezed,Object? kind = null,Object? takenAt = null,Object? latitude = freezed,Object? longitude = freezed,Object? uploadState = null,Object? progress = null,Object? lastError = freezed,}) {
  return _then(TaskPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PhotoKind,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,uploadState: null == uploadState ? _self.uploadState : uploadState // ignore: cast_nullable_to_non_nullable
as PhotoUploadState,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskPhoto].
extension TaskPhotoPatterns on TaskPhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskPhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskPhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskPhoto value)  $default,){
final _that = this;
switch (_that) {
case _TaskPhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskPhoto value)?  $default,){
final _that = this;
switch (_that) {
case _TaskPhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  String? localPath,  PhotoKind kind,  DateTime takenAt,  double? latitude,  double? longitude,  PhotoUploadState uploadState,  double progress,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskPhoto() when $default != null:
return $default(_that.id,_that.taskId,_that.localPath,_that.kind,_that.takenAt,_that.latitude,_that.longitude,_that.uploadState,_that.progress,_that.lastError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  String? localPath,  PhotoKind kind,  DateTime takenAt,  double? latitude,  double? longitude,  PhotoUploadState uploadState,  double progress,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _TaskPhoto():
return $default(_that.id,_that.taskId,_that.localPath,_that.kind,_that.takenAt,_that.latitude,_that.longitude,_that.uploadState,_that.progress,_that.lastError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  String? localPath,  PhotoKind kind,  DateTime takenAt,  double? latitude,  double? longitude,  PhotoUploadState uploadState,  double progress,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _TaskPhoto() when $default != null:
return $default(_that.id,_that.taskId,_that.localPath,_that.kind,_that.takenAt,_that.latitude,_that.longitude,_that.uploadState,_that.progress,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskPhoto implements TaskPhoto {
  const _TaskPhoto({required this.id, required this.taskId, this.localPath, this.kind = PhotoKind.photo, required this.takenAt, this.latitude, this.longitude, this.uploadState = PhotoUploadState.pending, this.progress = 0, this.lastError});
  factory _TaskPhoto.fromJson(Map<String, dynamic> json) => _$TaskPhotoFromJson(json);

@override final  String id;
@override final  String taskId;
/// Local file; null for photos that only exist on the server (history).
@override final  String? localPath;
@override@JsonKey() final  PhotoKind kind;
@override final  DateTime takenAt;
@override final  double? latitude;
@override final  double? longitude;
@override@JsonKey() final  PhotoUploadState uploadState;
/// 0.0 – 1.0 while uploading.
@override@JsonKey() final  double progress;
@override final  String? lastError;

/// Create a copy of TaskPhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskPhotoCopyWith<_TaskPhoto> get copyWith => __$TaskPhotoCopyWithImpl<_TaskPhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskPhotoToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskPhoto&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.takenAt, takenAt) || other.takenAt == takenAt)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.uploadState, uploadState) || other.uploadState == uploadState)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,localPath,kind,takenAt,latitude,longitude,uploadState,progress,lastError);
}

@override
String toString() {
    return 'TaskPhoto(id: $id, taskId: $taskId, localPath: $localPath, kind: $kind, takenAt: $takenAt, latitude: $latitude, longitude: $longitude, uploadState: $uploadState, progress: $progress, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$TaskPhotoCopyWith<$Res> implements $TaskPhotoCopyWith<$Res> {
  factory _$TaskPhotoCopyWith(_TaskPhoto value, $Res Function(_TaskPhoto) _then) = __$TaskPhotoCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, String? localPath, PhotoKind kind, DateTime takenAt, double? latitude, double? longitude, PhotoUploadState uploadState, double progress, String? lastError
});




}
/// @nodoc
class __$TaskPhotoCopyWithImpl<$Res>
    implements _$TaskPhotoCopyWith<$Res> {
  __$TaskPhotoCopyWithImpl(this._self, this._then);

  final _TaskPhoto _self;
  final $Res Function(_TaskPhoto) _then;

/// Create a copy of TaskPhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? localPath = freezed,Object? kind = null,Object? takenAt = null,Object? latitude = freezed,Object? longitude = freezed,Object? uploadState = null,Object? progress = null,Object? lastError = freezed,}) {
  return _then(_TaskPhoto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,localPath: freezed == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String?,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as PhotoKind,takenAt: null == takenAt ? _self.takenAt : takenAt // ignore: cast_nullable_to_non_nullable
as DateTime,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,uploadState: null == uploadState ? _self.uploadState : uploadState // ignore: cast_nullable_to_non_nullable
as PhotoUploadState,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CatalogItem {

 String get id; String get name; String get unit;
/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogItemCopyWith<CatalogItem> get copyWith => _$CatalogItemCopyWithImpl<CatalogItem>(this as CatalogItem, _$identity);

  /// Serializes this CatalogItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CatalogItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.unit, _this.unit) || other.unit == _this.unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CatalogItem;
  return Object.hash(runtimeType,_this.id,_this.name,_this.unit);
}

@override
String toString() {
  final _this = this as CatalogItem;
  return 'CatalogItem(id: ${_this.id}, name: ${_this.name}, unit: ${_this.unit})';
}


}

/// @nodoc
abstract mixin class $CatalogItemCopyWith<$Res>  {
  factory $CatalogItemCopyWith(CatalogItem value, $Res Function(CatalogItem) _then) = _$CatalogItemCopyWithImpl;
@useResult
$Res call({
 String id, String name, String unit
});




}
/// @nodoc
class _$CatalogItemCopyWithImpl<$Res>
    implements $CatalogItemCopyWith<$Res> {
  _$CatalogItemCopyWithImpl(this._self, this._then);

  final CatalogItem _self;
  final $Res Function(CatalogItem) _then;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? unit = null,}) {
  return _then(CatalogItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogItem].
extension CatalogItemPatterns on CatalogItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogItem value)  $default,){
final _that = this;
switch (_that) {
case _CatalogItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogItem value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String unit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that.id,_that.name,_that.unit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String unit)  $default,) {final _that = this;
switch (_that) {
case _CatalogItem():
return $default(_that.id,_that.name,_that.unit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String unit)?  $default,) {final _that = this;
switch (_that) {
case _CatalogItem() when $default != null:
return $default(_that.id,_that.name,_that.unit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogItem implements CatalogItem {
  const _CatalogItem({required this.id, required this.name, required this.unit});
  factory _CatalogItem.fromJson(Map<String, dynamic> json) => _$CatalogItemFromJson(json);

@override final  String id;
@override final  String name;
@override final  String unit;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogItemCopyWith<_CatalogItem> get copyWith => __$CatalogItemCopyWithImpl<_CatalogItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.unit, unit) || other.unit == unit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,unit);
}

@override
String toString() {
    return 'CatalogItem(id: $id, name: $name, unit: $unit)';
}


}

/// @nodoc
abstract mixin class _$CatalogItemCopyWith<$Res> implements $CatalogItemCopyWith<$Res> {
  factory _$CatalogItemCopyWith(_CatalogItem value, $Res Function(_CatalogItem) _then) = __$CatalogItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String unit
});




}
/// @nodoc
class __$CatalogItemCopyWithImpl<$Res>
    implements _$CatalogItemCopyWith<$Res> {
  __$CatalogItemCopyWithImpl(this._self, this._then);

  final _CatalogItem _self;
  final $Res Function(_CatalogItem) _then;

/// Create a copy of CatalogItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? unit = null,}) {
  return _then(_CatalogItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$ExpectedMaterial {

 CatalogItem get item; double get quantity;
/// Create a copy of ExpectedMaterial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpectedMaterialCopyWith<ExpectedMaterial> get copyWith => _$ExpectedMaterialCopyWithImpl<ExpectedMaterial>(this as ExpectedMaterial, _$identity);

  /// Serializes this ExpectedMaterial to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ExpectedMaterial;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpectedMaterial&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ExpectedMaterial;
  return Object.hash(runtimeType,_this.item,_this.quantity);
}

@override
String toString() {
  final _this = this as ExpectedMaterial;
  return 'ExpectedMaterial(item: ${_this.item}, quantity: ${_this.quantity})';
}


}

/// @nodoc
abstract mixin class $ExpectedMaterialCopyWith<$Res>  {
  factory $ExpectedMaterialCopyWith(ExpectedMaterial value, $Res Function(ExpectedMaterial) _then) = _$ExpectedMaterialCopyWithImpl;
@useResult
$Res call({
 CatalogItem item, double quantity
});


$CatalogItemCopyWith<$Res> get item;

}
/// @nodoc
class _$ExpectedMaterialCopyWithImpl<$Res>
    implements $ExpectedMaterialCopyWith<$Res> {
  _$ExpectedMaterialCopyWithImpl(this._self, this._then);

  final ExpectedMaterial _self;
  final $Res Function(ExpectedMaterial) _then;

/// Create a copy of ExpectedMaterial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? item = null,Object? quantity = null,}) {
  return _then(ExpectedMaterial(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as CatalogItem,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}
/// Create a copy of ExpectedMaterial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogItemCopyWith<$Res> get item {
  
  return $CatalogItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// Adds pattern-matching-related methods to [ExpectedMaterial].
extension ExpectedMaterialPatterns on ExpectedMaterial {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpectedMaterial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpectedMaterial() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpectedMaterial value)  $default,){
final _that = this;
switch (_that) {
case _ExpectedMaterial():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpectedMaterial value)?  $default,){
final _that = this;
switch (_that) {
case _ExpectedMaterial() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( CatalogItem item,  double quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpectedMaterial() when $default != null:
return $default(_that.item,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( CatalogItem item,  double quantity)  $default,) {final _that = this;
switch (_that) {
case _ExpectedMaterial():
return $default(_that.item,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( CatalogItem item,  double quantity)?  $default,) {final _that = this;
switch (_that) {
case _ExpectedMaterial() when $default != null:
return $default(_that.item,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ExpectedMaterial implements ExpectedMaterial {
  const _ExpectedMaterial({required this.item, required this.quantity});
  factory _ExpectedMaterial.fromJson(Map<String, dynamic> json) => _$ExpectedMaterialFromJson(json);

@override final  CatalogItem item;
@override final  double quantity;

/// Create a copy of ExpectedMaterial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpectedMaterialCopyWith<_ExpectedMaterial> get copyWith => __$ExpectedMaterialCopyWithImpl<_ExpectedMaterial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ExpectedMaterialToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpectedMaterial&&(identical(other.item, item) || other.item == item)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,item,quantity);
}

@override
String toString() {
    return 'ExpectedMaterial(item: $item, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$ExpectedMaterialCopyWith<$Res> implements $ExpectedMaterialCopyWith<$Res> {
  factory _$ExpectedMaterialCopyWith(_ExpectedMaterial value, $Res Function(_ExpectedMaterial) _then) = __$ExpectedMaterialCopyWithImpl;
@override @useResult
$Res call({
 CatalogItem item, double quantity
});


@override $CatalogItemCopyWith<$Res> get item;

}
/// @nodoc
class __$ExpectedMaterialCopyWithImpl<$Res>
    implements _$ExpectedMaterialCopyWith<$Res> {
  __$ExpectedMaterialCopyWithImpl(this._self, this._then);

  final _ExpectedMaterial _self;
  final $Res Function(_ExpectedMaterial) _then;

/// Create a copy of ExpectedMaterial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? item = null,Object? quantity = null,}) {
  return _then(_ExpectedMaterial(
item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as CatalogItem,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

/// Create a copy of ExpectedMaterial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CatalogItemCopyWith<$Res> get item {
  
  return $CatalogItemCopyWith<$Res>(_self.item, (value) {
    return _then(_self.copyWith(item: value));
  });
}
}


/// @nodoc
mixin _$MaterialEntry {

 String get id; String get taskId; String get catalogItemId; String get itemName; String get unit; double get quantity; MaterialMovement get movement; String? get note;
/// Create a copy of MaterialEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MaterialEntryCopyWith<MaterialEntry> get copyWith => _$MaterialEntryCopyWithImpl<MaterialEntry>(this as MaterialEntry, _$identity);

  /// Serializes this MaterialEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as MaterialEntry;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MaterialEntry&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.catalogItemId, _this.catalogItemId) || other.catalogItemId == _this.catalogItemId)&&(identical(other.itemName, _this.itemName) || other.itemName == _this.itemName)&&(identical(other.unit, _this.unit) || other.unit == _this.unit)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.movement, _this.movement) || other.movement == _this.movement)&&(identical(other.note, _this.note) || other.note == _this.note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as MaterialEntry;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.catalogItemId,_this.itemName,_this.unit,_this.quantity,_this.movement,_this.note);
}

@override
String toString() {
  final _this = this as MaterialEntry;
  return 'MaterialEntry(id: ${_this.id}, taskId: ${_this.taskId}, catalogItemId: ${_this.catalogItemId}, itemName: ${_this.itemName}, unit: ${_this.unit}, quantity: ${_this.quantity}, movement: ${_this.movement}, note: ${_this.note})';
}


}

/// @nodoc
abstract mixin class $MaterialEntryCopyWith<$Res>  {
  factory $MaterialEntryCopyWith(MaterialEntry value, $Res Function(MaterialEntry) _then) = _$MaterialEntryCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, String catalogItemId, String itemName, String unit, double quantity, MaterialMovement movement, String? note
});




}
/// @nodoc
class _$MaterialEntryCopyWithImpl<$Res>
    implements $MaterialEntryCopyWith<$Res> {
  _$MaterialEntryCopyWithImpl(this._self, this._then);

  final MaterialEntry _self;
  final $Res Function(MaterialEntry) _then;

/// Create a copy of MaterialEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? catalogItemId = null,Object? itemName = null,Object? unit = null,Object? quantity = null,Object? movement = null,Object? note = freezed,}) {
  return _then(MaterialEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,catalogItemId: null == catalogItemId ? _self.catalogItemId : catalogItemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,movement: null == movement ? _self.movement : movement // ignore: cast_nullable_to_non_nullable
as MaterialMovement,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MaterialEntry].
extension MaterialEntryPatterns on MaterialEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MaterialEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MaterialEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MaterialEntry value)  $default,){
final _that = this;
switch (_that) {
case _MaterialEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MaterialEntry value)?  $default,){
final _that = this;
switch (_that) {
case _MaterialEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  String catalogItemId,  String itemName,  String unit,  double quantity,  MaterialMovement movement,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MaterialEntry() when $default != null:
return $default(_that.id,_that.taskId,_that.catalogItemId,_that.itemName,_that.unit,_that.quantity,_that.movement,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  String catalogItemId,  String itemName,  String unit,  double quantity,  MaterialMovement movement,  String? note)  $default,) {final _that = this;
switch (_that) {
case _MaterialEntry():
return $default(_that.id,_that.taskId,_that.catalogItemId,_that.itemName,_that.unit,_that.quantity,_that.movement,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  String catalogItemId,  String itemName,  String unit,  double quantity,  MaterialMovement movement,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _MaterialEntry() when $default != null:
return $default(_that.id,_that.taskId,_that.catalogItemId,_that.itemName,_that.unit,_that.quantity,_that.movement,_that.note);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MaterialEntry implements MaterialEntry {
  const _MaterialEntry({required this.id, required this.taskId, required this.catalogItemId, required this.itemName, required this.unit, required this.quantity, required this.movement, this.note});
  factory _MaterialEntry.fromJson(Map<String, dynamic> json) => _$MaterialEntryFromJson(json);

@override final  String id;
@override final  String taskId;
@override final  String catalogItemId;
@override final  String itemName;
@override final  String unit;
@override final  double quantity;
@override final  MaterialMovement movement;
@override final  String? note;

/// Create a copy of MaterialEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MaterialEntryCopyWith<_MaterialEntry> get copyWith => __$MaterialEntryCopyWithImpl<_MaterialEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MaterialEntryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MaterialEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.catalogItemId, catalogItemId) || other.catalogItemId == catalogItemId)&&(identical(other.itemName, itemName) || other.itemName == itemName)&&(identical(other.unit, unit) || other.unit == unit)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.movement, movement) || other.movement == movement)&&(identical(other.note, note) || other.note == note));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,catalogItemId,itemName,unit,quantity,movement,note);
}

@override
String toString() {
    return 'MaterialEntry(id: $id, taskId: $taskId, catalogItemId: $catalogItemId, itemName: $itemName, unit: $unit, quantity: $quantity, movement: $movement, note: $note)';
}


}

/// @nodoc
abstract mixin class _$MaterialEntryCopyWith<$Res> implements $MaterialEntryCopyWith<$Res> {
  factory _$MaterialEntryCopyWith(_MaterialEntry value, $Res Function(_MaterialEntry) _then) = __$MaterialEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, String catalogItemId, String itemName, String unit, double quantity, MaterialMovement movement, String? note
});




}
/// @nodoc
class __$MaterialEntryCopyWithImpl<$Res>
    implements _$MaterialEntryCopyWith<$Res> {
  __$MaterialEntryCopyWithImpl(this._self, this._then);

  final _MaterialEntry _self;
  final $Res Function(_MaterialEntry) _then;

/// Create a copy of MaterialEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? catalogItemId = null,Object? itemName = null,Object? unit = null,Object? quantity = null,Object? movement = null,Object? note = freezed,}) {
  return _then(_MaterialEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,catalogItemId: null == catalogItemId ? _self.catalogItemId : catalogItemId // ignore: cast_nullable_to_non_nullable
as String,itemName: null == itemName ? _self.itemName : itemName // ignore: cast_nullable_to_non_nullable
as String,unit: null == unit ? _self.unit : unit // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as double,movement: null == movement ? _self.movement : movement // ignore: cast_nullable_to_non_nullable
as MaterialMovement,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TaskCompletion {

 String get id; String get taskId; String get workerId; DateTime get completedAt; String? get completionLocationCheckId; List<TimeEntry> get timeEntries; Duration get totalWorkDuration; Duration get totalBreakDuration; List<String> get photoIds; List<MaterialEntry> get materials; String? get comment;
/// Create a copy of TaskCompletion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCompletionCopyWith<TaskCompletion> get copyWith => _$TaskCompletionCopyWithImpl<TaskCompletion>(this as TaskCompletion, _$identity);

  /// Serializes this TaskCompletion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as TaskCompletion;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskCompletion&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.taskId, _this.taskId) || other.taskId == _this.taskId)&&(identical(other.workerId, _this.workerId) || other.workerId == _this.workerId)&&(identical(other.completedAt, _this.completedAt) || other.completedAt == _this.completedAt)&&(identical(other.completionLocationCheckId, _this.completionLocationCheckId) || other.completionLocationCheckId == _this.completionLocationCheckId)&&const DeepCollectionEquality().equals(other.timeEntries, _this.timeEntries)&&(identical(other.totalWorkDuration, _this.totalWorkDuration) || other.totalWorkDuration == _this.totalWorkDuration)&&(identical(other.totalBreakDuration, _this.totalBreakDuration) || other.totalBreakDuration == _this.totalBreakDuration)&&const DeepCollectionEquality().equals(other.photoIds, _this.photoIds)&&const DeepCollectionEquality().equals(other.materials, _this.materials)&&(identical(other.comment, _this.comment) || other.comment == _this.comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as TaskCompletion;
  return Object.hash(runtimeType,_this.id,_this.taskId,_this.workerId,_this.completedAt,_this.completionLocationCheckId,const DeepCollectionEquality().hash(_this.timeEntries),_this.totalWorkDuration,_this.totalBreakDuration,const DeepCollectionEquality().hash(_this.photoIds),const DeepCollectionEquality().hash(_this.materials),_this.comment);
}

@override
String toString() {
  final _this = this as TaskCompletion;
  return 'TaskCompletion(id: ${_this.id}, taskId: ${_this.taskId}, workerId: ${_this.workerId}, completedAt: ${_this.completedAt}, completionLocationCheckId: ${_this.completionLocationCheckId}, timeEntries: ${_this.timeEntries}, totalWorkDuration: ${_this.totalWorkDuration}, totalBreakDuration: ${_this.totalBreakDuration}, photoIds: ${_this.photoIds}, materials: ${_this.materials}, comment: ${_this.comment})';
}


}

/// @nodoc
abstract mixin class $TaskCompletionCopyWith<$Res>  {
  factory $TaskCompletionCopyWith(TaskCompletion value, $Res Function(TaskCompletion) _then) = _$TaskCompletionCopyWithImpl;
@useResult
$Res call({
 String id, String taskId, String workerId, DateTime completedAt, String? completionLocationCheckId, List<TimeEntry> timeEntries, Duration totalWorkDuration, Duration totalBreakDuration, List<String> photoIds, List<MaterialEntry> materials, String? comment
});




}
/// @nodoc
class _$TaskCompletionCopyWithImpl<$Res>
    implements $TaskCompletionCopyWith<$Res> {
  _$TaskCompletionCopyWithImpl(this._self, this._then);

  final TaskCompletion _self;
  final $Res Function(TaskCompletion) _then;

/// Create a copy of TaskCompletion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? taskId = null,Object? workerId = null,Object? completedAt = null,Object? completionLocationCheckId = freezed,Object? timeEntries = null,Object? totalWorkDuration = null,Object? totalBreakDuration = null,Object? photoIds = null,Object? materials = null,Object? comment = freezed,}) {
  return _then(TaskCompletion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completionLocationCheckId: freezed == completionLocationCheckId ? _self.completionLocationCheckId : completionLocationCheckId // ignore: cast_nullable_to_non_nullable
as String?,timeEntries: null == timeEntries ? _self.timeEntries : timeEntries // ignore: cast_nullable_to_non_nullable
as List<TimeEntry>,totalWorkDuration: null == totalWorkDuration ? _self.totalWorkDuration : totalWorkDuration // ignore: cast_nullable_to_non_nullable
as Duration,totalBreakDuration: null == totalBreakDuration ? _self.totalBreakDuration : totalBreakDuration // ignore: cast_nullable_to_non_nullable
as Duration,photoIds: null == photoIds ? _self.photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,materials: null == materials ? _self.materials : materials // ignore: cast_nullable_to_non_nullable
as List<MaterialEntry>,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskCompletion].
extension TaskCompletionPatterns on TaskCompletion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskCompletion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskCompletion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskCompletion value)  $default,){
final _that = this;
switch (_that) {
case _TaskCompletion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskCompletion value)?  $default,){
final _that = this;
switch (_that) {
case _TaskCompletion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String taskId,  String workerId,  DateTime completedAt,  String? completionLocationCheckId,  List<TimeEntry> timeEntries,  Duration totalWorkDuration,  Duration totalBreakDuration,  List<String> photoIds,  List<MaterialEntry> materials,  String? comment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskCompletion() when $default != null:
return $default(_that.id,_that.taskId,_that.workerId,_that.completedAt,_that.completionLocationCheckId,_that.timeEntries,_that.totalWorkDuration,_that.totalBreakDuration,_that.photoIds,_that.materials,_that.comment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String taskId,  String workerId,  DateTime completedAt,  String? completionLocationCheckId,  List<TimeEntry> timeEntries,  Duration totalWorkDuration,  Duration totalBreakDuration,  List<String> photoIds,  List<MaterialEntry> materials,  String? comment)  $default,) {final _that = this;
switch (_that) {
case _TaskCompletion():
return $default(_that.id,_that.taskId,_that.workerId,_that.completedAt,_that.completionLocationCheckId,_that.timeEntries,_that.totalWorkDuration,_that.totalBreakDuration,_that.photoIds,_that.materials,_that.comment);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String taskId,  String workerId,  DateTime completedAt,  String? completionLocationCheckId,  List<TimeEntry> timeEntries,  Duration totalWorkDuration,  Duration totalBreakDuration,  List<String> photoIds,  List<MaterialEntry> materials,  String? comment)?  $default,) {final _that = this;
switch (_that) {
case _TaskCompletion() when $default != null:
return $default(_that.id,_that.taskId,_that.workerId,_that.completedAt,_that.completionLocationCheckId,_that.timeEntries,_that.totalWorkDuration,_that.totalBreakDuration,_that.photoIds,_that.materials,_that.comment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskCompletion implements TaskCompletion {
  const _TaskCompletion({required this.id, required this.taskId, required this.workerId, required this.completedAt, this.completionLocationCheckId, required  List<TimeEntry> timeEntries, required this.totalWorkDuration, required this.totalBreakDuration, required  List<String> photoIds, required  List<MaterialEntry> materials, this.comment}): _timeEntries = timeEntries,_photoIds = photoIds,_materials = materials;
  factory _TaskCompletion.fromJson(Map<String, dynamic> json) => _$TaskCompletionFromJson(json);

@override final  String id;
@override final  String taskId;
@override final  String workerId;
@override final  DateTime completedAt;
@override final  String? completionLocationCheckId;
 final  List<TimeEntry> _timeEntries;
@override List<TimeEntry> get timeEntries {
  if (_timeEntries is EqualUnmodifiableListView) return _timeEntries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_timeEntries);
}

@override final  Duration totalWorkDuration;
@override final  Duration totalBreakDuration;
 final  List<String> _photoIds;
@override List<String> get photoIds {
  if (_photoIds is EqualUnmodifiableListView) return _photoIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoIds);
}

 final  List<MaterialEntry> _materials;
@override List<MaterialEntry> get materials {
  if (_materials is EqualUnmodifiableListView) return _materials;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_materials);
}

@override final  String? comment;

/// Create a copy of TaskCompletion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCompletionCopyWith<_TaskCompletion> get copyWith => __$TaskCompletionCopyWithImpl<_TaskCompletion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskCompletionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskCompletion&&(identical(other.id, id) || other.id == id)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.completionLocationCheckId, completionLocationCheckId) || other.completionLocationCheckId == completionLocationCheckId)&&const DeepCollectionEquality().equals(other.timeEntries, _timeEntries)&&(identical(other.totalWorkDuration, totalWorkDuration) || other.totalWorkDuration == totalWorkDuration)&&(identical(other.totalBreakDuration, totalBreakDuration) || other.totalBreakDuration == totalBreakDuration)&&const DeepCollectionEquality().equals(other.photoIds, _photoIds)&&const DeepCollectionEquality().equals(other.materials, _materials)&&(identical(other.comment, comment) || other.comment == comment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,taskId,workerId,completedAt,completionLocationCheckId,const DeepCollectionEquality().hash(_timeEntries),totalWorkDuration,totalBreakDuration,const DeepCollectionEquality().hash(_photoIds),const DeepCollectionEquality().hash(_materials),comment);
}

@override
String toString() {
    return 'TaskCompletion(id: $id, taskId: $taskId, workerId: $workerId, completedAt: $completedAt, completionLocationCheckId: $completionLocationCheckId, timeEntries: $timeEntries, totalWorkDuration: $totalWorkDuration, totalBreakDuration: $totalBreakDuration, photoIds: $photoIds, materials: $materials, comment: $comment)';
}


}

/// @nodoc
abstract mixin class _$TaskCompletionCopyWith<$Res> implements $TaskCompletionCopyWith<$Res> {
  factory _$TaskCompletionCopyWith(_TaskCompletion value, $Res Function(_TaskCompletion) _then) = __$TaskCompletionCopyWithImpl;
@override @useResult
$Res call({
 String id, String taskId, String workerId, DateTime completedAt, String? completionLocationCheckId, List<TimeEntry> timeEntries, Duration totalWorkDuration, Duration totalBreakDuration, List<String> photoIds, List<MaterialEntry> materials, String? comment
});




}
/// @nodoc
class __$TaskCompletionCopyWithImpl<$Res>
    implements _$TaskCompletionCopyWith<$Res> {
  __$TaskCompletionCopyWithImpl(this._self, this._then);

  final _TaskCompletion _self;
  final $Res Function(_TaskCompletion) _then;

/// Create a copy of TaskCompletion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? taskId = null,Object? workerId = null,Object? completedAt = null,Object? completionLocationCheckId = freezed,Object? timeEntries = null,Object? totalWorkDuration = null,Object? totalBreakDuration = null,Object? photoIds = null,Object? materials = null,Object? comment = freezed,}) {
  return _then(_TaskCompletion(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completionLocationCheckId: freezed == completionLocationCheckId ? _self.completionLocationCheckId : completionLocationCheckId // ignore: cast_nullable_to_non_nullable
as String?,timeEntries: null == timeEntries ? _self._timeEntries : timeEntries // ignore: cast_nullable_to_non_nullable
as List<TimeEntry>,totalWorkDuration: null == totalWorkDuration ? _self.totalWorkDuration : totalWorkDuration // ignore: cast_nullable_to_non_nullable
as Duration,totalBreakDuration: null == totalBreakDuration ? _self.totalBreakDuration : totalBreakDuration // ignore: cast_nullable_to_non_nullable
as Duration,photoIds: null == photoIds ? _self._photoIds : photoIds // ignore: cast_nullable_to_non_nullable
as List<String>,materials: null == materials ? _self._materials : materials // ignore: cast_nullable_to_non_nullable
as List<MaterialEntry>,comment: freezed == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
