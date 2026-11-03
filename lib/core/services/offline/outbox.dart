import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:jospar/core/db/app_db.dart';
import 'package:uuid/uuid.dart';

enum OutboxOpType {
  createTask,
  updateTask,
  deleteTask,
  toggleTaskCompleted,
  restoreTask,
  clearTrash,
  createTaskList,
  updateTaskList,
  deleteTaskList,
}

class OutboxOp {
  const OutboxOp({
    required this.localRowId,
    required this.operationId,
    required this.deviceId,
    required this.type,
    required this.entityId,
    required this.payload,
    required this.clientTimestamp,
    required this.retries,
    this.lastError,
  });

  final int localRowId;
  final String operationId;
  final String deviceId;
  final OutboxOpType type;
  final String? entityId;
  final Map<String, dynamic> payload;
  final DateTime clientTimestamp;
  final int retries;
  final String? lastError;
}

class OutboxStore {
  OutboxStore(this.db);

  final AppDb db;
  final Set<int> _sendingRows = <int>{};

  static String newId() => const Uuid().v4();

  Future<void> enqueue({
    required String deviceId,
    required String accountId,
    required OutboxOpType type,
    required String? entityId,
    required Map<String, dynamic> payload,
    String? operationId,
    DateTime? clientTimestamp,
  }) {
    final now = (clientTimestamp ?? DateTime.now()).toUtc();
    return db.into(db.outboxTable).insert(
          OutboxTableCompanion.insert(
            operationId: Value(operationId ?? newId()),
            deviceId: Value(deviceId),
            accountId: Value(accountId),
            type: type.name,
            entityId: Value(entityId),
            payloadJson: jsonEncode(payload),
            clientTimestamp: Value(now),
            nextAttemptAt: Value(now),
            createdAt: Value(now),
          ),
        );
  }

