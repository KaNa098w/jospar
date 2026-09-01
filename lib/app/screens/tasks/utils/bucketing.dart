import 'package:flutter/material.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'date_utils_ext.dart';

/// Ключи секций
const kBucketToday = 'today';
const kBucketTomorrow = 'tomorrow';
const kBucketWeek = 'week';
const kBucketMonth = 'month';
const kBucketLater = 'later';
const kBucketNote = 'note';

/// Завершённые задачи, состояние которых было обновлено в указанный день.
/// Backend пока не возвращает отдельный completed_at, поэтому временем
/// завершения служит updated_at операции переключения is_completed.
List<TaskItems> completedOnDay(List<TaskItems> items, DateTime day) {
  final target = DateUtils.dateOnly(day);
  return items.where((task) {
    if (task.isCompleted != true) return false;
    final updated = parseApiDateOrYmd(task.updatedAt);
    return updated != null && DateUtils.dateOnly(updated) == target;
  }).toList(growable: false);
}

/// Определяем "корзину" (сегмент) задачи относительно базовой даты.
String bucketFor(DateTime? taskDate, DateTime base) {
  if (taskDate == null) return kBucketNote;

  final bd = DateUtils.dateOnly(base);
  final td = DateUtils.dateOnly(taskDate);

  // только строго сегодня
  if (td.isAtSameMomentAs(bd)) return kBucketToday;

  // Keep overdue tasks visible in Today until they are completed or assigned
  // another date. Moving them to Week made yesterday's unfinished tasks appear
  // to jump sections overnight.
  if (td.isBefore(bd)) return kBucketToday;
  final diff = td.difference(bd).inDays;
  if (diff == 1) return kBucketTomorrow;
  if (diff >= 2 && diff <= 7) return kBucketWeek;
  if (diff >= 8 && diff <= 30) return kBucketMonth;
  return kBucketLater;
}

/// Группируем задачи по корзинам и аккуратно сортируем в каждой группе.
/// Сортировка: незавершённые → ручная позиция → дата → updatedAt.
Map<String, List<TaskItems>> groupByBuckets(
  List<TaskItems> items,
  DateTime base,
) {
  final map = <String, List<TaskItems>>{
    kBucketToday: [],
    kBucketTomorrow: [],
    kBucketWeek: [],
    kBucketMonth: [],
    kBucketLater: [],
    kBucketNote: [],
  };

  int safeCompareDates(String? a, String? b) {
    final da = parseApiDateOrYmd(a) ?? DateTime(3000);
    final db = parseApiDateOrYmd(b) ?? DateTime(3000);
    return da.compareTo(db);
  }

  for (final t in items) {
    final d = parseApiDateOrYmd(t.date);
    final bucket = bucketFor(d, base);
    map[bucket]!.add(t);
  }

  for (final k in map.keys) {
    map[k]!.sort((a, b) {
      final ac = a.isCompleted ?? false;
      final bc = b.isCompleted ?? false;
      if (ac != bc) return ac ? 1 : -1;

      final p1 = a.position ?? 0;
      final p2 = b.position ?? 0;
      if (p1 != p2) return p1.compareTo(p2);

      if (k != kBucketNote) {
        final c1 = safeCompareDates(a.date, b.date);
        if (c1 != 0) return c1;
      }

      // При одинаковой позиции новая задача должна появляться первой.
      return (b.updatedAt ?? b.createdAt ?? '')
          .compareTo(a.updatedAt ?? a.createdAt ?? '');
    });
  }

  return map;
}

/// Выбираем дату для секции при DnD.
DateTime dateForBucket(String bucket, DateTime base, {DateTime? current}) {
  final b = DateUtils.dateOnly(base);
  switch (bucket) {
    case kBucketToday:
      return b;
    case kBucketTomorrow:
      return b.add(const Duration(days: 1));
    case kBucketWeek:
      if (current != null) {
        final diff = DateUtils.dateOnly(current).difference(b).inDays;
        if (diff >= 2 && diff <= 7) return DateUtils.dateOnly(current);
      }
      return b.add(const Duration(days: 3));
    case kBucketMonth:
      if (current != null) {
        final diff = DateUtils.dateOnly(current).difference(b).inDays;
        if (diff >= 8 && diff <= 30) return DateUtils.dateOnly(current);
      }
      return b.add(const Duration(days: 14));
    case kBucketLater:
      return DateTime(b.year + 1, b.month, b.day);
    default:
      return b;
  }
}

/// Dates are useful in the combined "Later" section only while they are
/// close enough to scan quickly. Far-future tasks stay visually compact.
bool showDateInLater(DateTime? taskDate, DateTime base) {
  if (taskDate == null) return false;
  final b = DateUtils.dateOnly(base);
  final date = DateUtils.dateOnly(taskDate);
  final threeMonthsLater = DateTime(b.year, b.month + 3, b.day);
  return date.isAfter(b) && !date.isAfter(threeMonthsLater);
}
