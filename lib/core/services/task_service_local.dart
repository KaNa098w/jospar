import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:jospar/core/models/task_list_response.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/collaboration_service.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:jospar/core/services/task_list_service.dart';
import 'package:jospar/core/services/task_service_i.dart';

class LocalTaskService implements ITaskService {
  Future<String> _deviceId() => AuthStorage().ensureDeviceId();
  Future<String> _accountId() => AuthStorage().getAccountId();

  @override
  Future<TaskResponse> getTasks(
    BuildContext context, {
    int? trash,
    int? only_parent,
  }) async {
    final store = OfflineRuntime.store;
    final accountId = await _accountId();
    final rows = await store.allTaskRows(
      accountId: accountId,
      trashed: trash == 1,
    );
    final listRows = await store.allTaskListRows(accountId);
    final listsById = {
      for (final list in listRows)
        if (list.serverId != null)
          list.serverId!: store.taskListRowToJson(list),
    };
    final tasks = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      if (row.serverId == null) continue;
      final json = store.taskRowToJson(row);
      final list = listsById[row.taskListServerId];
      if (list != null) json['task_list'] = list;
      json['children'] = <Map<String, dynamic>>[];
      tasks[row.serverId!] = json;
    }

    for (final task in tasks.values) {
      final parentId = task['parent_task_id']?.toString();
      if (parentId == null) continue;
      final parent = tasks[parentId];
      if (parent != null) {
        (parent['children'] as List<Map<String, dynamic>>).add(task);
      }
    }

    final result = tasks.values.where((task) {
      if (only_parent != 1) return true;
      return task['parent_task_id'] == null;
    }).toList(growable: false);
    return TaskResponse.fromJson({'items': result, 'count': result.length});
  }

  @override
  Future<TaskListResponse> fetchTaskLists(BuildContext context) async {
    final response = await TaskListService().getTaskLists(context);
    return TaskListResponse.fromJson({
      'items': response.items?.map((item) => item.toJson()).toList() ?? [],
    });
  }

  @override
  Future<TaskItems> getTaskByHash(BuildContext context, String hash) async {
    final accountId = await _accountId();
    final local = await getLocalTaskByHash(hash);
    if (local != null) return local;

    final accepted = await CollaborationService().acceptInvite(hash);
    // The hash belongs to the invitation and is required to make subsequent
    // openings local and idempotent, even if the server task omits it.
    accepted['hash'] = hash;
    accepted['is_shared'] ??= true;
    final userId = await AuthStorage().getUserId();
    if (userId == null) return TaskItems.fromJson(accepted);
    await OfflineRuntime.store.applyChangesPage(
      userId: userId,
      changes: [
        {
          'entity': 'task',
          'action': 'created',
          'version': accepted['version'],
          'data': accepted,
        },
      ],
      nextCursor: await OfflineRuntime.store.cursorFor(userId),
      pendingEntityIds: await OfflineRuntime.outbox.pendingEntityIds(accountId),
    );
    return await getLocalTaskByHash(hash) ?? TaskItems.fromJson(accepted);
  }

  Future<TaskItems?> getLocalTaskByHash(String hash) async {
    final accountId = await _accountId();
    final json = await OfflineRuntime.store.taskTreeJsonByHash(accountId, hash);
    return json == null ? null : TaskItems.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> createTask(
    BuildContext context, {
    required String name,
    required String date,
    int? position,
    required String taskListId,
    String? parentTaskId,
    String? urgency,
  }) async {
    final id = await OfflineRuntime.store.createTask(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
      name: name,
      date: date,
      taskListId: taskListId.isEmpty ? null : taskListId,
      parentTaskId: parentTaskId,
      urgency: urgency,
      position: position,
    );
    OfflineRuntime.requestSync();
    return {'id': id};
  }

  @override
  Future<Map<String, dynamic>> createSubtask(
    BuildContext context, {
    required String name,
    required String parentTaskId,
    required String taskListId,
    String? date,
    int? position,
  }) {
    return createTask(
      context,
      name: name,
      date: date ?? '',
      taskListId: taskListId,
      parentTaskId: parentTaskId,
      position: position,
    );
  }

  @override
  Future<Map<String, dynamic>> updateTaskPut(
    BuildContext context, {
    required String id,
    String? name,
    String? note,
    String? notificationTime,
    String? date,
    bool clearDate = false,
    String? urgency,
    int? position,
    String? taskListId,
    String? parentTaskId,
    bool? isCompleted,
    List<Map<String, dynamic>>? children,
  }) async {
    final patch = <String, dynamic>{
      if (name != null) 'name': name,
      if (note != null) 'note': note,
      if (notificationTime != null) 'notification_time': notificationTime,
      if (clearDate) 'date': null else if (date != null) 'date': date,
      if (urgency != null) 'urgency': urgency,
      if (position != null) 'position': position,
      if (taskListId != null) 'task_list_id': taskListId,
      if (parentTaskId != null) 'parent_task_id': parentTaskId,
      if (isCompleted != null) 'is_completed': isCompleted,
    };
    await OfflineRuntime.store.updateTask(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
      id: id,
      patch: patch,
    );
    OfflineRuntime.requestSync();
    return {'id': id, 'updated': true};
  }

  @override
  Future<Map<String, dynamic>> updateTask(
    BuildContext context, {
    required String id,
  }) async {
    final accountId = await _accountId();
    final row = await OfflineRuntime.store.taskById(accountId, id);
    if (row == null) throw StateError('Задача не найдена локально: $id');
    return _setTaskCompleted(
      accountId: accountId,
      id: id,
      isCompleted: !row.isCompleted,
    );
  }

  @override
  Future<Map<String, dynamic>> setTaskCompleted(
    BuildContext context, {
    required String id,
    required bool isCompleted,
  }) async {
    final accountId = await _accountId();
    final row = await OfflineRuntime.store.taskById(accountId, id);
    if (row == null) throw StateError('Задача не найдена локально: $id');
    return _setTaskCompleted(
      accountId: accountId,
      id: id,
      isCompleted: isCompleted,
    );
  }

  Future<Map<String, dynamic>> _setTaskCompleted({
    required String accountId,
    required String id,
    required bool isCompleted,
  }) async {
    await OfflineRuntime.store.updateTask(
      deviceId: await _deviceId(),
      accountId: accountId,
      id: id,
      type: OutboxOpType.toggleTaskCompleted,
      patch: {'is_completed': isCompleted},
    );
    OfflineRuntime.requestSync();
    return {'id': id, 'is_completed': isCompleted};
  }

  @override
  Future<void> deleteTask(BuildContext context, String id) async {
    await OfflineRuntime.store.setTrashed(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
      id: id,
      trashed: true,
    );
    OfflineRuntime.requestSync();
  }

  @override
  Future<void> restoreTask(
    BuildContext context, {
    required String id,
  }) async {
    await OfflineRuntime.store.setTrashed(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
      id: id,
      trashed: false,
    );
    OfflineRuntime.requestSync();
  }

  Future<void> deleteTaskPermanently(
    BuildContext context, {
    required String id,
  }) async {
    final accountId = await _accountId();
    await (OfflineRuntime.db.delete(OfflineRuntime.db.tasksTable)
          ..where(
            (table) =>
                table.serverId.equals(id) & table.accountId.equals(accountId),
          ))
        .go();
  }

  @override
  Future<void> clearTrash(BuildContext context) async {
    await OfflineRuntime.store.clearTrash(
      deviceId: await _deviceId(),
      accountId: await _accountId(),
    );
    OfflineRuntime.requestSync();
  }
}
