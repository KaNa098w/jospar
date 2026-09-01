import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/tasks/section/widgets/task_item_widget.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('ordinary tasks have no background in dark theme',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GlobalProvider(),
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: TaskItem(
              task: TaskItems(
                id: 'dark-task',
                name: 'Dark task',
              ),
              urgency: 'high',
              colorHex: Colors.teal,
              onToggle: () {},
            ),
          ),
        ),
      ),
    );

    final taskContainer = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(TaskItem),
            matching: find.byType(Container),
          ),
        )
        .firstWhere(
          (container) =>
              container.padding ==
              const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        );

    expect(
      (taskContainer.decoration! as BoxDecoration).color,
      Colors.transparent,
    );
  });

  testWidgets('shared tasks keep their background in dark theme',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GlobalProvider(),
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: TaskItem(
              task: TaskItems(
                id: 'dark-shared-task',
                name: 'Dark shared task',
                collaborators: const [
                  {'user_id': 'participant-1', 'name': 'Participant'},
                ],
              ),
              colorHex: Colors.teal,
              onToggle: () {},
            ),
          ),
        ),
      ),
    );

    final taskContainer = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(TaskItem),
            matching: find.byType(Container),
          ),
        )
        .firstWhere(
          (container) =>
              container.padding ==
              const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        );

    expect(
      (taskContainer.decoration! as BoxDecoration).color,
      const Color(0xFF19324B),
    );
  });

  testWidgets('task with a visible participant avatar gets shared background',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GlobalProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: TaskItems(
                id: 'shared-1',
                name: 'Shared task',
                isShared: true,
                collaborators: const [
                  {'user_id': 'participant-1', 'name': 'Participant'},
                ],
              ),
              urgency: 'high',
              colorHex: Colors.teal,
              onToggle: () {},
            ),
          ),
        ),
      ),
    );

    final decoratedContainers = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(TaskItem),
        matching: find.byType(Container),
      ),
    );
    expect(
      decoratedContainers.any(
        (container) =>
            container.decoration is BoxDecoration &&
            (container.decoration! as BoxDecoration).color ==
                const Color(0xFFD9EAFC),
      ),
      isTrue,
    );
  });

  testWidgets('shared flag without an avatar does not color the task',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GlobalProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: TaskItems(
                id: 'shared-without-participants',
                name: 'Shared without participants',
                isShared: true,
              ),
              colorHex: Colors.teal,
              onToggle: () {},
            ),
          ),
        ),
      ),
    );

    final decoratedContainers = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(TaskItem),
        matching: find.byType(Container),
      ),
    );
    expect(
      decoratedContainers.any(
        (container) =>
            container.decoration is BoxDecoration &&
            (container.decoration! as BoxDecoration).color ==
                const Color(0xFFD9EAFC),
      ),
      isFalse,
    );
  });

  testWidgets('ordinary owner task does not get collaboration background',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => GlobalProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: TaskItem(
              task: TaskItems(
                id: 'ordinary-1',
                name: 'Ordinary task',
                isShared: false,
                collaborationRole: 'owner',
              ),
              colorHex: Colors.teal,
              onToggle: () {},
            ),
          ),
        ),
      ),
    );

    final decoratedContainers = tester.widgetList<Container>(
      find.descendant(
        of: find.byType(TaskItem),
        matching: find.byType(Container),
      ),
    );
    expect(
      decoratedContainers.any(
        (container) =>
            container.decoration is BoxDecoration &&
            (container.decoration! as BoxDecoration).color ==
                const Color(0xFFD9EAFC),
      ),
      isFalse,
    );
  });
}
