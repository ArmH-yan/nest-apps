// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Task {

 String get id; String get jobId; String get visitId; JobType get jobType; String get title; String get projectName; String get customerName; String get instructions; String get siteName; String get address; double get latitude; double get longitude; double? get geofenceRadiusM; String get accessNotes; String? get siteContactName; String? get siteContactPhone; DateTime get scheduledStart; DateTime get scheduledEnd; TaskRole get role; List<CrewMember> get crew; ServerTaskStatus get serverStatus;
/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskCopyWith<Task> get copyWith => _$TaskCopyWithImpl<Task>(this as Task, _$identity);

  /// Serializes this Task to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Task;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Task&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.jobId, _this.jobId) || other.jobId == _this.jobId)&&(identical(other.visitId, _this.visitId) || other.visitId == _this.visitId)&&(identical(other.jobType, _this.jobType) || other.jobType == _this.jobType)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.projectName, _this.projectName) || other.projectName == _this.projectName)&&(identical(other.customerName, _this.customerName) || other.customerName == _this.customerName)&&(identical(other.instructions, _this.instructions) || other.instructions == _this.instructions)&&(identical(other.siteName, _this.siteName) || other.siteName == _this.siteName)&&(identical(other.address, _this.address) || other.address == _this.address)&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.geofenceRadiusM, _this.geofenceRadiusM) || other.geofenceRadiusM == _this.geofenceRadiusM)&&(identical(other.accessNotes, _this.accessNotes) || other.accessNotes == _this.accessNotes)&&(identical(other.siteContactName, _this.siteContactName) || other.siteContactName == _this.siteContactName)&&(identical(other.siteContactPhone, _this.siteContactPhone) || other.siteContactPhone == _this.siteContactPhone)&&(identical(other.scheduledStart, _this.scheduledStart) || other.scheduledStart == _this.scheduledStart)&&(identical(other.scheduledEnd, _this.scheduledEnd) || other.scheduledEnd == _this.scheduledEnd)&&(identical(other.role, _this.role) || other.role == _this.role)&&const DeepCollectionEquality().equals(other.crew, _this.crew)&&(identical(other.serverStatus, _this.serverStatus) || other.serverStatus == _this.serverStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Task;
  return Object.hashAll([runtimeType,_this.id,_this.jobId,_this.visitId,_this.jobType,_this.title,_this.projectName,_this.customerName,_this.instructions,_this.siteName,_this.address,_this.latitude,_this.longitude,_this.geofenceRadiusM,_this.accessNotes,_this.siteContactName,_this.siteContactPhone,_this.scheduledStart,_this.scheduledEnd,_this.role,const DeepCollectionEquality().hash(_this.crew),_this.serverStatus]);
}

@override
String toString() {
  final _this = this as Task;
  return 'Task(id: ${_this.id}, jobId: ${_this.jobId}, visitId: ${_this.visitId}, jobType: ${_this.jobType}, title: ${_this.title}, projectName: ${_this.projectName}, customerName: ${_this.customerName}, instructions: ${_this.instructions}, siteName: ${_this.siteName}, address: ${_this.address}, latitude: ${_this.latitude}, longitude: ${_this.longitude}, geofenceRadiusM: ${_this.geofenceRadiusM}, accessNotes: ${_this.accessNotes}, siteContactName: ${_this.siteContactName}, siteContactPhone: ${_this.siteContactPhone}, scheduledStart: ${_this.scheduledStart}, scheduledEnd: ${_this.scheduledEnd}, role: ${_this.role}, crew: ${_this.crew}, serverStatus: ${_this.serverStatus})';
}


}

