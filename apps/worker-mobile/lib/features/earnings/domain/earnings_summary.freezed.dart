// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'earnings_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EarningsSummary {

 int get year; int get month; int get approvedTasks;/// Decimal string as sent by the API (`numeric(12,2)`), never a double.
 String get approvedAmount; String get currency;
/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EarningsSummaryCopyWith<EarningsSummary> get copyWith => _$EarningsSummaryCopyWithImpl<EarningsSummary>(this as EarningsSummary, _$identity);

  /// Serializes this EarningsSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EarningsSummary;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EarningsSummary&&(identical(other.year, _this.year) || other.year == _this.year)&&(identical(other.month, _this.month) || other.month == _this.month)&&(identical(other.approvedTasks, _this.approvedTasks) || other.approvedTasks == _this.approvedTasks)&&(identical(other.approvedAmount, _this.approvedAmount) || other.approvedAmount == _this.approvedAmount)&&(identical(other.currency, _this.currency) || other.currency == _this.currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EarningsSummary;
  return Object.hash(runtimeType,_this.year,_this.month,_this.approvedTasks,_this.approvedAmount,_this.currency);
}

@override
String toString() {
  final _this = this as EarningsSummary;
  return 'EarningsSummary(year: ${_this.year}, month: ${_this.month}, approvedTasks: ${_this.approvedTasks}, approvedAmount: ${_this.approvedAmount}, currency: ${_this.currency})';
}


}

/// @nodoc
abstract mixin class $EarningsSummaryCopyWith<$Res>  {
  factory $EarningsSummaryCopyWith(EarningsSummary value, $Res Function(EarningsSummary) _then) = _$EarningsSummaryCopyWithImpl;
@useResult
$Res call({
 int year, int month, int approvedTasks, String approvedAmount, String currency
});




}
/// @nodoc
class _$EarningsSummaryCopyWithImpl<$Res>
    implements $EarningsSummaryCopyWith<$Res> {
  _$EarningsSummaryCopyWithImpl(this._self, this._then);

  final EarningsSummary _self;
  final $Res Function(EarningsSummary) _then;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? year = null,Object? month = null,Object? approvedTasks = null,Object? approvedAmount = null,Object? currency = null,}) {
  return _then(EarningsSummary(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,approvedTasks: null == approvedTasks ? _self.approvedTasks : approvedTasks // ignore: cast_nullable_to_non_nullable
as int,approvedAmount: null == approvedAmount ? _self.approvedAmount : approvedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [EarningsSummary].
extension EarningsSummaryPatterns on EarningsSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EarningsSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EarningsSummary value)  $default,){
final _that = this;
switch (_that) {
case _EarningsSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EarningsSummary value)?  $default,){
final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int year,  int month,  int approvedTasks,  String approvedAmount,  String currency)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.year,_that.month,_that.approvedTasks,_that.approvedAmount,_that.currency);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int year,  int month,  int approvedTasks,  String approvedAmount,  String currency)  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary():
return $default(_that.year,_that.month,_that.approvedTasks,_that.approvedAmount,_that.currency);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int year,  int month,  int approvedTasks,  String approvedAmount,  String currency)?  $default,) {final _that = this;
switch (_that) {
case _EarningsSummary() when $default != null:
return $default(_that.year,_that.month,_that.approvedTasks,_that.approvedAmount,_that.currency);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EarningsSummary implements EarningsSummary {
  const _EarningsSummary({required this.year, required this.month, required this.approvedTasks, required this.approvedAmount, this.currency = 'AMD'});
  factory _EarningsSummary.fromJson(Map<String, dynamic> json) => _$EarningsSummaryFromJson(json);

@override final  int year;
@override final  int month;
@override final  int approvedTasks;
/// Decimal string as sent by the API (`numeric(12,2)`), never a double.
@override final  String approvedAmount;
@override@JsonKey() final  String currency;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EarningsSummaryCopyWith<_EarningsSummary> get copyWith => __$EarningsSummaryCopyWithImpl<_EarningsSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EarningsSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EarningsSummary&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.approvedTasks, approvedTasks) || other.approvedTasks == approvedTasks)&&(identical(other.approvedAmount, approvedAmount) || other.approvedAmount == approvedAmount)&&(identical(other.currency, currency) || other.currency == currency));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,year,month,approvedTasks,approvedAmount,currency);
}

@override
String toString() {
    return 'EarningsSummary(year: $year, month: $month, approvedTasks: $approvedTasks, approvedAmount: $approvedAmount, currency: $currency)';
}


}

/// @nodoc
abstract mixin class _$EarningsSummaryCopyWith<$Res> implements $EarningsSummaryCopyWith<$Res> {
  factory _$EarningsSummaryCopyWith(_EarningsSummary value, $Res Function(_EarningsSummary) _then) = __$EarningsSummaryCopyWithImpl;
@override @useResult
$Res call({
 int year, int month, int approvedTasks, String approvedAmount, String currency
});




}
/// @nodoc
class __$EarningsSummaryCopyWithImpl<$Res>
    implements _$EarningsSummaryCopyWith<$Res> {
  __$EarningsSummaryCopyWithImpl(this._self, this._then);

  final _EarningsSummary _self;
  final $Res Function(_EarningsSummary) _then;

/// Create a copy of EarningsSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? year = null,Object? month = null,Object? approvedTasks = null,Object? approvedAmount = null,Object? currency = null,}) {
  return _then(_EarningsSummary(
year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,approvedTasks: null == approvedTasks ? _self.approvedTasks : approvedTasks // ignore: cast_nullable_to_non_nullable
as int,approvedAmount: null == approvedAmount ? _self.approvedAmount : approvedAmount // ignore: cast_nullable_to_non_nullable
as String,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
