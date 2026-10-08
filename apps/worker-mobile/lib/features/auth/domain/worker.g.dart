// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Worker _$WorkerFromJson(Map<String, dynamic> json) => _Worker(
  id: json['id'] as String,
  fullName: json['fullName'] as String,
  employeeCode: json['employeeCode'] as String,
  phone: json['phone'] as String,
  companyName: json['companyName'] as String? ?? 'NEST',
  locale: json['locale'] as String? ?? 'hy',
  mustChangePassword: json['mustChangePassword'] as bool? ?? false,
);

Map<String, dynamic> _$WorkerToJson(_Worker instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'employeeCode': instance.employeeCode,
  'phone': instance.phone,
  'companyName': instance.companyName,
  'locale': instance.locale,
  'mustChangePassword': instance.mustChangePassword,
};
