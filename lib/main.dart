import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:upgrader/upgrader.dart';
import 'package:app_links/app_links.dart';

import 'package:jospar/core/constants/router.dart';
import 'package:jospar/core/constants/local_provider.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/constants/theme_provider.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/offline/sync_engine.dart';
import 'package:jospar/core/services/offline/realtime_sync.dart';
import 'package:jospar/core/services/social_auth_service.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';
import 'package:jospar/core/services/reminder_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
    await SystemChrome.setPreferredOrientations(
      const [DeviceOrientation.portraitUp],
    );
  }
  if (kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    await SocialAuthService().initialize();
  }

  // Hive открывается только для одноразовой миграции старых данных в SQLite.
  await Hive.initFlutter();
  await Hive.openBox('tasks_box');
  await Hive.openBox('task_lists_box');
  await OfflineRuntime.initialize();
  await ReminderService.instance.initialize();
  await Hive.box('tasks_box').close();
  await Hive.box('task_lists_box').close();

  // локали
  await initializeDateFormatting('ru');
  await initializeDateFormatting('kk');
  await initializeDateFormatting('en');

  // ✅ только теперь создаём провайдеры
  final globalProvider = GlobalProvider();
  await globalProvider.initialize();

  final localeProvider = LocaleProvider();
  await localeProvider.load();

  final appThemeProvider = AppThemeProvider();
  await appThemeProvider.load();

  void refreshLocalData() {
    final context = AppRouter.navigatorKey.currentContext;
    if (context == null) {
      globalProvider.notifyLocalDataChanged();
      return;
    }
    globalProvider.refreshTasks(context, silent: true);
    globalProvider.refreshTaskLists(context, silent: true);
  }

  final syncEngine = SyncEngine(
    outbox: OfflineRuntime.outbox,
    store: OfflineRuntime.store,
    onDataChanged: refreshLocalData,
  );
  OfflineRuntime.syncEngine = syncEngine;
  syncEngine.start();
  final realtimeSync = RealtimeSync(syncEngine: syncEngine);
  OfflineRuntime.realtimeSync = realtimeSync;
  realtimeSync.start();

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<GlobalProvider>.value(value: globalProvider),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<AppThemeProvider>.value(value: appThemeProvider),
      ],
      child: MyApp(globalProvider: globalProvider),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.globalProvider});

  final GlobalProvider globalProvider;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final Upgrader _upgrader;

  @override
  void initState() {
    super.initState();
    _upgrader = Upgrader(
      checkOnResume: true,
      countryCode: 'KZ',
      debugDisplayAlways: const bool.fromEnvironment('SHOW_UPDATE_PROMPT'),
      durationUntilAlertAgain: const Duration(days: 1),
    );
  }

  @override
  void dispose() {
    _upgrader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final appTheme = context.watch<AppThemeProvider>();
    final primary = appTheme.primary;
    final lightScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      brightness: Brightness.dark,
      surface: const Color(0xFF181B21),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: locale,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        primaryColor: primary,
        colorScheme: lightScheme,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        cardColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        brightness: Brightness.dark,
        primaryColor: primary,
        colorScheme: darkScheme,
        scaffoldBackgroundColor: const Color(0xFF101216),
        cardColor: const Color(0xFF181B21),
        dividerColor: const Color(0xFF2B3039),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101216),
          foregroundColor: Color(0xFFF4F5F7),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: Color(0xFF181B21),
          surfaceTintColor: Colors.transparent,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: Color(0xFF181B21),
          surfaceTintColor: Colors.transparent,
        ),
      ),
      themeMode: appTheme.mode,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const <Locale>[
        Locale('ru'),
        Locale('en'),
        Locale('kk'),
      ],
      routerConfig: AppRouter.router,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        final appContent = _AppLinkCoordinator(
          globalProvider: widget.globalProvider,
          child: content,
        );
        final isMobileStore = !kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS);
        if (!isMobileStore) return appContent;

        return UpgradeAlert(
          upgrader: _upgrader,
          navigatorKey: AppRouter.navigatorKey,
          showIgnore: false,
          showLater: true,
          showReleaseNotes: true,
          barrierDismissible: false,
          child: appContent,
        );
      },
    );
  }
}

/// Keeps the app-link subscription alive for the whole application lifetime.
/// A listener owned by the preloader is disposed as soon as `/tasks` opens,
/// which made only the first link reliable.
class _AppLinkCoordinator extends StatefulWidget {
  const _AppLinkCoordinator({
    required this.globalProvider,
    required this.child,
  });

  final GlobalProvider globalProvider;
  final Widget child;

  @override
  State<_AppLinkCoordinator> createState() => _AppLinkCoordinatorState();
}

class _AppLinkCoordinatorState extends State<_AppLinkCoordinator> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  String? _lastUri;
  DateTime? _lastUriAt;

  @override
  void initState() {
    super.initState();
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (Object error) => debugPrint('[AppLinks] $error'),
    );
    unawaited(_loadInitialUri());
  }

  Future<void> _loadInitialUri() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _handleUri(uri);
    } catch (error) {
      debugPrint('[AppLinks] initial link failed: $error');
    }
  }

  void _handleUri(Uri uri) {
    final hash = extractShareHash(uri);
    if (hash == null || hash.isEmpty) return;
    debugPrint('[AppLinks] received share: $hash');

    final now = DateTime.now();
    if (_lastUri == uri.toString() &&
        _lastUriAt != null &&
        now.difference(_lastUriAt!) < const Duration(milliseconds: 800)) {
      return;
    }
    _lastUri = uri.toString();
    _lastUriAt = now;

    widget.globalProvider.setInComingHash(hash);
    final currentPath =
        AppRouter.router.routeInformationProvider.value.uri.path;
    // TasksPage observes GlobalProvider and opens warm links in place. Avoid
    // rebuilding the whole screen through the preloader for every link.
    if (currentPath == '/tasks') return;
    if (currentPath != '/preloader') {
      AppRouter.router.go('/preloader');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
