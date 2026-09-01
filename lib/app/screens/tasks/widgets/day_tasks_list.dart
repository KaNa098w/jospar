import 'package:flutter/material.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:provider/provider.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';
import 'package:jospar/app/screens/tasks/section/widgets/task_item_widget.dart';
import '../utils/date_utils_ext.dart';
import '../utils/sorting.dart';

class DayTasksList extends StatelessWidget {
  final List<TaskItems> items;
  final DateTime selectedDay;
  final TaskService taskService;

  const DayTasksList({
    super.key,
    required this.items,
    required this.selectedDay,
    required this.taskService,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            S.of(context).noTasksToday,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ThemeColors.grey5,
            ),
          ),
        ),
      );
    }

    final list = List<TaskItems>.from(items);
    sortDayTasks(list);

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 130, left: 20, right: 20),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final task = list[i];
        return GestureDetector(
          onTap: () async {
            await showAddTaskModal(
              context: context,
              selectedDay: selectedDay,
              taskId: task.id ?? '',
              existingTask: task,
              onSaveTask: (title, subtasks, date, taskListId, urgency) async {
                await taskService.updateTaskPut(
                  context,
                  id: task.id ?? '',
                  name: title,
                  taskListId: taskListId,
                  date: date == null ? null : fmtYmd(date),
                  clearDate: date == null,
                  urgency: urgency,
                );
                if (context.mounted) {
                  await context.read<GlobalProvider>().refreshTasks(context);
                }
                return task.id;
              },
            );
          },
          child: TaskItem(
            colorHex: ThemeColors.primary,
            task: task,
            urgency: task.urgency,
            completedColor: ThemeColors.primary,
            keepCompletedTaskActiveStyle: true,
            onToggle: () async {
              final prev = task.isCompleted == true;
              task.isCompleted = !prev;
              (context as Element).markNeedsBuild();
              try {
                await taskService.updateTask(context, id: task.id ?? '');
                if (context.mounted) {
                  await context.read<GlobalProvider>().refreshTasks(context);
                }
              } catch (e) {
                task.isCompleted = prev;
                context.markNeedsBuild();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Не удалось обновить задачу: $e')),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}
