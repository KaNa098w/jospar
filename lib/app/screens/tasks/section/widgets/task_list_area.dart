import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jospar/core/models/tasks_response.dart';

typedef TaskItemBuilder = Widget Function(int index, TaskItems task);
typedef OnDropToSection = void Function(TaskItems task, int index);

class TaskListArea extends StatefulWidget {
  const TaskListArea({
    super.key,
    required this.tasks,
    required this.sizeFactor,
    required this.itemBuilder,
    required this.onDropToSection,
    this.onDragStarted,
    this.onDragEnded,
  });

  final List<TaskItems> tasks;
  final Animation<double> sizeFactor;
  final TaskItemBuilder itemBuilder;
  final OnDropToSection onDropToSection;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  State<TaskListArea> createState() => _TaskListAreaState();
}

class _TaskListAreaState extends State<TaskListArea> {
  String? _landedTaskId;
  int? _lastHapticIndex;

  void _handleHoverIndex(int index) {
    if (_lastHapticIndex == index) return;
    _lastHapticIndex = index;
    HapticFeedback.selectionClick();
  }

  void _handleDrop(TaskItems task, int index) {
    _lastHapticIndex = null;
    setState(() => _landedTaskId = task.id);
    widget.onDropToSection(task, index);
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (mounted && _landedTaskId == task.id) {
        setState(() => _landedTaskId = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: widget.sizeFactor,
      alignment: Alignment.topCenter,
      child: SlidableAutoCloseBehavior(
        child: Column(
          children: [
            for (final entry in widget.tasks.asMap().entries)
              _TaskDropTarget(
                key: ValueKey('drop-${entry.value.id}'),
                index: entry.key,
                onDrop: _handleDrop,
                onHoverIndex: _handleHoverIndex,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: _landedTaskId == entry.value.id
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _landedTaskId == entry.value.id
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .16),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ]
                        : const [],
                  ),
                  child: widget.itemBuilder(entry.key, entry.value),
                ),
              ),
            if (widget.tasks.isEmpty)
              DragTarget<TaskItems>(
                onWillAcceptWithDetails: (_) => true,
                onAcceptWithDetails: (details) => _handleDrop(details.data, 0),
                builder: (_, candidates, __) => AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  height: candidates.isEmpty ? 8 : 44,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskDropTarget extends StatefulWidget {
  const _TaskDropTarget({
    super.key,
    required this.index,
    required this.onDrop,
    required this.onHoverIndex,
    required this.child,
  });

  final int index;
  final OnDropToSection onDrop;
  final ValueChanged<int> onHoverIndex;
  final Widget child;

  @override
  State<_TaskDropTarget> createState() => _TaskDropTargetState();
}

class _TaskDropTargetState extends State<_TaskDropTarget> {
  bool _insertAfter = false;

  void _updateSide(DragTargetDetails<TaskItems> details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final after = box.globalToLocal(details.offset).dy > box.size.height / 2;
    if (after != _insertAfter) setState(() => _insertAfter = after);
    widget.onHoverIndex(after ? widget.index + 1 : widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<TaskItems>(
      onWillAcceptWithDetails: (_) => true,
      onMove: _updateSide,
      onAcceptWithDetails: (details) {
        final insertIndex = _insertAfter ? widget.index + 1 : widget.index;
        widget.onDrop(details.data, insertIndex);
      },
      builder: (_, candidates, __) {
        final active = candidates.isNotEmpty;
        return Column(
          children: [
            _TaskShadow(
              visible: active && !_insertAfter,
            ),
            widget.child,
            _TaskShadow(
              visible: active && _insertAfter,
            ),
          ],
        );
      },
    );
  }
}

class _TaskShadow extends StatelessWidget {
  const _TaskShadow({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return AnimatedSize(
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: visible
          ? AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: visible ? .48 : 0,
              child: Container(
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
