import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:jospar/core/constants/constants.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/device_registration_service.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:jospar/core/services/offline/sqlite_store.dart';

typedef SyncDataChanged = void Function();
typedef SyncErrorHandler = void Function(SyncException error);
typedef AsyncNullableStringGetter = Future<String?> Function();
typedef OnlineCheck = Future<bool> Function();
typedef DeviceRegistrar = Future<void> Function(
  String token,
  String userId,
  String deviceId,
);

enum SyncLogKind { info, sent, received, success, error }

class SyncLogEntry {
  const SyncLogEntry({
    required this.timestamp,
    required this.kind,
    required this.title,
    this.details,
  });

  final DateTime timestamp;
  final SyncLogKind kind;
  final String title;
  final String? details;
}

class SyncEngine with WidgetsBindingObserver {
  SyncEngine({
    required this.outbox,
    required this.store,
    this.onDataChanged,
    this.onOperationError,
    http.Client? client,
    AsyncNullableStringGetter? tokenProvider,
    AsyncNullableStringGetter? deviceIdProvider,
    AsyncNullableStringGetter? userIdProvider,
    OnlineCheck? onlineCheck,
    DeviceRegistrar? deviceRegistrar,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider ?? AuthStorage().getToken,
        _deviceIdProvider = deviceIdProvider ?? AuthStorage().getDeviceId,
        _userIdProvider = userIdProvider ?? AuthStorage().getUserId,
        _onlineCheck = onlineCheck,
        _deviceRegistrar = deviceRegistrar;

  final OutboxStore outbox;
  final SqliteStore store;
  final SyncDataChanged? onDataChanged;
  final SyncErrorHandler? onOperationError;
  final http.Client _client;
  final AsyncNullableStringGetter _tokenProvider;
  final AsyncNullableStringGetter _deviceIdProvider;
  final AsyncNullableStringGetter _userIdProvider;
  final OnlineCheck? _onlineCheck;
  final DeviceRegistrar? _deviceRegistrar;

  Future<void>? _activeSync;
  bool _syncRequested = false;
  Object? _lastError;
  bool _stopped = true;
  Timer? _timer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<SyncLogEntry> _logController =
      StreamController<SyncLogEntry>.broadcast();
  final List<SyncLogEntry> _logs = <SyncLogEntry>[];

  Object? get lastError => _lastError;
  Stream<SyncLogEntry> get logStream => _logController.stream;
  List<SyncLogEntry> get logs => List.unmodifiable(_logs);
  bool get isRunning => _activeSync != null;
  int lastPullChangeCount = 0;
  bool lastPullCursorUpdated = false;

  void _log(SyncLogKind kind, String title, [String? details]) {
    final entry = SyncLogEntry(
      timestamp: DateTime.now(),
      kind: kind,
      title: title,
      details: details,
    );
    _logs.add(entry);
    if (_logs.length > 200) _logs.removeAt(0);
    _logController.add(entry);
  }

  void start() {
    if (!_stopped) return;
    _stopped = false;
    WidgetsBinding.instance.addObserver(this);
    _timer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => synchronize(),
    );
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) synchronize();
    });
    synchronize();
  }

  Future<void> stop() async {
    _stopped = true;
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _client.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) synchronize();
  }

  Future<void> synchronize({bool ignoreStopped = false}) {
    if (_stopped && !ignoreStopped) return Future<void>.value();
    _syncRequested = true;
    final running = _activeSync;
    if (running != null) return running;

    final future = _runSyncLoop(ignoreStopped: ignoreStopped);
    _activeSync = future;
    return future;
  }

  Future<void> _runSyncLoop({required bool ignoreStopped}) async {
    _lastError = null;
    _log(SyncLogKind.info, 'Синхронизация запущена');

    try {
      while (_syncRequested) {
        _syncRequested = false;
        if (_stopped && !ignoreStopped) return;
        if (!await _canSync()) {
          _lastError = const SyncUnavailableException(
            'Нет подключения к интернету',
          );
          _log(SyncLogKind.error, 'Нет подключения к интернету');
          return;
        }

        final token = await _tokenProvider();
        final deviceId = await _deviceIdProvider();
        final userId = await _userIdProvider();
        if (token == null || deviceId == null || userId == null) {
          _lastError = const SyncUnavailableException(
            'Не найдены данные авторизации или идентификатор устройства',
          );
          _log(
            SyncLogKind.error,
            'Нет данных авторизации или устройства',
          );
          return;
        }

        if (_deviceRegistrar != null) {
          await _deviceRegistrar(token, userId, deviceId);
        } else {
          await DeviceRegistrationService(client: _client).ensureRegistered(
            token: token,
            userId: userId,
            deviceId: deviceId,
          );
        }
        await store.claimAnonymousData(userId);
        var cursor = await store.cursorFor(userId);
        if (cursor == null) {
          await _applySnapshot(
            token: token,
            deviceId: deviceId,
            userId: userId,
          );
          cursor = await store.cursorFor(userId);
        }
        await _pullUntilComplete(
          token: token,
          deviceId: deviceId,
          userId: userId,
          initialCursor: cursor,
        );
        await _pushPending(
          token: token,
          deviceId: deviceId,
          userId: userId,
        );
        cursor = await store.cursorFor(userId);
        await _pullUntilComplete(
          token: token,
          deviceId: deviceId,
          userId: userId,
          initialCursor: cursor,
        );
      }
      if (_lastError == null) {
        _log(SyncLogKind.success, 'Синхронизация завершена успешно');
      }
    } on SyncException catch (error) {
      _lastError = error;
      _log(SyncLogKind.error, 'Ошибка синхронизации', error.toString());
      // A queued retry, next connectivity event, or periodic run recovers.
    } on http.ClientException catch (error) {
      _lastError = error;
      _log(SyncLogKind.error, 'Ошибка сети', error.toString());
      // Network failures are expected in offline-first mode.
    } on DeviceRegistrationException catch (error) {
      _lastError = error;
      _log(
          SyncLogKind.error, 'Ошибка регистрации устройства', error.toString());
      // Registration will be retried on the next sync trigger.
    } catch (error) {
      _lastError = error;
      _log(SyncLogKind.error, 'Неизвестная ошибка', error.toString());
      // Background synchronization must never crash the UI isolate.
    } finally {
      _activeSync = null;
      if (_syncRequested) unawaited(synchronize(ignoreStopped: ignoreStopped));
    }
  }

  Future<bool> _canSync() async {
    if (_onlineCheck != null) return _onlineCheck();
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<void> _pushPending({
    required String token,
    required String deviceId,
    required String userId,
  }) async {
    while (true) {
      final operations = await outbox.pending(userId);
      if (operations.isEmpty) return;
      var operation = operations.first;
      try {
        _log(
          SyncLogKind.sent,
          'Отправка на бэкенд: 1',
          '${operation.type.name}: ${_entityId(operation) ?? '-'}',
        );
        while (true) {
          final document = _operationDocument(operation);
          debugPrint('SYNC REQUEST: ${jsonEncode(document)}');
          late final http.Response response;
          outbox.markSending(operation);
          try {
            response = await _client.post(
              Uri.parse('${Constants.baseUrl}/v1/sync/operations'),
              headers: _headers(token),
              body: jsonEncode(document),
            );
          } finally {
            outbox.unmarkSending(operation);
          }
          debugPrint('SYNC HTTP: ${response.statusCode}');
          debugPrint('SYNC BODY: ${response.body}');
          if (_successful(response.statusCode)) {
            final result = _decodeObject(response.body);
            if (result['operation_id']?.toString() != operation.operationId) {
              throw const SyncException(
                statusCode: 500,
                body: 'Invalid sync operation response',
                code: 'invalid_response',
                message: 'Сервер вернул некорректный результат операции',
              );
            }
            await store.db.transaction(() async {
              await store.markOperationSynced(
                operation,
                accountId: userId,
                serverId: result['server_id']?.toString(),
                version: _asInt(result['entity_version']),
              );
              await outbox.remove(operation.localRowId);
            });
            final entityId = _entityId(operation);
            final entityVersion = _asInt(result['entity_version']);
            if (entityId != null && entityVersion != null) {
              await _rebaseEntityPending(userId, entityId, entityVersion);
            }
            _log(SyncLogKind.success, 'Ответ бэкенда: обработано 1, ошибок 0');
            break;
          }
          final error = SyncException.fromResponse(response);
          if (error.code == 'version_conflict') {
            if (operation.retries >= 2) throw error;
            final entityId = _entityId(operation);
            await _pullUntilComplete(
              token: token,
              deviceId: deviceId,
              userId: userId,
              initialCursor: await store.cursorFor(userId),
            );
            if (entityId == null ||
                await store.taskById(userId, entityId) == null) {
              throw const SyncException(
                statusCode: 404,
                body: 'Entity disappeared while rebasing operation',
                code: 'task_not_found',
                message: 'Задача больше не существует',
              );
            }
            final payload = Map<String, dynamic>.from(operation.payload);
            final version = _asInt(error.details?['current_version']) ??
                await _entityVersion(userId, operation);
            payload.remove('version');
            if (version != null) payload['expected_version'] = version;
            operation = await outbox.renewForRetry(operation, payload: payload);
            await store.reapplyOptimisticOperation(userId, operation);
            continue;
          }
          throw error;
        }
      } on SyncException catch (error) {
        _lastError = error;
        final terminal = error.isTerminalOperationFailure;
        await outbox.recordFailure(operation, error, terminal: terminal);
        if (terminal) onOperationError?.call(error);
        if (terminal) {
          await store.discardOptimisticOperation(
            operation,
            accountId: userId,
          );
          if (error.statusCode == 403 || error.statusCode == 404) {
            await store.clearUserSyncState(userId);
            await _applySnapshot(
              token: token,
              deviceId: deviceId,
              userId: userId,
            );
          }
        }
        break;
      } catch (error) {
        _lastError = error;
        await outbox.recordFailure(operation, error, terminal: false);
        break;
      }
    }
  }

  Future<void> _rebaseEntityPending(
    String userId,
    String entityId,
    int version,
  ) async {
    for (final operation in await outbox.queued(userId)) {
      if (_entityId(operation) != entityId ||
          !_usesExpectedVersion(operation.type)) {
        continue;
      }
      await outbox.rebase(operation, version: version);
    }
  }

  Map<String, dynamic> _operationDocument(OutboxOp operation) => {
        'operation_id': operation.operationId,
        'device_id': operation.deviceId,
        'type': operation.type.name,
        'entity_id': _entityId(operation),
        'client_timestamp': operation.clientTimestamp.toUtc().toIso8601String(),
        'payload': _normalizedPayload(operation),
      };

  Map<String, dynamic> _normalizedPayload(OutboxOp operation) {
    final payload = Map<String, dynamic>.from(operation.payload);
    final legacyVersion = payload.remove('version');
    if (_usesExpectedVersion(operation.type) &&
        !payload.containsKey('expected_version') &&
        legacyVersion != null) {
      payload['expected_version'] = legacyVersion;
    }
    final allowedFields = switch (operation.type) {
      OutboxOpType.createTask => const {
          'id',
          'name',
          'note',
          'date',
          'notification_time',
          'urgency',
          'position',
          'task_list_id',
          'parent_task_id',
          'is_completed',
        },
      OutboxOpType.updateTask => const {
          'name',
          'note',
          'date',
          'notification_time',
          'urgency',
          'position',
          'task_list_id',
          'parent_task_id',
          'is_completed',
          'expected_version',
          'updated_at',
        },
      OutboxOpType.toggleTaskCompleted => const {
          'is_completed',
          'expected_version',
        },
      OutboxOpType.deleteTask || OutboxOpType.restoreTask => const {
          'expected_version',
        },
      OutboxOpType.clearTrash ||
      OutboxOpType.deleteTaskList =>
        const <String>{},
      OutboxOpType.createTaskList => const {
          'id',
          'name',
          'color_hex',
          'is_hidden',
        },
      OutboxOpType.updateTaskList => const {
          'name',
          'color_hex',
          'is_hidden',
        },
    };
    payload.removeWhere((key, _) => !allowedFields.contains(key));
    return payload;
  }

  bool _usesExpectedVersion(OutboxOpType type) =>
      type == OutboxOpType.updateTask ||
      type == OutboxOpType.toggleTaskCompleted ||
      type == OutboxOpType.deleteTask ||
      type == OutboxOpType.restoreTask;

  Future<int?> _entityVersion(String userId, OutboxOp operation) async {
    final id = _entityId(operation);
    if (id == null) return null;
    if (operation.type.name.endsWith('TaskList')) {
      final row = await (store.db.select(store.db.taskListsTable)
            ..where((table) =>
                table.serverId.equals(id) & table.accountId.equals(userId)))
          .getSingleOrNull();
      return row?.version;
    }
    return (await store.taskById(userId, id))?.version;
  }

  String? _entityId(OutboxOp operation) {
    final direct = operation.entityId;
    if (direct != null && direct.isNotEmpty) return direct;
    final payloadId = operation.payload['id']?.toString();
    return payloadId == null || payloadId.isEmpty ? null : payloadId;
  }

  Future<void> _pullUntilComplete({
    required String token,
    required String deviceId,
    required String userId,
    required String? initialCursor,
  }) async {
    var cursor = initialCursor;
    var hasMore = true;
    var pulledChanges = 0;
    var cursorUpdated = false;
    while (hasMore) {
      final uri = Uri.parse('${Constants.baseUrl}/v1/sync/changes').replace(
        queryParameters: {
          'device_id': deviceId,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
          'limit': '500',
        },
      );
      final response = await _client.get(uri, headers: _headers(token));
      if (response.statusCode == 410) {
        final error = SyncException.fromResponse(response);
        if (error.code == 'cursor_expired' || error.code == null) {
          await store.clearUserSyncState(userId);
          await _applySnapshot(
            token: token,
            deviceId: deviceId,
            userId: userId,
          );
          cursor = await store.cursorFor(userId);
          continue;
        }
      }
      if (!_successful(response.statusCode)) {
        throw SyncException.fromResponse(response);
      }

      final body = _decodeObject(response.body);
      final nextCursor = body['next_cursor']?.toString();
      final changes = body['changes'] as List<dynamic>? ?? const [];
      pulledChanges += changes.length;
      cursorUpdated = cursorUpdated || nextCursor != cursor;
      _log(
        SyncLogKind.received,
        'Получено с бэкенда: ${changes.length}',
        changes.whereType<Map>().map((change) {
          final type = change['type'] ?? change['entity_type'] ?? 'change';
          final id = change['entity_id'] ?? change['id'] ?? '-';
          return '$type: $id';
        }).join('\n'),
      );
      await store.applyChangesPage(
        userId: userId,
        changes: changes,
        nextCursor: nextCursor,
        pendingEntityIds: const {},
      );
      await _rebaseAndReapplyPending(userId);
      cursor = nextCursor;
      hasMore = body['has_more'] == true;
      onDataChanged?.call();
    }
    lastPullChangeCount = pulledChanges;
    lastPullCursorUpdated = cursorUpdated;
  }

  Future<void> _rebaseAndReapplyPending(String userId) async {
    for (var operation in await outbox.queued(userId)) {
      if (_usesExpectedVersion(operation.type)) {
        final version = await _entityVersion(userId, operation);
        if (version != null) {
          operation = await outbox.rebase(operation, version: version);
        }
      }
      await store.reapplyOptimisticOperation(userId, operation);
    }
  }

  Future<void> _applySnapshot({
    required String token,
    required String deviceId,
    required String userId,
  }) async {
    final uri = Uri.parse('${Constants.baseUrl}/v1/sync/snapshot').replace(
      queryParameters: {'device_id': deviceId},
    );
    final response = await _client.get(uri, headers: _headers(token));
    if (!_successful(response.statusCode)) {
      throw SyncException.fromResponse(response);
    }
    final body = _decodeObject(response.body);
    final tasks = body['tasks'] as List<dynamic>? ?? const [];
    final taskLists = body['task_lists'] as List<dynamic>? ?? const [];
    _log(
      SyncLogKind.received,
      'Получен полный снимок',
      'Задачи: ${tasks.length}\nСписки: ${taskLists.length}',
    );
    await store.applySnapshot(
      userId: userId,
      tasks: tasks,
      taskLists: taskLists,
      cursor: body['cursor']?.toString(),
    );
    await _rebaseAndReapplyPending(userId);
    onDataChanged?.call();
  }

  Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  bool _successful(int statusCode) => statusCode >= 200 && statusCode < 300;

  Map<String, dynamic> _decodeObject(String body) {
    if (body.isEmpty) return const {};
    final decoded = jsonDecode(body);
    return decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}

class SyncUnavailableException implements Exception {
  const SyncUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SyncException implements Exception {
  const SyncException({
    required this.statusCode,
    required this.body,
    this.code,
    this.message,
    this.details,
  });

  factory SyncException.fromResponse(http.Response response) {
    String? code;
    String? message;
    Map<String, dynamic>? details;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        final error = decoded['error'] as Map;
        code = error['code']?.toString();
        message = error['message']?.toString();
        if (error['details'] is Map) {
          details = Map<String, dynamic>.from(error['details'] as Map);
        }
      }
    } catch (_) {
      // The raw response remains available for diagnostics.
    }
    return SyncException(
      statusCode: response.statusCode,
      body: response.body,
      code: code,
      message: message,
      details: details,
    );
  }

  final int statusCode;
  final String body;
  final String? code;
  final String? message;
  final Map<String, dynamic>? details;

  bool get isTerminalOperationFailure =>
      statusCode == 401 ||
      statusCode == 403 ||
      statusCode == 404 ||
      statusCode == 409 ||
      statusCode == 410 ||
      statusCode == 422;

  @override
  String toString() =>
      message ?? 'Sync failed ($statusCode${code == null ? '' : ', $code'})';
}
