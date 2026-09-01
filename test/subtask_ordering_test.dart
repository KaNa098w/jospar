import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';

void main() {
  test('completed subtasks move below active subtasks in stable order', () {
    final subtasks = <Map<String, dynamic>>[
      {'title': 'Выполненная 1', 'completed': true},
      {'title': 'Активная 1', 'completed': false},
      {'title': 'Выполненная 2', 'completed': true},
      {'title': 'Активная 2', 'completed': false},
    ];

    moveCompletedSubtasksToBottom(subtasks);

    expect(
      subtasks.map((subtask) => subtask['title']),
      ['Активная 1', 'Активная 2', 'Выполненная 1', 'Выполненная 2'],
    );
  });
}
