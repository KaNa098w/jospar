import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';
import 'package:jospar/core/services/task_share_message.dart';

void main() {
  test('builds a collaboration message with recursive task tree', () {
    final message = buildTaskShareMessage(
      task: TaskItems(
        name: 'Покупки',
        children: [
          TaskItems(name: 'Молоко'),
          TaskItems(name: 'Хлеб', isCompleted: true),
        ],
      ),
      shareUrl: 'https://jospar.kz/s/A7kP4xQ9',
      mode: ShareDeliveryMode.collaborate,
    );

    expect(message, contains('Приглашаю вас к совместной работе'));
    expect(message, contains('• Покупки'));
    expect(message, contains('  • Молоко'));
    expect(message, contains('  • Хлеб'));
    expect(message, isNot(contains('☐')));
    expect(message, isNot(contains('☑')));
    expect(message, endsWith('https://jospar.kz/s/A7kP4xQ9'));
  });
}
