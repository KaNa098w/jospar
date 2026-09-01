import 'date_utils_ext.dart';
import 'package:jospar/core/models/tasks_response.dart';

/// Сортируем задачи «на день»: незавершённые вверх, затем по дате/updatedAt.
void sortDayTasks(List<TaskItems> items) {
  items.sort((a, b) {
    final ac = a.isCompleted == true;
    final bc = b.isCompleted == true;
    if (ac != bc) return ac ? 1 : -1;

    final ad = parseLocal(a.date) ?? parseLocal(a.updatedAt) ?? DateTime(1900);
    final bd = parseLocal(b.date) ?? parseLocal(b.updatedAt) ?? DateTime(1900);
    return ad.compareTo(bd);
  });
}
