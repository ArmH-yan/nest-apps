import 'package:flutter_test/flutter_test.dart';
import 'package:nest_worker/features/completion/domain/completion_models.dart';
import 'package:nest_worker/features/completion/domain/completion_validator.dart';
import 'package:nest_worker/features/tasks/domain/task.dart';
import 'package:nest_worker/features/tasks/domain/task_config.dart';

import '../../support/fixtures.dart';

TaskPhoto photo(String id) => TaskPhoto(
  id: id,
  taskId: 'task-1',
  localPath: '/p/$id.jpg',
  takenAt: nineAmYerevan,
);

MaterialEntry material(double qty) => MaterialEntry(
  id: 'm1',
  taskId: 'task-1',
  catalogItemId: 'net-m2',
  itemName: 'Safety net',
  unit: 'm2',
  quantity: qty,
  movement: MaterialMovement.installed,
);

void main() {
  const config = TaskConfig(minCompletionPhotos: 1);

  test('photo requirement: at least minCompletionPhotos', () {
    final member = buildTask(role: TaskRole.member);

    expect(
      CompletionValidator.validate(
        task: member,
        config: config,
        photos: [],
        materials: [],
      ),
      [CompletionIssue.notEnoughPhotos],
    );
    expect(
      CompletionValidator.validate(
        task: member,
        config: config,
        photos: [photo('a')],
        materials: [],
      ),
      isEmpty,
    );
    expect(
      CompletionValidator.validate(
        task: member,
        config: const TaskConfig(minCompletionPhotos: 2),
        photos: [photo('a')],
        materials: [],
      ),
      [CompletionIssue.notEnoughPhotos],
    );
  });

  test('installation / dismantling lead must record materials', () {
    for (final type in [JobType.installation, JobType.dismantling]) {
      final lead = buildTask(jobType: type);
      expect(
        CompletionValidator.validate(
          task: lead,
          config: config,
          photos: [photo('a')],
          materials: [],
        ),
        [CompletionIssue.materialsRequired],
      );
      expect(
        CompletionValidator.validate(
          task: lead,
          config: config,
          photos: [photo('a')],
          materials: [material(0)],
        ),
        [CompletionIssue.materialsRequired],
        reason: 'zero quantities do not count',
      );
      expect(
        CompletionValidator.validate(
          task: lead,
          config: config,
          photos: [photo('a')],
          materials: [material(420)],
        ),
        isEmpty,
      );
    }
  });

  test('members and non-installation leads skip materials', () {
    expect(buildTask(role: TaskRole.member).materialsRequired, isFalse);
    expect(buildTask(jobType: JobType.inspection).materialsRequired, isFalse);
    expect(buildTask(jobType: JobType.inspection).leadRecordsMaterials, isTrue);
    expect(buildTask(jobType: JobType.survey).leadRecordsMaterials, isFalse);
  });
}
