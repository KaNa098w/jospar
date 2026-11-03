import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';
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

  Future<void> _openTask(TaskItems task) async {
    final taskId = task.id;
    if (taskId == null || taskId.isEmpty) return;

    await showAddTaskModal(
      context: context,
      selectedDay: parseLocal(task.date) ??
          parseLocal(task.updatedAt) ??
          parseLocal(task.createdAt) ??
          DateTime.now(),
      taskId: taskId,
      existingTask: task,
      onSaveTask: (title, subtasks, date, taskListId, urgency) async {
        await _saveTaskAndSubtasks(
          task: task,
          title: title,
          subtasks: List<Map<String, dynamic>>.from(subtasks),
          date: date,
          taskListId: taskListId,
          urgency: urgency,
        );
        return taskId;
      },
    );

    if (!mounted) return;
    await _reloadDiary();
  }

  Future<void> _saveTaskAndSubtasks({
    required TaskItems task,
    required String title,
    required List<Map<String, dynamic>> subtasks,
    required DateTime? date,
    required String taskListId,
    required String urgency,
  }) async {
    final parentId = task.id;
    if (parentId == null || parentId.isEmpty) return;
    final originals = {
      for (final child in task.children ?? const <TaskItems>[])
        if (child.id != null)
          child.id!: {
            'title': child.name ?? '',
            'completed': child.isCompleted == true,
            'position': child.position,
          },
    };
    final retainedIds = subtasks
        .map((item) => item['_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    await _taskService.updateTaskPut(
      context,
      id: parentId,
      name: title,
      date: date == null ? null : _ymd(date),
      clearDate: date == null,
      urgency: urgency,
      taskListId: taskListId,
    );

    for (final entry in subtasks.asMap().entries) {
      final subtask = entry.value;
      final id = subtask['_id']?.toString();
      final name = (subtask['title'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final completed = subtask['completed'] == true;
      if (id == null || id.isEmpty) {
        if (!mounted) return;
        await _taskService.createSubtask(
          context,
          name: name,
          parentTaskId: parentId,
          taskListId: taskListId,
          date: date == null ? null : _ymd(date),
          position: entry.key,
        );
        continue;
      }

      final original = originals[id];
      if (original == null ||
          original['title'] != name ||
          original['completed'] != completed ||
          original['position'] != entry.key) {
        if (!mounted) return;
        await _taskService.updateTaskPut(
          context,
          id: id,
          name: name,
          isCompleted: completed,
          position: entry.key,
          date: task.date,
        );
      }
    }

    for (final id in originals.keys.where((id) => !retainedIds.contains(id))) {
      if (!mounted) return;
      await _taskService.deleteTask(context, id);
    }

    final allSubtasksCompleted = subtasks.isNotEmpty &&
        subtasks.every((item) => item['completed'] == true);
    if (subtasks.isNotEmpty && task.isCompleted != allSubtasksCompleted) {
      if (!mounted) return;
      await _taskService.updateTaskPut(
        context,
        id: parentId,
        isCompleted: allSubtasksCompleted,
        date: date == null ? null : _ymd(date),
        clearDate: date == null,
      );
      task.isCompleted = allSubtasksCompleted;
    }
  }

  Future<void> _reloadDiary() async {
    final provider = context.read<GlobalProvider>();
    await provider.refreshTasks(context, silent: true);
    if (!mounted) return;
    final refreshed = provider.allApiTasks
        .map((task) => TaskItems.fromJson(task.toJson()))
        .toList(growable: false);
    final days = _groupTasks(refreshed).keys.toList()
      ..sort((a, b) => b.compareTo(a));
    setState(() {
      _tasks
        ..clear()
        ..addAll(refreshed);
      _days
        ..clear()
        ..addAll(days);
    });
  }

  String _ymd(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

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
                                                child: GestureDetector(
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  onTap: () => _openTask(task),
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
