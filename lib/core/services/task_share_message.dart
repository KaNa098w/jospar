import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';

String buildTaskShareMessage({
  required TaskItems task,
  required String shareUrl,
  required ShareDeliveryMode mode,
  int maxTasks = 15,
}) {
  var count = 0;

  String append(TaskItems item, int level) {
    if (count >= maxTasks) return '';
    count++;
    final name = (item.name ?? '').trim();
    // Use a plain bullet for every item. Checkbox glyphs are rendered as
    // square placeholders by some iOS share targets and fonts.
    final line = '${'  ' * level}• '
        '${name.isEmpty ? 'Задача без названия' : name}';
    final lines = <String>[line];
    for (final child in item.children ?? const <TaskItems>[]) {
      final childText = append(child, level + 1);
      if (childText.isNotEmpty) lines.add(childText);
    }
    return lines.join('\n');
  }

  int total(TaskItems item) =>
      1 +
      (item.children ?? const <TaskItems>[])
          .fold<int>(0, (sum, child) => sum + total(child));

  final tree = append(task, 0);
  final hidden = total(task) - count;
  final title = mode == ShareDeliveryMode.duplicate
      ? 'Скопируйте этот список задач в Jospar:'
      : 'Приглашаю вас к совместной работе в Jospar:';
  final hiddenText = hidden > 0 ? '\n… и ещё $hidden задач' : '';
  return '$title\n\n$tree$hiddenText\n\nОткрыть в Jospar:\n$shareUrl';
}
