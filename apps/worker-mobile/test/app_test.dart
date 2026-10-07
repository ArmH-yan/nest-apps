import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/app.dart';
import 'package:nest_worker/core/theme/app_colors.dart';

void main() {
  testWidgets('app boots with theme, router and English localization', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: NestWorkerApp()));
    await tester.pumpAndSettle();

    expect(find.text('NEST Worker'), findsOneWidget);
    expect(find.text('Setup complete'), findsOneWidget);

    final context = tester.element(find.text('Setup complete'));
    expect(Theme.of(context).colorScheme.primary, AppColors.primary);
    expect(Theme.of(context).useMaterial3, isTrue);
  });

  testWidgets('Armenian and Russian translations load', (tester) async {
    for (final (locale, headline) in [
      (const Locale('hy'), 'Կարգավորումն ավարտված է'),
      (const Locale('ru'), 'Настройка завершена'),
    ]) {
      tester.platformDispatcher.localesTestValue = [locale];
      await tester.pumpWidget(
        ProviderScope(key: UniqueKey(), child: const NestWorkerApp()),
      );
      await tester.pumpAndSettle();

      expect(find.text(headline), findsOneWidget);
    }
    tester.platformDispatcher.clearLocalesTestValue();
  });
}
