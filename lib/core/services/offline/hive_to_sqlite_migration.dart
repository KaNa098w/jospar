import 'package:drift/drift.dart';
import 'package:hive/hive.dart';
import 'package:jospar/core/db/app_db.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HiveToSqliteMigration {
  HiveToSqliteMigration({required this.db, required this.outbox});

  static const _migrationKey = 'hive_to_sqlite_v1_complete';

  final AppDb db;
  final OutboxStore outbox;

  Future<void> runIfNeeded() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_migrationKey) == true) return;

    final deviceId = await AuthStorage().ensureDeviceId();
    final accountId = await AuthStorage().getAccountId();
    final tasksBox = Hive.box('tasks_box');
    final listsBox = Hive.box('task_lists_box');
    final now = DateTime.now().toUtc();

    await db.transaction(() async {
      for (final key in listsBox.keys) {
        final raw = listsBox.get(key);
        if (raw is! Map || raw['items'] is List) continue;
        final json = Map<String, dynamic>.from(raw);
        final id = json['id']?.toString() ?? key.toString();
        final name = json['name']?.toString();
        if (id.isEmpty || name == null || name.isEmpty) continue;
        final existing = await (db.select(db.taskListsTable)
              ..where(
                (table) =>
                    table.serverId.equals(id) &
                    table.accountId.equals(accountId),
              ))
            .getSingleOrNull();
        if (existing != null) continue;
        final color = json['color_hex']?.toString() ?? '#CCCCCC';
        final hidden = json['is_hidden'] == true || json['hidden'] == true;
        await db.into(db.taskListsTable).insert(
              TaskListsTableCompanion.insert(
                serverId: Value(id),
                accountId: Value(accountId),
                name: name,
                colorHex: Value(color),
                isHidden: Value(hidden),
                isDirty: const Value(true),
                createdAt: Value(_parseDate(json['created_at']) ?? now),
                updatedAt: Value(_parseDate(json['updated_at']) ?? now),
              ),
            );
        await outbox.enqueue(
          deviceId: deviceId,
          accountId: accountId,
          type: OutboxOpType.createTaskList,
          entityId: null,
          payload: {
            'id': id,
            'name': name,
            'color_hex': color,
            'is_hidden': hidden,
          },
        );
      }

      for (final key in tasksBox.keys) {
        final raw = tasksBox.get(key);
        if (raw is! Map) continue;
        final json = Map<String, dynamic>.from(raw);
        final id = json['id']?.toString() ?? key.toString();
        final name = json['name']?.toString();
        if (id.isEmpty || name == null || name.isEmpty) continue;
        final existing = await (db.select(db.tasksTable)
              ..where(
                (table) =>
                    table.serverId.equals(id) &
                    table.accountId.equals(accountId),
              ))
            .getSingleOrNull();
        if (existing != null) continue;
        final payload = <String, dynamic>{
          'id': id,
          'name': name,
          'note': json['note']?.toString(),
          'date': json['date']?.toString(),
          'notification_time': json['notification_time']?.toString(),
          'urgency': json['urgency']?.toString(),
          'position': _asInt(json['position']),
          'task_list_id': json['task_list_id']?.toString(),
          'parent_task_id': json['parent_task_id']?.toString(),
          'is_completed': json['is_completed'] == true,
          'trashed': json['trashed'] == true,
        };
        await db.into(db.tasksTable).insert(
              TasksTableCompanion.insert(
                serverId: Value(id),
                accountId: Value(accountId),
                name: name,
                note: Value(payload['note'] as String?),
                dateYmd: Value(payload['date'] as String?),
                notificationTime:
                    Value(payload['notification_time'] as String?),
                urgency: Value(payload['urgency'] as String?),
                position: Value(payload['position'] as int?),
                taskListServerId: Value(payload['task_list_id'] as String?),
                parentServerId: Value(payload['parent_task_id'] as String?),
                isCompleted: Value(payload['is_completed'] as bool),
                trashed: Value(payload['trashed'] as bool),
                isDirty: const Value(true),
                createdAt: Value(_parseDate(json['created_at']) ?? now),
                updatedAt: Value(_parseDate(json['updated_at']) ?? now),
              ),
            );
        await outbox.enqueue(
          deviceId: deviceId,
          accountId: accountId,
          type: OutboxOpType.createTask,
          entityId: null,
          payload: payload,
        );
      }
    });
    await preferences.setBool(_migrationKey, true);
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toUtc();
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
