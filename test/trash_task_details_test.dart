import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/widgets/info_row_widget.dart';

void main() {
  testWidgets('trash details support a shared task without a local task list',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfoRow(
            icon: Icons.calendar_today,
            value: '27.08.2026 10:00',
            taskList: const [],
          ),
        ),
      ),
    );

    expect(find.text('27.08.2026 10:00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
