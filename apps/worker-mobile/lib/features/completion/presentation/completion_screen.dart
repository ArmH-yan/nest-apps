import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/media/photo_capture_service.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/time/yerevan_time.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/common.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/domain/task_status.dart';
import '../../tasks/presentation/task_providers.dart';
import '../../work/domain/duration_calculator.dart';
import '../data/completion_service.dart';
import '../domain/completion_models.dart';
import '../domain/completion_validator.dart';
import 'completion_draft.dart';

/// Finish flow: summary → materials (lead) → photos → comment → confirm.
class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  final _comment = TextEditingController();
  bool _submitting = false;
  bool _picking = false;
  List<ExpectedMaterial>? _expected;
  Object? _expectedError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(completionDraftProvider);
    _comment.text = draft?.comment ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExpected());
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _loadExpected() async {
    final draft = ref.read(completionDraftProvider);
    if (draft == null) return;
    final task = await ref.read(taskRepositoryProvider).getTask(draft.taskId);
    if (task == null || task.jobType != JobType.dismantling || !task.isLead) {
      return;
    }
    try {
      final expected = await ref
          .read(taskRepositoryProvider)
          .expectedMaterials(task.id);
      // Pre-fill "retrieved" rows with the expected quantities once.
      final repo = ref.read(completionRepositoryProvider);
      final existing = await repo.watchMaterials(task.id).first;
      if (existing.isEmpty) {
        for (final e in expected) {
          await repo.saveMaterial(
            MaterialEntry(
              id: const Uuid().v4(),
              taskId: task.id,
              catalogItemId: e.item.id,
              itemName: e.item.name,
              unit: e.item.unit,
              quantity: e.quantity,
              movement: MaterialMovement.retrieved,
            ),
          );
        }
      }
      if (mounted) setState(() => _expected = expected);
    } on Object catch (e) {
      if (mounted) setState(() => _expectedError = e);
    }
  }

  Future<void> _addPhotos(Task task, PhotoSource source) async {
    setState(() => _picking = true);
    try {
      await ref
          .read(completionServiceProvider)
          .addPhotos(
            task,
            source,
            location: ref.read(completionDraftProvider)?.completionCheck,
          );
    } on Object catch (e) {
      if (mounted) showMessage(context, context.l10n.error(e));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  /// Dismantling: anything expected but not retrieved is recorded as lost.
  Future<void> _recordLosses(Task task, List<MaterialEntry> materials) async {
    final expected = _expected;
    if (expected == null || task.jobType != JobType.dismantling) return;
    final repo = ref.read(completionRepositoryProvider);
    for (final e in expected) {
      final retrieved = materials
          .where(
            (m) =>
                m.catalogItemId == e.item.id &&
                m.movement == MaterialMovement.retrieved,
          )
          .fold<double>(0, (sum, m) => sum + m.quantity);
      final missing = e.quantity - retrieved;
      final lostId = 'lost-${task.id}-${e.item.id}';
      if (missing > 0) {
        await repo.saveMaterial(
          MaterialEntry(
            id: lostId,
            taskId: task.id,
            catalogItemId: e.item.id,
            itemName: e.item.name,
            unit: e.item.unit,
            quantity: missing,
            movement: MaterialMovement.lost,
          ),
        );
      } else {
        await repo.removeMaterial(lostId);
      }
    }
  }

  Future<void> _submit(
    Task task,
    CompletionDraft draft,
    WorkSummary summary,
    int photoCount,
    List<MaterialEntry> materials,
  ) async {
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l10n.submitConfirmTitle,
      confirmLabel: l10n.submitTask,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoRow(label: l10n.taskLabel, value: task.title),
          InfoRow(label: l10n.workTime, value: formatHms(summary.work)),
          InfoRow(label: l10n.breakTime, value: formatHms(summary.breakTime)),
          InfoRow(label: l10n.photos, value: '$photoCount'),
          if (task.leadRecordsMaterials)
            InfoRow(
              label: l10n.materials,
              value: l10n.itemsCount(materials.length),
            ),
          InfoRow(
            label: l10n.locationLabel,
            value: summary.locationVerified ? '✓ ${l10n.verified}' : '—',
          ),
        ],
      ),
    );
    if (!ok || !mounted) return;

    setState(() => _submitting = true);
    try {
      await _recordLosses(task, materials);
      await ref
          .read(completionServiceProvider)
          .submit(
            task: task,
            worker: ref.read(currentWorkerProvider)!,
            finishAt: draft.finishAt,
            completionCheck: draft.completionCheck,
            comment: _comment.text,
          );
      ref.read(completionDraftProvider.notifier).clear();
      if (mounted) context.go('/work/done/${task.id}');
    } on CompletionValidationException {
      if (mounted) showMessage(context, l10n.errInvalidAction);
    } on Object catch (e) {
      if (mounted) showMessage(context, l10n.error(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = ref.watch(completionDraftProvider);
    final view = draft == null
        ? null
        : ref.watch(taskViewProvider(draft.taskId)).value;

    if (draft == null || view == null || !view.status.isActive) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.completeTask)),
        body: EmptyState(
          icon: Icons.timer_off_outlined,
          title: l10n.noActiveTaskTitle,
          action: SecondaryButton(
            label: l10n.myTasks,
            onPressed: () => context.go('/tasks'),
          ),
        ),
      );
    }

    final task = view.task;
    final config = ref.watch(taskConfigProvider);
    final photos = ref.watch(photosProvider(task.id)).value ?? const [];
    final materials = ref.watch(materialsProvider(task.id)).value ?? const [];
    final checks = ref.watch(locationChecksProvider(task.id)).value ?? const [];
    final totals = DurationCalculator.totals(view.entries, draft.finishAt);
    final summary = WorkSummary(
      work: totals.work,
      breakTime: totals.breakTime,
      locationVerified: checks.any((c) => c.verified),
    );
    final issues = CompletionValidator.validate(
      task: task,
      config: config,
      photos: photos,
      materials: materials,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.completeTask)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CardSection(
            title: l10n.summary,
            children: [
              InfoRow(label: l10n.taskLabel, value: task.title),
              InfoRow(label: l10n.workTime, value: formatHms(summary.work)),
              InfoRow(
                label: l10n.breakTime,
                value: formatHms(summary.breakTime),
              ),
              InfoRow(
                label: l10n.totalDuration,
                value: formatHms(totals.total),
              ),
              InfoRow(
                label: l10n.locationLabel,
                value: summary.locationVerified ? '✓ ${l10n.verified}' : '—',
              ),
              InfoRow(
                label: l10n.completionTime,
                value: YerevanTime.hm(draft.finishAt),
              ),
            ],
          ),
          if (task.leadRecordsMaterials)
            _MaterialsSection(
              task: task,
              materials: materials,
              expected: _expected,
              expectedError: _expectedError,
              missing: issues.contains(CompletionIssue.materialsRequired),
            ),
          CardSection(
            title: l10n.photosTitle,
            children: [
              _PhotoGrid(photos: photos),
              if (issues.contains(CompletionIssue.notEnoughPhotos))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: MessageBanner(
                    message: l10n.photosRequired(config.minCompletionPhotos),
                    color: AppColors.warning,
                    icon: Icons.photo_camera_outlined,
                  ),
                ),
              const SizedBox(height: 12),
              PrimaryButton(
                key: const Key('completion.camera'),
                icon: Icons.photo_camera,
                label: l10n.takePhoto,
                loading: _picking,
                onPressed: () => _addPhotos(task, PhotoSource.camera),
              ),
              const SizedBox(height: 8),
              SecondaryButton(
                key: const Key('completion.gallery'),
                icon: Icons.photo_library_outlined,
                label: l10n.chooseFromGallery,
                onPressed: _picking
                    ? null
                    : () => _addPhotos(task, PhotoSource.gallery),
              ),
            ],
          ),
          CardSection(
            title: l10n.commentTitle,
            children: [
              TextField(
                key: const Key('completion.comment'),
                controller: _comment,
                minLines: 3,
                maxLines: 6,
                onChanged: ref
                    .read(completionDraftProvider.notifier)
                    .setComment,
                decoration: InputDecoration(
                  hintText: l10n.commentHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            key: const Key('completion.submit'),
            icon: Icons.send,
            label: l10n.submitTask,
            color: AppColors.success,
            loading: _submitting,
            onPressed: issues.isEmpty
                ? () => _submit(task, draft, summary, photos.length, materials)
                : null,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class WorkSummary {
  const WorkSummary({
    required this.work,
    required this.breakTime,
    required this.locationVerified,
  });

  final Duration work;
  final Duration breakTime;
  final bool locationVerified;
}

class _PhotoGrid extends ConsumerWidget {
  const _PhotoGrid({required this.photos});

  final List<TaskPhoto> photos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (photos.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final p in photos)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PhotoThumb(photo: p),
                if (p.uploadState == PhotoUploadState.uploading)
                  Container(
                    color: Colors.black38,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: p.progress > 0 ? p.progress : null,
                      color: Colors.white,
                    ),
                  ),
                if (p.uploadState == PhotoUploadState.uploaded)
                  const Positioned(
                    left: 4,
                    bottom: 4,
                    child: Icon(Icons.cloud_done, color: AppColors.success),
                  ),
                if (p.uploadState == PhotoUploadState.failed)
                  Material(
                    color: Colors.black54,
                    child: InkWell(
                      onTap: () =>
                          ref.read(completionServiceProvider).retryUploads(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, color: Colors.white),
                          Text(
                            l10n.uploadFailed,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    tooltip: l10n.removePhoto,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: () =>
                        ref.read(completionServiceProvider).removePhoto(p.id),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Thumbnail from the local file, or a placeholder for server-only photos.
class PhotoThumb extends StatelessWidget {
  const PhotoThumb({super.key, required this.photo});

  final TaskPhoto photo;

  @override
  Widget build(BuildContext context) {
    final path = photo.localPath;
    final placeholder = Container(
      color: AppColors.outline,
      alignment: Alignment.center,
      child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
    );
    if (path == null || !File(path).existsSync()) return placeholder;
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      cacheWidth: 300,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

class _MaterialsSection extends ConsumerWidget {
  const _MaterialsSection({
    required this.task,
    required this.materials,
    required this.expected,
    required this.expectedError,
    required this.missing,
  });

  final Task task;
  final List<MaterialEntry> materials;
  final List<ExpectedMaterial>? expected;
  final Object? expectedError;
  final bool missing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final repo = ref.read(completionRepositoryProvider);
    final hint = switch (task.jobType) {
      JobType.dismantling => l10n.materialsDismantleHint,
      JobType.inspection => l10n.materialsInspectionHint,
      _ => l10n.materialsInstalledHint,
    };
    final visible = materials
        .where((m) => m.movement != MaterialMovement.lost)
        .toList();

    return CardSection(
      title: l10n.materialsTitle,
      children: [
        Text(hint, style: Theme.of(context).textTheme.bodyMedium),
        if (expectedError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MessageBanner(
              message: l10n.materialsUnavailable,
              color: AppColors.warning,
            ),
          ),
        for (final m in visible)
          _MaterialRow(
            entry: m,
            expected: expected
                ?.where((e) => e.item.id == m.catalogItemId)
                .firstOrNull
                ?.quantity,
            onChanged: (q) => repo.saveMaterial(m.copyWith(quantity: q)),
            onRemove: () => repo.removeMaterial(m.id),
          ),
        if (missing)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MessageBanner(
              message: l10n.materialsRequired,
              color: AppColors.warning,
              icon: Icons.inventory_2_outlined,
            ),
          ),
        if (task.jobType == JobType.inspection)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              l10n.checklistComingSoon,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        const SizedBox(height: 12),
        SecondaryButton(
          key: const Key('completion.addMaterial'),
          icon: Icons.add,
          label: l10n.addMaterial,
          onPressed: () => _showAddSheet(context, ref),
        ),
      ],
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    List<CatalogItem> catalog;
    try {
      catalog = await ref.read(taskRepositoryProvider).catalog();
    } on Object {
      if (context.mounted) showMessage(context, l10n.materialsUnavailable);
      return;
    }
    if (!context.mounted) return;
    final movement = switch (task.jobType) {
      JobType.dismantling => MaterialMovement.retrieved,
      JobType.inspection => MaterialMovement.damaged,
      _ => MaterialMovement.installed,
    };
    final entry = await showModalBottomSheet<MaterialEntry>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMaterialSheet(
        taskId: task.id,
        catalog: catalog,
        movement: movement,
        allowMovementChoice: task.jobType == JobType.inspection,
      ),
    );
    if (entry != null) {
      await ref.read(completionRepositoryProvider).saveMaterial(entry);
    }
  }
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({
    required this.entry,
    required this.expected,
    required this.onChanged,
    required this.onRemove,
  });

  final MaterialEntry entry;
  final double? expected;
  final ValueChanged<double> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.itemName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  [
                    l10n.movement(entry.movement),
                    if (expected != null)
                      l10n.expectedQuantity('${_fmt(expected!)} ${entry.unit}'),
                  ].join(' · '),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(
            width: 96,
            child: TextFormField(
              initialValue: _fmt(entry.quantity),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                suffixText: entry.unit,
                isDense: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                final q = double.tryParse(v.replaceAll(',', '.'));
                if (q != null && q >= 0) onChanged(q);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

class _AddMaterialSheet extends StatefulWidget {
  const _AddMaterialSheet({
    required this.taskId,
    required this.catalog,
    required this.movement,
    required this.allowMovementChoice,
  });

  final String taskId;
  final List<CatalogItem> catalog;
  final MaterialMovement movement;
  final bool allowMovementChoice;

  @override
  State<_AddMaterialSheet> createState() => _AddMaterialSheetState();
}

class _AddMaterialSheetState extends State<_AddMaterialSheet> {
  CatalogItem? _item;
  late MaterialMovement _movement = widget.movement;
  final _qty = TextEditingController();

  @override
  void dispose() {
    _qty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final qty = double.tryParse(_qty.text.replaceAll(',', '.'));
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addMaterial, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<CatalogItem>(
            key: const Key('material.item'),
            initialValue: _item,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n.item,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final c in widget.catalog)
                DropdownMenuItem(
                  value: c,
                  child: Text('${c.name} (${c.unit})'),
                ),
            ],
            onChanged: (c) => setState(() => _item = c),
          ),
          if (widget.allowMovementChoice) ...[
            const SizedBox(height: 12),
            SegmentedButton<MaterialMovement>(
              segments: [
                for (final m in [
                  MaterialMovement.damaged,
                  MaterialMovement.adjustment,
                ])
                  ButtonSegment(value: m, label: Text(l10n.movement(m))),
              ],
              selected: {_movement},
              onSelectionChanged: (s) => setState(() => _movement = s.first),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            key: const Key('material.quantity'),
            controller: _qty,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l10n.quantity,
              suffixText: _item?.unit,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            key: const Key('material.save'),
            label: l10n.addMaterial,
            onPressed: _item == null || qty == null || qty <= 0
                ? null
                : () => Navigator.of(context).pop(
                    MaterialEntry(
                      id: const Uuid().v4(),
                      taskId: widget.taskId,
                      catalogItemId: _item!.id,
                      itemName: _item!.name,
                      unit: _item!.unit,
                      quantity: qty,
                      movement: _movement,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
