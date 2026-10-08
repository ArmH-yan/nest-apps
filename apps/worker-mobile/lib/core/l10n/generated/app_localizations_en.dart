// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NEST Worker';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get open => 'Open';

  @override
  String get tryAgain => 'Try again';

  @override
  String get fieldRequired => 'Required';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navWork => 'Work';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginSubtitle => 'Sign in to see your tasks';

  @override
  String get phoneLabel => 'Phone number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Log In';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordBody =>
      'Contact your manager to reset your password.';

  @override
  String get changePasswordTitle => 'Set a new password';

  @override
  String get changePasswordBody =>
      'For your security, choose a new password before you start.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get newPassword => 'New password';

  @override
  String get repeatPassword => 'Repeat new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'At least 8 characters';

  @override
  String get savePassword => 'Save password';

  @override
  String get myTasks => 'My Tasks';

  @override
  String get sectionToday => 'TODAY';

  @override
  String get sectionUpcoming => 'UPCOMING';

  @override
  String get sectionYesterday => 'YESTERDAY';

  @override
  String get emptyTasksTitle => 'No tasks assigned';

  @override
  String get emptyTasksBody => 'New tasks from your manager will appear here.';

  @override
  String lastUpdated(String time) {
    return 'Last updated $time';
  }

  @override
  String activeTaskBanner(String title) {
    return 'You are working on: $title';
  }

  @override
  String get leadBadge => 'LEAD';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get statusUpcoming => 'UPCOMING';

  @override
  String get statusToday => 'READY TO START';

  @override
  String get statusInProgress => 'WORKING';

  @override
  String get statusOnBreak => 'ON BREAK';

  @override
  String get statusWaiting => 'WAITING TO SEND';

  @override
  String get statusSyncFailed => 'SYNC FAILED';

  @override
  String get statusCompleted => 'COMPLETED';

  @override
  String get statusCancelled => 'CANCELLED';

  @override
  String get jobSurvey => 'Site survey';

  @override
  String get jobInstallation => 'Installation';

  @override
  String get jobInspection => 'Inspection';

  @override
  String get jobMaintenance => 'Maintenance';

  @override
  String get jobDismantling => 'Dismantling';

  @override
  String get taskInformation => 'Task information';

  @override
  String get project => 'Project';

  @override
  String get customer => 'Customer';

  @override
  String get instructions => 'Instructions';

  @override
  String get scheduledDate => 'Date';

  @override
  String get scheduledTime => 'Time';

  @override
  String get yourRole => 'Your role';

  @override
  String get roleLead => 'Crew lead';

  @override
  String get roleMember => 'Crew member';

  @override
  String get crew => 'Crew';

  @override
  String get siteContact => 'Site contact';

  @override
  String get workLocation => 'Work location';

  @override
  String get address => 'Address';

  @override
  String get accessNotes => 'Access notes';

  @override
  String get coordinates => 'Coordinates';

  @override
  String get workRadius => 'Work radius';

  @override
  String metersValue(String meters) {
    return '$meters m';
  }

  @override
  String get currentDistance => 'Your distance';

  @override
  String get navigate => 'Navigate';

  @override
  String get verifyMyLocation => 'Verify My Location';

  @override
  String get openWorkScreen => 'Open work screen';

  @override
  String get taskNotFound => 'This task is no longer available.';

  @override
  String get errNotScheduledToday => 'This task is not scheduled for today.';

  @override
  String errTooEarly(String time) {
    return 'You can start this task from $time.';
  }

  @override
  String get errAnotherTaskActive => 'Finish your active task first.';

  @override
  String get errAlreadyCompleted => 'This task is already completed.';

  @override
  String get errCancelled => 'This task was cancelled by your manager.';

  @override
  String get errLocationNotVerified => 'Verify your location first.';

  @override
  String get errInvalidAction => 'This action is not available right now.';

  @override
  String get verifyTitle => 'Location check';

  @override
  String get checkingLocation => 'Checking your location…';

  @override
  String get locationVerified => 'Location Verified';

  @override
  String get atWorkLocation => 'You are at the work location.';

  @override
  String get distance => 'Distance';

  @override
  String get gpsAccuracy => 'GPS accuracy';

  @override
  String get outsideTitle => 'You\'re outside the work area';

  @override
  String get outsideBody =>
      'Move closer to the assigned work location to start working.';

  @override
  String allowedRadius(String meters) {
    return 'Allowed: $meters m';
  }

  @override
  String get lowAccuracyTitle => 'GPS signal is weak';

  @override
  String get lowAccuracyBody => 'Move to an open area and try again.';

  @override
  String get permissionDeniedTitle =>
      'Location permission is required to start working.';

  @override
  String get allowLocation => 'Allow location';

  @override
  String get openSettings => 'Open settings';

  @override
  String get servicesDisabledTitle => 'Location services are disabled.';

  @override
  String get openLocationSettings => 'Open location settings';

  @override
  String get locationTimeout => 'Could not get your location. Try again.';

  @override
  String get startWorkingTimer => 'Start Working Timer';

  @override
  String get noActiveTaskTitle => 'No active task';

  @override
  String get noActiveTaskBody => 'Start a task from My Tasks.';

  @override
  String get workTime => 'WORK TIME';

  @override
  String get breakTime => 'BREAK TIME';

  @override
  String get startedLabel => 'STARTED';

  @override
  String get locationLabel => 'LOCATION';

  @override
  String get verified => 'Verified';

  @override
  String get stopAndStartBreak => 'STOP & START BREAK';

  @override
  String get resumeWorking => 'RESUME WORKING';

  @override
  String get finishTask => 'FINISH TASK';

  @override
  String get tapToBreak => 'Tap to take a break';

  @override
  String get tapToResume => 'Tap to resume work';

  @override
  String get earningsTitle => 'This month';

  @override
  String get worksDoneThisMonth => 'Works done (approved)';

  @override
  String get earnedThisMonth => 'Earned (approved)';

  @override
  String get earningsApprovedOnly =>
      'Only tasks approved by your manager are counted. A submitted task is added here after approval.';

  @override
  String get earningsUnavailable =>
      'Not loaded yet. Pull down on My Tasks to refresh when you are online.';

  @override
  String get finishConfirmTitle => 'Finish this task?';

  @override
  String get finishConfirmBody =>
      'Next you will add photos and submit. The timer keeps running until you submit.';

  @override
  String get finish => 'Finish';

  @override
  String get syncAllSent => 'All changes sent';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items waiting to send',
      one: '1 item waiting to send',
    );
    return '$_temp0';
  }

  @override
  String get syncFailedBanner => 'Sending failed';

  @override
  String get syncOffline => 'Offline — your work is saved on this phone';

  @override
  String get syncing => 'Sending…';

  @override
  String get syncNow => 'Sync now';

  @override
  String get completeTask => 'Complete Task';

  @override
  String get summary => 'Summary';

  @override
  String get taskLabel => 'Task';

  @override
  String get totalDuration => 'Total duration';

  @override
  String get completionTime => 'Completion time';

  @override
  String get materialsTitle => 'Materials';

  @override
  String get materialsInstalledHint => 'What did you install?';

  @override
  String get materialsDismantleHint =>
      'Enter what you brought back. Differences are recorded as lost.';

  @override
  String get materialsInspectionHint => 'Record damaged items, if any.';

  @override
  String get addMaterial => 'Add material';

  @override
  String get item => 'Item';

  @override
  String get quantity => 'Quantity';

  @override
  String expectedQuantity(String quantity) {
    return 'Expected: $quantity';
  }

  @override
  String get materialsRequired => 'Add at least one material.';

  @override
  String get materialsUnavailable =>
      'Material list is not available offline. Try again when online.';

  @override
  String get checklistComingSoon =>
      'Inspection checklist will be added in a later version.';

  @override
  String get photosTitle => 'Photos of Completed Work';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose From Gallery';

  @override
  String photosRequired(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add at least $count photos.',
      one: 'Add at least 1 photo.',
    );
    return '$_temp0';
  }

  @override
  String get uploadFailed => 'Upload failed';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get commentTitle => 'Comment (optional)';

  @override
  String get commentHint => 'Anything your manager should know';

  @override
  String get submitTask => 'Submit Task';

  @override
  String get submitConfirmTitle => 'Submit Task?';

  @override
  String get photos => 'Photos';

  @override
  String get materials => 'Materials';

  @override
  String itemsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get movementInstalled => 'Installed';

  @override
  String get movementRetrieved => 'Retrieved';

  @override
  String get movementDamaged => 'Damaged';

  @override
  String get movementLost => 'Lost';

  @override
  String get movementAdjustment => 'Adjustment';

  @override
  String get submittedTitle => 'Task submitted ✓';

  @override
  String get submittedBody => 'Your manager can see it now.';

  @override
  String get savedOfflineTitle => 'Task saved';

  @override
  String get savedOfflineBody =>
      'It will be sent automatically when you\'re online.';

  @override
  String get goToHistory => 'Go to History';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmptyTitle => 'No completed tasks yet';

  @override
  String get historyEmptyBody => 'Submitted tasks appear here.';

  @override
  String workingDuration(String duration) {
    return '$duration working';
  }

  @override
  String completedAtTime(String time) {
    return 'Completed $time';
  }

  @override
  String get workAndBreaks => 'Work and breaks';

  @override
  String get sessionWork => 'Work';

  @override
  String get sessionBreak => 'Break';

  @override
  String get completionLocation => 'Completion location';

  @override
  String get comment => 'Comment';

  @override
  String get notRecorded => 'Not recorded';

  @override
  String hoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get employeeId => 'Employee ID';

  @override
  String get phone => 'Phone';

  @override
  String get company => 'Company';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get locationPermission => 'Location permission';

  @override
  String get cameraPermission => 'Camera permission';

  @override
  String get manageInSettings => 'Manage in system settings';

  @override
  String get language => 'Language';

  @override
  String get languageDevice => 'Device language';

  @override
  String get appVersion => 'App version';

  @override
  String get unsyncedItems => 'Unsynced items';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out?';

  @override
  String logoutUnsyncedBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count unsynced items.',
      one: 'You have 1 unsynced item.',
    );
    return '$_temp0 It stays on this phone and is sent after you log in again.';
  }

  @override
  String get developer => 'Developer (dev build)';

  @override
  String get gpsSource => 'GPS source';

  @override
  String get simulateOffline => 'Simulate no internet';

  @override
  String get failNextUpload => 'Fail next photo upload';

  @override
  String get rejectNextCompletion => 'Reject next submission (409)';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get errorNoInternet => 'No internet connection.';

  @override
  String get errorOfflineCached => 'You\'re offline. Showing saved tasks.';

  @override
  String get errorServer => 'Something went wrong on the server.';

  @override
  String get errorGeneric => 'Something went wrong. Try again.';

  @override
  String get errorInvalidCredentials => 'Wrong phone number or password.';

  @override
  String requestId(String id) {
    return 'Request ID: $id';
  }
}