/// @nodoc
abstract mixin class $TaskCopyWith<$Res>  {
  factory $TaskCopyWith(Task value, $Res Function(Task) _then) = _$TaskCopyWithImpl;
@useResult
$Res call({
 String id, String jobId, String visitId, JobType jobType, String title, String projectName, String customerName, String instructions, String siteName, String address, double latitude, double longitude, double? geofenceRadiusM, String accessNotes, String? siteContactName, String? siteContactPhone, DateTime scheduledStart, DateTime scheduledEnd, TaskRole role, List<CrewMember> crew, ServerTaskStatus serverStatus
});




}
/// @nodoc
class _$TaskCopyWithImpl<$Res>
    implements $TaskCopyWith<$Res> {
  _$TaskCopyWithImpl(this._self, this._then);

  final Task _self;
  final $Res Function(Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? jobId = null,Object? visitId = null,Object? jobType = null,Object? title = null,Object? projectName = null,Object? customerName = null,Object? instructions = null,Object? siteName = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? geofenceRadiusM = freezed,Object? accessNotes = null,Object? siteContactName = freezed,Object? siteContactPhone = freezed,Object? scheduledStart = null,Object? scheduledEnd = null,Object? role = null,Object? crew = null,Object? serverStatus = null,}) {
  return _then(Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,visitId: null == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String,jobType: null == jobType ? _self.jobType : jobType // ignore: cast_nullable_to_non_nullable
as JobType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,projectName: null == projectName ? _self.projectName : projectName // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,geofenceRadiusM: freezed == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as double?,accessNotes: null == accessNotes ? _self.accessNotes : accessNotes // ignore: cast_nullable_to_non_nullable
as String,siteContactName: freezed == siteContactName ? _self.siteContactName : siteContactName // ignore: cast_nullable_to_non_nullable
as String?,siteContactPhone: freezed == siteContactPhone ? _self.siteContactPhone : siteContactPhone // ignore: cast_nullable_to_non_nullable
as String?,scheduledStart: null == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledEnd: null == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TaskRole,crew: null == crew ? _self.crew : crew // ignore: cast_nullable_to_non_nullable
as List<CrewMember>,serverStatus: null == serverStatus ? _self.serverStatus : serverStatus // ignore: cast_nullable_to_non_nullable
as ServerTaskStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Task].
extension TaskPatterns on Task {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Task value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Task value)  $default,){
final _that = this;
switch (_that) {
case _Task():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Task value)?  $default,){
final _that = this;
switch (_that) {
case _Task() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String jobId,  String visitId,  JobType jobType,  String title,  String projectName,  String customerName,  String instructions,  String siteName,  String address,  double latitude,  double longitude,  double? geofenceRadiusM,  String accessNotes,  String? siteContactName,  String? siteContactPhone,  DateTime scheduledStart,  DateTime scheduledEnd,  TaskRole role,  List<CrewMember> crew,  ServerTaskStatus serverStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.jobId,_that.visitId,_that.jobType,_that.title,_that.projectName,_that.customerName,_that.instructions,_that.siteName,_that.address,_that.latitude,_that.longitude,_that.geofenceRadiusM,_that.accessNotes,_that.siteContactName,_that.siteContactPhone,_that.scheduledStart,_that.scheduledEnd,_that.role,_that.crew,_that.serverStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String jobId,  String visitId,  JobType jobType,  String title,  String projectName,  String customerName,  String instructions,  String siteName,  String address,  double latitude,  double longitude,  double? geofenceRadiusM,  String accessNotes,  String? siteContactName,  String? siteContactPhone,  DateTime scheduledStart,  DateTime scheduledEnd,  TaskRole role,  List<CrewMember> crew,  ServerTaskStatus serverStatus)  $default,) {final _that = this;
switch (_that) {
case _Task():
return $default(_that.id,_that.jobId,_that.visitId,_that.jobType,_that.title,_that.projectName,_that.customerName,_that.instructions,_that.siteName,_that.address,_that.latitude,_that.longitude,_that.geofenceRadiusM,_that.accessNotes,_that.siteContactName,_that.siteContactPhone,_that.scheduledStart,_that.scheduledEnd,_that.role,_that.crew,_that.serverStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String jobId,  String visitId,  JobType jobType,  String title,  String projectName,  String customerName,  String instructions,  String siteName,  String address,  double latitude,  double longitude,  double? geofenceRadiusM,  String accessNotes,  String? siteContactName,  String? siteContactPhone,  DateTime scheduledStart,  DateTime scheduledEnd,  TaskRole role,  List<CrewMember> crew,  ServerTaskStatus serverStatus)?  $default,) {final _that = this;
switch (_that) {
case _Task() when $default != null:
return $default(_that.id,_that.jobId,_that.visitId,_that.jobType,_that.title,_that.projectName,_that.customerName,_that.instructions,_that.siteName,_that.address,_that.latitude,_that.longitude,_that.geofenceRadiusM,_that.accessNotes,_that.siteContactName,_that.siteContactPhone,_that.scheduledStart,_that.scheduledEnd,_that.role,_that.crew,_that.serverStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Task extends Task {
  const _Task({required this.id, required this.jobId, required this.visitId, required this.jobType, required this.title, required this.projectName, required this.customerName, this.instructions = '', required this.siteName, required this.address, required this.latitude, required this.longitude, this.geofenceRadiusM, this.accessNotes = '', this.siteContactName, this.siteContactPhone, required this.scheduledStart, required this.scheduledEnd, required this.role,  List<CrewMember> crew = const <CrewMember>[], required this.serverStatus}): _crew = crew,super._();
  factory _Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

@override final  String id;
@override final  String jobId;
@override final  String visitId;
@override final  JobType jobType;
@override final  String title;
@override final  String projectName;
@override final  String customerName;
@override@JsonKey() final  String instructions;
@override final  String siteName;
@override final  String address;
@override final  double latitude;
@override final  double longitude;
@override final  double? geofenceRadiusM;
@override@JsonKey() final  String accessNotes;
@override final  String? siteContactName;
@override final  String? siteContactPhone;
@override final  DateTime scheduledStart;
@override final  DateTime scheduledEnd;
@override final  TaskRole role;
 final  List<CrewMember> _crew;
@override@JsonKey() List<CrewMember> get crew {
  if (_crew is EqualUnmodifiableListView) return _crew;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_crew);
}

@override final  ServerTaskStatus serverStatus;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskCopyWith<_Task> get copyWith => __$TaskCopyWithImpl<_Task>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Task&&(identical(other.id, id) || other.id == id)&&(identical(other.jobId, jobId) || other.jobId == jobId)&&(identical(other.visitId, visitId) || other.visitId == visitId)&&(identical(other.jobType, jobType) || other.jobType == jobType)&&(identical(other.title, title) || other.title == title)&&(identical(other.projectName, projectName) || other.projectName == projectName)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.siteName, siteName) || other.siteName == siteName)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.geofenceRadiusM, geofenceRadiusM) || other.geofenceRadiusM == geofenceRadiusM)&&(identical(other.accessNotes, accessNotes) || other.accessNotes == accessNotes)&&(identical(other.siteContactName, siteContactName) || other.siteContactName == siteContactName)&&(identical(other.siteContactPhone, siteContactPhone) || other.siteContactPhone == siteContactPhone)&&(identical(other.scheduledStart, scheduledStart) || other.scheduledStart == scheduledStart)&&(identical(other.scheduledEnd, scheduledEnd) || other.scheduledEnd == scheduledEnd)&&(identical(other.role, role) || other.role == role)&&const DeepCollectionEquality().equals(other.crew, _crew)&&(identical(other.serverStatus, serverStatus) || other.serverStatus == serverStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hashAll([runtimeType,id,jobId,visitId,jobType,title,projectName,customerName,instructions,siteName,address,latitude,longitude,geofenceRadiusM,accessNotes,siteContactName,siteContactPhone,scheduledStart,scheduledEnd,role,const DeepCollectionEquality().hash(_crew),serverStatus]);
}

