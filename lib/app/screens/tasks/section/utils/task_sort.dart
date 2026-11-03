import 'package:jospar/core/models/tasks_response.dart';

DateTime _parse(String? s) =>
    DateTime.tryParse(s ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);

/// Ручная позиция имеет приоритет внутри группы задач одного статуса.
void sortTasks(List<TaskItems> tasks) {
  tasks.sort((a, b) {
    final ac = a.isCompleted ?? false;
    final bc = b.isCompleted ?? false;
    if (ac != bc) return ac ? 1 : -1;

    final aDate = _parse(a.date) == DateTime.fromMillisecondsSinceEpoch(0)
        ? _parse(a.createdAt)
        : _parse(a.date);
    final bDate = _parse(b.date) == DateTime.fromMillisecondsSinceEpoch(0)
        ? _parse(b.createdAt)
        : _parse(b.date);

    final positionComparison = (a.position ?? 0).compareTo(b.position ?? 0);
    if (positionComparison != 0) return positionComparison;

    // При одинаковой ручной позиции новая задача всегда идёт первой
    // внутри своего раздела.
    final recencyComparison = (b.createdAt ?? b.updatedAt ?? '')
        .compareTo(a.createdAt ?? a.updatedAt ?? '');
    if (recencyComparison != 0) return recencyComparison;

    final dateComparison = aDate.compareTo(bDate);
    if (dateComparison != 0) return dateComparison;
    return 0;
  });
}
