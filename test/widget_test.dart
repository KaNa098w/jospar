import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/modal_sheet/action_panel.dart';

void main() {
  testWidgets('task action panel renders and saves', (tester) async {
    var saved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionPanel(
            selectedDate: DateTime(2026, 7, 29),
            onDateChanged: (_) {},
            onSave: () => saved = true,
            taskId: null,
            urgency: null,
            onChangeUrgency: (_) {},
          ),
        ),
      ),
    );

    expect(find.byTooltip('Поделиться'), findsOneWidget);
    final shareButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.send),
        matching: find.byType(IconButton),
      ),
    );
    expect(shareButton.onPressed, isNull);

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();
    expect(saved, isTrue);
  });

  testWidgets('share stays disabled until a new task has a persisted id',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionPanel(
            selectedDate: DateTime(2026, 7, 29),
            onDateChanged: (_) {},
            onSave: () {},
            taskId: null,
            onPrepareShare: () async => 'new-task-id',
            urgency: null,
            onChangeUrgency: (_) {},
          ),
        ),
      ),
    );

    final shareButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.send),
        matching: find.byType(IconButton),
      ),
    );
    expect(shareButton.onPressed, isNull);
  });

  testWidgets('share is enabled after the task has a persisted id',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionPanel(
            selectedDate: DateTime(2026, 7, 29),
            onDateChanged: (_) {},
            onSave: () {},
            taskId: 'persisted-task-id',
            urgency: null,
            onChangeUrgency: (_) {},
          ),
        ),
      ),
    );

    final shareButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.send),
        matching: find.byType(IconButton),
      ),
    );
    expect(shareButton.onPressed, isNotNull);
  });

  testWidgets('share is disabled for a received collaborative task',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ActionPanel(
            selectedDate: DateTime(2026, 7, 29),
            onDateChanged: (_) {},
            onSave: () {},
            taskId: 'shared-task-id',
            shareAllowed: false,
            urgency: null,
            onChangeUrgency: (_) {},
          ),
        ),
      ),
    );

    final shareButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.send),
        matching: find.byType(IconButton),
      ),
    );
    expect(shareButton.onPressed, isNull);
  });
}
