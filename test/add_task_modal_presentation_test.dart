import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';
import 'package:jospar/app/screens/modal_sheet/action_panel.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:provider/provider.dart';

void main() {
  Future<void> pumpHost(
    WidgetTester tester, {
    Future<String?> Function(String, List, DateTime?, String, String)? onSave,
    TaskItems? existingTask,
  }) async {
    final provider = GlobalProvider()
      ..setTaskLists([
        TaskListItems(id: 'list-1', name: 'Основной', colorHex: '#6750A4'),
      ]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ru')],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showAddTaskModal(
                  context: context,
                  selectedDay: DateTime(2026, 8, 25),
                  taskId: '',
                  existingTask: existingTask,
                  onSaveTask:
                      onSave ?? (_, __, ___, ____, _____) async => 'task-1',
                ),
                child: const Text('Открыть'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('uses a centered dialog on desktop', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await pumpHost(tester);

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Scrollbar &&
              widget.thumbVisibility == true &&
              widget.trackVisibility == true,
        ),
        findsOneWidget,
      );
      expect(
        find.ancestor(
          of: find.byType(ActionPanel),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.backgroundColor, Colors.transparent);
      final decoratedWindow =
          tester.widgetList<Container>(find.byType(Container)).firstWhere(
                (container) =>
                    container.decoration is BoxDecoration &&
                    (container.decoration! as BoxDecoration)
                            .boxShadow
                            ?.isNotEmpty ==
                        true,
              );
      final shadows = (decoratedWindow.decoration! as BoxDecoration).boxShadow!;
      expect(shadows.first.offset, Offset.zero);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('desktop editor saves and closes without framework errors',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    var saveCount = 0;
    try {
      await pumpHost(
        tester,
        onSave: (_, __, ___, ____, _____) async {
          saveCount++;
          return 'task-1';
        },
      );

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Новая задача');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(saveCount, 1);
      expect(find.byType(Dialog), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('keeps the bottom sheet presentation on mobile', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await pumpHost(tester);

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();

      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.byType(Dialog), findsNothing);
      expect(find.byType(Scrollbar), findsNothing);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('saving a Notes task keeps its date null', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    DateTime? savedDate = DateTime(2000);
    try {
      await pumpHost(
        tester,
        existingTask: TaskItems(
          id: 'note-1',
          name: 'Заметка',
          date: null,
          taskListId: 'list-1',
        ),
        onSave: (_, __, date, ___, ____) async {
          savedDate = date;
          return 'note-1';
        },
      );

      await tester.tap(find.text('Открыть'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ActionPanel),
          matching: find.byType(ElevatedButton),
        ),
      );
      await tester.pumpAndSettle();

      expect(savedDate, isNull);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
