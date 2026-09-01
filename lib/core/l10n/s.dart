import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 's_en.dart';
import 's_kk.dart';
import 's_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/s.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
    Locale('kk'),
    Locale('ru')
  ];

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

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @pickTaskList.
  ///
  /// In en, this message translates to:
  /// **'Select a task list'**
  String get pickTaskList;

  /// No description provided for @createTaskFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create a task: {error}'**
  String createTaskFailed(Object error);

  /// No description provided for @changeDateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change date: {error}'**
  String changeDateFailed(Object error);

  /// No description provided for @noTasksForDay.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTasksForDay;

  /// No description provided for @calendarTooltipToday.
  ///
  /// In en, this message translates to:
  /// **'Today is {day}'**
  String calendarTooltipToday(Object day);

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @shortMonthJanuary.
  ///
  /// In en, this message translates to:
  /// **'JAN'**
  String get shortMonthJanuary;

  /// No description provided for @shortMonthFebruary.
  ///
  /// In en, this message translates to:
  /// **'FEB'**
  String get shortMonthFebruary;

  /// No description provided for @shortMonthMarch.
  ///
  /// In en, this message translates to:
  /// **'MAR'**
  String get shortMonthMarch;

  /// No description provided for @shortMonthApril.
  ///
  /// In en, this message translates to:
  /// **'APR'**
  String get shortMonthApril;

  /// No description provided for @shortMonthMay.
  ///
  /// In en, this message translates to:
  /// **'MAY'**
  String get shortMonthMay;

  /// No description provided for @shortMonthJune.
  ///
  /// In en, this message translates to:
  /// **'JUN'**
  String get shortMonthJune;

  /// No description provided for @shortMonthJuly.
  ///
  /// In en, this message translates to:
  /// **'JUL'**
  String get shortMonthJuly;

  /// No description provided for @shortMonthAugust.
  ///
  /// In en, this message translates to:
  /// **'AUG'**
  String get shortMonthAugust;

  /// No description provided for @shortMonthSeptember.
  ///
  /// In en, this message translates to:
  /// **'SEP'**
  String get shortMonthSeptember;

  /// No description provided for @shortMonthOctober.
  ///
  /// In en, this message translates to:
  /// **'OCT'**
  String get shortMonthOctober;

  /// No description provided for @shortMonthNovember.
  ///
  /// In en, this message translates to:
  /// **'NOV'**
  String get shortMonthNovember;

  /// No description provided for @shortMonthDecember.
  ///
  /// In en, this message translates to:
  /// **'DEC'**
  String get shortMonthDecember;

  /// No description provided for @shortWeekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'MO'**
  String get shortWeekdayMonday;

  /// No description provided for @shortWeekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'TU'**
  String get shortWeekdayTuesday;

  /// No description provided for @shortWeekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'WE'**
  String get shortWeekdayWednesday;

  /// No description provided for @shortWeekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'TH'**
  String get shortWeekdayThursday;

  /// No description provided for @shortWeekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'FR'**
  String get shortWeekdayFriday;

  /// No description provided for @shortWeekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'SA'**
  String get shortWeekdaySaturday;

  /// No description provided for @shortWeekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'SU'**
  String get shortWeekdaySunday;

  /// No description provided for @screenHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get screenHome;

  /// No description provided for @screenTaskDiary.
  ///
  /// In en, this message translates to:
  /// **'Task Diary'**
  String get screenTaskDiary;

  /// No description provided for @screenCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get screenCart;

  /// No description provided for @taskTitle.
  ///
  /// In en, this message translates to:
  /// **'Task title'**
  String get taskTitle;

  /// No description provided for @addSubtask.
  ///
  /// In en, this message translates to:
  /// **'Add subtask'**
  String get addSubtask;

  /// No description provided for @subtaskTitle.
  ///
  /// In en, this message translates to:
  /// **'Subtask title'**
  String get subtaskTitle;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @searchList.
  ///
  /// In en, this message translates to:
  /// **'Search list'**
  String get searchList;

  /// No description provided for @noTaskLists.
  ///
  /// In en, this message translates to:
  /// **'No task lists — create one first.'**
  String get noTaskLists;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found'**
  String get nothingFound;

  /// No description provided for @untitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitled;

  /// No description provided for @taskLists.
  ///
  /// In en, this message translates to:
  /// **'TASK LISTS'**
  String get taskLists;

  /// No description provided for @listTitleHint.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get listTitleHint;

  /// No description provided for @listHideFromHome.
  ///
  /// In en, this message translates to:
  /// **'Hide from home'**
  String get listHideFromHome;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @reminderTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderTitle;

  /// No description provided for @reminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose when to remind you about the task'**
  String get reminderSubtitle;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @daytime.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get daytime;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @saveReminder.
  ///
  /// In en, this message translates to:
  /// **'Save reminder'**
  String get saveReminder;

  /// No description provided for @removeReminder.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminder;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for your task'**
  String get reminderNotificationTitle;

  /// No description provided for @reminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminderTooltip;

  /// No description provided for @enterListTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a list name'**
  String get enterListTitle;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @noTasksToday.
  ///
  /// In en, this message translates to:
  /// **'No tasks for this day'**
  String get noTasksToday;

  /// No description provided for @addTask.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get addTask;

  /// No description provided for @clearTrash.
  ///
  /// In en, this message translates to:
  /// **'Clear trash'**
  String get clearTrash;

  /// No description provided for @sharedTasks.
  ///
  /// In en, this message translates to:
  /// **'Shared tasks'**
  String get sharedTasks;

  /// No description provided for @sharedProgress.
  ///
  /// In en, this message translates to:
  /// **'Shared progress'**
  String get sharedProgress;

  /// No description provided for @sharedProgressCount.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} completed'**
  String sharedProgressCount(Object completed, Object total);

  /// No description provided for @subtasksProgress.
  ///
  /// In en, this message translates to:
  /// **'Subtasks: {completed}/{total}'**
  String subtasksProgress(Object completed, Object total);

  /// No description provided for @participants.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participants;

  /// No description provided for @participant.
  ///
  /// In en, this message translates to:
  /// **'Participant'**
  String get participant;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @editor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editor;

  /// No description provided for @viewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get viewer;

  /// No description provided for @canEdit.
  ///
  /// In en, this message translates to:
  /// **'Can edit'**
  String get canEdit;

  /// No description provided for @viewOnly.
  ///
  /// In en, this message translates to:
  /// **'View only'**
  String get viewOnly;

  /// No description provided for @onlineNow.
  ///
  /// In en, this message translates to:
  /// **'Online now'**
  String get onlineNow;

  /// No description provided for @removeParticipant.
  ///
  /// In en, this message translates to:
  /// **'Remove participant'**
  String get removeParticipant;

  /// No description provided for @leaveSharedTask.
  ///
  /// In en, this message translates to:
  /// **'Leave shared task'**
  String get leaveSharedTask;

  /// No description provided for @emptyParticipants.
  ///
  /// In en, this message translates to:
  /// **'The participant list is empty'**
  String get emptyParticipants;

  /// No description provided for @emptySharedTasks.
  ///
  /// In en, this message translates to:
  /// **'No shared tasks yet'**
  String get emptySharedTasks;

  /// No description provided for @emptySharedTasksHint.
  ///
  /// In en, this message translates to:
  /// **'Invite participants or accept an invitation link — tasks will appear here.'**
  String get emptySharedTasksHint;

  /// No description provided for @howToSendTask.
  ///
  /// In en, this message translates to:
  /// **'How would you like to send the task?'**
  String get howToSendTask;

  /// No description provided for @subtasksIncluded.
  ///
  /// In en, this message translates to:
  /// **'Subtasks will be included in both options.'**
  String get subtasksIncluded;

  /// No description provided for @workTogether.
  ///
  /// In en, this message translates to:
  /// **'Collaborate'**
  String get workTogether;

  /// No description provided for @workTogetherHint.
  ///
  /// In en, this message translates to:
  /// **'Changes will be visible to all participants'**
  String get workTogetherHint;

  /// No description provided for @sendAsCopy.
  ///
  /// In en, this message translates to:
  /// **'Send as a copy'**
  String get sendAsCopy;

  /// No description provided for @sendAsCopyHint.
  ///
  /// In en, this message translates to:
  /// **'The recipient will get an independent task with all subtasks'**
  String get sendAsCopyHint;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @sharedTaskSubject.
  ///
  /// In en, this message translates to:
  /// **'Shared Jospar task'**
  String get sharedTaskSubject;

  /// No description provided for @taskCopySubject.
  ///
  /// In en, this message translates to:
  /// **'Jospar task copy'**
  String get taskCopySubject;

  /// No description provided for @signInToShare.
  ///
  /// In en, this message translates to:
  /// **'Sign in or register to share a task.'**
  String get signInToShare;

  /// No description provided for @syncNotReady.
  ///
  /// In en, this message translates to:
  /// **'Sync is not ready yet. Restart the app.'**
  String get syncNotReady;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the latest changes: {error}'**
  String syncFailed(Object error);

  /// No description provided for @tasksPendingSync.
  ///
  /// In en, this message translates to:
  /// **'The task or its subtasks have not been sent to the server yet. Check your connection and try again.'**
  String get tasksPendingSync;

  /// No description provided for @inviteLinkMissing.
  ///
  /// In en, this message translates to:
  /// **'The server did not return an invitation link.'**
  String get inviteLinkMissing;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in again.'**
  String get sessionExpired;

  /// No description provided for @inviteCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create an invitation: {error}'**
  String inviteCreationFailed(Object error);

  /// No description provided for @taskSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Task saved. {message}'**
  String taskSavedMessage(Object message);

  /// No description provided for @taskSavedShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Task saved. Could not share it. Check your connection and try again from the task card.'**
  String get taskSavedShareFailed;

  /// No description provided for @shareTaskFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not share the task. Check your connection and try again.'**
  String get shareTaskFailed;

  /// No description provided for @openShareFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not open the link'**
  String get openShareFailedTitle;

  /// No description provided for @sharedCopyAdded.
  ///
  /// In en, this message translates to:
  /// **'The task and all its subtasks were added as an independent copy.'**
  String get sharedCopyAdded;

  /// No description provided for @shareSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Sign in and open the link again.'**
  String get shareSessionExpired;

  /// No description provided for @shareAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Your account does not have access to this task.'**
  String get shareAccessDenied;

  /// No description provided for @shareLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The link was not found, was revoked, or has expired.'**
  String get shareLinkUnavailable;

  /// No description provided for @shareAlreadyUsedMissingLocal.
  ///
  /// In en, this message translates to:
  /// **'The link was already used, but the task is not on this device. Synchronize or ask for a new link.'**
  String get shareAlreadyUsedMissingLocal;

  /// No description provided for @unknownRetryError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred. Check your connection and try again.'**
  String get unknownRetryError;

  /// No description provided for @taskTitleRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a task title.'**
  String get taskTitleRequired;

  /// No description provided for @selectTaskListForSave.
  ///
  /// In en, this message translates to:
  /// **'Select the list where the task should be saved.'**
  String get selectTaskListForSave;

  /// No description provided for @taskSaveFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not save the task'**
  String get taskSaveFailedTitle;

  /// No description provided for @synchronization.
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get synchronization;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing…'**
  String get syncInProgress;

  /// No description provided for @syncSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Successfully synchronized'**
  String get syncSuccessful;

  /// No description provided for @syncFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Synchronization error'**
  String get syncFailedStatus;

  /// No description provided for @syncNotRun.
  ///
  /// In en, this message translates to:
  /// **'Not run yet'**
  String get syncNotRun;

  /// No description provided for @syncQueue.
  ///
  /// In en, this message translates to:
  /// **'Waiting to be sent'**
  String get syncQueue;

  /// No description provided for @syncQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Everything has been sent to the backend'**
  String get syncQueueEmpty;

  /// No description provided for @syncHistory.
  ///
  /// In en, this message translates to:
  /// **'Synchronization history'**
  String get syncHistory;

  /// No description provided for @syncHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'The history will appear after synchronization'**
  String get syncHistoryEmpty;

  /// No description provided for @syncRetries.
  ///
  /// In en, this message translates to:
  /// **'Attempts: {count}'**
  String syncRetries(Object count);

  /// No description provided for @subtaskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Subtask deleted'**
  String get subtaskDeleted;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'kk':
      return SKk();
    case 'ru':
      return SRu();
  }

  throw FlutterError(
      'S.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
