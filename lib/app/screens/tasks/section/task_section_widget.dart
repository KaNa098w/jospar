import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:provider/provider.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/services/collaboration_service.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/app/widgets/custom_alert_dialog.dart';

import 'utils/task_sort.dart';
import 'utils/date_fmt.dart';
import 'utils/task_color.dart';
import 'widgets/section_header.dart';
import 'widgets/task_list_area.dart';
import 'widgets/task_card.dart';
import '../utils/bucketing.dart';
import '../utils/date_utils_ext.dart' hide fmtYmd;

class TaskSection extends StatefulWidget {
  final String title;
  final String tasksKey;
  final VoidCallback? onBeforeOpenModal;
  final VoidCallback? onAfterCloseModal;
  final List<TaskItems>? items;
  final VoidCallback? onDragStart; // ← ДОБАВЬ
  final VoidCallback? onDragEnd; // ← ДОБАВЬ
  final ValueChanged<Offset>? onDragUpdate;
  final bool initiallyExpanded;
  final bool showTaskCount;
  final bool showCompletedCount;
  final Color? titleColor;
  final Color? countColor;
  final String? highlightedTaskId;
  final int? headerCompletedCount;
  final int? headerTotalCount;
  final VoidCallback? onHeaderCountTap;
  final DateTime? bucketBaseDate;

  final Function(TaskItems task, String targetSectionKey, int targetIndex)?
      onTaskDroppedOnSection;

  const TaskSection({
    super.key,
    required this.title,
    required this.tasksKey,
    this.onBeforeOpenModal,
    this.onAfterCloseModal,
    this.items,
    this.onTaskDroppedOnSection,
    this.onDragStart,
    this.onDragEnd,
    this.onDragUpdate,
    this.initiallyExpanded = true,
    this.showTaskCount = true,
    this.showCompletedCount = true,
    this.titleColor,
    this.countColor,
    this.highlightedTaskId,
    this.headerCompletedCount,
    this.headerTotalCount,
    this.onHeaderCountTap,
    this.bucketBaseDate,
  });

  @override
  State<TaskSection> createState() => TaskSectionState();
}

