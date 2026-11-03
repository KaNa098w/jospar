import 'dart:convert';
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jospar/core/db/app_db.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:jospar/core/services/offline/sqlite_store.dart';
import 'package:jospar/core/services/offline/sync_engine.dart';

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

  SyncEngine engine(http.Client client) {
    return SyncEngine(
      outbox: outbox,
      store: store,
      client: client,
      tokenProvider: () async => 'token',
      deviceIdProvider: () async => 'device-1',
      userIdProvider: () async => 'user-1',
      onlineCheck: () async => true,
      deviceRegistrar: (_, __, ___) async {},
    );
  }

  Map<String, dynamic> operationDocument(http.Request request) {
    expect(request.headers['authorization'], 'Bearer token');
    expect(request.headers['accept'], 'application/json');
    expect(request.headers['content-type'], 'application/json');
    final operation = jsonDecode(request.body) as Map<String, dynamic>;
    return {
      'schema_version': 1,
      'operations': [operation]
    };
  }

  test('pushes pending operation, snapshots, then pulls changes', () async {
    final localId = await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Local task',
      date: null,
      taskListId: null,
    );
    final requests = <http.Request>[];
    var changesCalls = 0;
    final client = MockClient((request) async {
      requests.add(request);
      if (request.method == 'POST' &&
          request.url.path.endsWith('/sync/operations')) {
        final body = operationDocument(request);
        expect(body['schema_version'], 1);
        final operations = body['operations'] as List;
        final operation = operations.single as Map;
        expect(operation['device_id'], 'device-1');
        expect(operation['type'], 'createTask');
        expect(operation['entity_id'], localId);
        expect((operation['payload'] as Map)['id'], localId);
        return http.Response(
          jsonEncode({
            'operation_id': operation['operation_id'],
            'server_id': localId,
            'entity_version': 1,
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/sync/snapshot')) {
        return http.Response(
          jsonEncode({
            'task_lists': [],
            'tasks': [
              {
                'id': localId,
                'name': 'Server task',
                'version': 1,
              },
            ],
            'cursor': 'snapshot-1',
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/sync/changes')) {
        changesCalls++;
        expect(
          request.url.queryParameters['cursor'],
          changesCalls == 1 ? 'snapshot-1' : 'cursor-2',
        );
        return http.Response(
          jsonEncode({
            'changes': changesCalls == 1
                ? []
                : [
                    {
                      'entity': 'task',
                      'action': 'updated',
                      'version': 2,
                      'data': {
                        'id': localId,
                        'name': 'Realtime server task',
                        'version': 2,
                      },
                    },
                  ],
            'next_cursor': changesCalls == 1 ? 'cursor-2' : 'cursor-3',
            'has_more': false,
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    await engine(client).synchronize(ignoreStopped: true);

    expect(
      requests.map((request) => request.method),
      ['GET', 'GET', 'POST', 'GET'],
    );
    expect(await outbox.pending('user-1'), isEmpty);
    final task = await store.taskById('user-1', localId);
    expect(task!.name, 'Realtime server task');
    expect(task.version, 2);
    expect(await store.cursorFor('user-1'), 'cursor-3');
  });

  test('a concurrent caller waits for the active synchronization', () async {
    final snapshotStarted = Completer<void>();
    final releaseSnapshot = Completer<void>();
    var changesCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/snapshot')) {
        if (!snapshotStarted.isCompleted) snapshotStarted.complete();
        await releaseSnapshot.future;
        return http.Response(
          jsonEncode({
            'task_lists': [],
            'tasks': [],
            'cursor': 'snapshot-cursor',
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/sync/changes')) {
        changesCalls++;
        return http.Response(
          jsonEncode({
            'changes': [],
            'next_cursor': 'cursor-$changesCalls',
            'has_more': false,
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });
    final sync = engine(client);

    final first = sync.synchronize(ignoreStopped: true);
    await snapshotStarted.future;
    var secondCompleted = false;
    final second = sync.synchronize(ignoreStopped: true).then((_) {
      secondCompleted = true;
    });
    await Future<void>.delayed(Duration.zero);

    expect(secondCompleted, isFalse);
    releaseSnapshot.complete();
    await Future.wait([first, second]);

    expect(secondCompleted, isTrue);
    expect(changesCalls, 4);
  });

  test('422 validation failure becomes terminal and is not retried', () async {
    await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Invalid task',
      date: null,
      taskListId: null,
    );
    var pushCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/operations')) {
        pushCalls++;
        operationDocument(request);
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'validation_error',
              'message': 'Invalid payload',
              'details': {},
            },
          }),
          422,
        );
      }
      if (request.url.path.endsWith('/sync/snapshot')) {
        return http.Response(
          jsonEncode({
            'task_lists': [],
            'tasks': [],
            'cursor': 'snapshot',
          }),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'changes': [],
          'next_cursor': 'cursor',
          'has_more': false,
        }),
        200,
      );
    });
    final sync = engine(client);

    await sync.synchronize(ignoreStopped: true);
    await sync.synchronize(ignoreStopped: true);

    final rows = await db.select(db.outboxTable).get();
    expect(pushCalls, 1);
    expect(rows, hasLength(1));
    expect(rows.single.isTerminal, isTrue);
    expect(rows.single.retryCount, 1);
    expect(rows.single.lastError, contains('Invalid payload'));
  });

  test('restores a completed task through import and completed change',
      () async {
    await store.applyChangesPage(
      userId: 'user-1',
      changes: const [
        {
          'entity': 'task',
          'action': 'completed',
          'version': 7,
          'data': {
            'id': 'task-1',
            'name': 'Completed task',
            'is_completed': true,
            'date': '2026-08-07',
            'position': 37,
            'version': 7,
            'updated_at': '2026-08-13T10:00:00.000Z',
          },
        },
      ],
      nextCursor: 'cursor-7',
      pendingEntityIds: const {},
    );
    await store.updateTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      id: 'task-1',
      type: OutboxOpType.toggleTaskCompleted,
      patch: const {'is_completed': false},
    );
    final queued = (await outbox.pending('user-1')).single;

    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/operations')) {
        final body = operationDocument(request);
        final operation = (body['operations'] as List).single as Map;
        expect(operation['operation_id'], queued.operationId);
        expect(operation['type'], 'toggleTaskCompleted');
        expect(operation['entity_id'], 'task-1');
        final payload = operation['payload'] as Map;
        expect(payload.containsKey('is_completed'), isTrue);
        expect(payload['is_completed'], isFalse);
        expect(payload['is_completed'], isA<bool>());
        return http.Response(
          jsonEncode({
            'operation_id': queued.operationId,
            'server_id': 'task-1',
            'entity_version': 8,
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/sync/changes')) {
        expect(request.url.queryParameters['cursor'], 'cursor-7');
        return http.Response(
          jsonEncode({
            'changes': [
              {
                'entity': 'task',
                'action': 'completed',
                'version': 8,
                'data': {
                  'id': 'task-1',
                  'name': 'Completed task',
                  'is_completed': false,
                  'date': '2026-08-07',
                  'position': 37,
                  'version': 8,
                  'updated_at': '2026-08-13T10:30:00.000Z',
                },
              },
            ],
            'next_cursor': 'cursor-8',
            'has_more': false,
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    await engine(client).synchronize(ignoreStopped: true);

    expect(await outbox.pending('user-1'), isEmpty);
    expect(await store.cursorFor('user-1'), 'cursor-8');
    final task = await store.taskById('user-1', 'task-1');
    expect(task, isNotNull);
    expect(task!.isCompleted, isFalse);
    expect(task.dateYmd, '2026-08-07');
    expect(task.position, 37);
    expect(task.version, 8);
    expect(
        task.updatedAt.toUtc().toIso8601String(), '2026-08-13T10:30:00.000Z');
  });

  test('pushes queued operations individually', () async {
    await outbox.enqueue(
      deviceId: 'device-1',
      accountId: 'user-1',
      type: OutboxOpType.createTask,
      entityId: 'child-1',
      payload: const {
        'id': 'child-1',
        'name': 'Child',
        'task_list_id': 'list-1',
        'parent_task_id': 'root-1',
      },
      operationId: 'child-op',
    );
    await outbox.enqueue(
      deviceId: 'device-1',
      accountId: 'user-1',
      type: OutboxOpType.createTask,
      entityId: 'root-1',
      payload: const {
        'id': 'root-1',
        'name': 'Root',
        'task_list_id': 'list-1',
        'parent_task_id': null,
      },
      operationId: 'root-op',
    );
    await outbox.enqueue(
      deviceId: 'device-1',
      accountId: 'user-1',
      type: OutboxOpType.createTaskList,
      entityId: 'list-1',
      payload: const {
        'id': 'list-1',
        'name': 'Personal',
        'color_hex': '#FF9500',
      },
      operationId: 'list-op',
    );

    final pushedIds = <String>[];
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/operations')) {
        final body = operationDocument(request);
        final operation = (body['operations'] as List).single as Map;
        pushedIds.add(operation['operation_id'] as String);
        return http.Response(
          jsonEncode({
            'operation_id': operation['operation_id'],
            'server_id': operation['entity_id'],
            'entity_version': 1,
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/sync/snapshot')) {
        return http.Response(
          jsonEncode({'task_lists': [], 'tasks': [], 'cursor': 'snapshot'}),
          200,
        );
      }
      return http.Response(
        jsonEncode({
          'changes': [],
          'next_cursor': 'cursor',
          'has_more': false,
        }),
        200,
      );
    });

    await engine(client).synchronize(ignoreStopped: true);

    expect(await outbox.pending('user-1'), isEmpty);
    expect(pushedIds, ['child-op', 'root-op', 'list-op']);
  });

  test('410 cursor_expired loads snapshot and resumes from new cursor',
      () async {
    await store.setCursor('user-1', 'expired');
    var changesCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/changes')) {
        changesCalls++;
        if (changesCalls == 1) {
          expect(request.url.queryParameters['cursor'], 'expired');
          return http.Response(
            jsonEncode({
              'error': {
                'code': 'cursor_expired',
                'message': 'Expired',
              },
            }),
            410,
          );
        }
        expect(request.url.queryParameters['cursor'], 'snapshot-cursor');
        return http.Response(
          jsonEncode({
            'changes': [],
            'next_cursor': 'final-cursor',
            'has_more': false,
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/sync/snapshot')) {
        return http.Response(
          jsonEncode({
            'task_lists': [],
            'tasks': [],
            'cursor': 'snapshot-cursor',
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    await engine(client).synchronize(ignoreStopped: true);

    expect(changesCalls, 3);
    expect(await store.cursorFor('user-1'), 'final-cursor');
  });

  test('version conflict pulls, renews operation id, and retries', () async {
    await store.applyChangesPage(
      userId: 'user-1',
      changes: const [
        {
          'entity': 'task',
          'action': 'updated',
          'version': 1,
          'data': {'id': 'task-1', 'name': 'Old', 'version': 1},
        },
      ],
      nextCursor: 'cursor-1',
      pendingEntityIds: const {},
    );
    await store.updateTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      id: 'task-1',
      patch: const {'name': 'My edit'},
    );
    final originalId = (await outbox.pending('user-1')).single.operationId;
    final sentIds = <String>[];
    var changesCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/operations')) {
        final operation = jsonDecode(request.body) as Map<String, dynamic>;
        sentIds.add(operation['operation_id'] as String);
        if (sentIds.length == 1) {
          expect((operation['payload'] as Map)['expected_version'], 2);
          return http.Response(
            jsonEncode({
              'error': {
                'code': 'version_conflict',
                'message': 'Conflict',
                'details': {
                  'expected_version': 2,
                  'current_version': 3,
                },
              },
            }),
            409,
          );
        }
        expect((operation['payload'] as Map)['expected_version'], 3);
        return http.Response(
          jsonEncode({
            'operation_id': operation['operation_id'],
            'server_id': 'task-1',
            'entity_version': 4,
          }),
          200,
        );
      }
      if (request.url.path.endsWith('/sync/changes')) {
        changesCalls++;
        return http.Response(
          jsonEncode({
            'changes': changesCalls == 1
                ? [
                    {
                      'entity': 'task',
                      'action': 'updated',
                      'version': 2,
                      'data': {
                        'id': 'task-1',
                        'name': 'Other device edit',
                        'version': 2,
                      },
                    }
                  ]
                : [],
            'next_cursor': 'cursor-${changesCalls + 1}',
            'has_more': false,
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    await engine(client).synchronize(ignoreStopped: true);

    expect(sentIds, hasLength(2));
    expect(sentIds.first, originalId);
    expect(sentIds.last, isNot(originalId));
    expect((await store.taskById('user-1', 'task-1'))!.name, 'My edit');
    expect(await outbox.pending('user-1'), isEmpty);
  });
}
