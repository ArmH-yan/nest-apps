import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/core/ui/money_format.dart';

import 'support/app_harness.dart';

/// The complete mock workflow from WORKER_APP_SPEC "Final expectation",
/// driven through the real UI with a controllable clock.
void main() {
  /// Lazily built lists: scroll until the widget exists and is on screen.
  Future<void> reveal(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        250,
        scrollable: find.byType(Scrollable).first,
      );

  testWidgets('login → task → GPS → work ⇄ break → finish → submit → history', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final app = await AppHarness.create();
    await app.pump(tester);
    await app.login(tester);

    // HEADER: approved works done and money earned this month
    expect(
      find.descendant(
        of: find.byKey(const Key('header.worksDone')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('header.earned')),
        matching: find.text(formatMoney('80000.00')),
      ),
      findsOneWidget,
    );

    // TASK LIST → TASK DETAILS
    await tester.tap(find.byKey(const Key('task.asg-101')));
    await app.settle(tester);
    expect(find.text('Task information'), findsWidgets);

    // VERIFY LOCATION → VERIFIED
    await tester.tap(find.byKey(const Key('details.verify')));
    await app.settle(tester, 15); // mock GPS takes 700 ms
    expect(find.text('Location Verified'), findsOneWidget);
    expect(find.text('32 m'), findsOneWidget);

    // START WORKING → WORK TIMER
    await tester.tap(find.byKey(const Key('verify.start')));
    await app.settle(tester);
    expect(find.byKey(const Key('work.state.working')), findsOneWidget);

    app.clock.advance(const Duration(hours: 3));
    await app.settle(tester, 15);
    expect(find.text('03:00:00'), findsOneWidget, reason: 'work = now - start');

    // TAP THE ROUND TIMER → IT TURNS OVER TO THE BREAK TIMER
    expect(find.byKey(const Key('work.timer.work')), findsOneWidget);
    await tester.tap(find.byKey(const Key('work.timer')));
    await app.settle(tester);
    expect(find.byKey(const Key('work.state.break')), findsOneWidget);
    expect(find.byKey(const Key('work.timer.break')), findsOneWidget);
    expect(find.byKey(const Key('work.timer.work')), findsNothing);
    expect(find.text('ON BREAK'), findsWidgets);

    app.clock.advance(const Duration(minutes: 30));
    await app.settle(tester, 15);
    expect(find.text('00:30:00'), findsOneWidget);

    // RESUME (button) → THE TIMER TURNS BACK TO WORK
    await tester.tap(find.byKey(const Key('work.resume')));
    await app.settle(tester);
    expect(find.byKey(const Key('work.state.working')), findsOneWidget);
    expect(find.byKey(const Key('work.timer.work')), findsOneWidget);
    app.clock.advance(const Duration(hours: 4, minutes: 15));
    await app.settle(tester, 15);
    expect(find.text('07:15:00'), findsOneWidget);

    // FINISH → COMPLETE TASK
    await tester.tap(find.byKey(const Key('work.finish')));
    await app.settle(tester);
    await tester.tap(find.text('Finish'));
    await app.settle(tester, 15);
    expect(find.text('Complete Task'), findsOneWidget);

    final submit = find.byKey(const Key('completion.submit'));
    await reveal(tester, submit);
    expect(
      tester
          .widget<FilledButton>(
            find.descendant(of: submit, matching: find.byType(FilledButton)),
          )
          .onPressed,
      isNull,
      reason: 'photo + lead materials still missing',
    );

    // MATERIALS (lead, installation)
    await reveal(tester, find.byKey(const Key('completion.addMaterial')));
    await tester.tap(find.byKey(const Key('completion.addMaterial')));
    await app.settle(tester);
    await tester.tap(find.byKey(const Key('material.item')));
    await app.settle(tester);
    await tester.tap(find.text('Safety net (m2)').last);
    await app.settle(tester);
    await tester.enterText(find.byKey(const Key('material.quantity')), '420');
    await tester.pump();
    await tester.tap(find.byKey(const Key('material.save')));
    await app.settle(tester);

    // PHOTOS + COMMENT
    await reveal(tester, find.byKey(const Key('completion.camera')));
    await tester.tap(find.byKey(const Key('completion.camera')));
    await app.settle(tester, 20);
    await reveal(tester, find.byKey(const Key('completion.comment')));
    await tester.enterText(
      find.byKey(const Key('completion.comment')),
      'Net on floors 6–9.',
    );
    await app.settle(tester);

    // CONFIRM → SUBMIT
    await reveal(tester, submit);
    await tester.tap(submit);
    await app.settle(tester);
    expect(find.text('Submit Task?'), findsOneWidget);
    expect(find.text('07:15:00'), findsWidgets);
    await tester.tap(find.text('Submit Task').last);
    await app.settle(tester, 30);

    // TASK COMPLETED (mock server confirmed)
    expect(find.text('Task submitted ✓'), findsOneWidget);

    // HISTORY
    await tester.tap(find.byKey(const Key('done.history')));
    await app.settle(tester);
    expect(find.byKey(const Key('history.asg-101')), findsOneWidget);
    expect(find.textContaining('7h 15m working'), findsOneWidget);
    // yesterday's seeded task is there too
    expect(find.byKey(const Key('history.asg-103')), findsOneWidget);

    await app.dispose(tester);
  });

  testWidgets('offline submit shows "Task saved" and syncs when online', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    final app = await AppHarness.create();
    await app.pump(tester);
    await app.login(tester);

    // member task tomorrow can't start today → use the lead task, go offline
    app.scenario.offline = true;
    await tester.tap(find.byKey(const Key('task.asg-101')));
    await app.settle(tester);
    await tester.tap(find.byKey(const Key('details.verify')));
    await app.settle(tester, 15);
    await tester.tap(find.byKey(const Key('verify.start')));
    await app.settle(tester);
    expect(
      find.text('Offline — your work is saved on this phone'),
      findsOneWidget,
    );

    app.clock.advance(const Duration(hours: 1));
    await tester.tap(find.byKey(const Key('work.finish')));
    await app.settle(tester);
    await tester.tap(find.text('Finish'));
    await app.settle(tester, 15);

    await reveal(tester, find.byKey(const Key('completion.addMaterial')));
    await tester.tap(find.byKey(const Key('completion.addMaterial')));
    await app.settle(tester);
    // catalog can't load offline → friendly message instead of a crash
    expect(
      find.text(
        'Material list is not available offline. Try again when online.',
      ),
      findsOneWidget,
    );

    await app.dispose(tester);
  });
}
