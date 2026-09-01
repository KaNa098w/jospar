import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  static const _payloadPrefix = 'jospar-task:';
  static const _channelId = 'task_reminders';
  static const _channelName = 'Напоминания о задачах';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized || !_isSupportedPlatform) return;
    tz_data.initializeTimeZones();
    await _notifications.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<void> schedule({
    required String taskId,
    required String taskTitle,
    required DateTime date,
    required TimeOfDay time,
    bool requestPermissions = true,
  }) async {
    if (!_isSupportedPlatform) return;
    await initialize();

    final notificationId = _notificationId(taskId);
    await _notifications.cancel(id: notificationId);

    final localDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!localDateTime.isAfter(DateTime.now())) return;

    var androidMode = AndroidScheduleMode.inexactAllowWhileIdle;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (requestPermissions) {
        await android?.requestNotificationsPermission();
      }
      var exactAllowed =
          await android?.canScheduleExactNotifications() ?? false;
      if (!exactAllowed && requestPermissions) {
        await android?.requestExactAlarmsPermission();
        exactAllowed = await android?.canScheduleExactNotifications() ?? false;
      }
      if (exactAllowed) {
        androidMode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    } else if (requestPermissions &&
        defaultTargetPlatform == TargetPlatform.iOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (requestPermissions &&
        defaultTargetPlatform == TargetPlatform.macOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    final scheduledUtc = tz.TZDateTime.from(localDateTime.toUtc(), tz.UTC);
    await _notifications.zonedSchedule(
      id: notificationId,
      title: _notificationTitle(),
      body: taskTitle,
      scheduledDate: scheduledUtc,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Звуковые уведомления о запланированных задачах',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          enableVibration: true,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        macOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: androidMode,
      payload: '$_payloadPrefix$taskId',
    );
  }

  Future<void> cancel(String taskId) async {
    if (!_isSupportedPlatform) return;
    await initialize();
    await _notifications.cancel(id: _notificationId(taskId));
  }

  Future<void> reconcile(Iterable<TaskItems> tasks) async {
    if (!_isSupportedPlatform) return;
    await initialize();

    final desiredIds = <int>{};
    for (final task in tasks) {
      final id = task.id;
      final time = tryParseTime(task.notificationTime);
      final date = DateTime.tryParse(task.date ?? '');
      if (id == null ||
          id.isEmpty ||
          time == null ||
          date == null ||
          task.isCompleted == true ||
          task.trashed == true) {
        if (id != null && id.isNotEmpty) await cancel(id);
        continue;
      }
      desiredIds.add(_notificationId(id));
      await schedule(
        taskId: id,
        taskTitle: task.name?.trim().isNotEmpty == true
            ? task.name!.trim()
            : _untitledTask(),
        date: date,
        time: time,
        requestPermissions: false,
      );
    }

    final pending = await _notifications.pendingNotificationRequests();
    for (final notification in pending) {
      if (notification.payload?.startsWith(_payloadPrefix) == true &&
          !desiredIds.contains(notification.id)) {
        await _notifications.cancel(id: notification.id);
      }
    }
  }

  static TimeOfDay? tryParseTime(String? value) {
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value?.trim() ?? '');
    if (match == null) return null;
    final hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || hour > 23 || minute > 59) {
      return null;
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String formatTime(TimeOfDay? time) {
    if (time == null) return '';
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  int _notificationId(String taskId) {
    var hash = 0x811C9DC5;
    for (final unit in taskId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash == 0 ? 1 : hash;
  }

  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  String _notificationTitle() {
    return switch (PlatformDispatcher.instance.locale.languageCode) {
      'kk' => 'Тапсырманы орындайтын уақыт келді',
      'en' => 'Time for your task',
      _ => 'Пора выполнить задачу',
    };
  }

  String _untitledTask() {
    return switch (PlatformDispatcher.instance.locale.languageCode) {
      'kk' => 'Атаусыз тапсырма',
      'en' => 'Untitled task',
      _ => 'Задача без названия',
    };
  }
}
