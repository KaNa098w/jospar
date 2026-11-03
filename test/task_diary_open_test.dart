import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/tasks/task_diary_screen.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('completed task opens from the task diary', (tester) async {
    final provider = GlobalProvider()
      ..setTaskLists([
        TaskListItems(id: 'list-1', name: 'Личные', colorHex: '#6750A4'),
      ]);
    await provider.setApiTasks([
      TaskItems(
        id: 'task-1',
        name: 'Выполненная задача',
        date: '2026-09-02',
        updatedAt: '2026-09-02T10:15:30.000Z',
        taskListId: 'list-1',
        isCompleted: true,
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
          home: TaskDiaryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Выполненная задача'));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Выполненная задача'),
      findsOneWidget,
    );
  });
}
