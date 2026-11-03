import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';
import 'package:jospar/app/screens/modal_sheet/subtasks_section.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/models/tasks_response.dart';

void main() {
  test('extractSubtasks places completed subtasks after active ones', () {
    final task = TaskItems(
      children: [
        TaskItems(id: '1', name: 'Первая', isCompleted: true, position: 0),
        TaskItems(id: '2', name: 'Вторая', isCompleted: false, position: 1),
      ],
    );

    expect(
      extractSubtasks(task).map((item) => item['title']),
      ['Вторая', 'Первая'],
    );
  });

  test('extractSubtasks preserves completion actor metadata', () {
    final task = TaskItems(
      children: [
        TaskItems(
          id: 'child-1',
          name: 'Подзадача',
          isCompleted: true,
          completedByUserId: 'user-1',
          completedBy: const {'id': 'user-1', 'name': 'Иван Иванов'},
          completedAt: '2026-09-02T10:15:30.000Z',
        ),
      ],
    );

    expect(extractSubtasks(task).single, containsPair('_id', 'child-1'));
    expect(
      extractSubtasks(task).single,
      containsPair('completed_by_user_id', 'user-1'),
    );
    expect(
      extractSubtasks(task).single['completed_by'],
      {'id': 'user-1', 'name': 'Иван Иванов'},
    );
    expect(
      extractSubtasks(task).single['completed_at'],
      '2026-09-02T10:15:30.000Z',
    );
  });

  testWidgets('completed subtask shows actor avatar without growing the row',
      (tester) async {
    final subtasks = <Map<String, dynamic>>[
      {
        '_id': 'child-1',
        'title': 'Выполненная подзадача',
        'completed': true,
        'completed_by_user_id': 'user-1',
        'completed_by': {'id': 'user-1', 'name': 'Иван Иванов'},
      },
      {
        '_id': 'child-2',
        'title': 'Без данных исполнителя',
        'completed': true,
      },
    ];
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SubtasksSection(
            subtasks: subtasks,
            showSubtaskInput: false,
            subtaskController: controller,
            subtaskFocusNode: focusNode,
            onToggleComplete: (_) {},
            onAdd: (_) {},
            onToggleInput: (_) {},
          ),
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey('completed-by-avatar-child-1')),
      findsOneWidget,
    );
    expect(find.byTooltip('Иван Иванов'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('completed-by-avatar-child-2')),
      findsNothing,
    );
    expect(
      tester.getSize(find.byKey(GlobalObjectKey(subtasks.first))).height,
      tester.getSize(find.byKey(GlobalObjectKey(subtasks.last))).height,
    );
  });

  testWidgets('editing a one-line subtask keeps the same row height',
      (tester) async {
    final subtasks = <Map<String, dynamic>>[
      {'title': 'Первая', 'completed': true},
      {'title': 'Вторая', 'completed': false},
    ];
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SubtasksSection(
            subtasks: subtasks,
            showSubtaskInput: false,
            subtaskController: controller,
            subtaskFocusNode: focusNode,
            onToggleComplete: (_) {},
            onAdd: (_) {},
            onToggleInput: (_) {},
          ),
        ),
      ),
    );

    final row = find.byKey(GlobalObjectKey(subtasks.first));
    final initialHeight = tester.getSize(row).height;
    final displayField = find.byKey(const ValueKey('subtask-display-0'));
    final initialTextLeft = tester.getTopLeft(displayField).dx;
    final displayText = tester.widget<TextField>(displayField);

    await tester.tap(row);
    await tester.pump();
    final editingHeight = tester.getSize(row).height;
    final field = find.byKey(const ValueKey('subtask-inline-0'));
    final editingTextLeft = tester.getTopLeft(field).dx;
    final editingText = tester.widget<TextField>(field);

    expect(editingHeight, initialHeight);
    expect(editingTextLeft, initialTextLeft);
    expect(editingText.style, displayText.style);
    expect(editingText.strutStyle, displayText.strutStyle);
    expect(editingText.style?.fontFamily, 'Roboto');
    expect(editingText.style?.letterSpacing, 0);
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('editing a wrapped subtask keeps the same line count',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const title =
        'Очень длинное название подзадачи для проверки одинакового переноса';
    final subtasks = <Map<String, dynamic>>[
      {'title': title, 'completed': false},
    ];
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SubtasksSection(
            subtasks: subtasks,
            showSubtaskInput: false,
            subtaskController: controller,
            subtaskFocusNode: focusNode,
            onToggleComplete: (_) {},
            onAdd: (_) {},
            onToggleInput: (_) {},
          ),
        ),
      ),
    );

    final row = find.byKey(GlobalObjectKey(subtasks.first));
    final displayHeight = tester.getSize(row).height;
    expect(displayHeight, greaterThan(49));

    await tester.tap(row);
    await tester.pump();

    expect(tester.getSize(row).height, displayHeight);
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('Enter creates and focuses a subtask directly below',
      (tester) async {
    final subtasks = <Map<String, dynamic>>[
      {'title': 'Первая', 'completed': false},
    ];
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SubtasksSection(
            subtasks: subtasks,
            showSubtaskInput: false,
            subtaskController: controller,
            subtaskFocusNode: focusNode,
            onToggleComplete: (_) {},
            onAdd: (_) {},
            onToggleInput: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(GlobalObjectKey(subtasks.first)));
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pump();
    await tester.pump();

    expect(subtasks, hasLength(2));
    expect(subtasks[1]['title'], '');
    final newField = find.byKey(const ValueKey('subtask-inline-1'));
    expect(newField, findsOneWidget);
    expect(tester.widget<TextField>(newField).focusNode?.hasFocus, isTrue);
    await tester.pump(const Duration(milliseconds: 350));
  });

  testWidgets('deleted subtask can be restored to its original position',
      (tester) async {
    final subtasks = <Map<String, dynamic>>[
      {'title': 'Первая', 'completed': false},
      {'title': 'Вторая', 'completed': false},
    ];
    final controller = TextEditingController();
    final focusNode = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: SubtasksSection(
            subtasks: subtasks,
            showSubtaskInput: false,
            subtaskController: controller,
            subtaskFocusNode: focusNode,
            onToggleComplete: (_) {},
            onAdd: (_) {},
            onToggleInput: (_) {},
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(GlobalObjectKey(subtasks.first)));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump(const Duration(milliseconds: 250));

    expect(subtasks.map((item) => item['title']), ['Вторая']);
    expect(find.byKey(const ValueKey('subtask-undo-panel')), findsOneWidget);

    tester
        .widget<TextButton>(
          find.byKey(const ValueKey('undo-subtask-delete')),
        )
        .onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(subtasks.map((item) => item['title']), ['Первая', 'Вторая']);
    expect(find.byKey(const ValueKey('subtask-undo-panel')), findsNothing);
  });
}
