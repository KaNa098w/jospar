import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/db/app_db.dart';

void main() {
  test('schema version 1 upgrades to current schema without data loss',
      () async {
    final executor = NativeDatabase.memory(
      setup: (database) {
        database.execute('''
          CREATE TABLE task_lists_table (
            local_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            server_id TEXT NULL,
            name TEXT NOT NULL,
            color_hex TEXT NOT NULL DEFAULT '#CCCCCC',
            is_hidden INTEGER NOT NULL DEFAULT 0,
            is_dirty INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE tasks_table (
            local_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            server_id TEXT NULL,
            name TEXT NOT NULL,
            date_ymd TEXT NULL,
            note TEXT NULL,
            is_completed INTEGER NOT NULL DEFAULT 0,
            urgency TEXT NULL,
            task_list_local_id INTEGER NULL,
            task_list_server_id TEXT NULL,
            parent_local_id INTEGER NULL,
            parent_server_id TEXT NULL,
            is_dirty INTEGER NOT NULL DEFAULT 0,
            is_deleted INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL
          )
        ''');
        database.execute('''
          CREATE TABLE outbox_table (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            created_at INTEGER NOT NULL,
            type TEXT NOT NULL,
            payload_json TEXT NOT NULL,
            retry_count INTEGER NOT NULL DEFAULT 0,
            next_attempt_at INTEGER NOT NULL,
            last_error TEXT NULL
          )
        ''');
        database.execute('''
          INSERT INTO tasks_table (
            server_id, name, is_completed, is_dirty, is_deleted, updated_at
          ) VALUES ('old-task', 'Preserved task', 0, 0, 0, 1)
        ''');
        database.execute('PRAGMA user_version = 1');
      },
    );
    final db = AppDb(executor);
    addTearDown(db.close);

    final tasks = await db.select(db.tasksTable).get();
    final outbox = await db.select(db.outboxTable).get();

    expect(db.schemaVersion, 4);
    expect(tasks.single.serverId, 'old-task');
    expect(tasks.single.name, 'Preserved task');
    expect(tasks.single.accountId, 'anonymous');
    expect(tasks.single.version, 0);
    expect(tasks.single.completedByUserId, isNull);
    expect(tasks.single.completedByJson, isNull);
    expect(tasks.single.completedAt, isNull);
    expect(outbox, isEmpty);
    expect(await db.select(db.syncStatesTable).get(), isEmpty);
    expect(await db.select(db.collaboratorsTable).get(), isEmpty);
  });
}
