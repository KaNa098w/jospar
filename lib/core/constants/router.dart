// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:jospar/app/screens/preloader/preloader_screen.dart';
import 'package:jospar/app/screens/tasks/task_page.dart';
import 'package:jospar/app/screens/settings/settings_page.dart';
import 'package:jospar/app/screens/auth/phone_input_modul.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/preloader',
    redirect: (BuildContext context, GoRouterState state) {
      final uri = state.uri;
      final hash = extractShareHash(uri);

      // Both universal links (`/s/...`, `/share/...`) and the custom scheme
      // enter through the same preloader so an already running app also
      // processes the invitation reliably.
      if (hash != null && hash.isNotEmpty) {
        context.read<GlobalProvider>().setInComingHash(hash);
        return '/preloader';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/preloader',
        name: 'preloader',
        builder: (ctx, state) => const TasksPreloaderScreen(),
      ),
      GoRoute(
        path: '/tasks',
        name: 'tasks',
        builder: (ctx, state) => const TasksPage(),
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (ctx, state) => const AuthPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (ctx, state) => const SettingsPage(),
      ),
      // Explicit matches prevent GoRouter from rendering its error route if a
      // platform converts the universal link into a relative app location.
      GoRoute(
        path: '/s/:hash',
        redirect: (context, state) {
          context
              .read<GlobalProvider>()
              .setInComingHash(state.pathParameters['hash']);
          return '/preloader';
        },
      ),
      GoRoute(
        path: '/share/:hash',
        redirect: (context, state) {
          context
              .read<GlobalProvider>()
              .setInComingHash(state.pathParameters['hash']);
          return '/preloader';
        },
      ),
    ],
    errorBuilder: (ctx, state) =>
        Scaffold(body: Center(child: Text('Route error: ${state.error}'))),
  );
}
