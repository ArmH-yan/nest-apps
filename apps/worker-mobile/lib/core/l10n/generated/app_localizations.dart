import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hy.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hy'),
    Locale('ru'),
  ];

  /// Application name.
  ///
  /// In en, this message translates to:
  /// **'NEST Worker'**
  String get appTitle;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get navWork;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to see your tasks'**
  String get loginSubtitle;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phoneLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In en, this message translates to:
  /// **'Contact your manager to reset your password.'**
  String get forgotPasswordBody;

  /// No description provided for @changePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordBody.
  ///
  /// In en, this message translates to:
  /// **'For your security, choose a new password before you start.'**
  String get changePasswordBody;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat new password'**
  String get repeatPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters'**
  String get passwordTooShort;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @sectionToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get sectionToday;

  /// No description provided for @sectionUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get sectionUpcoming;

  /// No description provided for @sectionYesterday.
  ///
  /// In en, this message translates to:
  /// **'YESTERDAY'**
  String get sectionYesterday;

  /// No description provided for @emptyTasksTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks assigned'**
  String get emptyTasksTitle;

  /// No description provided for @emptyTasksBody.
  ///
  /// In en, this message translates to:
  /// **'New tasks from your manager will appear here.'**
  String get emptyTasksBody;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated {time}'**
  String lastUpdated(String time);

  /// No description provided for @activeTaskBanner.
  ///
  /// In en, this message translates to:
  /// **'You are working on: {title}'**
  String activeTaskBanner(String title);

  /// No description provided for @leadBadge.
  ///
  /// In en, this message translates to:
  /// **'LEAD'**
  String get leadBadge;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'UPCOMING'**
  String get statusUpcoming;

  /// No description provided for @statusToday.
  ///
  /// In en, this message translates to:
  /// **'READY TO START'**
  String get statusToday;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'WORKING'**
  String get statusInProgress;

  /// No description provided for @statusOnBreak.
  ///
  /// In en, this message translates to:
  /// **'ON BREAK'**
  String get statusOnBreak;

  /// No description provided for @statusWaiting.
  ///
  /// In en, this message translates to:
  /// **'WAITING TO SEND'**
  String get statusWaiting;

  /// No description provided for @statusSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'SYNC FAILED'**
  String get statusSyncFailed;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get statusCompleted;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'CANCELLED'**
  String get statusCancelled;

  /// No description provided for @jobSurvey.
  ///
  /// In en, this message translates to:
  /// **'Site survey'**
  String get jobSurvey;

  /// No description provided for @jobInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation'**
  String get jobInstallation;

  /// No description provided for @jobInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get jobInspection;

  /// No description provided for @jobMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get jobMaintenance;

  /// No description provided for @jobDismantling.
  ///
  /// In en, this message translates to:
  /// **'Dismantling'**
  String get jobDismantling;

  /// No description provided for @taskInformation.
  ///
  /// In en, this message translates to:
  /// **'Task information'**
  String get taskInformation;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @instructions.
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get instructions;

  /// No description provided for @scheduledDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get scheduledDate;

  /// No description provided for @scheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get scheduledTime;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'Your role'**
  String get yourRole;

  /// No description provided for @roleLead.
  ///
  /// In en, this message translates to:
  /// **'Crew lead'**
  String get roleLead;

  /// No description provided for @roleMember.
  ///
  /// In en, this message translates to:
  /// **'Crew member'**
  String get roleMember;

  /// No description provided for @crew.
  ///
  /// In en, this message translates to:
  /// **'Crew'**
  String get crew;

  /// No description provided for @siteContact.
  ///
  /// In en, this message translates to:
  /// **'Site contact'**
  String get siteContact;

  /// No description provided for @workLocation.
  ///
  /// In en, this message translates to:
  /// **'Work location'**
  String get workLocation;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @accessNotes.
  ///
  /// In en, this message translates to:
  /// **'Access notes'**
  String get accessNotes;

  /// No description provided for @coordinates.
  ///
  /// In en, this message translates to:
  /// **'Coordinates'**
  String get coordinates;

  /// No description provided for @workRadius.
  ///
  /// In en, this message translates to:
  /// **'Work radius'**
  String get workRadius;

  /// No description provided for @metersValue.
  ///
  /// In en, this message translates to:
  /// **'{meters} m'**
  String metersValue(String meters);

  /// No description provided for @currentDistance.
  ///
  /// In en, this message translates to:
  /// **'Your distance'**
  String get currentDistance;

  /// No description provided for @navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// No description provided for @verifyMyLocation.
  ///
  /// In en, this message translates to:
  /// **'Verify My Location'**
  String get verifyMyLocation;

  /// No description provided for @openWorkScreen.
  ///
  /// In en, this message translates to:
  /// **'Open work screen'**
  String get openWorkScreen;

  /// No description provided for @taskNotFound.
  ///
  /// In en, this message translates to:
  /// **'This task is no longer available.'**
  String get taskNotFound;

  /// No description provided for @errNotScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'This task is not scheduled for today.'**
  String get errNotScheduledToday;

  /// No description provided for @errTooEarly.
  ///
  /// In en, this message translates to:
  /// **'You can start this task from {time}.'**
  String errTooEarly(String time);

  /// No description provided for @errAnotherTaskActive.
  ///
  /// In en, this message translates to:
  /// **'Finish your active task first.'**
  String get errAnotherTaskActive;

  /// No description provided for @errAlreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'This task is already completed.'**
  String get errAlreadyCompleted;

  /// No description provided for @errCancelled.
  ///
  /// In en, this message translates to:
  /// **'This task was cancelled by your manager.'**
  String get errCancelled;

  /// No description provided for @errLocationNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Verify your location first.'**
  String get errLocationNotVerified;

  /// No description provided for @errInvalidAction.
  ///
  /// In en, this message translates to:
  /// **'This action is not available right now.'**
  String get errInvalidAction;

  /// No description provided for @verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Location check'**
  String get verifyTitle;

  /// No description provided for @checkingLocation.
  ///
  /// In en, this message translates to:
  /// **'Checking your location…'**
  String get checkingLocation;

  /// No description provided for @locationVerified.
  ///
  /// In en, this message translates to:
  /// **'Location Verified'**
  String get locationVerified;

  /// No description provided for @atWorkLocation.
  ///
  /// In en, this message translates to:
  /// **'You are at the work location.'**
  String get atWorkLocation;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @gpsAccuracy.
  ///
  /// In en, this message translates to:
  /// **'GPS accuracy'**
  String get gpsAccuracy;

  /// No description provided for @outsideTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re outside the work area'**
  String get outsideTitle;

  /// No description provided for @outsideBody.
  ///
  /// In en, this message translates to:
  /// **'Move closer to the assigned work location to start working.'**
  String get outsideBody;

  /// No description provided for @allowedRadius.
  ///
  /// In en, this message translates to:
  /// **'Allowed: {meters} m'**
  String allowedRadius(String meters);

  /// No description provided for @lowAccuracyTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS signal is weak'**
  String get lowAccuracyTitle;

  /// No description provided for @lowAccuracyBody.
  ///
  /// In en, this message translates to:
  /// **'Move to an open area and try again.'**
  String get lowAccuracyBody;

  /// No description provided for @permissionDeniedTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to start working.'**
  String get permissionDeniedTitle;

  /// No description provided for @allowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow location'**
  String get allowLocation;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @servicesDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Location services are disabled.'**
  String get servicesDisabledTitle;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open location settings'**
  String get openLocationSettings;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Try again.'**
  String get locationTimeout;

  /// No description provided for @startWorkingTimer.
  ///
  /// In en, this message translates to:
  /// **'Start Working Timer'**
  String get startWorkingTimer;

  /// No description provided for @noActiveTaskTitle.
  ///
  /// In en, this message translates to:
  /// **'No active task'**
  String get noActiveTaskTitle;

  /// No description provided for @noActiveTaskBody.
  ///
  /// In en, this message translates to:
  /// **'Start a task from My Tasks.'**
  String get noActiveTaskBody;

  /// No description provided for @workTime.
  ///
  /// In en, this message translates to:
  /// **'WORK TIME'**
  String get workTime;

  /// No description provided for @breakTime.
  ///
  /// In en, this message translates to:
  /// **'BREAK TIME'**
  String get breakTime;

  /// No description provided for @startedLabel.
  ///
  /// In en, this message translates to:
  /// **'STARTED'**
  String get startedLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'LOCATION'**
  String get locationLabel;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @stopAndStartBreak.
  ///
  /// In en, this message translates to:
  /// **'STOP & START BREAK'**
  String get stopAndStartBreak;

  /// No description provided for @resumeWorking.
  ///
  /// In en, this message translates to:
  /// **'RESUME WORKING'**
  String get resumeWorking;

  /// No description provided for @finishTask.
  ///
  /// In en, this message translates to:
  /// **'FINISH TASK'**
  String get finishTask;

  /// No description provided for @tapToBreak.
  ///
  /// In en, this message translates to:
  /// **'Tap to take a break'**
  String get tapToBreak;

  /// No description provided for @tapToResume.
  ///
  /// In en, this message translates to:
  /// **'Tap to resume work'**
  String get tapToResume;

  /// No description provided for @earningsTitle.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get earningsTitle;

  /// No description provided for @worksDoneThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Works done (approved)'**
  String get worksDoneThisMonth;

  /// No description provided for @earnedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Earned (approved)'**
  String get earnedThisMonth;

  /// No description provided for @earningsApprovedOnly.
  ///
  /// In en, this message translates to:
  /// **'Only tasks approved by your manager are counted. A submitted task is added here after approval.'**
  String get earningsApprovedOnly;

  /// No description provided for @earningsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not loaded yet. Pull down on My Tasks to refresh when you are online.'**
  String get earningsUnavailable;

  /// No description provided for @finishConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish this task?'**
  String get finishConfirmTitle;

  /// No description provided for @finishConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Next you will add photos and submit. The timer keeps running until you submit.'**
  String get finishConfirmBody;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @syncAllSent.
  ///
  /// In en, this message translates to:
  /// **'All changes sent'**
  String get syncAllSent;

  /// No description provided for @syncPending.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item waiting to send} other{{count} items waiting to send}}'**
  String syncPending(int count);

  /// No description provided for @syncFailedBanner.
  ///
  /// In en, this message translates to:
  /// **'Sending failed'**
  String get syncFailedBanner;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline — your work is saved on this phone'**
  String get syncOffline;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get syncing;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete Task'**
  String get completeTask;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @taskLabel.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get taskLabel;

  /// No description provided for @totalDuration.
  ///
  /// In en, this message translates to:
  /// **'Total duration'**
  String get totalDuration;

  /// No description provided for @completionTime.
  ///
  /// In en, this message translates to:
  /// **'Completion time'**
  String get completionTime;

  /// No description provided for @materialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materialsTitle;

  /// No description provided for @materialsInstalledHint.
  ///
  /// In en, this message translates to:
  /// **'What did you install?'**
  String get materialsInstalledHint;

  /// No description provided for @materialsDismantleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter what you brought back. Differences are recorded as lost.'**
  String get materialsDismantleHint;

  /// No description provided for @materialsInspectionHint.
  ///
  /// In en, this message translates to:
  /// **'Record damaged items, if any.'**
  String get materialsInspectionHint;

  /// No description provided for @addMaterial.
  ///
  /// In en, this message translates to:
  /// **'Add material'**
  String get addMaterial;

  /// No description provided for @item.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get item;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @expectedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Expected: {quantity}'**
  String expectedQuantity(String quantity);

  /// No description provided for @materialsRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one material.'**
  String get materialsRequired;

  /// No description provided for @materialsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Material list is not available offline. Try again when online.'**
  String get materialsUnavailable;

  /// No description provided for @checklistComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Inspection checklist will be added in a later version.'**
  String get checklistComingSoon;

  /// No description provided for @photosTitle.
  ///
  /// In en, this message translates to:
  /// **'Photos of Completed Work'**
  String get photosTitle;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose From Gallery'**
  String get chooseFromGallery;

  /// No description provided for @photosRequired.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add at least 1 photo.} other{Add at least {count} photos.}}'**
  String photosRequired(int count);

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailed;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @commentTitle.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentTitle;

  /// No description provided for @commentHint.
  ///
  /// In en, this message translates to:
  /// **'Anything your manager should know'**
  String get commentHint;

  /// No description provided for @submitTask.
  ///
  /// In en, this message translates to:
  /// **'Submit Task'**
  String get submitTask;

  /// No description provided for @submitConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Submit Task?'**
  String get submitConfirmTitle;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemsCount(int count);

  /// No description provided for @movementInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get movementInstalled;

  /// No description provided for @movementRetrieved.
  ///
  /// In en, this message translates to:
  /// **'Retrieved'**
  String get movementRetrieved;

  /// No description provided for @movementDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get movementDamaged;

  /// No description provided for @movementLost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get movementLost;

  /// No description provided for @movementAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get movementAdjustment;

  /// No description provided for @submittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Task submitted ✓'**
  String get submittedTitle;

  /// No description provided for @submittedBody.
  ///
  /// In en, this message translates to:
  /// **'Your manager can see it now.'**
  String get submittedBody;

  /// No description provided for @savedOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Task saved'**
  String get savedOfflineTitle;

  /// No description provided for @savedOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'It will be sent automatically when you\'re online.'**
  String get savedOfflineBody;

  /// No description provided for @goToHistory.
  ///
  /// In en, this message translates to:
  /// **'Go to History'**
  String get goToHistory;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No completed tasks yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Submitted tasks appear here.'**
  String get historyEmptyBody;

  /// No description provided for @workingDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration} working'**
  String workingDuration(String duration);

  /// No description provided for @completedAtTime.
  ///
  /// In en, this message translates to:
  /// **'Completed {time}'**
  String completedAtTime(String time);

  /// No description provided for @workAndBreaks.
  ///
  /// In en, this message translates to:
  /// **'Work and breaks'**
  String get workAndBreaks;

  /// No description provided for @sessionWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get sessionWork;

  /// No description provided for @sessionBreak.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get sessionBreak;

  /// No description provided for @completionLocation.
  ///
  /// In en, this message translates to:
  /// **'Completion location'**
  String get completionLocation;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @notRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded'**
  String get notRecorded;

  /// No description provided for @hoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String hoursMinutes(int hours, int minutes);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @employeeId.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeId;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @locationPermission.
  ///
  /// In en, this message translates to:
  /// **'Location permission'**
  String get locationPermission;

  /// No description provided for @cameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Camera permission'**
  String get cameraPermission;

  /// No description provided for @manageInSettings.
  ///
  /// In en, this message translates to:
  /// **'Manage in system settings'**
  String get manageInSettings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDevice.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageDevice;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// No description provided for @unsyncedItems.
  ///
  /// In en, this message translates to:
  /// **'Unsynced items'**
  String get unsyncedItems;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutUnsyncedBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 unsynced item.} other{You have {count} unsynced items.}} It stays on this phone and is sent after you log in again.'**
  String logoutUnsyncedBody(int count);

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer (dev build)'**
  String get developer;

  /// No description provided for @gpsSource.
  ///
  /// In en, this message translates to:
  /// **'GPS source'**
  String get gpsSource;

  /// No description provided for @simulateOffline.
  ///
  /// In en, this message translates to:
  /// **'Simulate no internet'**
  String get simulateOffline;

  /// No description provided for @failNextUpload.
  ///
  /// In en, this message translates to:
  /// **'Fail next photo upload'**
  String get failNextUpload;

  /// No description provided for @rejectNextCompletion.
  ///
  /// In en, this message translates to:
  /// **'Reject next submission (409)'**
  String get rejectNextCompletion;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmpty;

  /// No description provided for @errorNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNoInternet;

  /// No description provided for @errorOfflineCached.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing saved tasks.'**
  String get errorOfflineCached;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server.'**
  String get errorServer;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorGeneric;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong phone number or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @requestId.
  ///
  /// In en, this message translates to:
  /// **'Request ID: {id}'**
  String requestId(String id);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hy', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hy':
      return AppLocalizationsHy();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
