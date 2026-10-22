import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/features/auth/domain/phone_number.dart';

void main() {
  test('every usual way of typing an Armenian number gives +374XXXXXXXX', () {
    const typed = [
      '+374 91 000 007',
      '+37491000007',
      '091 000 007',
      '091000007',
      '0 91   000   007',
      '  091 000 007 ',
      '(091) 00-00-07',
      '374 91 000 007',
      '00374 91 000 007',
      '+374 091 000 007',
    ];
    for (final t in typed) {
      expect(normalizePhone(t), '+37491000007', reason: t);
    }
  });

  test('other input loses only its separators', () {
    expect(normalizePhone('+1 (415) 555-0100'), '+14155550100');
    expect(normalizePhone('091 000'), '091000');
  });
}
