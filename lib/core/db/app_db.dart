import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_db.g.dart';

class TaskListsTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get accountId => text().withDefault(const Constant('anonymous'))();

  TextColumn get name => text()();
  TextColumn get colorHex => text().withDefault(const Constant('#CCCCCC'))();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class TasksTable extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get accountId => text().withDefault(const Constant('anonymous'))();

  TextColumn get name => text()();
  TextColumn get dateYmd => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get notificationTime => text().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  BoolColumn get trashed => boolean().withDefault(const Constant(false))();
  TextColumn get urgency => text().nullable()();
  IntColumn get position => integer().nullable()();

  IntColumn get taskListLocalId => integer().nullable()();
  TextColumn get taskListServerId => text().nullable()();
  IntColumn get parentLocalId => integer().nullable()();
  TextColumn get parentServerId => text().nullable()();

  TextColumn get hash => text().nullable()();
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();
  TextColumn get collaborationRole => text().nullable()();
  TextColumn get collaboratorsJson => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(0))();

  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

class CollaboratorsTable extends Table {
  TextColumn get taskId => text()();
  TextColumn get userId => text()();
  TextColumn get name => text().nullable()();
  TextColumn get role => text()();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {taskId, userId};
}

class OutboxTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get operationId => text().nullable().unique()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get accountId => text().withDefault(const Constant('anonymous'))();
  TextColumn get type => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get payloadJson => text()();
  DateTimeColumn get clientTimestamp =>
      dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt =>
      dateTime().withDefault(currentDateAndTime)();
  TextColumn get lastError => text().nullable()();
  BoolColumn get isTerminal => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class SyncStatesTable extends Table {
  TextColumn get userId => text()();
  TextColumn get cursor => text().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}

@DriftDatabase(
  tables: [
    TaskListsTable,
    TasksTable,
    CollaboratorsTable,
    OutboxTable,
    SyncStatesTable,
  ],
)
class AppDb extends _$AppDb {
  AppDb([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'jospar.sqlite'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await migrator.addColumn(taskListsTable, taskListsTable.version);
            await migrator.addColumn(taskListsTable, taskListsTable.createdAt);
            await migrator.addColumn(taskListsTable, taskListsTable.deletedAt);

            await migrator.addColumn(tasksTable, tasksTable.notificationTime);
            await migrator.addColumn(tasksTable, tasksTable.trashed);
            await migrator.addColumn(tasksTable, tasksTable.position);
            await migrator.addColumn(tasksTable, tasksTable.hash);
            await migrator.addColumn(tasksTable, tasksTable.isShared);
            await migrator.addColumn(tasksTable, tasksTable.collaborationRole);
            await migrator.addColumn(tasksTable, tasksTable.collaboratorsJson);
            await migrator.addColumn(tasksTable, tasksTable.version);
            await migrator.addColumn(tasksTable, tasksTable.createdAt);
            await migrator.addColumn(tasksTable, tasksTable.deletedAt);

            // The previous Drift outbox was never connected to the app or
            // backend. Recreating it avoids unsafe ALTER TABLE defaults and
            // lets the active Hive data be migrated transactionally below.
            await migrator.deleteTable(outboxTable.actualTableName);
            await migrator.createTable(outboxTable);

            await migrator.createTable(collaboratorsTable);
            await migrator.createTable(syncStatesTable);
          }
          if (from < 3) {
            await migrator.addColumn(taskListsTable, taskListsTable.accountId);
            await migrator.addColumn(tasksTable, tasksTable.accountId);
            if (from >= 2) {
              await migrator.addColumn(outboxTable, outboxTable.accountId);
            }
          }
        },
      );
}
