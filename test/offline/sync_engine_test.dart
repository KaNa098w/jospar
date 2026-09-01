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

  Map<String, dynamic> importDocument(http.Request request) {
    expect(request.headers['authorization'], 'Bearer token');
    expect(request.headers['accept'], 'application/json');
    expect(request.headers['content-type'], startsWith('multipart/form-data;'));
    expect(request.body, contains('name="file"'));
    expect(request.body, contains('filename="sync.json"'));
    final start = request.body.indexOf('{');
    final end = request.body.lastIndexOf('}');
    return jsonDecode(request.body.substring(start, end + 1))
        as Map<String, dynamic>;
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
    final client = MockClient((request) async {
      requests.add(request);
      if (request.method == 'POST' &&
          request.url.path.endsWith('/sync/import')) {
        final body = importDocument(request);
        expect(body['schema_version'], 1);
        final operations = body['operations'] as List;
        final operation = operations.single as Map;
        expect(operation, isNot(contains('device_id')));
        expect(operation['type'], 'createTask');
        expect(operation['entity_id'], localId);
        expect((operation['payload'] as Map)['id'], localId);
        return http.Response(
          jsonEncode({
            'schema_version': 1,
            'processed': 1,
            'failed': 0,
            'results': [
              {
                'operation_id': operation['operation_id'],
                'server_id': localId,
                'entity_version': 1,
                'status': 'processed',
              }
            ],
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
        expect(request.url.queryParameters['cursor'], 'snapshot-1');
        return http.Response(
          jsonEncode({
            'changes': [
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
            'next_cursor': 'cursor-2',
            'has_more': false,
          }),
          200,
        );
      }
      return http.Response('not found', 404);
    });

    await engine(client).synchronize(ignoreStopped: true);

    expect(requests.map((request) => request.method), ['POST', 'GET', 'GET']);
    expect(await outbox.pending('user-1'), isEmpty);
    final task = await store.taskById('user-1', localId);
    expect(task!.name, 'Realtime server task');
    expect(task.version, 2);
    expect(await store.cursorFor('user-1'), 'cursor-2');
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
    expect(changesCalls, 2);
  });

  test('failed import operation remains queued for retry', () async {
    await store.createTask(
      deviceId: 'device-1',
      accountId: 'user-1',
      name: 'Invalid task',
      date: null,
      taskListId: null,
    );
    var pushCalls = 0;
    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/import')) {
        pushCalls++;
        final body = importDocument(request);
        final operation = (body['operations'] as List).single as Map;
        return http.Response(
          jsonEncode({
            'schema_version': 1,
            'processed': 0,
            'failed': 1,
            'results': [
              {
                'operation_id': operation['operation_id'],
                'status': 'failed',
                'error': {
                  'code': 'validation_error',
                  'message': 'Invalid payload',
                  'details': {},
                },
              }
            ],
          }),
          200,
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
    expect(rows.single.isTerminal, isFalse);
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
      if (request.url.path.endsWith('/sync/import')) {
        final body = importDocument(request);
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
            'schema_version': 1,
            'processed': 1,
            'failed': 0,
            'results': [
              {
                'operation_id': queued.operationId,
                'status': 'processed',
                'server_id': 'task-1',
                'entity_version': 8,
              },
            ],
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

  test('import orders lists, root tasks, child tasks, then shares', () async {
    await outbox.enqueue(
      deviceId: 'device-1',
      accountId: 'user-1',
      type: OutboxOpType.createShare,
      entityId: 'root-1',
      payload: const {'task_id': 'root-1'},
      operationId: 'share-op',
    );
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

    final client = MockClient((request) async {
      if (request.url.path.endsWith('/sync/import')) {
        final body = importDocument(request);
        final operations = body['operations'] as List;
        expect(
          operations.map((item) => (item as Map)['operation_id']),
          ['list-op', 'root-op', 'child-op', 'share-op'],
        );
        return http.Response(
          jsonEncode({
            'schema_version': 1,
            'processed': 4,
            'failed': 0,
            'results': [
              for (final item in operations)
                {
                  'operation_id': (item as Map)['operation_id'],
                  'server_id': item['entity_id'],
                  'entity_version': 1,
                  'status': 'processed',
                }
            ],
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

    expect(changesCalls, 2);
    expect(await store.cursorFor('user-1'), 'final-cursor');
  });
}
