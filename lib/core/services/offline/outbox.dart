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
  createShare,
  revokeShare,
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
    if (retries <= 1) return 1;
    final seconds = 1 << (retries - 1).clamp(0, 6);
    return seconds > 60 ? 60 : seconds;
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
