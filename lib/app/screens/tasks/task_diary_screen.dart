import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jospar/app/screens/tasks/section/utils/task_color.dart';
import 'package:jospar/app/screens/tasks/section/widgets/task_item_widget.dart';
import 'package:jospar/app/screens/tasks/utils/date_utils_ext.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:provider/provider.dart';

class TaskDiaryScreen extends StatefulWidget {
  const TaskDiaryScreen({super.key});

  @override
  State<TaskDiaryScreen> createState() => _TaskDiaryScreenState();
}

class _TaskDiaryScreenState extends State<TaskDiaryScreen> {
  final TaskService _taskService = TaskService();
  final Set<String> _updating = {};
  final Set<String> _disappearing = {};
  final List<TaskItems> _tasks = [];
  final List<DateTime> _days = [];
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;

    // Keep the diary stable while a row is animating out. Background sync may
    // refresh the global task list at the same moment, but it must not rebuild
    // every date section on this route.
    _tasks.addAll(
      context
          .read<GlobalProvider>()
          .allApiTasks
          .map((task) => TaskItems.fromJson(task.toJson())),
    );
    _days.addAll(_groupTasks(_tasks).keys);
    _days.sort((a, b) => b.compareTo(a));
    _loaded = true;
  }

  DateTime? _completionDay(TaskItems task) =>
      parseLocal(task.updatedAt) ??
      parseLocal(task.date) ??
      parseLocal(task.createdAt);

  Map<DateTime, List<TaskItems>> _groupTasks(List<TaskItems> tasks) {
    final groups = <DateTime, List<TaskItems>>{};
    for (final task in tasks.where(
      (item) =>
          item.isCompleted == true ||
          _updating.contains(item.id) ||
          _disappearing.contains(item.id),
    )) {
      final completedAt = _completionDay(task);
      if (completedAt == null) continue;
      final day = DateUtils.dateOnly(completedAt);
      groups.putIfAbsent(day, () => []).add(task);
    }
    for (final items in groups.values) {
      items.sort((a, b) => (b.updatedAt ?? '').compareTo(a.updatedAt ?? ''));
    }
    return groups;
  }

  Future<void> _restoreTask(TaskItems task) async {
    final id = task.id;
    if (id == null || id.isEmpty || _updating.contains(id)) return;
    setState(() {
      _updating.add(id);
      task.isCompleted = false;
    });
    try {
      // Send the completion-specific sync operation expected by the backend.
      // Only the status changes; date and position remain untouched.
      final update = _taskService.setTaskCompleted(
        context,
        id: id,
        isCompleted: false,
      );
      final animation = () async {
        // First show the unchecked state, then collapse only this row just as
        // completed tasks do on the main screen.
        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (!mounted) return;
        setState(() => _disappearing.add(id));
        await Future<void>.delayed(const Duration(milliseconds: 320));
      }();
      await Future.wait([update, animation]);
      if (!mounted) return;
      setState(() {
        _tasks.removeWhere((item) => item.id == id);
        _updating.remove(id);
        _disappearing.remove(id);
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        task.isCompleted = true;
        _updating.remove(id);
        _disappearing.remove(id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${S.of(context).error}: $error')),
      );
    }
  }

  String _dateTitle(BuildContext context, DateTime day) {
    if (day == DateUtils.dateOnly(DateTime.now())) {
      return S.of(context).today.toUpperCase();
    }
    final locale = Localizations.localeOf(context).languageCode;
    return DateFormat.MMMMd(locale).format(day).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupTasks(_tasks);
    final hasTasks = groups.values.any((items) => items.isNotEmpty);
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          S.of(context).screenTaskDiary,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _days.isEmpty
          ? Center(
              child: Text(
                S.of(context).noTasksForDay,
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            )
          : Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                  itemCount: _days.length,
                  findChildIndexCallback: (key) {
                    if (key is! ValueKey<DateTime>) return null;
                    final index = _days.indexOf(key.value);
                    return index < 0 ? null : index;
                  },
                  itemBuilder: (context, index) {
                    final day = _days[index];
                    final dayTasks = groups[day] ?? const <TaskItems>[];
                    final isToday = day == DateUtils.dateOnly(DateTime.now());
                    final hideDay = dayTasks.isEmpty;
                    return KeyedSubtree(
                      key: ValueKey(day),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchOutCurve: Curves.easeInOutCubic,
                        transitionBuilder: _fadeAndCollapse,
                        child: hideDay
                            ? SizedBox.shrink(
                                key: ValueKey('diary-day-hidden-$day'),
                              )
                            : Padding(
                                key: ValueKey('diary-day-visible-$day'),
                                padding: const EdgeInsets.only(bottom: 22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _dateTitle(context, day),
                                      style: TextStyle(
                                        fontFamily: 'Oswald',
                                        color: isToday
                                            ? ThemeColors.primary
                                            : colors.onSurfaceVariant,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    for (final task in dayTasks)
                                      AnimatedSwitcher(
                                        key: ValueKey(
                                          'diary-switch-${task.id}',
                                        ),
                                        duration:
                                            const Duration(milliseconds: 320),
                                        switchOutCurve: Curves.easeInOutCubic,
                                        transitionBuilder: _fadeAndCollapse,
                                        child: _disappearing.contains(task.id)
                                            ? SizedBox.shrink(
                                                key: ValueKey(
                                                  'diary-hidden-${task.id}',
                                                ),
                                              )
                                            : Padding(
                                                key: ValueKey(
                                                  'diary-visible-${task.id}',
                                                ),
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: TaskItem(
                                                  task: task,
                                                  urgency: task.urgency,
                                                  colorHex: resolveTaskColor(
                                                    context,
                                                    task,
                                                  ),
                                                  completedColor:
                                                      resolveTaskColor(
                                                    context,
                                                    task,
                                                  ),
                                                  keepCompletedTaskActiveStyle:
                                                      true,
                                                  onToggle: () =>
                                                      _restoreTask(task),
                                                ),
                                              ),
                                      ),
                                  ],
                                ),
                              ),
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: hasTasks ? 0 : 1,
                      duration: const Duration(milliseconds: 220),
                      child: Center(
                        child: Text(
                          S.of(context).noTasksForDay,
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _fadeAndCollapse(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: animation,
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }
}
