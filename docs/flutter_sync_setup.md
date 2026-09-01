# Flutter offline sync setup

## Reverb configuration

The Reverb public app key is injected at build time and must not be committed:

```bash
flutter run --dart-define=REVERB_APP_KEY=<REVERB_APP_KEY>
flutter build apk --dart-define=REVERB_APP_KEY=<REVERB_APP_KEY>
flutter build ios --dart-define=REVERB_APP_KEY=<REVERB_APP_KEY>
```

Never add `REVERB_APP_SECRET` to the Flutter application.

If `REVERB_APP_KEY` is omitted, REST synchronization still works. Realtime is
disabled and the 30-second periodic sync remains as a fallback.

## Runtime flow

1. The UI reads tasks and lists only from Drift/SQLite.
2. A local mutation and its outbox operation are committed in one transaction.
3. `SyncEngine` registers the stable secure-storage device UUID.
4. Pending operations are pushed sequentially.
5. A first sync or `410 cursor_expired` loads an atomic snapshot.
6. `/sync/changes` pages are applied atomically, then their cursor is saved.
7. Reverb `sync.changed` events trigger a debounced cursor pull.
8. Resume, network recovery and the periodic timer also trigger sync.

Hive is opened only once at startup to migrate data from older application
versions. Active application reads and writes use SQLite.

## Release verification

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --dart-define=REVERB_APP_KEY=<REVERB_APP_KEY>
flutter build ios --dart-define=REVERB_APP_KEY=<REVERB_APP_KEY>
```
