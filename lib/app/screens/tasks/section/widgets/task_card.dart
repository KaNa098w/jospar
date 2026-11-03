import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/app/screens/tasks/section/widgets/task_item_widget.dart';

typedef TaskVoidCallback = void Function();
typedef TaskCallback = void Function(TaskItems task);
typedef ConfirmTaskCallback = Future<bool> Function(TaskItems task);

class TaskCard extends StatelessWidget {
  final TaskItems task;
  final Color color;
  final TaskVoidCallback onToggle;
  final TaskCallback onDelete; // вызывает удаление
  final ConfirmTaskCallback onConfirmDelete;
  final TaskCallback onOpenEditor; // открыть модалку редактирования
  final VoidCallback? onDragStarted; // ← ДОБАВЬ
  final VoidCallback? onDragEnded; // ← ДОБАВЬ
  final ValueChanged<Offset>? onDragUpdate;
  final bool isHighlighted;
  final String? trailingText;

  const TaskCard({
    super.key,
    required this.task,
    required this.color,
    required this.onToggle,
    required this.onDelete,
    required this.onConfirmDelete,
    required this.onOpenEditor,
    required this.onDragStarted,
    required this.onDragEnded,
    this.onDragUpdate,
    this.isHighlighted = false,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.transparent
          : Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (task.isCompleted == true) {
                  onToggle();
                } else {
                  onOpenEditor(task);
                }
              },
              child: TaskItem(
                colorHex: color,
                urgency: task.urgency, // ← ДОБАВЬ
                task: task,
                completedColor: color,
                keepCompletedTaskActiveStyle: true,
                useLargeCheckboxTapTarget: true,
                trailingText: trailingText,
                onToggle: onToggle,
              ),
            )
                .animate()
                .slideY(begin: -0.5, end: 0, duration: 300.ms)
                .fadeIn(duration: 300.ms),
          ),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: color.withValues(alpha: .30),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : const [],
      ),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          dismissible: DismissiblePane(
            confirmDismiss: () => onConfirmDelete(task),
            onDismissed: () => onDelete(task),
          ),
          extentRatio: 0.18,
          children: [
            SlidableAction(
              onPressed: (_) async {
                if (await onConfirmDelete(task)) onDelete(task);
              },
              icon: Icons.delete,
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(6),
              flex: 1,
            ),
          ],
        ),
        child: LongPressDraggable<TaskItems>(
          data: task,
          onDragStarted: () {
            if (onDragStarted != null) onDragStarted!(); // ← ВЫЗОВ
          },
          onDragEnd: (_) {
            if (onDragEnded != null) onDragEnded!(); // ← ВЫЗОВ
          },
          onDragCompleted: onDragEnded,
          onDraggableCanceled: (_, __) => onDragEnded?.call(),
          onDragUpdate: (details) => onDragUpdate?.call(details.globalPosition),
          dragAnchorStrategy: childDragAnchorStrategy,
          feedback: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Opacity(opacity: 0.92, child: card),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.35, child: card),
          child: card,
        ),
      ),
    );
  }
}
