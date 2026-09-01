import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/models/tasks_response.dart';

void main() {
  test('restoring a task publishes a new task list instance', () async {
    final provider = GlobalProvider();
    final task = TaskItems(
      id: 'task-1',
      name: 'Task',
      date: '2026-08-10',
      position: 3,
      isCompleted: true,
    );
    await provider.setApiTasks([task]);
    final before = provider.allApiTasks;

    provider.setTaskCompletedOptimistic('task-1', false);

    expect(provider.allApiTasks, isNot(same(before)));
    expect(provider.allApiTasks.single.isCompleted, isFalse);
    expect(provider.allApiTasks.single.date, '2026-08-10');
    expect(provider.allApiTasks.single.position, 3);
  });
}
