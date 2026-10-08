import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/theme/app_colors.dart';

import 'support/app_harness.dart';

void main() {
  testWidgets('starts on Login, signs in with mock credentials, shows tasks', (
    tester,
  ) async {
    final app = await AppHarness.create();
    await app.pump(tester);

    expect(find.text('Log In'), findsOneWidget);
    final context = tester.element(find.text('Log In'));
    expect(Theme.of(context).colorScheme.primary, AppColors.primary);

    await app.login(tester);

    expect(find.text('My Tasks'), findsOneWidget);
    expect(find.text('Install Safety Net – Building A'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('READY TO START'), findsWidgets);
    await app.dispose(tester);
  });

  testWidgets('wrong password shows a friendly error, not an exception', (
    tester,
  ) async {
    final app = await AppHarness.create();
    await app.pump(tester);

    await tester.enterText(
      find.byKey(const Key('login.phone')),
      '+37491000007',
    );
    await tester.enterText(find.byKey(const Key('login.password')), 'nope');
    await tester.tap(find.byKey(const Key('login.submit')));
    await app.settle(tester);

    expect(find.text('Wrong phone number or password.'), findsOneWidget);
    await app.dispose(tester);
  });

  testWidgets('Armenian and Russian translations load', (tester) async {
    for (final (code, button) in [('hy', 'Մուտք'), ('ru', 'Войти')]) {
      final app = await AppHarness.create(prefs: {'settings.locale': code});
      await app.pump(tester);

      expect(find.text(button), findsOneWidget, reason: code);
      await app.dispose(tester);
    }
  });
}