  Future<void> enqueueOrMergeTaskMutation({
    required String deviceId,
    required String accountId,
    required OutboxOpType type,
    required String entityId,
    required Map<String, dynamic> payload,
    DateTime? clientTimestamp,
  }) async {
    final rows = await (db.select(db.outboxTable)
          ..where(
            (row) =>
                row.accountId.equals(accountId) &
                row.entityId.equals(entityId) &
                row.type.equals(type.name) &
                row.isTerminal.equals(false) &
                row.retryCount.equals(0) &
                row.lastError.isNull(),
          )
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
        .get();
    for (final row in rows) {
      if (_sendingRows.contains(row.id)) continue;
      final decoded = jsonDecode(row.payloadJson);
      final merged = decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{};
      merged.addAll(payload);
      await (db.update(db.outboxTable)..where((item) => item.id.equals(row.id)))
          .write(
        OutboxTableCompanion(
          payloadJson: Value(jsonEncode(merged)),
          nextAttemptAt: Value(DateTime.now().toUtc()),
          lastError: const Value(null),
        ),
      );
      return;
    }
    await enqueue(
      deviceId: deviceId,
      accountId: accountId,
      type: type,
      entityId: entityId,
      payload: payload,
      clientTimestamp: clientTimestamp,
    );
  }

  void markSending(OutboxOp operation) {
    _sendingRows.add(operation.localRowId);
  }

  void unmarkSending(OutboxOp operation) {
    _sendingRows.remove(operation.localRowId);
  }

  Future<OutboxOp> rebase(
    OutboxOp operation, {
    required int version,
  }) async {
    final payload = Map<String, dynamic>.from(operation.payload)
      ..remove('version')
      ..['expected_version'] = version;
    await (db.update(db.outboxTable)
          ..where((row) => row.id.equals(operation.localRowId)))
        .write(OutboxTableCompanion(payloadJson: Value(jsonEncode(payload))));
    return OutboxOp(
      localRowId: operation.localRowId,
      operationId: operation.operationId,
      deviceId: operation.deviceId,
      type: operation.type,
      entityId: operation.entityId,
      payload: payload,
      clientTimestamp: operation.clientTimestamp,
      retries: operation.retries,
      lastError: operation.lastError,
    );
  }

  Future<List<OutboxOp>> pending(String accountId) async {
    final now = DateTime.now().toUtc();
    final query = db.select(db.outboxTable)
      ..where(
        (row) =>
            row.isTerminal.equals(false) &
            row.operationId.isNotNull() &
            row.deviceId.isNotNull() &
            row.accountId.equals(accountId),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);

    final rows = await query.get();
    final ready = <OutboxTableData>[];
    for (final row in rows) {
      if (row.nextAttemptAt.isAfter(now)) break;
      ready.add(row);
    }
    return ready.map(_fromRow).toList(growable: false);
  }

  Future<List<OutboxOp>> queued(String accountId) async {
    final query = db.select(db.outboxTable)
      ..where(
        (row) =>
            row.isTerminal.equals(false) &
            row.operationId.isNotNull() &
            row.deviceId.isNotNull() &
            row.accountId.equals(accountId),
      )
      ..orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return (await query.get()).map(_fromRow).toList(growable: false);
  }

  Future<Set<String>> pendingEntityIds(String accountId) async {
    final query = db.select(db.outboxTable)
      ..where(
        (row) =>
            row.operationId.isNotNull() &
            row.accountId.equals(accountId) &
            row.isTerminal.equals(false),
      );
    final rows = await query.get();
    final ids = <String>{};
    for (final row in rows) {
      final entityId = row.entityId;
      if (entityId != null && entityId.isNotEmpty) {
        ids.add(entityId);
        continue;
      }
      try {
        final payload = jsonDecode(row.payloadJson);
        if (payload is Map) {
          final payloadId = payload['id']?.toString();
          if (payloadId != null && payloadId.isNotEmpty) ids.add(payloadId);
        }
      } catch (_) {
        // Malformed terminal operations are preserved but have no entity id.
      }
    }
    return ids;
  }

  /// Makes selected queued operations immediately eligible for an explicit
  /// user-requested sync, without clearing their retry history.
  Future<void> retryEntitiesNow(
    String accountId,
    Set<String> entityIds,
  ) async {
    if (entityIds.isEmpty) return;
    final rows = await (db.select(db.outboxTable)
          ..where(
            (row) =>
                row.accountId.equals(accountId) & row.isTerminal.equals(false),
          ))
        .get();
    final rowIds = <int>[];
    for (final row in rows) {
      var entityId = row.entityId;
      if (entityId == null || entityId.isEmpty) {
        try {
          final payload = jsonDecode(row.payloadJson);
          if (payload is Map) entityId = payload['id']?.toString();
        } catch (_) {
          // Invalid operations are left untouched for normal error handling.
        }
      }
      if (entityId != null && entityIds.contains(entityId)) {
        rowIds.add(row.id);
      }
    }
    if (rowIds.isEmpty) return;
    await (db.update(db.outboxTable)..where((row) => row.id.isIn(rowIds)))
        .write(
      OutboxTableCompanion(
        nextAttemptAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> remove(int localRowId) {
    return (db.delete(db.outboxTable)
          ..where((row) => row.id.equals(localRowId)))
        .go();
  }

  Future<OutboxOp> renewForRetry(
    OutboxOp operation, {
    required Map<String, dynamic> payload,
  }) async {
    final operationId = newId();
    final now = DateTime.now().toUtc();
    await (db.update(db.outboxTable)
          ..where((row) => row.id.equals(operation.localRowId)))
        .write(
      OutboxTableCompanion(
        operationId: Value(operationId),
        payloadJson: Value(jsonEncode(payload)),
        nextAttemptAt: Value(now),
        lastError: const Value(null),
        retryCount: Value(operation.retries + 1),
      ),
    );
    return OutboxOp(
      localRowId: operation.localRowId,
      operationId: operationId,
      deviceId: operation.deviceId,
      type: operation.type,
      entityId: operation.entityId,
      payload: payload,
      clientTimestamp: now,
      retries: operation.retries + 1,
    );
  }

  Future<void> recordFailure(
    OutboxOp operation,
    Object error, {
    required bool terminal,
  }) {
    final retries = operation.retries + 1;
    final backoffSeconds = terminal ? 0 : _backoffSeconds(retries);
    return (db.update(db.outboxTable)
          ..where((row) => row.id.equals(operation.localRowId)))
        .write(
      OutboxTableCompanion(
        retryCount: Value(retries),
        nextAttemptAt: Value(
          DateTime.now().toUtc().add(Duration(seconds: backoffSeconds)),
        ),
        lastError: Value(error.toString()),
        isTerminal: Value(terminal),
      ),
    );
  }

  Future<void> clear() => db.delete(db.outboxTable).go();

  int _backoffSeconds(int retries) {
    const delays = [1, 2, 5, 10, 30];
    return delays[(retries - 1).clamp(0, delays.length - 1)];
  }

  OutboxOp _fromRow(OutboxTableData row) {
    final decoded = jsonDecode(row.payloadJson);
    return OutboxOp(
      localRowId: row.id,
      operationId: row.operationId!,
      deviceId: row.deviceId!,
      type: OutboxOpType.values.firstWhere(
        (value) => value.name == row.type,
      ),
      entityId: row.entityId,
      payload: decoded is Map
          ? Map<String, dynamic>.from(decoded)
          : <String, dynamic>{},
      clientTimestamp: row.clientTimestamp,
      retries: row.retryCount,
      lastError: row.lastError,
    );
  }
}
