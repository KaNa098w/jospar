import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/shared/shared_tasks_screen.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shared sync defaults to 30 seconds and can switch to 2 seconds',
      (tester) async {
    final provider = GlobalProvider();
    await provider.setApiTasks([
      TaskItems(
        id: 'shared-1',
        name: 'Совместная задача',
        isShared: true,
        collaborationRole: 'owner',
        children: [
          TaskItems(
            id: 'child-1',
            name: 'Подзадача',
            isCompleted: false,
          ),
        ],
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          locale: Locale('ru'),
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('ru')],
          home: SharedTasksScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Совместная задача'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('shared-realtime-console')),
      findsOneWidget,
    );
    expect(find.text('Консоль WebSocket'), findsOneWidget);
    expect(find.text('WS отключён'), findsOneWidget);
    expect(find.text('POLL 30s'), findsOneWidget);
    expect(tester.takeException(), isNull);

    final toggle = find.byKey(
      const ValueKey('shared-fallback-sync-toggle'),
    );
    expect(toggle, findsOneWidget);
    expect(find.byIcon(Icons.cloud_sync_outlined), findsOneWidget);

    await tester.tap(toggle);
    await tester.pump();

    expect(find.byIcon(Icons.speed_rounded), findsOneWidget);
    expect(find.text('POLL 2s'), findsOneWidget);
    expect(
      find.text('Быстрая синхронизация включена: каждые 2 секунды'),
      findsOneWidget,
    );

    await tester.tap(toggle);
    await tester.pump();

    expect(find.byIcon(Icons.cloud_sync_outlined), findsOneWidget);
    expect(find.text('POLL 30s'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
