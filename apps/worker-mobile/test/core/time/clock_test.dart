import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/time/clock.dart';

void main() {
  test('FixedClock moves only when told to', () {
    final clock = FixedClock(DateTime.utc(2026, 10, 7, 9));

    expect(clock.now(), DateTime.utc(2026, 10, 7, 9));
    clock.advance(const Duration(hours: 2, minutes: 34, seconds: 18));
    expect(clock.now(), DateTime.utc(2026, 10, 7, 11, 34, 18));
  });

  test('clocks always return UTC', () {
    expect(const SystemClock().now().isUtc, isTrue);
    expect(FixedClock(DateTime(2026, 10, 7, 9)).now().isUtc, isTrue);
  });
}
