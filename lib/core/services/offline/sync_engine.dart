import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:jospar/core/constants/constants.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/device_registration_service.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:jospar/core/services/offline/sqlite_store.dart';

typedef SyncDataChanged = void Function();
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
  final http.Client _client;
  final AsyncNullableStringGetter _tokenProvider;
  final AsyncNullableStringGetter _deviceIdProvider;
  final AsyncNullableStringGetter _userIdProvider;
  final OnlineCheck? _onlineCheck;
  final DeviceRegistrar? _deviceRegistrar;

  bool _running = false;
  bool _rerunRequested = false;
  Completer<void>? _activeSynchronization;
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
  bool get isRunning => _running;
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
      const Duration(seconds: 30),
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

  Future<void> synchronize({bool ignoreStopped = false}) async {
    if (_stopped && !ignoreStopped) return;
    if (_running) {
      _rerunRequested = true;
      await _activeSynchronization?.future;
      return;
    }
    _running = true;
    _lastError = null;
    _log(SyncLogKind.info, 'Синхронизация запущена');
    final synchronization = Completer<void>();
    _activeSynchronization = synchronization;

    try {
      do {
        _rerunRequested = false;
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
        await _pushPending(token, userId);
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
      } while (_rerunRequested);
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
      _running = false;
      if (!synchronization.isCompleted) synchronization.complete();
      if (identical(_activeSynchronization, synchronization)) {
        _activeSynchronization = null;
      }
    }
  }

  Future<bool> _canSync() async {
    if (_onlineCheck != null) return _onlineCheck();
    final results = await Connectivity().checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  Future<void> _pushPending(String token, String userId) async {
    final operations = await outbox.pending(userId);
    if (operations.isEmpty) return;

    final ordered = _orderForImport(operations);
    for (final batch in _importBatches(ordered)) {
      try {
        _log(
          SyncLogKind.sent,
          'Отправка на бэкенд: ${batch.length}',
          batch
              .map((operation) =>
                  '${operation.type.name}: ${_entityId(operation) ?? '-'}')
              .join('\n'),
        );
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${Constants.baseUrl}/v1/sync/import'),
        )
          ..headers.addAll({
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          })
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              utf8.encode(jsonEncode(_importDocument(batch))),
              filename: 'sync.json',
              contentType: http.MediaType('application', 'json'),
            ),
          );
        final streamed = await _client.send(request);
        final response = await http.Response.fromStream(streamed);
        if (!_successful(response.statusCode)) {
          throw SyncException.fromResponse(response);
        }

        final responseBody = _decodeObject(response.body);
        if (responseBody['schema_version'] != 1 ||
            responseBody['results'] is! List) {
          throw const SyncException(
            statusCode: 500,
            body: 'Invalid sync import response',
            code: 'invalid_response',
            message: 'Сервер вернул некорректный результат импорта',
          );
        }
        final byId = {
          for (final operation in batch) operation.operationId: operation,
        };
        final returnedIds = <String>{};
        var processedCount = 0;
        var rejectedCount = 0;
        for (final raw in responseBody['results'] as List) {
          if (raw is! Map) continue;
          final result = Map<String, dynamic>.from(raw);
          final operationId = result['operation_id']?.toString();
          final operation = byId[operationId];
          if (operation == null || operationId == null) continue;
          returnedIds.add(operationId);
          if (result['status'] == 'processed') {
            processedCount++;
            await store.db.transaction(() async {
              await store.markOperationSynced(
                operation,
                accountId: userId,
                serverId: result['server_id']?.toString(),
                version: _asInt(result['entity_version']),
              );
              await outbox.remove(operation.localRowId);
            });
            continue;
          }
          rejectedCount++;
          final error = result['error'];
          final message = error is Map
              ? error['message']?.toString() ?? jsonEncode(error)
              : 'Операция импорта отклонена сервером';
          await outbox.recordFailure(operation, message, terminal: false);
        }
        _log(
          rejectedCount == 0 ? SyncLogKind.success : SyncLogKind.error,
          'Ответ бэкенда: обработано $processedCount, ошибок $rejectedCount',
        );
        for (final operation in batch) {
          if (!returnedIds.contains(operation.operationId)) {
            await outbox.recordFailure(
              operation,
              'Сервер не вернул результат операции',
              terminal: false,
            );
          }
        }
      } on SyncException catch (error) {
        _lastError = error;
        for (final operation in batch) {
          await outbox.recordFailure(operation, error, terminal: false);
        }
        break;
      } catch (error) {
        _lastError = error;
        for (final operation in batch) {
          await outbox.recordFailure(operation, error, terminal: false);
        }
        break;
      }
    }
  }

  static const int _maxImportOperations = 500;
  static const int _maxImportBytes = 10 * 1024 * 1024;

  List<OutboxOp> _orderForImport(List<OutboxOp> operations) {
    final originalIndex = <int, int>{
      for (var i = 0; i < operations.length; i++) operations[i].localRowId: i,
    };
    final createTasksById = <String, OutboxOp>{};
    for (final operation in operations) {
      if (operation.type != OutboxOpType.createTask) continue;
      final id = _entityId(operation);
      if (id != null) createTasksById[id] = operation;
    }
    final depthCache = <String, int>{};
    int taskDepth(OutboxOp operation, Set<String> visiting) {
      final id = _entityId(operation);
      if (id == null) return 0;
      final cached = depthCache[id];
      if (cached != null) return cached;
      if (!visiting.add(id)) return 0;
      final parentId = operation.payload['parent_task_id']?.toString();
      final parent = parentId == null ? null : createTasksById[parentId];
      final depth = parent == null ? 0 : taskDepth(parent, visiting) + 1;
      visiting.remove(id);
      depthCache[id] = depth;
      return depth;
    }

    final ordered = List<OutboxOp>.from(operations);
    ordered.sort((left, right) {
      final leftRank = _importRank(left, taskDepth(left, <String>{}));
      final rightRank = _importRank(right, taskDepth(right, <String>{}));
      final rankComparison = leftRank.compareTo(rightRank);
      if (rankComparison != 0) return rankComparison;
      return originalIndex[left.localRowId]!
          .compareTo(originalIndex[right.localRowId]!);
    });
    return ordered;
  }

  int _importRank(OutboxOp operation, int taskDepth) {
    if (operation.type == OutboxOpType.createTaskList) return 0;
    if (operation.type == OutboxOpType.createTask) return 1 + taskDepth;
    if (operation.type == OutboxOpType.createShare) return 1000000;
    return 500000;
  }

  Iterable<List<OutboxOp>> _importBatches(List<OutboxOp> operations) sync* {
    var batch = <OutboxOp>[];
    for (final operation in operations) {
      final candidate = [...batch, operation];
      final size = utf8.encode(jsonEncode(_importDocument(candidate))).length;
      if (candidate.length > _maxImportOperations || size > _maxImportBytes) {
        if (batch.isEmpty) {
          throw const SyncException(
            statusCode: 413,
            body: 'Single operation exceeds 10 MB',
            code: 'import_too_large',
            message: 'Одна операция синхронизации превышает 10 МБ',
          );
        }
        yield batch;
        batch = [operation];
        final singleSize =
            utf8.encode(jsonEncode(_importDocument(batch))).length;
        if (singleSize > _maxImportBytes) {
          throw const SyncException(
            statusCode: 413,
            body: 'Single operation exceeds 10 MB',
            code: 'import_too_large',
            message: 'Одна операция синхронизации превышает 10 МБ',
          );
        }
      } else {
        batch = candidate;
      }
    }
    if (batch.isNotEmpty) yield batch;
  }

  Map<String, dynamic> _importDocument(List<OutboxOp> operations) => {
        'schema_version': 1,
        'operations': operations
            .map(
              (operation) => {
                'operation_id': operation.operationId,
                'type': operation.type.name,
                'entity_id': _entityId(operation),
                'payload': operation.payload,
              },
            )
            .toList(growable: false),
      };

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
        pendingEntityIds: await outbox.pendingEntityIds(userId),
      );
      cursor = nextCursor;
      hasMore = body['has_more'] == true;
      onDataChanged?.call();
    }
    lastPullChangeCount = pulledChanges;
    lastPullCursorUpdated = cursorUpdated;
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
  });

  factory SyncException.fromResponse(http.Response response) {
    String? code;
    String? message;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        final error = decoded['error'] as Map;
        code = error['code']?.toString();
        message = error['message']?.toString();
      }
    } catch (_) {
      // The raw response remains available for diagnostics.
    }
    return SyncException(
      statusCode: response.statusCode,
      body: response.body,
      code: code,
      message: message,
    );
  }

  final int statusCode;
  final String body;
  final String? code;
  final String? message;

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
