import 'package:freezed_annotation/freezed_annotation.dart';

part 'earnings_summary.freezed.dart';
part 'earnings_summary.g.dart';

/// Manager-approved work for one calendar month in Yerevan
/// (`GET /worker/earnings?month=YYYY-MM`, ARCHITECTURE §18). Each task pays
/// the fixed `visit_assignments.pay_amount` the manager entered. Only tasks
/// whose timesheet was approved count. The server computes the totals and
/// the app only displays them.
@freezed
abstract class EarningsSummary with _$EarningsSummary {
  const factory EarningsSummary({
    required int year,
    required int month,
    required int approvedTasks,

    /// Decimal string as sent by the API (`numeric(12,2)`), never a double.
    required String approvedAmount,
    @Default('AMD') String currency,
  }) = _EarningsSummary;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) =>
      _$EarningsSummaryFromJson(json);
}
