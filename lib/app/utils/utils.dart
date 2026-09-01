import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:table_calendar/table_calendar.dart';

Widget buildAddButton() {
  return Container(
    width: 70,
    height: 70,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        colors: [
          ThemeColors.primary, // верх - голубой
          Color.fromARGB(255, 63, 205, 215) // низ - белый
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          spreadRadius: 2,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Center(
      child: Icon(
        Icons.add,
        size: 32,
        color: Colors.white, // можно сменить цвет иконки при белом фоне
      ),
    ),
  ).animate().scale(duration: 200.ms, curve: Curves.easeInOut);
}

typedef OnCalendarDaySelected = void Function(
    DateTime selected, DateTime focused);

Widget buildAnimatedCalendar({
  required bool isVisible,
  required DateTime selectedDay,
  required DateTime focusedDay,
  required OnCalendarDaySelected onDaySelected,
}) {
  return AnimatedContainer(
    duration: isVisible ? 400.ms : 200.ms,
    curve: Curves.easeOut,
    height: isVisible ? 400 : 0,
    child: Visibility(
      visible: isVisible,
      child: TableCalendar(
        locale: 'ru_RU',
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => DateUtils.isSameDay(selectedDay, day),
        onDaySelected: (sel, foc) => onDaySelected(sel, foc),
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          selectedDecoration: BoxDecoration(
            color: ThemeColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          todayDecoration: BoxDecoration(
            color: ThemeColors.primary.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: const TextStyle(color: Colors.black),
          weekendTextStyle: const TextStyle(color: Colors.redAccent),
        ),
      )
          .animate(target: isVisible ? 1 : 0)
          .moveY(begin: isVisible ? -200 : 0, end: isVisible ? 0 : -300)
          .then()
          .moveY(begin: 0, end: isVisible ? -12 : 12, duration: 100.ms)
          .then()
          .moveY(begin: isVisible ? -12 : 12, end: 0, duration: 100.ms),
    ),
  );
}

Widget buildAnimatedSection(Widget section, bool animate) {
  return section
      .animate(target: animate ? 1 : 0)
      .moveY(begin: animate ? -30 : 0, end: animate ? 0 : -20)
      .then()
      .moveY(begin: 0, end: animate ? -12 : 12, duration: 100.ms)
      .then()
      .moveY(begin: animate ? -12 : 12, end: 0, duration: 100.ms);
}

// bool _isSameDay(DateTime a, DateTime b) =>
//     a.year == b.year && a.month == b.month && a.day == b.day;

bool sameDay(DateTime a, DateTime b) => DateUtils.isSameDay(a, b);

String bucketFor(DateTime date) {
  final today = DateUtils.dateOnly(DateTime.now());
  final target = DateUtils.dateOnly(date);
  final tomorrow = today.add(const Duration(days: 1));
  final weekEnd = today.add(const Duration(days: 7));

  if (sameDay(target, today)) return 'today';
  if (sameDay(target, tomorrow)) return 'tomorrow';
  if (target.isAfter(tomorrow) && !target.isAfter(weekEnd)) return 'week';
  return 'later';
}

String humanizeRu(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final d = DateTime(date.year, date.month, date.day);

  if (sameDay(d, today)) return 'Сегодня';
  if (sameDay(d, tomorrow)) return 'Завтра';

  // 25 июля 2025
  return '${date.day} ${monthName(context, date.month)} ${date.year}';
}

// lib/utils/date_utils.dart

String monthName(BuildContext context, int month) {
  final months = [
    S.of(context).monthJanuary,
    S.of(context).monthFebruary,
    S.of(context).monthMarch,
    S.of(context).monthApril,
    S.of(context).monthMay,
    S.of(context).monthJune,
    S.of(context).monthJuly,
    S.of(context).monthAugust,
    S.of(context).monthSeptember,
    S.of(context).monthOctober,
    S.of(context).monthNovember,
    S.of(context).monthDecember,
  ];
  return months[month - 1];
}
