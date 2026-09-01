import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/db/app_db.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:jospar/core/services/offline/sqlite_store.dart';

void main() {
  late AppDb db;
  late OutboxStore outbox;
  late SqliteStore store;

  setUp(() {
    db = AppDb(NativeDatabase.memory());
    outbox = OutboxStore(db);
    store = SqliteStore(db: db, outbox: outbox);
  });

  tearDown(() => db.close());

  test('create task writes entity and operation atomically', () async {
    final id = await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Offline task',
      date: '2026-07-30',
      taskListId: null,
      urgency: 'medium',
    );

    final task = await store.taskById('user-1', id);
    final operations = await outbox.pending('user-1');

    expect(task, isNotNull);
    expect(task!.name, 'Offline task');
    expect(task.isDirty, isTrue);
    expect(operations, hasLength(1));
    expect(operations.single.type, OutboxOpType.createTask);
    expect(operations.single.entityId, isNull);
    expect(operations.single.payload, {
      'id': id,
      'name': 'Offline task',
      'note': null,
      'date': '2026-07-30',
      'notification_time': null,
      'urgency': 'medium',
      'position': 0,
      'task_list_id': null,
      'parent_task_id': null,
      'is_completed': false,
      'trashed': false,
    });
  });

  test('repairs null positions in legacy tasks and queued payloads', () async {
    final id = await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Legacy task',
      date: null,
      taskListId: null,
    );
    final task = await store.taskById('user-1', id);
    final operation = (await outbox.pending('user-1')).single;
    final legacyPayload = Map<String, dynamic>.from(operation.payload)
      ..['position'] = null;

    await (db.update(db.tasksTable)
          ..where((table) => table.localId.equals(task!.localId)))
        .write(const TasksTableCompanion(position: Value(null)));
    await (db.update(db.outboxTable)
          ..where((table) => table.id.equals(operation.localRowId)))
        .write(
      OutboxTableCompanion(
        payloadJson: Value(jsonEncode(legacyPayload)),
        retryCount: const Value(3),
        lastError: const Value('position cannot be null'),
      ),
    );

    expect(await store.repairLegacyNullTaskPositions(), 1);

    final repairedTask = await store.taskById('user-1', id);
    final repairedOperation = (await outbox.pending('user-1')).single;
    expect(repairedTask!.position, 0);
    expect(repairedOperation.payload['position'], 0);
    expect(repairedOperation.lastError, isNull);
  });

  test('local row still resolves after server replaces the client id',
      () async {
    final clientId = await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Task to share',
      date: null,
      taskListId: null,
    );
    final localRow = await store.taskById('user-1', clientId);
    final operation = (await outbox.pending('user-1')).single;

    await store.markOperationSynced(
      operation,
      accountId: 'user-1',
      serverId: 'server-task-1',
      version: 1,
    );

    final resolved = await store.taskByLocalId('user-1', localRow!.localId);
    expect(resolved!.serverId, 'server-task-1');
    expect(await store.taskById('user-1', clientId), isNull);
  });

  test('completion operation sends final value and no server-only fields',
      () async {
    final id = await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Task',
      date: null,
      taskListId: null,
    );
    await store.updateTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      id: id,
      type: OutboxOpType.toggleTaskCompleted,
      patch: {'is_completed': true},
    );

    final operations = await outbox.pending('user-1');
    final completion = operations.last;
    expect(completion.type, OutboxOpType.toggleTaskCompleted);
    expect(completion.payload, {'is_completed': true});
    expect(completion.payload, isNot(contains('updated_at')));
    expect(completion.payload, isNot(contains('version')));
    expect((await store.taskById('user-1', id))!.isCompleted, isTrue);
  });

  test('restoring a completed task queues an explicit false completion',
      () async {
    final id = await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Completed task',
      date: '2026-08-10',
      taskListId: null,
      position: 4,
    );
    await store.updateTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      id: id,
      type: OutboxOpType.toggleTaskCompleted,
      patch: {'is_completed': true},
    );

    await store.updateTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      id: id,
      type: OutboxOpType.toggleTaskCompleted,
      patch: {'is_completed': false},
    );

    final restoration = (await outbox.pending('user-1')).last;
    final row = await store.taskById('user-1', id);
    expect(restoration.type, OutboxOpType.toggleTaskCompleted);
    expect(restoration.payload, {'is_completed': false});
    expect(row!.isCompleted, isFalse);
    expect(row.dateYmd, '2026-08-10');
    expect(row.position, 4);
  });

  test('older remote version never overwrites newer local server state',
      () async {
    await store.applyChangesPage(
      userId: 'user-1',
      changes: [
        {
          'entity': 'task',
          'action': 'updated',
          'version': 4,
          'data': {
            'id': 'task-1',
            'name': 'Version four',
            'version': 4,
          },
        },
      ],
      nextCursor: 'cursor-4',
      pendingEntityIds: const {},
    );
    await store.applyChangesPage(
      userId: 'user-1',
      changes: [
        {
          'entity': 'task',
          'action': 'updated',
          'version': 3,
          'data': {
            'id': 'task-1',
            'name': 'Stale version',
            'version': 3,
          },
        },
      ],
      nextCursor: 'cursor-5',
      pendingEntityIds: const {},
    );

    final task = await store.taskById('user-1', 'task-1');
    expect(task!.name, 'Version four');
    expect(task.version, 4);
    expect(await store.cursorFor('user-1'), 'cursor-5');
  });

  test('snapshot preserves pending local entities', () async {
    final localId = await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Pending offline task',
      date: null,
      taskListId: null,
    );

    await store.applySnapshot(
      userId: 'user-1',
      tasks: const [
        {
          'id': 'server-task',
          'name': 'Server task',
          'version': 2,
        },
      ],
      taskLists: const [],
      cursor: 'snapshot-cursor',
    );

    expect(await store.taskById('user-1', localId), isNotNull);
    expect(await store.taskById('user-1', 'server-task'), isNotNull);
    expect(await store.cursorFor('user-1'), 'snapshot-cursor');
  });

  test('local data and queues are isolated by account', () async {
    await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'First user',
      date: null,
      taskListId: null,
    );
    await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-2',
      name: 'Second user',
      date: null,
      taskListId: null,
    );

    final firstTasks = await store.allTaskRows(
      accountId: 'user-1',
      trashed: false,
    );
    final secondTasks = await store.allTaskRows(
      accountId: 'user-2',
      trashed: false,
    );

    expect(firstTasks.single.name, 'First user');
    expect(secondTasks.single.name, 'Second user');
    expect(await outbox.pending('user-1'), hasLength(1));
    expect(await outbox.pending('user-2'), hasLength(1));
  });

  test('snapshot persists shared subtasks and collaborators', () async {
    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-1',
      tasks: [
        {
          'id': 'parent-1',
          'name': 'Shared task',
          'is_shared': true,
          'collaboration_role': 'editor',
          'version': 2,
          'collaborators': [
            {'user_id': 'owner-1', 'name': 'Owner', 'role': 'owner'},
            {'user_id': 'user-1', 'name': 'Editor', 'role': 'editor'},
          ],
          'children': [
            {
              'id': 'child-1',
              'name': 'Shared subtask',
              'is_completed': true,
              'version': 1,
            },
          ],
        },
      ],
    );

    final parent = await store.taskById('user-1', 'parent-1');
    final child = await store.taskById('user-1', 'child-1');
    final collaborators = await db.select(db.collaboratorsTable).get();

    expect(parent?.isShared, isTrue);
    expect(child?.parentServerId, 'parent-1');
    expect(child?.name, 'Shared subtask');
    expect(child?.isCompleted, isTrue);
    expect(collaborators, hasLength(2));
  });

  test('reopened share hydrates its complete local subtask tree', () async {
    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [
        {
          'id': 'list-1',
          'name': 'Work',
          'color_hex': '#123456',
          'version': 1,
        },
      ],
      cursor: 'cursor-1',
      tasks: const [
        {
          'id': 'parent-1',
          'name': 'Shared task',
          'hash': 'same-link-hash',
          'task_list_id': 'list-1',
          'is_shared': true,
          'collaboration_role': 'editor',
          'version': 2,
          'children': [
            {
              'id': 'child-1',
              'name': 'First subtask',
              'position': 0,
              'version': 1,
              'children': [
                {
                  'id': 'child-2',
                  'name': 'Nested subtask',
                  'position': 0,
                  'version': 1,
                },
              ],
            },
          ],
        },
      ],
    );

    final reopened = await store.taskTreeJsonByHash('user-1', 'same-link-hash');
    expect(reopened?['task_list'], isA<Map<String, dynamic>>());
    final children = reopened?['children'] as List<dynamic>;
    expect(children, hasLength(1));
    expect(children.single['name'], 'First subtask');
    expect(children.single['children'], hasLength(1));
    expect(children.single['children'].single['name'], 'Nested subtask');

    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-2',
      tasks: const [
        {
          'id': 'parent-1',
          'name': 'Shared task',
          'is_shared': true,
          'collaboration_role': 'editor',
          'version': 3,
          'children': [
            {
              'id': 'child-1',
              'name': 'First subtask',
              'version': 2,
            },
          ],
        },
      ],
    );
    final afterSnapshot =
        await store.taskTreeJsonByHash('user-1', 'same-link-hash');
    expect(afterSnapshot?['children'], hasLength(1));
  });

  test('successful owner share is retained across stale server payloads',
      () async {
    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-1',
      tasks: const [
        {
          'id': 'parent-1',
          'name': 'Owner task',
          'is_shared': false,
          'collaboration_role': 'owner',
          'version': 1,
          'children': [
            {'id': 'child-1', 'name': 'Child', 'version': 1},
          ],
        },
      ],
    );

    await store.recordSuccessfulShare(
      accountId: 'user-1',
      taskId: 'parent-1',
      collaborative: true,
      inviteHash: 'invite-hash',
    );
    await store.applyChangesPage(
      userId: 'user-1',
      nextCursor: 'cursor-2',
      pendingEntityIds: const {},
      changes: const [
        {
          'entity': 'task',
          'action': 'updated',
          'version': 2,
          'data': {
            'id': 'parent-1',
            'name': 'Owner task',
            'is_shared': false,
            'collaboration_role': 'owner',
            'hash': null,
            'version': 2,
          },
        },
      ],
    );

    final parent = await store.taskById('user-1', 'parent-1');
    final child = await store.taskById('user-1', 'child-1');
    expect(parent?.isShared, isTrue);
    expect(parent?.collaborationRole, 'owner');
    expect(parent?.hash, 'invite-hash');
    expect(child?.isShared, isTrue);
    expect(child?.collaborationRole, 'owner');
  });

  test('copy link protects the original without marking it collaborative',
      () async {
    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-1',
      tasks: const [
        {
          'id': 'task-1',
          'name': 'Original',
          'is_shared': false,
          'version': 1,
        },
      ],
    );

    await store.recordSuccessfulShare(
      accountId: 'user-1',
      taskId: 'task-1',
      collaborative: false,
      inviteHash: 'copy-hash',
    );
    final recorded = await store.taskById('user-1', 'task-1');
    expect(recorded?.isShared, isFalse);
    expect(recorded?.collaborationRole, 'owner');
    expect(recorded?.hash, 'copy-hash');

    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-2',
      tasks: const [],
    );
    expect(await store.taskById('user-1', 'task-1'), isNotNull);
  });

  test('snapshot and access_revoked cannot remove an owner shared task',
      () async {
    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-1',
      tasks: const [
        {
          'id': 'owner-task',
          'name': 'Owner task',
          'is_shared': true,
          'collaboration_role': 'owner',
          'version': 1,
        },
        {
          'id': 'editor-task',
          'name': 'Editor task',
          'is_shared': true,
          'collaboration_role': 'editor',
          'version': 1,
        },
      ],
    );

    await store.applyChangesPage(
      userId: 'user-1',
      nextCursor: 'cursor-2',
      pendingEntityIds: const {},
      changes: const [
        {
          'entity': 'task',
          'action': 'access_revoked',
          'data': {'id': 'owner-task'},
        },
        {
          'entity': 'task',
          'action': 'access_revoked',
          'data': {'id': 'editor-task'},
        },
      ],
    );

    expect(await store.taskById('user-1', 'owner-task'), isNotNull);
    expect(await store.taskById('user-1', 'editor-task'), isNull);

    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-3',
      tasks: const [],
    );
    expect(await store.taskById('user-1', 'owner-task'), isNotNull);
  });

  test('restore keeps scheduling fields omitted by the server', () async {
    await store.applySnapshot(
      userId: 'user-1',
      taskLists: const [],
      cursor: 'cursor-1',
      tasks: const [
        {
          'id': 'restored-task',
          'name': 'Original section',
          'date': '2026-09-02',
          'position': 4,
          'trashed': true,
          'version': 1,
        },
      ],
    );

    await store.applyChangesPage(
      userId: 'user-1',
      nextCursor: 'cursor-2',
      pendingEntityIds: const {},
      changes: const [
        {
          'entity': 'task',
          'action': 'restored',
          'version': 2,
          'data': {
            'id': 'restored-task',
            'name': 'Original section',
            'date': null,
            'position': null,
            'trashed': false,
            'version': 2,
          },
        },
      ],
    );

    final restored = await store.taskById('user-1', 'restored-task');
    expect(restored?.trashed, isFalse);
    expect(restored?.dateYmd, '2026-09-02');
    expect(restored?.position, 4);
  });

  test('clearAccountData removes only the deleted account data', () async {
    await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Delete me',
      date: null,
      taskListId: null,
    );
    await store.createTask(
      deviceId: 'device-2',
      accountId: 'user-2',
      name: 'Keep me',
      date: null,
      taskListId: null,
    );
    await store.setCursor('user-1', 'cursor-1');
    await store.setCursor('user-2', 'cursor-2');

    await store.clearAccountData('user-1');

    expect(
      await store.allTaskRows(accountId: 'user-1', trashed: false),
      isEmpty,
    );
    expect(
      await store.allTaskRows(accountId: 'user-2', trashed: false),
      hasLength(1),
    );
    expect(await outbox.pending('user-1'), isEmpty);
    expect(await outbox.pending('user-2'), hasLength(1));
    expect(await store.cursorFor('user-1'), isNull);
    expect(await store.cursorFor('user-2'), 'cursor-2');
  });
}
