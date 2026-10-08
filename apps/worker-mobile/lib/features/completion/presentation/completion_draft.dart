import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../tasks/domain/task.dart';
import '../../work/domain/location_check.dart';

/// In-progress completion: which task, when the worker pressed Finish, and
/// the background completion GPS fix. Photos/materials are already in the DB.
class CompletionDraft {
  const CompletionDraft({
    required this.taskId,
    required this.finishAt,
    this.completionCheck,
    this.comment = '',
  });

  final String taskId;
  final DateTime finishAt;
  final LocationCheck? completionCheck;
  final String comment;

  CompletionDraft copyWith({LocationCheck? completionCheck, String? comment}) =>
      CompletionDraft(
        taskId: taskId,
        finishAt: finishAt,
        completionCheck: completionCheck ?? this.completionCheck,
        comment: comment ?? this.comment,
      );
}

class CompletionDraftNotifier extends Notifier<CompletionDraft?> {
  @override
  CompletionDraft? build() => null;

  /// Starts the completion flow; takes a non-blocking completion location fix.
  void begin(Task task, DateTime finishAt) {
    state = CompletionDraft(taskId: task.id, finishAt: finishAt);
    unawaited(
      ref
          .read(workActionsProvider)
          .captureInBackground(task, LocationCheckPurpose.completion)
          .then((check) {
            final current = state;
            if (check != null && current?.taskId == task.id) {
              state = current!.copyWith(completionCheck: check);
            }
          }),
    );
  }

  void setComment(String comment) {
    final current = state;
    if (current != null) state = current.copyWith(comment: comment);
  }

  void clear() => state = null;
}

final completionDraftProvider =
    NotifierProvider<CompletionDraftNotifier, CompletionDraft?>(
      CompletionDraftNotifier.new,
    );
