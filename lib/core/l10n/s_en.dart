// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacyPolicy => 'Privacy policy';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsBuild => 'Build';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get later => 'Later';

  @override
  String get pickTaskList => 'Select a task list';

  @override
  String createTaskFailed(Object error) {
    return 'Failed to create a task: $error';
  }

  @override
  String changeDateFailed(Object error) {
    return 'Failed to change date: $error';
  }

  @override
  String get noTasksForDay => 'No tasks for this day';

  @override
  String calendarTooltipToday(Object day) {
    return 'Today is $day';
  }

  @override
  String get menu => 'Menu';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get shortMonthJanuary => 'JAN';

  @override
  String get shortMonthFebruary => 'FEB';

  @override
  String get shortMonthMarch => 'MAR';

  @override
  String get shortMonthApril => 'APR';

  @override
  String get shortMonthMay => 'MAY';

  @override
  String get shortMonthJune => 'JUN';

  @override
  String get shortMonthJuly => 'JUL';

  @override
  String get shortMonthAugust => 'AUG';

  @override
  String get shortMonthSeptember => 'SEP';

  @override
  String get shortMonthOctober => 'OCT';

  @override
  String get shortMonthNovember => 'NOV';

  @override
  String get shortMonthDecember => 'DEC';

  @override
  String get shortWeekdayMonday => 'MO';

  @override
  String get shortWeekdayTuesday => 'TU';

  @override
  String get shortWeekdayWednesday => 'WE';

  @override
  String get shortWeekdayThursday => 'TH';

  @override
  String get shortWeekdayFriday => 'FR';

  @override
  String get shortWeekdaySaturday => 'SA';

  @override
  String get shortWeekdaySunday => 'SU';

  @override
  String get screenHome => 'Home';

  @override
  String get screenTaskDiary => 'Task Diary';

  @override
  String get screenCart => 'Cart';

  @override
  String get taskTitle => 'Task title';

  @override
  String get addSubtask => 'Add subtask';

  @override
  String get subtaskTitle => 'Subtask title';

  @override
  String get delete => 'Delete';

  @override
  String get searchList => 'Search list';

  @override
  String get noTaskLists => 'No task lists — create one first.';

  @override
  String get nothingFound => 'Nothing found';

  @override
  String get untitled => 'Untitled';

  @override
  String get taskLists => 'TASK LISTS';

  @override
  String get listTitleHint => 'List name';

  @override
  String get listHideFromHome => 'Hide from home';

  @override
  String get done => 'Done';

  @override
  String get reminderTitle => 'Reminder';

  @override
  String get reminderSubtitle => 'Choose when to remind you about the task';

  @override
  String get hours => 'Hours';

  @override
  String get minutes => 'Minutes';

  @override
  String get morning => 'Morning';

  @override
  String get daytime => 'Day';

  @override
  String get evening => 'Evening';

  @override
  String get saveReminder => 'Save reminder';

  @override
  String get removeReminder => 'Remove reminder';

  @override
  String get reminderNotificationTitle => 'Time for your task';

  @override
  String get reminderTooltip => 'Reminder';

  @override
  String get enterListTitle => 'Enter a list name';

  @override
  String get error => 'Error';

  @override
  String get notes => 'Notes';

  @override
  String get noTasksToday => 'No tasks for this day';

  @override
  String get addTask => 'Add task';

  @override
  String get clearTrash => 'Clear trash';

  @override
  String get sharedTasks => 'Shared tasks';

  @override
  String get developerModeEnabled => 'You are now a developer';

  @override
  String get sharedProgress => 'Shared progress';

  @override
  String sharedProgressCount(Object completed, Object total) {
    return '$completed of $total completed';
  }

  @override
  String subtasksProgress(Object completed, Object total) {
    return 'Subtasks: $completed/$total';
  }

  @override
  String get participants => 'Participants';

  @override
  String get participant => 'Participant';

  @override
  String get invite => 'Invite';

  @override
  String get edit => 'Edit';

  @override
  String get refresh => 'Refresh';

  @override
  String get owner => 'Owner';

  @override
  String get editor => 'Editor';

  @override
  String get viewer => 'Viewer';

  @override
  String get canEdit => 'Can edit';

  @override
  String get viewOnly => 'View only';

  @override
  String get onlineNow => 'Online now';

  @override
  String get removeParticipant => 'Remove participant';

  @override
  String get leaveSharedTask => 'Leave shared task';

  @override
  String get emptyParticipants => 'The participant list is empty';

  @override
  String get emptySharedTasks => 'No shared tasks yet';

  @override
  String get emptySharedTasksHint =>
      'Invite participants or accept an invitation link — tasks will appear here.';

  @override
  String get howToSendTask => 'How would you like to send the task?';

  @override
  String get subtasksIncluded => 'Subtasks will be included in both options.';

  @override
  String get workTogether => 'Collaborate';

  @override
  String get workTogetherHint => 'Changes will be visible to all participants';

  @override
  String get sendAsCopy => 'Send as a copy';

  @override
  String get sendAsCopyHint =>
      'The recipient will get an independent task with all subtasks';

  @override
  String get share => 'Share';

  @override
  String get sharedTaskSubject => 'Shared Jospar task';

  @override
  String get taskCopySubject => 'Jospar task copy';

  @override
  String get signInToShare => 'Sign in or register to share a task.';

  @override
  String get syncNotReady => 'Sync is not ready yet. Restart the app.';

  @override
  String syncFailed(Object error) {
    return 'Could not send the latest changes: $error';
  }

  @override
  String get tasksPendingSync =>
      'The task or its subtasks have not been sent to the server yet. Check your connection and try again.';

  @override
  String get inviteLinkMissing =>
      'The server did not return an invitation link.';

  @override
  String get sessionExpired => 'Your session has expired. Sign in again.';

  @override
  String inviteCreationFailed(Object error) {
    return 'Could not create an invitation: $error';
  }

  @override
  String taskSavedMessage(Object message) {
    return 'Task saved. $message';
  }

  @override
  String get taskSavedShareFailed =>
      'Task saved. Could not share it. Check your connection and try again from the task card.';

  @override
  String get shareTaskFailed =>
      'Could not share the task. Check your connection and try again.';

  @override
  String get openShareFailedTitle => 'Could not open the link';

  @override
  String get sharedCopyAdded =>
      'The task and all its subtasks were added as an independent copy.';

  @override
  String get shareSessionExpired =>
      'Your session has expired. Sign in and open the link again.';

  @override
  String get shareAccessDenied =>
      'Your account does not have access to this task.';

  @override
  String get shareLinkUnavailable =>
      'The link was not found, was revoked, or has expired.';

  @override
  String get shareAlreadyUsedMissingLocal =>
      'The link was already used, but the task is not on this device. Synchronize or ask for a new link.';

  @override
  String get unknownRetryError =>
      'An unknown error occurred. Check your connection and try again.';

  @override
  String get taskTitleRequired => 'Enter a task title.';

  @override
  String get selectTaskListForSave =>
      'Select the list where the task should be saved.';

  @override
  String get taskSaveFailedTitle => 'Could not save the task';

  @override
  String get synchronization => 'Synchronization';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncInProgress => 'Synchronizing…';

  @override
  String get syncSuccessful => 'Successfully synchronized';

  @override
  String get syncFailedStatus => 'Synchronization error';

  @override
  String get syncNotRun => 'Not run yet';

  @override
  String get syncQueue => 'Waiting to be sent';

  @override
  String get syncQueueEmpty => 'Everything has been sent to the backend';

  @override
  String get syncHistory => 'Synchronization history';

  @override
  String get syncHistoryEmpty =>
      'The history will appear after synchronization';

  @override
  String syncRetries(Object count) {
    return 'Attempts: $count';
  }

  @override
  String get fallbackSyncEnabled => 'Fallback synchronization is enabled';

  @override
  String get websocketOnlyMode =>
      'WebSocket only: periodic synchronization is disabled';

  @override
  String get enableFastSync => 'Enable synchronization every 2 seconds';

  @override
  String get fastSyncEnabled => 'Fast synchronization enabled: every 2 seconds';

  @override
  String get defaultSyncEnabled =>
      'Default synchronization enabled: every 30 seconds';

  @override
  String get realtimeConsole => 'WebSocket console';

  @override
  String get websocketConnected => 'WS connected';

  @override
  String get websocketDisconnected => 'WS disconnected';

  @override
  String get channelSubscribed => 'Channel subscribed';

  @override
  String get channelNotSubscribed => 'Not subscribed';

  @override
  String get realtimeHistoryEmpty => 'No events yet';

  @override
  String get subtaskDeleted => 'Subtask deleted';

  @override
  String get undo => 'Undo';
}