@override
String toString() {
    return 'Task(id: $id, jobId: $jobId, visitId: $visitId, jobType: $jobType, title: $title, projectName: $projectName, customerName: $customerName, instructions: $instructions, siteName: $siteName, address: $address, latitude: $latitude, longitude: $longitude, geofenceRadiusM: $geofenceRadiusM, accessNotes: $accessNotes, siteContactName: $siteContactName, siteContactPhone: $siteContactPhone, scheduledStart: $scheduledStart, scheduledEnd: $scheduledEnd, role: $role, crew: $crew, serverStatus: $serverStatus)';
}


}

/// @nodoc
abstract mixin class _$TaskCopyWith<$Res> implements $TaskCopyWith<$Res> {
  factory _$TaskCopyWith(_Task value, $Res Function(_Task) _then) = __$TaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String jobId, String visitId, JobType jobType, String title, String projectName, String customerName, String instructions, String siteName, String address, double latitude, double longitude, double? geofenceRadiusM, String accessNotes, String? siteContactName, String? siteContactPhone, DateTime scheduledStart, DateTime scheduledEnd, TaskRole role, List<CrewMember> crew, ServerTaskStatus serverStatus
});




}
/// @nodoc
class __$TaskCopyWithImpl<$Res>
    implements _$TaskCopyWith<$Res> {
  __$TaskCopyWithImpl(this._self, this._then);

  final _Task _self;
  final $Res Function(_Task) _then;

/// Create a copy of Task
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? jobId = null,Object? visitId = null,Object? jobType = null,Object? title = null,Object? projectName = null,Object? customerName = null,Object? instructions = null,Object? siteName = null,Object? address = null,Object? latitude = null,Object? longitude = null,Object? geofenceRadiusM = freezed,Object? accessNotes = null,Object? siteContactName = freezed,Object? siteContactPhone = freezed,Object? scheduledStart = null,Object? scheduledEnd = null,Object? role = null,Object? crew = null,Object? serverStatus = null,}) {
  return _then(_Task(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,jobId: null == jobId ? _self.jobId : jobId // ignore: cast_nullable_to_non_nullable
as String,visitId: null == visitId ? _self.visitId : visitId // ignore: cast_nullable_to_non_nullable
as String,jobType: null == jobType ? _self.jobType : jobType // ignore: cast_nullable_to_non_nullable
as JobType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,projectName: null == projectName ? _self.projectName : projectName // ignore: cast_nullable_to_non_nullable
as String,customerName: null == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String,instructions: null == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String,siteName: null == siteName ? _self.siteName : siteName // ignore: cast_nullable_to_non_nullable
as String,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,geofenceRadiusM: freezed == geofenceRadiusM ? _self.geofenceRadiusM : geofenceRadiusM // ignore: cast_nullable_to_non_nullable
as double?,accessNotes: null == accessNotes ? _self.accessNotes : accessNotes // ignore: cast_nullable_to_non_nullable
as String,siteContactName: freezed == siteContactName ? _self.siteContactName : siteContactName // ignore: cast_nullable_to_non_nullable
as String?,siteContactPhone: freezed == siteContactPhone ? _self.siteContactPhone : siteContactPhone // ignore: cast_nullable_to_non_nullable
as String?,scheduledStart: null == scheduledStart ? _self.scheduledStart : scheduledStart // ignore: cast_nullable_to_non_nullable
as DateTime,scheduledEnd: null == scheduledEnd ? _self.scheduledEnd : scheduledEnd // ignore: cast_nullable_to_non_nullable
as DateTime,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TaskRole,crew: null == crew ? _self._crew : crew // ignore: cast_nullable_to_non_nullable
as List<CrewMember>,serverStatus: null == serverStatus ? _self.serverStatus : serverStatus // ignore: cast_nullable_to_non_nullable
as ServerTaskStatus,
  ));
}


}


