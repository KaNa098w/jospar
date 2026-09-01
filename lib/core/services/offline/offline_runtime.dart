import 'package:jospar/core/db/app_db.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/offline/outbox.dart';
import 'package:jospar/core/services/offline/realtime_sync.dart';
import 'package:jospar/core/services/offline/sqlite_store.dart';
import 'package:jospar/core/services/offline/sync_engine.dart';
import 'package:jospar/core/services/offline/hive_to_sqlite_migration.dart';

class OfflineRuntime {
  OfflineRuntime._();

  static late final AppDb db;
  static late final OutboxStore outbox;
  static late final SqliteStore store;
  static SyncEngine? syncEngine;
  static RealtimeSync? realtimeSync;

  static Future<void> initialize({AppDb? database}) async {
    db = database ?? AppDb();
    outbox = OutboxStore(db);
    store = SqliteStore(db: db, outbox: outbox);
    await AuthStorage().ensureDeviceId();
    await HiveToSqliteMigration(db: db, outbox: outbox).runIfNeeded();
    await store.repairLegacyNullTaskPositions();
  }

  static void requestSync() {
    syncEngine?.synchronize();
  }
}
