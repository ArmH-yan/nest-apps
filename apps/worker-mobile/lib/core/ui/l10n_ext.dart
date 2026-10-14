import 'package:flutter/widgets.dart';

import '../../features/completion/domain/completion_models.dart';
import '../../features/tasks/domain/task.dart';
import '../../features/tasks/domain/task_status.dart';
import '../../features/work/domain/task_state_machine.dart';
import '../l10n/generated/app_localizations.dart';
import '../location/location_service.dart';
import '../network/api_exception.dart';
import '../time/yerevan_time.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Every enum / error shown to workers goes through these, so no raw codes
/// or exception text ever reach the UI.
extension StatusLabels on AppLocalizations {
  String status(TaskDisplayStatus s) => switch (s) {
    TaskDisplayStatus.upcoming => statusUpcoming,
    TaskDisplayStatus.today => statusToday,
    TaskDisplayStatus.inProgress => statusInProgress,
    TaskDisplayStatus.onBreak => statusOnBreak,
    TaskDisplayStatus.waitingForSubmission => statusWaiting,
    TaskDisplayStatus.synchronizationFailed => statusSyncFailed,
    TaskDisplayStatus.completed => statusCompleted,
    TaskDisplayStatus.cancelled => statusCancelled,
  };

  String jobType(JobType t) => switch (t) {
    JobType.survey => jobSurvey,
    JobType.installation => jobInstallation,
    JobType.inspection => jobInspection,
    JobType.maintenance => jobMaintenance,
    JobType.dismantling => jobDismantling,
  };

  String movement(MaterialMovement m) => switch (m) {
    MaterialMovement.installed => movementInstalled,
    MaterialMovement.retrieved => movementRetrieved,
    MaterialMovement.damaged => movementDamaged,
    MaterialMovement.lost => movementLost,
    MaterialMovement.adjustment => movementAdjustment,
  };

  String actionError(TaskActionError e, Task task, int startWindowMinutes) =>
      switch (e) {
        TaskActionError.notScheduledToday => errNotScheduledToday,
        TaskActionError.tooEarly => errTooEarly(
          YerevanTime.hm(
            task.scheduledStart.subtract(Duration(minutes: startWindowMinutes)),
          ),
        ),
        TaskActionError.anotherTaskActive => errAnotherTaskActive,
        TaskActionError.alreadyCompleted => errAlreadyCompleted,
        TaskActionError.cancelled => errCancelled,
        TaskActionError.locationNotVerified => errLocationNotVerified,
        TaskActionError.invalidTransition => errInvalidAction,
      };

  String locationFailure(LocationFailure f) => switch (f) {
    LocationFailure.servicesDisabled => servicesDisabledTitle,
    LocationFailure.permissionDenied ||
    LocationFailure.permissionDeniedForever => permissionDeniedTitle,
    LocationFailure.timeout || LocationFailure.unknown => locationTimeout,
  };

  /// Message for any error thrown at the UI boundary.
  String error(Object e) {
    if (e is ApiException) {
      if (e.statusCode == null) return errorNoInternet;
      if (apiError(e) case final message?) return message;
      if (e.statusCode! >= 500) return errorServer;
      return e.message.isNotEmpty ? e.message : errorGeneric;
    }
    if (e is TaskActionException) return errInvalidAction;
    if (e is LocationException) return locationFailure(e.failure);
    return errorGeneric;
  }

  /// Localized text for the server's stable error codes (ARCHITECTURE §18, §32).
  /// null → not a code the worker can act on; callers fall back.
  String? apiError(ApiException e) => switch (e.code) {
    'INVALID_CREDENTIALS' when e.statusCode == 400 => errWrongCurrentPassword,
    'INVALID_CREDENTIALS' => errorInvalidCredentials,
    'TOO_MANY_LOGIN_ATTEMPTS' => errTooManyAttempts,
    'ACCOUNT_DISABLED' => errAccountDisabled,
    'NOT_A_WORKER' => errNotAWorker,
    'PASSWORD_UNCHANGED' => errPasswordUnchanged,
    'TASK_CANCELLED' => errCancelled,
    'TASK_ALREADY_SUBMITTED' => errAlreadyCompleted,
    'START_CHECK_MISSING' => errStartCheckMissing,
    'PHOTOS_NOT_UPLOADED' => errPhotosNotUploaded,
    'NOT_ENOUGH_PHOTOS' => photosRequired(
      (e.details['required'] as num?)?.toInt() ?? 1,
    ),
    'MATERIALS_REQUIRED' => materialsRequired,
    'NOT_CREW_LEAD' => errNotCrewLead,
    'TIME_ENTRY_OVERLAP' => errTimeOverlap,
    'TIME_ENTRY_FINALIZED' ||
    'LOCATION_CHECK_FINALIZED' ||
    'MATERIAL_FINALIZED' => errAlreadySavedDifferently,
    'NOT_FOUND' => taskNotFound,
    _ => null,
  };

  /// "7h 15m"
  String hoursMinutesOf(Duration d) =>
      hoursMinutes(d.inHours, d.inMinutes.remainder(60));
}
