import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/api/mock_nest_api.dart';
import 'package:nest_worker/core/network/api_exception.dart';
import 'package:nest_worker/core/time/clock.dart';
import 'package:nest_worker/core/time/yerevan_time.dart';
import 'package:nest_worker/core/ui/money_format.dart';
import 'package:nest_worker/features/earnings/data/earnings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('formatMoney', () {
    test('groups thousands and drops a zero fraction', () {
      expect(formatMoney('80000.00'), '80 000 ֏');
      expect(formatMoney('1250000.00'), '1 250 000 ֏');
      expect(formatMoney('0.00'), '0 ֏');
      expect(formatMoney('950'), '950 ֏');
    });

    test('keeps a non-zero fraction and the sign', () {
      expect(formatMoney('1500.5'), '1 500.50 ֏');
      expect(formatMoney('-2000.00'), '-2 000 ֏');
      expect(formatMoney('10.00', currency: 'USD'), '10 USD');
    });
  });

  group('EarningsRepository', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    EarningsRepository repo(FixedClock clock, MockNestApi api) =>
        EarningsRepository(api: api, clock: clock, prefs: prefs);

    test('counts only approved tasks in the current Yerevan month', () async {
      // Mock approvals: days -1, -3, -6 are in October; -10, -20, -40 are not.
      final clock = FixedClock(YerevanTime.at(2026, 10, 7, 9, 5));
      final api = MockNestApi(clock: clock)..scenario.latency = Duration.zero;

      final summary = await repo(clock, api).refresh();

      expect(summary.year, 2026);
      expect(summary.month, 10);
      expect(summary.approvedTasks, 3);
      expect(summary.approvedAmount, '80000.00');
      expect(summary.currency, 'AMD');
    });

    test('the cache serves the same month offline, not a past one', () async {
      final clock = FixedClock(YerevanTime.at(2026, 10, 7, 9, 5));
      final api = MockNestApi(clock: clock)..scenario.latency = Duration.zero;
      final earnings = repo(clock, api);

      expect(earnings.cached(), isNull);
      await earnings.refresh();

      api.scenario.offline = true;
      await expectLater(earnings.refresh(), throwsA(isA<ApiException>()));
      expect(earnings.cached()?.approvedTasks, 3);

      // 1 November 00:30 Yerevan is still 31 October in UTC: the month
      // boundary is Yerevan's.
      final november = FixedClock(YerevanTime.at(2026, 11, 1, 0, 30));
      expect(repo(november, api).cached(), isNull);
    });
  });
}
