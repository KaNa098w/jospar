import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/models/tasks_response.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static final HomeWidgetService instance = HomeWidgetService._();

  static const appGroupId = 'group.com.beyinfotech.jospar';
  static const dataKey = 'jospar_widget_data';
  static const androidProvider = 'JosparWidgetProvider';
  static const iOSKind = 'JosparTasksWidget';

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> update({
    required List<TaskItems> tasks,
    required List<TaskListItems> lists,
    required String languageCode,
    required Color primaryColor,
  }) async {
    if (!_supported) return;
    final payload = buildPayload(
      tasks: tasks,
      lists: lists,
      languageCode: languageCode,
      primaryColor: primaryColor,
    );
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await HomeWidget.setAppGroupId(appGroupId);
      }
      await HomeWidget.saveWidgetData<String>(dataKey, jsonEncode(payload));
      await HomeWidget.updateWidget(
        androidName: androidProvider,
        iOSName: iOSKind,
      );
    } on MissingPluginException catch (error) {
      debugPrint('[HomeWidget] plugin unavailable: $error');
    } on PlatformException catch (error) {
      debugPrint('[HomeWidget] update failed: $error');
    }
  }

  @visibleForTesting
  Map<String, dynamic> buildPayload({
    required List<TaskItems> tasks,
    required List<TaskListItems> lists,
    required String languageCode,
    required Color primaryColor,
    DateTime? now,
  }) {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final colorsByList = <String, String>{
      for (final list in lists)
        if ((list.id ?? '').isNotEmpty)
          list.id!: _normalizeColor(list.colorHex),
    };
    bool isTopLevelVisibleTask(TaskItems task) =>
        task.trashed != true && (task.parentTaskId ?? '').isEmpty;

    final activeTodayTasks = tasks.where((task) {
      if (!isTopLevelVisibleTask(task) || task.isCompleted == true) {
        return false;
      }
      final date = _parseLocal(task.date);
      if (date == null) return false;
      return !DateUtils.dateOnly(date).isAfter(today);
    }).toList()
      ..sort((a, b) {
        final position = (a.position ?? 1 << 30).compareTo(
          b.position ?? 1 << 30,
        );
        if (position != 0) return position;
        final date = (a.date ?? '').compareTo(b.date ?? '');
        if (date != 0) return date;
        return (a.createdAt ?? '').compareTo(b.createdAt ?? '');
      });

    final completedTodayTasks = tasks.where((task) {
      if (!isTopLevelVisibleTask(task) || task.isCompleted != true) {
        return false;
      }
      final completedAt = _parseLocal(task.updatedAt);
      return completedAt != null && DateUtils.isSameDay(completedAt, today);
    }).toList(growable: false);

    final completed = completedTodayTasks.length;
    final total = activeTodayTasks.length + completed;
    final visible = activeTodayTasks.take(5).map((task) {
      final listId = task.taskListId ?? task.taskList?.id;
      return <String, dynamic>{
        'id': task.id ?? '',
        'title': (task.name ?? '').trim(),
        'color': _normalizeColor(
          task.taskList?.colorHex ?? colorsByList[listId] ?? '#0267AA',
        ),
      };
    }).toList(growable: false);
    final copy = _copyFor(languageCode);

    return <String, dynamic>{
      'version': 1,
      'date': _ymd(today),
      'language': languageCode,
      'primary':
          '#${primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
      'title': copy.title,
      'empty': copy.empty,
      'add': copy.add,
      'completed': completed,
      'total': total,
      'remaining': activeTodayTasks.length,
      'tasks': visible,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  DateTime? _parseLocal(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(value.trim());
    return parsed?.toLocal();
  }

  String _normalizeColor(String? value) {
    final raw = (value ?? '').trim().replaceFirst('#', '');
    if (RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(raw)) {
      return '#${raw.toUpperCase()}';
    }
    if (RegExp(r'^[0-9a-fA-F]{8}$').hasMatch(raw)) {
      return '#${raw.substring(2).toUpperCase()}';
    }
    return '#0267AA';
  }

  String _ymd(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  ({String title, String empty, String add}) _copyFor(String languageCode) {
    return switch (languageCode) {
      'en' => (title: 'TODAY', empty: 'Nothing planned', add: 'ADD TASK'),
      'kk' => (title: 'БҮГІН', empty: 'Жоспарланған іс жоқ', add: 'ІС ҚОСУ'),
      _ => (
          title: 'СЕГОДНЯ',
          empty: 'Ничего не запланировано',
          add: 'ДОБАВИТЬ'
        ),
    };
  }
}
