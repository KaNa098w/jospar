import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/home_widget_service.dart';

void main() {
  test('builds the same Today bucket as the main task screen', () {
    final payload = HomeWidgetService.instance.buildPayload(
      now: DateTime(2026, 9, 2, 12),
      languageCode: 'ru',
      primaryColor: const Color(0xFF0267AA),
      lists: [TaskListItems(id: 'work', colorHex: '#34c759')],
      tasks: [
        TaskItems(
          id: 'later',
          name: 'Вторая',
          date: '2026-09-01',
          position: 2,
          taskListId: 'work',
        ),
        TaskItems(
          id: 'done',
          name: 'Готово',
          date: '2026-09-01',
          position: 0,
          isCompleted: true,
          updatedAt: '2026-09-02T08:00:00',
        ),
        TaskItems(
          id: 'first',
          name: 'Первая',
          date: '2026-09-02T08:00:00',
          position: 1,
          taskListId: 'work',
        ),
        TaskItems(
          id: 'tomorrow',
          name: 'Завтра',
          date: '2026-09-03',
        ),
        TaskItems(
          id: 'child',
          name: 'Подзадача',
          date: '2026-09-02',
          parentTaskId: 'first',
        ),
        TaskItems(
          id: 'done-before',
          name: 'Выполнено раньше',
          date: '2026-09-01',
          isCompleted: true,
          updatedAt: '2026-09-01T18:00:00',
        ),
      ],
    );

    expect(payload['title'], 'СЕГОДНЯ');
    expect(payload['date'], '2026-09-02');
    expect(payload['completed'], 1);
    expect(payload['total'], 3);
    expect(payload['remaining'], 2);
    expect(payload['primary'], '#0267AA');
    expect(
      payload['tasks'],
      [
        {'id': 'first', 'title': 'Первая', 'color': '#34C759'},
        {'id': 'later', 'title': 'Вторая', 'color': '#34C759'},
      ],
    );
  });
}
