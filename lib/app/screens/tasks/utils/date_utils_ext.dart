import 'package:flutter/material.dart';
import 'package:jospar/core/l10n/s.dart';

/// Универсальная проверка равенства дат по дню (локально).
bool isSameDayLocal(DateTime? a, DateTime? b) {
  if (a == null || b == null) return false;
  final da = DateUtils.dateOnly(a);
  final db = DateUtils.dateOnly(b);
  return da == db;
}

/// Пытаемся распарсить ISO-дату из API и вернуть локальное время.
DateTime? parseLocal(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    final dt = DateTime.parse(s);
    return dt.isUtc ? dt.toLocal() : dt;
  } catch (_) {
    return null;
  }
}

/// Формат YYYY-MM-DD (для API).
String fmtYmd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Пробуем парсить дату из API:
/// 1) полноценный ISO
/// 2) или только YYYY-MM-DD
DateTime? parseApiDateOrYmd(String? s) {
  if (s == null || s.isEmpty) return null;

  try {
    final dt = DateTime.parse(s);
    return dt.isUtc ? dt.toLocal() : dt;
  } catch (_) {
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
    if (m != null) {
      final y = int.parse(m.group(1)!);
      final mm = int.parse(m.group(2)!);
      final d = int.parse(m.group(3)!);
      return DateTime(y, mm, d);
    }
    return null;
  }
}

String formatDayHeader(BuildContext context, DateTime d) {
  final months = [
    S.of(context).shortMonthJanuary,
    S.of(context).shortMonthFebruary,
    S.of(context).shortMonthMarch,
    S.of(context).shortMonthApril,
    S.of(context).shortMonthMay,
    S.of(context).shortMonthJune,
    S.of(context).shortMonthJuly,
    S.of(context).shortMonthAugust,
    S.of(context).shortMonthSeptember,
    S.of(context).shortMonthOctober,
    S.of(context).shortMonthNovember,
    S.of(context).shortMonthDecember,
  ];

  final weekdays = [
    S.of(context).shortWeekdayMonday,
    S.of(context).shortWeekdayTuesday,
    S.of(context).shortWeekdayWednesday,
    S.of(context).shortWeekdayThursday,
    S.of(context).shortWeekdayFriday,
    S.of(context).shortWeekdaySaturday,
    S.of(context).shortWeekdaySunday,
  ];

  final day = d.day.toString().padLeft(2, '0');
  final m = months[d.month - 1];
  final w = weekdays[(d.weekday - 1) % 7];
  return '$day $m, $w';
}