/// @nodoc
mixin _$CrewMember {

 String get workerId; String get fullName; TaskRole get role; String? get phone;
/// Create a copy of CrewMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CrewMemberCopyWith<CrewMember> get copyWith => _$CrewMemberCopyWithImpl<CrewMember>(this as CrewMember, _$identity);

  /// Serializes this CrewMember to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CrewMember;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CrewMember&&(identical(other.workerId, _this.workerId) || other.workerId == _this.workerId)&&(identical(other.fullName, _this.fullName) || other.fullName == _this.fullName)&&(identical(other.role, _this.role) || other.role == _this.role)&&(identical(other.phone, _this.phone) || other.phone == _this.phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CrewMember;
  return Object.hash(runtimeType,_this.workerId,_this.fullName,_this.role,_this.phone);
}

@override
String toString() {
  final _this = this as CrewMember;
  return 'CrewMember(workerId: ${_this.workerId}, fullName: ${_this.fullName}, role: ${_this.role}, phone: ${_this.phone})';
}


}

/// @nodoc
abstract mixin class $CrewMemberCopyWith<$Res>  {
  factory $CrewMemberCopyWith(CrewMember value, $Res Function(CrewMember) _then) = _$CrewMemberCopyWithImpl;
@useResult
$Res call({
 String workerId, String fullName, TaskRole role, String? phone
});




}
/// @nodoc
class _$CrewMemberCopyWithImpl<$Res>
    implements $CrewMemberCopyWith<$Res> {
  _$CrewMemberCopyWithImpl(this._self, this._then);

  final CrewMember _self;
  final $Res Function(CrewMember) _then;

/// Create a copy of CrewMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workerId = null,Object? fullName = null,Object? role = null,Object? phone = freezed,}) {
  return _then(CrewMember(
workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TaskRole,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CrewMember].
extension CrewMemberPatterns on CrewMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CrewMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CrewMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CrewMember value)  $default,){
final _that = this;
switch (_that) {
case _CrewMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CrewMember value)?  $default,){
final _that = this;
switch (_that) {
case _CrewMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String workerId,  String fullName,  TaskRole role,  String? phone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CrewMember() when $default != null:
return $default(_that.workerId,_that.fullName,_that.role,_that.phone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String workerId,  String fullName,  TaskRole role,  String? phone)  $default,) {final _that = this;
switch (_that) {
case _CrewMember():
return $default(_that.workerId,_that.fullName,_that.role,_that.phone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String workerId,  String fullName,  TaskRole role,  String? phone)?  $default,) {final _that = this;
switch (_that) {
case _CrewMember() when $default != null:
return $default(_that.workerId,_that.fullName,_that.role,_that.phone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CrewMember implements CrewMember {
  const _CrewMember({required this.workerId, required this.fullName, required this.role, this.phone});
  factory _CrewMember.fromJson(Map<String, dynamic> json) => _$CrewMemberFromJson(json);

@override final  String workerId;
@override final  String fullName;
@override final  TaskRole role;
@override final  String? phone;

/// Create a copy of CrewMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CrewMemberCopyWith<_CrewMember> get copyWith => __$CrewMemberCopyWithImpl<_CrewMember>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CrewMemberToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CrewMember&&(identical(other.workerId, workerId) || other.workerId == workerId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.role, role) || other.role == role)&&(identical(other.phone, phone) || other.phone == phone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,workerId,fullName,role,phone);
}

@override
String toString() {
    return 'CrewMember(workerId: $workerId, fullName: $fullName, role: $role, phone: $phone)';
}


}

/// @nodoc
abstract mixin class _$CrewMemberCopyWith<$Res> implements $CrewMemberCopyWith<$Res> {
  factory _$CrewMemberCopyWith(_CrewMember value, $Res Function(_CrewMember) _then) = __$CrewMemberCopyWithImpl;
@override @useResult
$Res call({
 String workerId, String fullName, TaskRole role, String? phone
});




}
/// @nodoc
class __$CrewMemberCopyWithImpl<$Res>
    implements _$CrewMemberCopyWith<$Res> {
  __$CrewMemberCopyWithImpl(this._self, this._then);

  final _CrewMember _self;
  final $Res Function(_CrewMember) _then;

/// Create a copy of CrewMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workerId = null,Object? fullName = null,Object? role = null,Object? phone = freezed,}) {
  return _then(_CrewMember(
workerId: null == workerId ? _self.workerId : workerId // ignore: cast_nullable_to_non_nullable
as String,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as TaskRole,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
