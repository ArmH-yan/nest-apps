import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/location/location_service.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/ui/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/common.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_providers.dart';
import '../domain/location_check.dart';
import '../domain/location_verification.dart';
import '../domain/task_state_machine.dart';

sealed class _VerifyState {
  const _VerifyState();
}

class _Checking extends _VerifyState {
  const _Checking();
}

class _Result extends _VerifyState {
  const _Result(this.result, this.check);

  final LocationVerificationResult result;
  final LocationCheck check;
}

class _Failed extends _VerifyState {
  const _Failed(this.failure);

  final LocationFailure failure;
}

/// GPS verification (WORKER_APP_SPEC "GPS verification"). All GPS logic is in
/// WorkActions / LocationService; this screen only renders states.
class VerifyLocationScreen extends ConsumerStatefulWidget {
  const VerifyLocationScreen({super.key, required this.taskId});

  final String taskId;

  @override
  ConsumerState<VerifyLocationScreen> createState() =>
      _VerifyLocationScreenState();
}

class _VerifyLocationScreenState extends ConsumerState<VerifyLocationScreen> {
  _VerifyState _state = const _Checking();
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<Task?> _task() =>
      ref.read(taskRepositoryProvider).getTask(widget.taskId);

  Future<void> _check() async {
    setState(() => _state = const _Checking());
    final task = await _task();
    if (task == null || !mounted) return;
    try {
      final (result, check) = await ref
          .read(workActionsProvider)
          .verifyLocation(task);
      if (mounted) setState(() => _state = _Result(result, check));
    } on LocationException catch (e) {
      if (mounted) setState(() => _state = _Failed(e.failure));
    } on Object {
      if (mounted) {
        setState(() => _state = const _Failed(LocationFailure.unknown));
      }
    }
  }

  Future<void> _start(LocationCheck check) async {
    final task = await _task();
    if (task == null || !mounted) return;
    setState(() => _starting = true);
    try {
      await ref.read(workActionsProvider).startWork(task, check);
      if (mounted) context.go('/work');
    } on TaskActionException catch (e) {
      if (mounted) {
        showMessage(
          context,
          context.l10n.actionError(
            e.error,
            task,
            ref.read(taskConfigProvider).startWindowMinutesBefore,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final task = ref.watch(taskViewProvider(widget.taskId)).value?.task;
    final location = ref.read(locationServiceProvider);

    final Widget body = switch (_state) {
      _Checking() => LoadingState(message: l10n.checkingLocation),
      _Failed(:final failure) => _StateCard(
        icon: failure == LocationFailure.servicesDisabled
            ? Icons.location_disabled
            : Icons.location_off,
        color: AppColors.error,
        title: l10n.locationFailure(failure),
        actions: [
          if (failure == LocationFailure.servicesDisabled)
            SecondaryButton(
              label: l10n.openLocationSettings,
              onPressed: location.openLocationSettings,
            ),
          if (failure == LocationFailure.permissionDeniedForever)
            SecondaryButton(
              label: l10n.openSettings,
              onPressed: location.openAppSettings,
            ),
          PrimaryButton(
            label: failure == LocationFailure.permissionDenied
                ? l10n.allowLocation
                : l10n.tryAgain,
            onPressed: _check,
          ),
        ],
      ),
      _Result(:final result, :final check) => switch (result.outcome) {
        VerificationOutcome.verified => _StateCard(
          icon: Icons.check_circle,
          color: AppColors.success,
          title: l10n.locationVerified,
          body: l10n.atWorkLocation,
          rows: [
            InfoRow(
              label: l10n.distance,
              value: l10n.metersValue(result.distanceMeters.toStringAsFixed(0)),
            ),
            if (task != null)
              InfoRow(label: l10n.workLocation, value: task.siteName),
            InfoRow(
              label: l10n.gpsAccuracy,
              value:
                  '± ${l10n.metersValue(result.accuracyMeters.toStringAsFixed(0))}',
            ),
          ],
          actions: [
            PrimaryButton(
              key: const Key('verify.start'),
              icon: Icons.play_arrow_rounded,
              label: l10n.startWorkingTimer,
              loading: _starting,
              color: AppColors.success,
              onPressed: () => _start(check),
            ),
          ],
        ),
        VerificationOutcome.outside => _StateCard(
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          title: l10n.outsideTitle,
          body: l10n.outsideBody,
          rows: [
            InfoRow(
              label: l10n.distance,
              value: l10n.metersValue(result.distanceMeters.toStringAsFixed(0)),
            ),
            InfoRow(
              label: l10n.workRadius,
              value: l10n.allowedRadius(result.radiusMeters.toStringAsFixed(0)),
            ),
          ],
          actions: [
            // stays visible but disabled outside the work area
            PrimaryButton(
              icon: Icons.play_arrow_rounded,
              label: l10n.startWorkingTimer,
              onPressed: null,
            ),
            SecondaryButton(label: l10n.tryAgain, onPressed: _check),
          ],
        ),
        VerificationOutcome.lowAccuracy => _StateCard(
          icon: Icons.gps_not_fixed,
          color: AppColors.warning,
          title: l10n.lowAccuracyTitle,
          body: l10n.lowAccuracyBody,
          rows: [
            InfoRow(
              label: l10n.gpsAccuracy,
              value:
                  '± ${l10n.metersValue(result.accuracyMeters.toStringAsFixed(0))}',
            ),
          ],
          actions: [PrimaryButton(label: l10n.tryAgain, onPressed: _check)],
        ),
      },
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyTitle)),
      body: SafeArea(child: body),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.color,
    required this.title,
    this.body,
    this.rows = const [],
    this.actions = const [],
  });

  final IconData icon;
  final Color color;
  final String title;
  final String? body;
  final List<Widget> rows;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Icon(icon, size: 96, color: color),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(color: color),
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 16),
          CardSection(children: rows),
        ],
        const SizedBox(height: 16),
        for (final a in actions) ...[a, const SizedBox(height: 12)],
      ],
    );
  }
}
