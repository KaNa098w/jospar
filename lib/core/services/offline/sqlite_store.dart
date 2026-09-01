import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jospar/core/db/app_db.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:uuid/uuid.dart';

class SqliteStore {
  SqliteStore({required this.db, required this.outbox});

  final AppDb db;
  final OutboxStore outbox;

  Future<String> createTask({
    required String deviceId,
    required String accountId,
    required String name,
    required String? date,
    required String? taskListId,
    String? parentTaskId,
    String? urgency,
    int? position,
    String? note,
    String? notificationTime,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();
    final payload = <String, dynamic>{
      'id': id,
      'name': name,
      'note': note,
      'date': date,
      'notification_time': notificationTime,
      'urgency': urgency,
      'position': position ?? 0,
      'task_list_id': taskListId,
      'parent_task_id': parentTaskId,
      'is_completed': false,
      'trashed': false,
    };

    await db.transaction(() async {
      await db.into(db.tasksTable).insert(
            TasksTableCompanion.insert(
              serverId: Value(id),
              accountId: Value(accountId),
              name: name,
              dateYmd: Value(date),
              note: Value(note),
              notificationTime: Value(notificationTime),
              urgency: Value(urgency),
              position: Value(position ?? 0),
              taskListServerId: Value(taskListId),
              parentServerId: Value(parentTaskId),
              isDirty: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await outbox.enqueue(
        deviceId: deviceId,
        accountId: accountId,
        type: OutboxOpType.createTask,
        entityId: null,
        payload: payload,
        clientTimestamp: now,
      );
    });
    return id;
  }

  Future<void> updateTask({
    required String deviceId,
    required String accountId,
    required String id,
    required Map<String, dynamic> patch,
    OutboxOpType type = OutboxOpType.updateTask,
  }) async {
    final row = await taskById(accountId, id);
    if (row == null) throw StateError('Задача не найдена локально: $id');
    final now = DateTime.now().toUtc();

    await db.transaction(() async {
      await (db.update(db.tasksTable)
            ..where(
              (table) =>
                  table.serverId.equals(id) & table.accountId.equals(accountId),
            ))
          .write(
        TasksTableCompanion(
          name: _valueIfKey<String>(patch, 'name'),
          note: _nullableValueIfKey<String>(patch, 'note'),
          notificationTime:
              _nullableValueIfKey<String>(patch, 'notification_time'),
          dateYmd: _nullableValueIfKey<String>(patch, 'date'),
          urgency: _nullableValueIfKey<String>(patch, 'urgency'),
          position: _nullableValueIfKey<int>(patch, 'position'),
          taskListServerId: _nullableValueIfKey<String>(patch, 'task_list_id'),
          parentServerId: _nullableValueIfKey<String>(patch, 'parent_task_id'),
          isCompleted: _valueIfKey<bool>(patch, 'is_completed'),
          isDirty: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await outbox.enqueue(
        deviceId: deviceId,
        accountId: accountId,
        type: type,
        entityId: id,
        payload: patch,
        clientTimestamp: now,
      );
    });
  }

  Future<void> setTrashed({
    required String deviceId,
    required String accountId,
    required String id,
    required bool trashed,
  }) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      final ids = await _taskTreeIds(accountId, id);
      await (db.update(db.tasksTable)
            ..where(
              (table) =>
                  table.serverId.isIn(ids) & table.accountId.equals(accountId),
            ))
          .write(
        TasksTableCompanion(
          trashed: Value(trashed),
          isDirty: const Value(true),
          updatedAt: Value(now),
        ),
      );
      await outbox.enqueue(
        deviceId: deviceId,
        accountId: accountId,
        type: trashed ? OutboxOpType.deleteTask : OutboxOpType.restoreTask,
        entityId: id,
        payload: const {},
        clientTimestamp: now,
      );
    });
  }

  Future<void> clearTrash({
    required String deviceId,
    required String accountId,
  }) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      await (db.delete(db.tasksTable)
            ..where(
              (table) =>
                  table.trashed.equals(true) &
                  table.accountId.equals(accountId),
            ))
          .go();
      await outbox.enqueue(
        deviceId: deviceId,
        accountId: accountId,
        type: OutboxOpType.clearTrash,
        entityId: null,
        payload: const {},
        clientTimestamp: now,
      );
    });
  }

  Future<String> createTaskList({
    required String deviceId,
    required String accountId,
    required String name,
    required String colorHex,
    required bool isHidden,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now().toUtc();
    final payload = {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'is_hidden': isHidden,
    };
    await db.transaction(() async {
      await db.into(db.taskListsTable).insert(
            TaskListsTableCompanion.insert(
              serverId: Value(id),
              accountId: Value(accountId),
              name: name,
              colorHex: Value(colorHex),
              isHidden: Value(isHidden),
              isDirty: const Value(true),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );
      await outbox.enqueue(
        deviceId: deviceId,
        accountId: accountId,
        type: OutboxOpType.createTaskList,
        entityId: null,
        payload: payload,
        clientTimestamp: now,
      );
    });
    return id;
  }

  Future<void> updateTaskList({
    required String deviceId,
    required String accountId,
    required String id,
    required Map<String, dynamic> patch,
  }) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      final affected = await (db.update(db.taskListsTable)
            ..where(
              (table) =>
                  table.serverId.equals(id) & table.accountId.equals(accountId),
            ))
          .write(
        TaskListsTableCompanion(
          name: _valueIfKey<String>(patch, 'name'),
          colorHex: _valueIfKey<String>(patch, 'color_hex'),
          isHidden: _valueIfKey<bool>(patch, 'is_hidden'),
          isDirty: const Value(true),
          updatedAt: Value(now),
        ),
      );
      if (affected == 0) {
        throw StateError('Список задач не найден локально: $id');
      }
      await outbox.enqueue(
        deviceId: deviceId,
        accountId: accountId,
        type: OutboxOpType.updateTaskList,
        entityId: id,
        payload: patch,
        clientTimestamp: now,
      );
    });
  }

  Future<void> deleteTaskList({
    required String deviceId,
    required String accountId,
    required String id,
  }) async {
    final now = DateTime.now().toUtc();
    await db.transaction(() async {
      final affected = await (db.delete(db.taskListsTable)
            ..where(
              (table) =>
                  table.serverId.equals(id) & table.accountId.equals(accountId),
            ))
          .go();
      if (affected == 0) {
        throw StateError('Список задач не найден локально: $id');
      }
      await outbox.enqueue(
        deviceId: deviceId,
        accountId: accountId,
        type: OutboxOpType.deleteTaskList,
        entityId: id,
        payload: const {},
        clientTimestamp: now,
      );
    });
  }

  Future<List<TasksTableData>> allTaskRows({
    required String accountId,
    required bool trashed,
  }) {
    return (db.select(db.tasksTable)
          ..where(
            (table) =>
                table.trashed.equals(trashed) &
                table.isDeleted.equals(false) &
                table.accountId.equals(accountId),
          )
          ..orderBy([
            (table) => OrderingTerm.asc(table.position),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .get();
  }

  Future<List<TaskListsTableData>> allTaskListRows(String accountId) {
    return (db.select(db.taskListsTable)
          ..where(
            (table) =>
                table.isDeleted.equals(false) &
                table.accountId.equals(accountId),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.updatedAt)]))
        .get();
  }

  Future<TasksTableData?> taskById(String accountId, String id) {
    return (db.select(db.tasksTable)
          ..where(
            (table) =>
                table.serverId.equals(id) & table.accountId.equals(accountId),
          ))
        .getSingleOrNull();
  }

  Future<TasksTableData?> taskByLocalId(String accountId, int localId) {
    return (db.select(db.tasksTable)
          ..where(
            (table) =>
                table.localId.equals(localId) &
                table.accountId.equals(accountId),
          ))
        .getSingleOrNull();
  }

  /// Records a successfully created share immediately, without waiting for
  /// the next pull. Some backend versions return only the invite and keep
  /// reporting `is_shared: false` for the owner for a short time.
  Future<void> recordSuccessfulShare({
    required String accountId,
    required String taskId,
    required bool collaborative,
    String? inviteHash,
  }) async {
    final root = await taskById(accountId, taskId);
    if (root == null) {
      throw StateError('Задача не найдена локально: $taskId');
    }

    final ids = await _taskTreeIds(accountId, taskId);
    await db.transaction(() async {
      await (db.update(db.tasksTable)
            ..where(
              (table) =>
                  table.serverId.isIn(ids) & table.accountId.equals(accountId),
            ))
          .write(
        TasksTableCompanion(
          isShared: collaborative ? const Value(true) : const Value.absent(),
          collaborationRole: const Value('owner'),
        ),
      );

      if (inviteHash != null && inviteHash.isNotEmpty) {
        await (db.update(db.tasksTable)
              ..where(
                (table) =>
                    table.serverId.equals(taskId) &
                    table.accountId.equals(accountId),
              ))
            .write(TasksTableCompanion(hash: Value(inviteHash)));
      }
    });
  }

  Future<int> repairLegacyNullTaskPositions() async {
    final legacyOperations = await (db.select(db.outboxTable)
          ..where((table) => table.type.equals(OutboxOpType.createTask.name)))
        .get();
    var repairedOperations = 0;
    final now = DateTime.now().toUtc();

    await db.transaction(() async {
      await (db.update(db.tasksTable)
            ..where((table) => table.position.isNull()))
          .write(const TasksTableCompanion(position: Value(0)));

      for (final operation in legacyOperations) {
        try {
          final decoded = jsonDecode(operation.payloadJson);
          if (decoded is! Map || decoded['position'] != null) continue;
          final payload = Map<String, dynamic>.from(decoded);
          payload['position'] = 0;
          await (db.update(db.outboxTable)
                ..where((table) => table.id.equals(operation.id)))
              .write(
            OutboxTableCompanion(
              payloadJson: Value(jsonEncode(payload)),
              nextAttemptAt:
                  operation.isTerminal ? const Value.absent() : Value(now),
              lastError: operation.isTerminal
                  ? const Value.absent()
                  : const Value(null),
            ),
          );
          repairedOperations++;
        } catch (_) {
          // Keep malformed operations intact for diagnostics.
        }
      }
    });
    return repairedOperations;
  }

  Future<TasksTableData?> taskByHash(String accountId, String hash) {
    return (db.select(db.tasksTable)
          ..where(
            (table) =>
                table.hash.equals(hash) & table.accountId.equals(accountId),
          ))
        .getSingleOrNull();
  }

  /// Hydrates a previously accepted share from SQLite, including every
  /// descendant. Returning only [taskByHash] would lose subtasks when the
  /// same invitation is opened for a second time.
  Future<Map<String, dynamic>?> taskTreeJsonByHash(
    String accountId,
    String hash,
  ) async {
    final root = await taskByHash(accountId, hash);
    if (root == null ||
        root.trashed ||
        root.isDeleted ||
        root.serverId == null) {
      return null;
    }

    final rows = await allTaskRows(accountId: accountId, trashed: false);
    final listRows = await allTaskListRows(accountId);
    final listsById = <String, Map<String, dynamic>>{
      for (final list in listRows)
        if (list.serverId != null) list.serverId!: taskListRowToJson(list),
    };
    final tasks = <String, Map<String, dynamic>>{};
    for (final row in rows) {
      final id = row.serverId;
      if (id == null) continue;
      final json = taskRowToJson(row);
      final list = listsById[row.taskListServerId];
      if (list != null) json['task_list'] = list;
      json['children'] = <Map<String, dynamic>>[];
      tasks[id] = json;
    }
    for (final task in tasks.values) {
      final parentId = task['parent_task_id']?.toString();
      if (parentId == null) continue;
      final parent = tasks[parentId];
      if (parent != null) {
        (parent['children'] as List<Map<String, dynamic>>).add(task);
      }
    }
    return tasks[root.serverId!];
  }

  Future<void> applyChangesPage({
    required String userId,
    required List<dynamic> changes,
    required String? nextCursor,
    required Set<String> pendingEntityIds,
  }) async {
    await db.transaction(() async {
      for (final raw in changes) {
        if (raw is! Map) continue;
        final change = Map<String, dynamic>.from(raw);
        final dataRaw = change['data'];
        if (dataRaw is! Map) continue;
        final data = Map<String, dynamic>.from(dataRaw);
        final id = data['id']?.toString();
        if (id == null || id.isEmpty || pendingEntityIds.contains(id)) continue;

        final action = change['action']?.toString() ?? '';
        final entity = change['entity']?.toString() ?? '';
        if (entity == 'task') {
          // Losing collaboration access is valid for an editor/viewer, but
          // never for the task owner. Keep the owner's original task even if
          // a malformed event is emitted after an invite is created.
          if (action == 'access_revoked') {
            final existing = await taskById(userId, id);
            if (existing?.collaborationRole == 'owner') continue;
          }
          if (_removesLocalEntity(action)) {
            await (db.delete(db.tasksTable)
                  ..where(
                    (table) =>
                        table.serverId.equals(id) &
                        table.accountId.equals(userId),
                  ))
                .go();
            await (db.delete(db.collaboratorsTable)
                  ..where((table) => table.taskId.equals(id)))
                .go();
          } else {
            await _upsertRemoteTaskTree(
              userId,
              data,
              eventVersion: _asInt(change['version']),
              action: action,
            );
          }
        } else if (entity == 'task_list') {
          if (_removesLocalEntity(action)) {
            await (db.delete(db.taskListsTable)
                  ..where(
                    (table) =>
                        table.serverId.equals(id) &
                        table.accountId.equals(userId),
                  ))
                .go();
          } else {
            await _upsertRemoteTaskList(
              userId,
              data,
              eventVersion: _asInt(change['version']),
            );
          }
        }
      }
      await setCursor(userId, nextCursor);
    });
  }

  Future<void> applySnapshot({
    required String userId,
    required List<dynamic> tasks,
    required List<dynamic> taskLists,
    required String? cursor,
  }) async {
    final pendingIds = await outbox.pendingEntityIds(userId);
    final rowsWithShareHash = await (db.select(db.tasksTable)
          ..where(
            (table) => table.accountId.equals(userId) & table.hash.isNotNull(),
          ))
        .get();
    final shareHashesByTaskId = <String, String>{
      for (final row in rowsWithShareHash)
        if (row.serverId != null && row.hash?.isNotEmpty == true)
          row.serverId!: row.hash!,
    };
    final locallySharedOwnerIds = await (db.selectOnly(db.tasksTable)
          ..addColumns([db.tasksTable.serverId])
          ..where(
            db.tasksTable.accountId.equals(userId) &
                db.tasksTable.collaborationRole.equals('owner') &
                (db.tasksTable.isShared.equals(true) |
                    db.tasksTable.hash.isNotNull()),
          ))
        .map((row) => row.read(db.tasksTable.serverId))
        .get();
    final retainedTaskIds = <String>{
      ...pendingIds,
      ...locallySharedOwnerIds.whereType<String>(),
    };
    await db.transaction(() async {
      await (db.delete(db.tasksTable)
            ..where(
              (table) =>
                  table.isDirty.equals(false) &
                  table.accountId.equals(userId) &
                  table.serverId.isNotIn(retainedTaskIds),
            ))
          .go();
      await (db.delete(db.taskListsTable)
            ..where(
              (table) =>
                  table.isDirty.equals(false) &
                  table.accountId.equals(userId) &
                  table.serverId.isNotIn(pendingIds),
            ))
          .go();
      final userTaskIds = await (db.selectOnly(db.tasksTable)
            ..addColumns([db.tasksTable.serverId])
            ..where(db.tasksTable.accountId.equals(userId)))
          .map((row) => row.read(db.tasksTable.serverId))
          .get();
      await (db.delete(db.collaboratorsTable)
            ..where(
              (table) =>
                  table.taskId.isIn(userTaskIds.whereType<String>()) &
                  table.taskId.isNotIn(
                    locallySharedOwnerIds.whereType<String>(),
                  ),
            ))
          .go();

      for (final raw in taskLists) {
        if (raw is Map) {
          await _upsertRemoteTaskList(
            userId,
            Map<String, dynamic>.from(raw),
          );
        }
      }
      for (final raw in tasks) {
        if (raw is Map) {
          await _upsertRemoteTaskTree(
            userId,
            Map<String, dynamic>.from(raw),
          );
        }
      }
      // Preserve the invitation lookup only for tasks that are still present
      // in the authoritative snapshot. Omitted editor/viewer tasks stay
      // deleted, so revoked access cannot leak stale local data.
      for (final entry in shareHashesByTaskId.entries) {
        await (db.update(db.tasksTable)
              ..where(
                (table) =>
                    table.accountId.equals(userId) &
                    table.serverId.equals(entry.key) &
                    table.hash.isNull(),
              ))
            .write(TasksTableCompanion(hash: Value(entry.value)));
      }
      await setCursor(userId, cursor);
    });
  }

  Future<String?> cursorFor(String userId) async {
    final row = await (db.select(db.syncStatesTable)
          ..where((table) => table.userId.equals(userId)))
        .getSingleOrNull();
    return row?.cursor;
  }

  Future<void> setCursor(String userId, String? cursor) {
    return db.into(db.syncStatesTable).insertOnConflictUpdate(
          SyncStatesTableCompanion.insert(
            userId: userId,
            cursor: Value(cursor),
            lastSyncAt: Value(DateTime.now().toUtc()),
          ),
        );
  }

  Future<void> clearUserSyncState(String userId) {
    return (db.delete(db.syncStatesTable)
          ..where((table) => table.userId.equals(userId)))
        .go();
  }

  Future<void> clearAccountData(String accountId) async {
    await db.transaction(() async {
      final taskRows = await (db.select(db.tasksTable)
            ..where((table) => table.accountId.equals(accountId)))
          .get();
      final taskIds =
          taskRows.map((row) => row.serverId).whereType<String>().toSet();
      final retainedTaskRows = await (db.select(db.tasksTable)
            ..where((table) => table.accountId.equals(accountId).not()))
          .get();
      taskIds.removeAll(
        retainedTaskRows.map((row) => row.serverId).whereType<String>(),
      );

      if (taskIds.isNotEmpty) {
        await (db.delete(db.collaboratorsTable)
              ..where((table) => table.taskId.isIn(taskIds)))
            .go();
      }
      await (db.delete(db.outboxTable)
            ..where((table) => table.accountId.equals(accountId)))
          .go();
      await (db.delete(db.tasksTable)
            ..where((table) => table.accountId.equals(accountId)))
          .go();
      await (db.delete(db.taskListsTable)
            ..where((table) => table.accountId.equals(accountId)))
          .go();
      await clearUserSyncState(accountId);
    });
  }

  Future<void> claimAnonymousData(String userId) async {
    if (userId == 'anonymous') return;
    await db.transaction(() async {
      await (db.update(db.tasksTable)
            ..where((table) => table.accountId.equals('anonymous')))
          .write(TasksTableCompanion(accountId: Value(userId)));
      await (db.update(db.taskListsTable)
            ..where((table) => table.accountId.equals('anonymous')))
          .write(TaskListsTableCompanion(accountId: Value(userId)));
      await (db.update(db.outboxTable)
            ..where((table) => table.accountId.equals('anonymous')))
          .write(OutboxTableCompanion(accountId: Value(userId)));
    });
  }

  Future<void> markOperationSynced(
    OutboxOp operation, {
    required String accountId,
    required String? serverId,
    required int? version,
  }) async {
    final localEntityId =
        operation.entityId ?? operation.payload['id']?.toString();
    if (localEntityId == null) return;
    final effectiveId =
        serverId == null || serverId.isEmpty ? localEntityId : serverId;

    if (operation.type.name.endsWith('TaskList')) {
      await (db.update(db.taskListsTable)
            ..where(
              (table) =>
                  table.serverId.equals(localEntityId) &
                  table.accountId.equals(accountId),
            ))
          .write(
        TaskListsTableCompanion(
          serverId: Value(effectiveId),
          version: version == null ? const Value.absent() : Value(version),
          isDirty: const Value(false),
        ),
      );
      return;
    }

    if (operation.type == OutboxOpType.clearTrash) return;
    await db.transaction(() async {
      await (db.update(db.tasksTable)
            ..where(
              (table) =>
                  table.serverId.equals(localEntityId) &
                  table.accountId.equals(accountId),
            ))
          .write(
        TasksTableCompanion(
          serverId: Value(effectiveId),
          version: version == null ? const Value.absent() : Value(version),
          isDirty: const Value(false),
        ),
      );
      if (effectiveId != localEntityId) {
        await (db.update(db.tasksTable)
              ..where(
                (table) =>
                    table.parentServerId.equals(localEntityId) &
                    table.accountId.equals(accountId),
              ))
            .write(TasksTableCompanion(parentServerId: Value(effectiveId)));
      }
    });
  }

  Future<void> discardOptimisticOperation(
    OutboxOp operation, {
    required String accountId,
  }) async {
    final entityId = operation.entityId ?? operation.payload['id']?.toString();
    if (entityId == null) return;

    if (operation.type.name.endsWith('TaskList')) {
      await (db.update(db.taskListsTable)
            ..where(
              (table) =>
                  table.serverId.equals(entityId) &
                  table.accountId.equals(accountId),
            ))
          .write(const TaskListsTableCompanion(isDirty: Value(false)));
      return;
    }

    await (db.update(db.tasksTable)
          ..where(
            (table) =>
                table.serverId.equals(entityId) &
                table.accountId.equals(accountId),
          ))
        .write(const TasksTableCompanion(isDirty: Value(false)));
  }

  Future<void> _upsertRemoteTask(
    String accountId,
    Map<String, dynamic> json, {
    int? eventVersion,
    String? action,
  }) async {
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) return;
    final existing = await taskById(accountId, id);
    final incomingVersion = _asInt(json['version']) ?? eventVersion ?? 0;
    if (existing != null && existing.version > incomingVersion) return;

    final merged = <String, dynamic>{
      if (existing != null) ...taskRowToJson(existing),
      ...json,
    };
    if (action == 'restored' && existing != null) {
      // A restore changes trash state, not scheduling. Some API responses
      // contain null placeholders for fields they did not load; retaining the
      // local values keeps the task in its original section.
      if (json['date'] == null) merged['date'] = existing.dateYmd;
      if (json['task_list_id'] == null) {
        merged['task_list_id'] = existing.taskListServerId;
      }
      if (json['position'] == null) merged['position'] = existing.position;
      if (json['parent_task_id'] == null) {
        merged['parent_task_id'] = existing.parentServerId;
      }
    }
    final preserveOwnerShare =
        existing?.isShared == true && existing?.collaborationRole == 'owner';
    if (preserveOwnerShare && json['is_shared'] != true) {
      merged['is_shared'] = true;
      merged['collaboration_role'] = 'owner';
    }
    if (existing?.hash?.isNotEmpty == true &&
        (json['hash'] == null || json['hash'].toString().isEmpty)) {
      merged['hash'] = existing!.hash;
    }
    final companion = _taskCompanion(
      merged,
      accountId: accountId,
      isDirty: false,
    );
    if (existing == null) {
      await db.into(db.tasksTable).insert(companion);
    } else {
      await (db.update(db.tasksTable)
            ..where((table) => table.localId.equals(existing.localId)))
          .write(companion);
    }
    await _replaceCollaborators(id, merged['collaborators']);
  }

  Future<void> _upsertRemoteTaskTree(
    String accountId,
    Map<String, dynamic> json, {
    int? eventVersion,
    String? parentId,
    String? action,
  }) async {
    final normalized = Map<String, dynamic>.from(json);
    if (parentId != null &&
        (normalized['parent_task_id'] == null ||
            normalized['parent_task_id'].toString().isEmpty)) {
      normalized['parent_task_id'] = parentId;
    }
    await _upsertRemoteTask(
      accountId,
      normalized,
      eventVersion: eventVersion,
      action: action,
    );

    final id = normalized['id']?.toString();
    final children = normalized['children'];
    if (id == null || id.isEmpty || children is! List) return;
    for (final child in children.whereType<Map>()) {
      await _upsertRemoteTaskTree(
        accountId,
        Map<String, dynamic>.from(child),
        parentId: id,
        action: action,
      );
    }
  }

  Future<void> _upsertRemoteTaskList(
    String accountId,
    Map<String, dynamic> json, {
    int? eventVersion,
  }) async {
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) return;
    final existing = await (db.select(db.taskListsTable)
          ..where(
            (table) =>
                table.serverId.equals(id) & table.accountId.equals(accountId),
          ))
        .getSingleOrNull();
    final incomingVersion = _asInt(json['version']) ?? eventVersion ?? 0;
    if (existing != null && existing.version > incomingVersion) return;

    final merged = <String, dynamic>{
      if (existing != null) ...taskListRowToJson(existing),
      ...json,
    };
    final companion = _taskListCompanion(
      merged,
      accountId: accountId,
      isDirty: false,
    );
    if (existing == null) {
      await db.into(db.taskListsTable).insert(companion);
    } else {
      await (db.update(db.taskListsTable)
            ..where((table) => table.localId.equals(existing.localId)))
          .write(companion);
    }
  }

  Future<void> _replaceCollaborators(String taskId, dynamic raw) async {
    if (raw is! List) return;
    await (db.delete(db.collaboratorsTable)
          ..where((table) => table.taskId.equals(taskId)))
        .go();
    for (final item in raw.whereType<Map>()) {
      final userId = item['user_id']?.toString();
      final role = item['role']?.toString();
      if (userId == null || role == null) continue;
      await db.into(db.collaboratorsTable).insertOnConflictUpdate(
            CollaboratorsTableCompanion.insert(
              taskId: taskId,
              userId: userId,
              name: Value(item['name']?.toString()),
              role: role,
            ),
          );
    }
  }

  Future<List<String>> _taskTreeIds(
    String accountId,
    String rootId,
  ) async {
    final result = <String>{rootId};
    var frontier = <String>{rootId};
    while (frontier.isNotEmpty) {
      final children = await (db.select(db.tasksTable)
            ..where(
              (table) =>
                  table.parentServerId.isIn(frontier) &
                  table.accountId.equals(accountId),
            ))
          .get();
      frontier = children
          .map((child) => child.serverId)
          .whereType<String>()
          .where(result.add)
          .toSet();
    }
    return result.toList(growable: false);
  }

  bool _removesLocalEntity(String action) =>
      action == 'purged' || action == 'deleted' || action == 'access_revoked';

  TasksTableCompanion _taskCompanion(
    Map<String, dynamic> json, {
    required String accountId,
    required bool isDirty,
  }) {
    return TasksTableCompanion.insert(
      serverId: Value(json['id']?.toString()),
      accountId: Value(accountId),
      name: json['name']?.toString() ?? '',
      dateYmd: Value(json['date']?.toString()),
      note: Value(json['note']?.toString()),
      notificationTime: Value(json['notification_time']?.toString()),
      isCompleted: Value(json['is_completed'] == true),
      trashed: Value(json['trashed'] == true),
      urgency: Value(json['urgency']?.toString()),
      position: Value(_asInt(json['position'])),
      taskListServerId: Value(json['task_list_id']?.toString()),
      parentServerId: Value(json['parent_task_id']?.toString()),
      hash: Value(json['hash']?.toString()),
      isShared: Value(json['is_shared'] == true),
      collaborationRole: Value(json['collaboration_role']?.toString()),
      collaboratorsJson: Value(
        json['collaborators'] == null
            ? null
            : jsonEncode(json['collaborators']),
      ),
      version: Value(_asInt(json['version']) ?? 0),
      isDirty: Value(isDirty),
      isDeleted: const Value(false),
      createdAt: Value(_parseDate(json['created_at'])),
      updatedAt:
          Value(_parseDate(json['updated_at']) ?? DateTime.now().toUtc()),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  TaskListsTableCompanion _taskListCompanion(
    Map<String, dynamic> json, {
    required String accountId,
    required bool isDirty,
  }) {
    return TaskListsTableCompanion.insert(
      serverId: Value(json['id']?.toString()),
      accountId: Value(accountId),
      name: json['name']?.toString() ?? '',
      colorHex: Value(json['color_hex']?.toString() ?? '#CCCCCC'),
      isHidden: Value(json['is_hidden'] == true),
      isDirty: Value(isDirty),
      isDeleted: const Value(false),
      version: Value(_asInt(json['version']) ?? 0),
      createdAt: Value(_parseDate(json['created_at'])),
      updatedAt:
          Value(_parseDate(json['updated_at']) ?? DateTime.now().toUtc()),
      deletedAt: Value(_parseDate(json['deleted_at'])),
    );
  }

  Map<String, dynamic> taskRowToJson(TasksTableData row) {
    return {
      'id': row.serverId,
      'name': row.name,
      'note': row.note,
      'notification_time': row.notificationTime,
      'date': row.dateYmd,
      'urgency': row.urgency,
      'position': row.position,
      'task_list_id': row.taskListServerId,
      'parent_task_id': row.parentServerId,
      'is_completed': row.isCompleted,
      'trashed': row.trashed,
      'hash': row.hash,
      'is_shared': row.isShared,
      'collaboration_role': row.collaborationRole,
      'collaborators': _decodeList(row.collaboratorsJson),
      'version': row.version,
      'created_at': row.createdAt?.toUtc().toIso8601String(),
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  Map<String, dynamic> taskListRowToJson(TaskListsTableData row) {
    return {
      'id': row.serverId,
      'name': row.name,
      'color_hex': row.colorHex,
      'is_hidden': row.isHidden,
      'version': row.version,
      'created_at': row.createdAt?.toUtc().toIso8601String(),
      'updated_at': row.updatedAt.toUtc().toIso8601String(),
      'deleted_at': row.deletedAt?.toUtc().toIso8601String(),
    };
  }

  Value<T> _valueIfKey<T>(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key) || map[key] is! T) return const Value.absent();
    return Value(map[key] as T);
  }

  Value<T?> _nullableValueIfKey<T>(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) return const Value.absent();
    final value = map[key];
    if (value == null) return const Value(null);
    if (value is T) return Value(value);
    return const Value.absent();
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  List<Map<String, dynamic>> _decodeList(String? value) {
    if (value == null || value.isEmpty) return const [];
    final decoded = jsonDecode(value);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}
