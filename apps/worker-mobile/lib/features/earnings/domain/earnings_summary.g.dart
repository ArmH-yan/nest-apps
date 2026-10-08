// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EarningsSummary _$EarningsSummaryFromJson(Map<String, dynamic> json) =>
    _EarningsSummary(
      year: (json['year'] as num).toInt(),
      month: (json['month'] as num).toInt(),
      approvedTasks: (json['approvedTasks'] as num).toInt(),
      approvedAmount: json['approvedAmount'] as String,
      currency: json['currency'] as String? ?? 'AMD',
    );

Map<String, dynamic> _$EarningsSummaryToJson(_EarningsSummary instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'approvedTasks': instance.approvedTasks,
      'approvedAmount': instance.approvedAmount,
      'currency': instance.currency,
    };
