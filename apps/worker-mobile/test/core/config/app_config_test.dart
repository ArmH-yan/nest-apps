import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/config/app_config.dart';

void main() {
  test('flavor parsing defaults to dev', () {
    expect(AppFlavor.parse('prod'), AppFlavor.prod);
    expect(AppFlavor.parse('dev'), AppFlavor.dev);
    expect(AppFlavor.parse(null), AppFlavor.dev);
  });

  test('defaults without --dart-define: mocks on, emulator host URL', () {
    final config = AppConfig.fromEnvironment();

    expect(config.useMocks, isTrue);
    expect(config.apiBaseUrl, 'http://10.0.2.2:8000');
  });
}
