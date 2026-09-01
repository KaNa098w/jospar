import 'dart:math';
import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class AnimatedCalendar extends StatefulWidget {
  final bool isVisible;
  final DateTime selectedDay;
  final DateTime focusedDay;
  final Map<DateTime, List<Color>> taskColorsByDay;
  final void Function(DateTime selected, DateTime focused) onDaySelected;
  final void Function(DateTime focusedMonth)? onMonthChanged;

  const AnimatedCalendar({
    super.key,
    required this.isVisible,
    required this.selectedDay,
    required this.focusedDay,
    this.taskColorsByDay = const {},
    required this.onDaySelected,
    this.onMonthChanged,
  });

  @override
  State<AnimatedCalendar> createState() => _AnimatedCalendarState();
}

class _AnimatedCalendarState extends State<AnimatedCalendar>
    with SingleTickerProviderStateMixin {
  static final DateTime _epoch = DateTime(2000, 1, 1);
  late final PageController _pageController;

  late final AnimationController _expandCtrl;
  late final Animation<double> _expand; // для высоты
  late final Animation<double> _fade; // для прозрачности

  int _monthDelta(DateTime a, DateTime b) =>
      (a.year - b.year) * 12 + (a.month - b.month);

  int get _initialPage => max(0, _monthDelta(widget.focusedDay, _epoch));

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage, keepPage: true);

    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 200),
    );

    final curve = CurvedAnimation(
      parent: _expandCtrl,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _expand = curve;
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    // Приводим контроллер к начальному состоянию
    if (widget.isVisible) {
      _expandCtrl.value = 1.0;
    } else {
      _expandCtrl.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Синхронизируем текущую страницу с focusedDay
    final wantPage = max(0, _monthDelta(widget.focusedDay, _epoch));
    final currentPage = _pageController.hasClients
        ? _pageController.page?.round()
        : _pageController.initialPage;
    if (currentPage != wantPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _pageController.jumpToPage(wantPage);
      });
    }

    // Гоним анимацию открытия/закрытия
    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        _expandCtrl.forward();
      } else {
        _expandCtrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _expandCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Не удаляем виджет из дерева — анимируем высоту и прозрачность
    return Padding(
      padding: const EdgeInsets.only(bottom: 0, top: 10),
      child: ClipRect(
        child: FadeTransition(
          opacity: _fade,
          child: SizeTransition(
            axis: Axis.vertical,
            sizeFactor: _expand, // 0..1
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _Weekday('Пн'),
                      _Weekday('Вт'),
                      _Weekday('Ср'),
                      _Weekday('Чт'),
                      _Weekday('Пт'),
                      _Weekday('Сб'),
                      _Weekday('Вс'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 280,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    onPageChanged: (page) {
                      final month =
                          DateTime(_epoch.year, _epoch.month + page, 1);
                      if (widget.onMonthChanged != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;
                          widget.onMonthChanged!(month);
                        });
                      }
                    },
                    itemBuilder: (context, page) {
                      final month =
                          DateTime(_epoch.year, _epoch.month + page, 1);
                      return _MonthGrid(
                        month: month,
                        selectedDay: widget.selectedDay,
                        taskColorsByDay: widget.taskColorsByDay,
                        onTapDay: (picked) {
                          final focused =
                              DateTime(picked.year, picked.month, picked.day);
                          widget.onDaySelected(picked, focused);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Weekday extends StatelessWidget {
  final String label;
  const _Weekday(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<Color>> taskColorsByDay;
  final void Function(DateTime day) onTapDay;

  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.taskColorsByDay,
    required this.onTapDay,
  });

  List<DateTime> _buildDays() {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final startOffset = (firstOfMonth.weekday + 6) % 7; // понедельник = 0
    final start = firstOfMonth.subtract(Duration(days: startOffset));
    return List.generate(
        42, (i) => DateTime(start.year, start.month, start.day + i));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final days = _buildDays();
    final today = DateTime.now();
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 0,
          crossAxisSpacing: 12,
        ),
        itemCount: days.length,
        itemBuilder: (context, i) {
          final d = days[i];
          final isCurrentMonth = d.month == month.month;
          final isSelected = _isSameDay(d, selectedDay);
          final isToday = _isSameDay(d, today);
          final markerColors =
              taskColorsByDay[DateTime(d.year, d.month, d.day)] ??
                  const <Color>[];

          final fgColor = isCurrentMonth
              ? (isSelected ? colors.onPrimary : colors.onSurface)
              : (isSelected
                  ? colors.onPrimary
                  : colors.onSurface.withValues(alpha: .38));

          final bgColor = isSelected
              ? ThemeColors.primary
              : (isToday ? ThemeColors.primary.withOpacity(0.1) : null);
          final border = isToday && !isSelected
              ? Border.all(color: ThemeColors.primary, width: 1.4)
              : null;

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onTapDay(d),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: border,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: fgColor,
                    ),
                  ),
                  if (markerColors.isNotEmpty)
                    Positioned(
                      bottom: 3,
                      left: 2,
                      right: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: markerColors.take(3).map((color) {
                          return Container(
                            width: 4.5,
                            height: 4.5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 0.7)
                                  : null,
                            ),
                          );
                        }).toList(growable: false),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