class TaskSectionState extends State<TaskSection>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();

  List<TaskItems> tasks = [];
  late bool isExpanded;
  bool isLoading = false;
  final Set<String> _disappearingTaskIds = {};

  late final AnimationController _controller;
  late final Animation<double> _heightFactor;

  void removeTaskById(String id) {
    setState(() => tasks.removeWhere((t) => (t.id ?? '') == id));
  }

  void setExpanded(bool value) {
    if (isExpanded == value) return;
    setState(() {
      isExpanded = value;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void insertTask(TaskItems t, int index) {
    setState(() {
      tasks.removeWhere((item) => item.id == t.id);
      tasks.insert(index.clamp(0, tasks.length), t);
      _numberTasks();
    });
  }

  void reorderTask(TaskItems task, int targetIndex) {
    setState(() {
      final oldIndex = tasks.indexWhere((item) => item.id == task.id);
      if (oldIndex < 0) return;
      final item = tasks.removeAt(oldIndex);
      if (oldIndex < targetIndex) targetIndex--;
      tasks.insert(targetIndex.clamp(0, tasks.length), item);
      _numberTasks();
    });
  }

  void _numberTasks() {
    for (var i = 0; i < tasks.length; i++) {
      tasks[i].position = i;
    }
  }

  void setApiItems(List<TaskItems> newItems) {
    setState(() {
      tasks = List.of(newItems);
      _clearFinishedDisappearances(newItems);
      sortTasks(tasks);
    });
  }

  void _clearFinishedDisappearances(List<TaskItems> newItems) {
    // Keep an id only while that completed task is still being animated in
    // this section. Once it is removed from the section (or restored as an
    // active task), the stale animation flag must not hide it on its return.
    _disappearingTaskIds.removeWhere(
      (id) => !newItems.any(
        (task) => task.id == id && task.isCompleted == true,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: isExpanded ? 1 : 0,
    );
    _heightFactor =
        CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);

    if (widget.items != null) {
      tasks = List.of(widget.items!);
      sortTasks(tasks);
    }
  }

  @override
  void didUpdateWidget(covariant TaskSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items != oldWidget.items && widget.items != null) {
      setState(() {
        tasks = List.of(widget.items!);
        _clearFinishedDisappearances(widget.items!);
        sortTasks(tasks);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSection() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _toggleTask(int index) async {
    final t = tasks[index];
    final taskId = t.id ?? '';
    final newVal = !(t.isCompleted ?? false);

    setState(() => t.isCompleted = newVal);

    try {
      final update = _taskService.updateTask(context, id: taskId);
      final animation = () async {
        if (!newVal) return;
        // Сначала показываем установленную галочку, затем мягко убираем
        // завершённую карточку с главного экрана.
        await Future<void>.delayed(const Duration(milliseconds: 120));
        if (mounted) setState(() => _disappearingTaskIds.add(taskId));
        await Future<void>.delayed(const Duration(milliseconds: 320));
      }();
      await Future.wait([update, animation]);
      if (!mounted) return;
      await context.read<GlobalProvider>().refreshTasks(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        t.isCompleted = !newVal;
        _disappearingTaskIds.remove(taskId);
        sortTasks(tasks);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось обновить задачу: $e')),
      );
    }
  }

  Future<void> _requestDelete(TaskItems task) async {
    final removedIndex = tasks.indexWhere((t) => t.id == task.id);
    if (removedIndex == -1) return;

    setState(() {
      tasks.removeAt(removedIndex);
      sortTasks(tasks);
    });

    setState(() => isLoading = true);
    try {
      final taskId = task.id ?? '';
      if (shouldLeaveSharedTask(task)) {
        await CollaborationService().leave(taskId);
        await OfflineRuntime.syncEngine?.synchronize(ignoreStopped: true);
      } else {
        await _taskService.deleteTask(context, taskId);
      }
      await context.read<GlobalProvider>().refreshTasks(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          tasks.insert(removedIndex, task);
          sortTasks(tasks);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось удалить: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<bool> _confirmDelete(TaskItems task) {
    if (!shouldLeaveSharedTask(task)) return Future.value(true);
    return confirmLeaveSharedTask(context);
  }

  Future<void> _openEditor(TaskItems task, int index) async {
    widget.onBeforeOpenModal?.call();

    await showAddTaskModal(
      context: context,
      selectedDay: DateTime.tryParse(task.date ?? '') ??
          DateTime.tryParse(task.createdAt ?? '') ??
          DateTime.now(),
      taskId: task.id ?? '',
      existingTask: task,
      onSaveTask: (title, updatedSubtasksAny, date, taskListId, urgency) async {
        try {
          final String parentId = task.id ?? '';
          if (parentId.isEmpty) throw Exception('Нет id задачи');

          final List<Map<String, dynamic>> updatedSubtasks =
              List<Map<String, dynamic>>.from(updatedSubtasksAny);

          // делаем снимок оригинальных детей из модели
          final List<Map<String, dynamic>> originalSubtasks =
              (task.children ?? [])
                  .map((c) => {
                        '_id': c.id,
                        'title': (c.name ?? '').toString(),
                        'completed': c.isCompleted == true,
                        'position': c.position,
                      })
                  .toList();

          Map<String, Map<String, dynamic>> _byId(
              List<Map<String, dynamic>> list) {
            final m = <String, Map<String, dynamic>>{};
            for (final s in list) {
              final id = (s['_id'] as String?);
              if (id != null && id.isNotEmpty) m[id] = s;
            }
            return m;
          }

          final oldById = _byId(originalSubtasks);
          final newById = _byId(updatedSubtasks);

          // 1) обновляем саму задачу
          await _taskService.updateTaskPut(context,
              id: parentId,
              name: title,
              taskListId: taskListId,
              date: date == null ? null : fmtYmd(date),
              clearDate: date == null,
              urgency: urgency);

          // 2) создаём новые подзадачи
          for (final entry in updatedSubtasks.asMap().entries) {
            final s = entry.value;
            if (s['_id'] != null) continue;
            final name = (s['title'] ?? '').toString().trim();
            if (name.isEmpty) continue;
            await _taskService.createSubtask(
              context,
              name: name,
              parentTaskId: parentId,
              taskListId: taskListId,
              position: entry.key,
            );
          }

          // 3) обновляем изменившиеся
          for (final entry in updatedSubtasks.asMap().entries) {
            final s = entry.value;
            final id = s['_id'] as String?;
            if (id == null || id.isEmpty) continue;

            final prev = oldById[id];
            final newName = (s['title'] ?? '').toString();
            final newCompleted = s['completed'] == true;

            final prevName = (prev?['title'] ?? '').toString();
            final prevCompleted = prev?['completed'] == true;
            final prevPosition = prev?['position'] as int?;

            final changed = (newName != prevName) ||
                (newCompleted != prevCompleted) ||
                prevPosition != entry.key;
            if (changed) {
              await _taskService.updateTaskPut(
                context,
                id: id,
                name: newName,
                isCompleted: newCompleted,
                position: entry.key,
                date: task.date,
              );
            }
          }

          // 4) удаляем исчезнувшие
          for (final entry in oldById.entries) {
            if (!newById.containsKey(entry.key)) {
              await _taskService.deleteTask(context, entry.key);
            }
          }

          final allSubtasksCompleted = updatedSubtasks.isNotEmpty &&
              updatedSubtasks.every((item) => item['completed'] == true);
          if (task.isCompleted != allSubtasksCompleted) {
            await _taskService.updateTaskPut(
              context,
              id: parentId,
              isCompleted: allSubtasksCompleted,
              date: date == null ? null : fmtYmd(date),
              clearDate: date == null,
            );
            task.isCompleted = allSubtasksCompleted;
          }

          await context.read<GlobalProvider>().refreshTasks(context);
          return parentId;
        } catch (e) {
          if (mounted) {
            setState(() => tasks[index] = task);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Не удалось сохранить: $e')),
            );
          }
          return null;
        }
      },
    );

    widget.onAfterCloseModal?.call();
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = tasks.where((t) => t.isCompleted ?? false).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TaskSectionHeader(
          title: widget.title,
          completed: widget.headerCompletedCount ?? completedCount,
          total: widget.headerTotalCount ?? tasks.length,
          expanded: isExpanded,
          showCount: widget.showTaskCount,
          showCompletedCount: widget.showCompletedCount,
          titleColor: widget.titleColor,
          countColor: widget.countColor,
          onCountTap: widget.onHeaderCountTap,
          onToggle: _toggleSection,
        ),
        const SizedBox(height: 15),
        // if (isLoading)
        //   const Padding(
        //     padding: EdgeInsets.symmetric(vertical: 12),
        //     child: Center(child: CircularProgressIndicator()),
        //   ),
        TaskListArea(
          tasks: tasks,
          sizeFactor: _heightFactor,
          onDropToSection: (task, index) {
            if (widget.onTaskDroppedOnSection != null) {
              widget.onTaskDroppedOnSection!(task, widget.tasksKey, index);
            } else {
              final alreadyInList = tasks.any((t) => t.id == task.id);
              if (alreadyInList) reorderTask(task, index);
              if (!alreadyInList) insertTask(task, index);
            }
          },
          itemBuilder: (index, task) {
            final disappearing = _disappearingTaskIds.contains(task.id ?? '');
            final taskDate = parseApiDateOrYmd(task.date);
            final showLaterDate = widget.tasksKey == kBucketLater &&
                widget.bucketBaseDate != null &&
                showDateInLater(taskDate, widget.bucketBaseDate!);
            final trailingText = showLaterDate
                ? DateFormat(
                    'd MMM',
                    Localizations.localeOf(context).languageCode,
                  ).format(taskDate!).replaceAll('.', '')
                : null;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
              child: disappearing
                  ? SizedBox.shrink(key: ValueKey('hidden-${task.id}'))
                  : KeyedSubtree(
                      key: ValueKey('visible-${task.id}'),
                      child: TaskCard(
                        task: task,
                        color: resolveTaskColor(context, task),
                        isHighlighted: task.id == widget.highlightedTaskId,
                        trailingText: trailingText,
                        onToggle: () => _toggleTask(index),
                        onDelete: (t) => _requestDelete(t),
                        onConfirmDelete: _confirmDelete,
                        onOpenEditor: (t) => _openEditor(t, index),
                        onDragStarted: widget.onDragStart,
                        onDragEnded: widget.onDragEnd,
                        onDragUpdate: widget.onDragUpdate,
                      ),
                    ),
            );
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
