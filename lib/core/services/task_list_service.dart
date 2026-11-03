import 'package:flutter/material.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskListService {
  static const _defaultListSeededKey = 'default_task_list_seeded_v1';
  static final Map<String, Future<void>> _seedOperations = {};

  Future<String> _deviceId() => AuthStorage().ensureDeviceId();
  Future<String> _accountId() => AuthStorage().getAccountId();

  Future<void> _seedIfNeeded() async {
    final accountId = await _accountId();
    final existingOperation = _seedOperations[accountId];
    if (existingOperation != null) {
      await existingOperation;
      return;
    }

    final operation = _seedAccountIfNeeded(accountId);
    _seedOperations[accountId] = operation;
    try {
      await operation;
    } finally {
      if (identical(_seedOperations[accountId], operation)) {
        _seedOperations.remove(accountId);
      }
    }
  }

  Future<void> _seedAccountIfNeeded(String accountId) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_defaultListSeededKey) == true) {
      return;
    }

    // This is an installation-wide seed, rather than an "empty account"
    // seed. The anonymous list is claimed by the account during the first
    // authenticated sync. Keeping this flag across logout prevents a deleted
    // default list from being recreated on the next launch or sign-in.
    if ((await OfflineRuntime.store.allTaskListRows(accountId)).isNotEmpty) {
      await preferences.setBool(_defaultListSeededKey, true);
      return;
    }

    await OfflineRuntime.store.createTaskList(
      deviceId: await _deviceId(),
      accountId: accountId,
      name: 'Личные',
      colorHex: '#5B67F1',
      isHidden: false,
    );
    await preferences.setBool(_defaultListSeededKey, true);
    OfflineRuntime.requestSync();
  }

  Future<Map<String, dynamic>> createTaskList(
    BuildContext context, {
    required String name,
    required String colorHex,
    bool hidden = false,
    String? userId,
  }) async {
    final id = await OfflineRuntime.store.createTaskList(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
      name: name,
      colorHex: colorHex,
      isHidden: hidden,
    );
    OfflineRuntime.requestSync();
    final row = (await OfflineRuntime.store.allTaskListRows(await _accountId()))
        .firstWhere((item) => item.serverId == id);
    return OfflineRuntime.store.taskListRowToJson(row);
  }

  Future<TaskListItemsResponse> getTaskLists(BuildContext context) async {
    await _seedIfNeeded();
    final rows = await OfflineRuntime.store.allTaskListRows(await _accountId());
    final items = rows
        .map(OfflineRuntime.store.taskListRowToJson)
        .toList(growable: false);
    return TaskListItemsResponse.fromJson({
      'items': items,
      'total': items.length,
    });
  }

  Future<Map<String, dynamic>> getTaskListById(
    BuildContext context,
    String id,
  ) async {
    await _seedIfNeeded();
    final rows = await OfflineRuntime.store.allTaskListRows(await _accountId());
    final row = rows.where((item) => item.serverId == id).firstOrNull;
    if (row == null) {
      throw StateError('Список задач не найден локально: $id');
    }
    return OfflineRuntime.store.taskListRowToJson(row);
  }

  Future<Map<String, dynamic>> updateTaskList(
    BuildContext context, {
    required String id,
    String? name,
    String? colorHex,
    bool? hidden,
    String? userId,
  }) async {
    final patch = <String, dynamic>{
      if (name != null) 'name': name,
      if (colorHex != null) 'color_hex': colorHex,
      if (hidden != null) 'is_hidden': hidden,
    };
    await OfflineRuntime.store.updateTaskList(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
      id: id,
      patch: patch,
    );
    OfflineRuntime.requestSync();
    return getTaskListById(context, id);
  }

  Future<void> deleteTaskList(BuildContext context, String id) async {
    await OfflineRuntime.store.deleteTaskList(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
      id: id,
    );
    OfflineRuntime.requestSync();
  }
}
