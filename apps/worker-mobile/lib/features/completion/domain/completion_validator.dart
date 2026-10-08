import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_config.dart';
import 'completion_models.dart';

enum CompletionIssue { notEnoughPhotos, materialsRequired }

/// Rules checked before Submit is enabled. The server re-checks them
/// (ARCHITECTURE §11 completion rules).
abstract final class CompletionValidator {
  static List<CompletionIssue> validate({
    required Task task,
    required TaskConfig config,
    required List<TaskPhoto> photos,
    required List<MaterialEntry> materials,
  }) {
    return [
      if (photos.length < config.minCompletionPhotos)
        CompletionIssue.notEnoughPhotos,
      if (task.materialsRequired &&
          materials.where((m) => m.quantity > 0).isEmpty)
        CompletionIssue.materialsRequired,
    ];
  }
}
