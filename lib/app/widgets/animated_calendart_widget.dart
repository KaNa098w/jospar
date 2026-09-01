import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AnimatedCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const AnimatedCalendar({Key? key, required this.onDateSelected})
      : super(key: key);

  @override
  _AnimatedCalendarState createState() => _AnimatedCalendarState();
}

class _AnimatedCalendarState extends State<AnimatedCalendar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: TableCalendar(
            locale: 'ru_RU',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: DateTime.now(),
            onDaySelected: (selectedDay, focusedDay) {
              widget.onDateSelected(selectedDay);
              Navigator.pop(context);
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Colors.blue, // Синий цвет для выбранной даты
                shape: BoxShape.circle, // Круглая форма
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue
                    .withOpacity(0.3), // Полупрозрачный синий для "сегодня"
                shape: BoxShape.circle,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white, // Белый текст на выбранной дате
                fontWeight: FontWeight.bold,
              ),
              defaultTextStyle: TextStyle(
                color: Colors.black, // Стандартный чёрный текст
              ),
            ),
          ),
        ),
      ),
    );
  }
}
