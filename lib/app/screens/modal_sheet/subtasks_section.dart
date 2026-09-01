import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jospar/core/l10n/s.dart';

const double _subtaskTrailingGap = 12;
const double _subtaskVerticalGap = 15;
const double _subtaskLineHeight = 19.375;
const double _subtaskToggleWidth = 42;
const double _subtaskToggleHeight = 24;
const double _editableCaretMargin = 3;
const TextStyle _subtaskTextStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 15.5,
  fontWeight: FontWeight.w400,
  height: 1.25,
  letterSpacing: 0,
  color: Colors.black,
);
const TextStyle _subtaskHintStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 15.5,
  fontWeight: FontWeight.w400,
  height: 1.25,
  letterSpacing: 0,
  color: Colors.grey,
);
const StrutStyle _subtaskStrutStyle = StrutStyle(
  fontFamily: 'Roboto',
  fontSize: 15.5,
  height: 1.25,
  leading: 0,
  forceStrutHeight: true,
);

class SubtasksSection extends StatefulWidget {
  final List<Map<String, dynamic>> subtasks;

  final bool showSubtaskInput;
  final TextEditingController subtaskController;
  final FocusNode subtaskFocusNode;

  final ValueChanged<int> onToggleComplete;
  final ValueChanged<String> onAdd;
  final void Function(int index, String title)? onInsertAfter;
  final ValueChanged<bool> onToggleInput;
  final ValueChanged<bool>? onEditingChanged;
  final Color? bulletColor;

  const SubtasksSection({
    super.key,
    required this.subtasks,
    required this.showSubtaskInput,
    required this.subtaskController,
    required this.subtaskFocusNode,
    required this.onToggleComplete,
    required this.onAdd,
    this.onInsertAfter,
    required this.onToggleInput,
    this.onEditingChanged,
    this.bulletColor,
  });

  @override
  State<SubtasksSection> createState() => _SubtasksSectionState();
}

class _SubtasksSectionState extends State<SubtasksSection> {
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focuses = {};
  final Set<int> _editing = {};
  Timer? _undoTimer;
  Map<String, dynamic>? _recentlyRemoved;
  int? _recentlyRemovedIndex;
  Map<String, dynamic>? _movingSubtask;
  Map<String, dynamic>? _arrivingSubtask;
  Map<String, dynamic>? _deletingSubtask;
  Timer? _dragAutoScrollTimer;
  ScrollPosition? _parentScrollPosition;
  double _dragAutoScrollVelocity = 0;
  bool _isReordering = false;
  Map<String, dynamic>? _reorderingSubtask;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _parentScrollPosition = Scrollable.maybeOf(context)?.position;
  }

  void _updateDragAutoScroll(PointerMoveEvent event) {
    if (!_isReordering) return;
    final position = _parentScrollPosition;
    final viewport = position?.context.notificationContext?.findRenderObject();
    if (position == null || viewport is! RenderBox || !viewport.hasSize) return;

    const edgeExtent = 80.0;
    const maxVelocity = 5.0;
    final viewportTop = viewport.localToGlobal(Offset.zero).dy;
    final viewportBottom = viewportTop + viewport.size.height;
    final pointerY = event.position.dy;

    if (pointerY < viewportTop + edgeExtent) {
      final proximity =
          ((viewportTop + edgeExtent - pointerY) / edgeExtent).clamp(0.0, 1.0);
      _dragAutoScrollVelocity = -maxVelocity * proximity;
    } else if (pointerY > viewportBottom - edgeExtent) {
      final proximity =
          ((pointerY - (viewportBottom - edgeExtent)) / edgeExtent)
              .clamp(0.0, 1.0);
      _dragAutoScrollVelocity = maxVelocity * proximity;
    } else {
      _dragAutoScrollVelocity = 0;
    }

    if (_dragAutoScrollVelocity == 0) {
      _stopDragAutoScroll();
      return;
    }
    _dragAutoScrollTimer ??=
        Timer.periodic(const Duration(milliseconds: 16), (_) {
      final activePosition = _parentScrollPosition;
      if (!_isReordering || activePosition == null) {
        _stopDragAutoScroll();
        return;
      }
      final nextOffset = (activePosition.pixels + _dragAutoScrollVelocity)
          .clamp(
            activePosition.minScrollExtent,
            activePosition.maxScrollExtent,
          )
          .toDouble();
      if (nextOffset == activePosition.pixels) return;
      activePosition.jumpTo(nextOffset);
    });
  }

  void _stopDragAutoScroll() {
    _dragAutoScrollVelocity = 0;
    _dragAutoScrollTimer?.cancel();
    _dragAutoScrollTimer = null;
  }

  Future<void> _toggleWithAnimation(
    Map<String, dynamic> subtask,
    int oldIndex,
  ) async {
    if (_movingSubtask != null) return;
    setState(() => _movingSubtask = subtask);

    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;

    widget.onToggleComplete(oldIndex);
    final newIndex = widget.subtasks.indexOf(subtask);
    if (newIndex >= 0 && newIndex != oldIndex) {
      _reindexAfterReorder(
        oldIndex,
        newIndex > oldIndex ? newIndex + 1 : newIndex,
      );
    }
    setState(() {
      _movingSubtask = null;
      _arrivingSubtask = subtask;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && identical(_arrivingSubtask, subtask)) {
        setState(() => _arrivingSubtask = null);
      }
    });
  }

  TextEditingController _ensureController(int index, {String? initial}) {
    final controller = _controllers.putIfAbsent(
      index,
      () => TextEditingController(text: initial ?? ''),
    );
    if (!_editing.contains(index) &&
        initial != null &&
        controller.text != initial) {
      controller.text = initial;
    }
    return controller;
  }

  FocusNode _ensureFocus(int index, Map<String, dynamic> subtask) {
    return _focuses.putIfAbsent(index, () {
      final node = FocusNode();
      node.addListener(() {
        widget.onEditingChanged?.call(node.hasFocus);
        if (node.hasFocus) {
          _ensureSubtaskVisible(subtask);
        }
        if (mounted) setState(() {}); // ← добавлено
      });
      return node;
    });
  }

  void _ensureSubtaskVisible(Map<String, dynamic> subtask) {
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final rowContext = GlobalObjectKey(subtask).currentContext;
      if (rowContext == null) return;
      Scrollable.ensureVisible(
        rowContext,
        alignment: 0.45,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _disposeAt(int index) {
    _controllers.remove(index)?.dispose();
    _focuses.remove(index)?.dispose();
    _editing.remove(index);
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    _stopDragAutoScroll();
    for (final c in _controllers.values) c.dispose();
    for (final f in _focuses.values) f.dispose();
    super.dispose();
  }

  Future<void> _removeWithUndo(int index) async {
    if (_deletingSubtask != null) return;
    _undoTimer?.cancel();
    final removed = widget.subtasks[index];
    setState(() => _deletingSubtask = removed);
    await Future<void>.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;

    final currentIndex = widget.subtasks.indexOf(removed);
    if (currentIndex < 0) {
      setState(() => _deletingSubtask = null);
      return;
    }
    setState(() {
      widget.subtasks.removeAt(currentIndex);
      _disposeAt(currentIndex);
      _reindexAfterRemove(currentIndex);
      _recentlyRemoved = removed;
      _recentlyRemovedIndex = currentIndex;
      _deletingSubtask = null;
    });
    _undoTimer = Timer(const Duration(seconds: 5), () {
      if (!mounted) return;
      setState(() {
        _recentlyRemoved = null;
        _recentlyRemovedIndex = null;
      });
    });
  }

  void _undoRemove() {
    final removed = _recentlyRemoved;
    final originalIndex = _recentlyRemovedIndex;
    if (removed == null || originalIndex == null) return;
    _undoTimer?.cancel();
    final insertIndex = originalIndex.clamp(0, widget.subtasks.length);
    setState(() {
      _reindexAfterInsert(insertIndex);
      widget.subtasks.insert(insertIndex, removed);
      _recentlyRemoved = null;
      _recentlyRemovedIndex = null;
    });
  }

  void _addEmptyAndFocus() {
    final previousItems = widget.subtasks.toSet();
    widget.onAdd('');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final insertedIndex = widget.subtasks.indexWhere(
        (item) => !previousItems.contains(item),
      );
      if (insertedIndex < 0) return;

      _reindexAfterInsert(insertedIndex);
      _editing
        ..clear()
        ..add(insertedIndex);
      _ensureController(insertedIndex, initial: '');
      final subtask = widget.subtasks[insertedIndex];
      final focus = _ensureFocus(insertedIndex, subtask);

      widget.onEditingChanged?.call(true);
      focus.requestFocus();
      if (mounted) setState(() {});
    });
  }

  void _addEmptyAfterAndFocus(int currentIndex) {
    final previousItems = widget.subtasks.toSet();
    final insertIndex = (currentIndex + 1).clamp(0, widget.subtasks.length);

    if (widget.onInsertAfter case final insertAfter?) {
      insertAfter(currentIndex, '');
    } else {
      widget.subtasks.insert(insertIndex, {
        'title': '',
        'completed': false,
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final insertedIndex = widget.subtasks.indexWhere(
        (item) => !previousItems.contains(item),
      );
      if (insertedIndex < 0) return;

      _reindexAfterInsert(insertedIndex);
      _editing
        ..clear()
        ..add(insertedIndex);
      _ensureController(insertedIndex, initial: '');
      final subtask = widget.subtasks[insertedIndex];
      final focus = _ensureFocus(insertedIndex, subtask);

      widget.onEditingChanged?.call(true);
      focus.requestFocus();
      setState(() {});
    });
  }

  void _reindexAfterInsert(int insertedIndex) {
    final controllers = <int, TextEditingController>{};
    for (final entry in _controllers.entries) {
      controllers[entry.key >= insertedIndex ? entry.key + 1 : entry.key] =
          entry.value;
    }
    final focuses = <int, FocusNode>{};
    for (final entry in _focuses.entries) {
      focuses[entry.key >= insertedIndex ? entry.key + 1 : entry.key] =
          entry.value;
    }
    final editing = _editing
        .map((index) => index >= insertedIndex ? index + 1 : index)
        .toSet();

    _controllers
      ..clear()
      ..addAll(controllers);
    _focuses
      ..clear()
      ..addAll(focuses);
    _editing
      ..clear()
      ..addAll(editing);
  }

  // --- перенос всех карт после reorder (контроллеры, фокусы, режимы) ---
  void _reindexAfterReorder(int oldIndex, int newIndex) {
    // В ReorderableListView newIndex уже «после удаления oldIndex», надо привести:
    if (newIndex > oldIndex) newIndex -= 1;

    // Перетаскиваем элементы в списке контроллеров и фокусов
    TextEditingController? movedC = _controllers.remove(oldIndex);
    FocusNode? movedF = _focuses.remove(oldIndex);

    final newControllers = <int, TextEditingController>{};
    final newFocuses = <int, FocusNode>{};

    // Сдвигаем ключи между oldIndex и newIndex
    final keysC = _controllers.keys.toList()..sort();
    for (final k in keysC) {
      final c = _controllers[k]!;
      int target = k;
      if (oldIndex < newIndex) {
        // перетаскиваем вниз: позиции (oldIndex+1 .. newIndex) сдвигаются на -1
        if (k > oldIndex && k <= newIndex) target = k - 1;
      } else if (oldIndex > newIndex) {
        // перетаскиваем вверх: позиции (newIndex .. oldIndex-1) сдвигаются на +1
        if (k >= newIndex && k < oldIndex) target = k + 1;
      }
      newControllers[target] = c;
    }

    final keysF = _focuses.keys.toList()..sort();
    for (final k in keysF) {
      final f = _focuses[k]!;
      int target = k;
      if (oldIndex < newIndex) {
        if (k > oldIndex && k <= newIndex) target = k - 1;
      } else if (oldIndex > newIndex) {
        if (k >= newIndex && k < oldIndex) target = k + 1;
      }
      newFocuses[target] = f;
    }

    if (movedC != null) newControllers[newIndex] = movedC;
    if (movedF != null) newFocuses[newIndex] = movedF;

    _controllers
      ..clear()
      ..addAll(newControllers);
    _focuses
      ..clear()
      ..addAll(newFocuses);

    // Перемещаем флаг редактирования
    final newEditing = <int>{};
    for (final k in _editing) {
      int target = k;
      if (k == oldIndex) {
        target = newIndex;
      } else if (oldIndex < newIndex) {
        if (k > oldIndex && k <= newIndex) target = k - 1;
      } else if (oldIndex > newIndex) {
        if (k >= newIndex && k < oldIndex) target = k + 1;
      }
      newEditing.add(target);
    }
    _editing
      ..clear()
      ..addAll(newEditing);
  }

  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      dense: true,
      minVerticalPadding: 0,
      contentPadding: EdgeInsets.zero,
      child: Column(
        children: [
          Listener(
            onPointerMove: _updateDragAutoScroll,
            onPointerUp: (_) => _stopDragAutoScroll(),
            onPointerCancel: (_) => _stopDragAutoScroll(),
            child: ReorderableListView.builder(
              key: const PageStorageKey('subtasks-list'),
              buildDefaultDragHandles: false,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderStart: (index) {
                setState(() {
                  _isReordering = true;
                  _reorderingSubtask = widget.subtasks[index];
                });
                HapticFeedback.mediumImpact();
              },
              onReorderEnd: (_) {
                setState(() {
                  _isReordering = false;
                  _reorderingSubtask = null;
                });
                _stopDragAutoScroll();
                HapticFeedback.selectionClick();
              },
              proxyDecorator: (child, index, animation) => Material(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: .10),
                elevation: 5,
                shadowColor: Colors.black26,
                borderRadius: BorderRadius.circular(10),
                clipBehavior: Clip.antiAlias,
                child: child,
              ),
              itemCount: widget.subtasks.length,
              onReorder: (oldIndex, newIndex) {
                final adjustedIndex =
                    oldIndex < newIndex ? newIndex - 1 : newIndex;
                if (oldIndex == adjustedIndex) return;
                _reindexAfterReorder(oldIndex, newIndex);
                setState(() {
                  final moved = widget.subtasks.removeAt(oldIndex);
                  widget.subtasks.insert(adjustedIndex, moved);
                });
              },
              itemBuilder: (context, index) {
                final s = widget.subtasks[index];
                final completed = (s['completed'] as bool?) ?? false;
                final title = (s['title'] as String?) ?? '';
                final isEditingRow = _editing.contains(index);

                final controller = _ensureController(index, initial: title);
                final focus = _ensureFocus(index, s);
                final itemKey = GlobalObjectKey(s);

                if (isEditingRow) {
                  final isDeleting = identical(_deletingSubtask, s);
                  return AnimatedSlide(
                    key: itemKey,
                    offset: isDeleting ? const Offset(0.08, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeInCubic,
                    child: AnimatedOpacity(
                      opacity: isDeleting ? 0 : 1,
                      duration: const Duration(milliseconds: 130),
                      curve: Curves.easeIn,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          bottom: _subtaskVerticalGap,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _toggleWithAnimation(s, index),
                              child: _SubtaskLeadingSlot(
                                child: _FirstLineSubtaskBullet(
                                  completed: completed,
                                  color: widget.bulletColor ?? Colors.grey,
                                ),
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                key: ValueKey('subtask-inline-$index'),
                                controller: controller,
                                focusNode: focus,
                                autofocus: false,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                minLines: 1,
                                maxLines: null,
                                expands: false,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.next,
                                cursorWidth: 2,
                                style: _subtaskTextStyle.copyWith(
                                  color: completed
                                      ? const Color(0xFF9CA3AF)
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                                strutStyle: _subtaskStrutStyle,
                                onChanged: (v) {
                                  widget.subtasks[index]['title'] = v;
                                  setState(() {});
                                },
                                // Keep the keyboard connected while focus moves
                                // to the new subtask created below this one.
                                onEditingComplete: () {},
                                onSubmitted: (_) =>
                                    _addEmptyAfterAndFocus(index),
                                decoration: InputDecoration(
                                  hintText: S.of(context).subtaskTitle,
                                  border: InputBorder.none,
                                  isDense: true,
                                  isCollapsed: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: _subtaskHintStyle,
                                ),
                              ),
                            ),
                            // RenderEditable reserves 1 px of caret gap plus the
                            // 2 px cursor width from its text layout. Give those
                            // exact 3 px back from the existing trailing gap so
                            // view and edit modes wrap at the same words.
                            const SizedBox(
                              width: _subtaskTrailingGap - _editableCaretMargin,
                            ),
                            _SubtaskTrailingSlot(
                              child: IconButton(
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                ),
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                tooltip: S.of(context).delete,
                                onPressed: () => _removeWithUndo(index),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final isMoving = identical(_movingSubtask, s);
                final isArriving = identical(_arrivingSubtask, s);

                return AnimatedSlide(
                  key: itemKey,
                  offset: isMoving
                      ? const Offset(0, 0.22)
                      : isArriving
                          ? const Offset(0, -0.18)
                          : Offset.zero,
                  duration: Duration(milliseconds: isMoving ? 120 : 170),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: isMoving ? 0.15 : (isArriving ? 0.35 : 1),
                    duration: Duration(milliseconds: isMoving ? 110 : 160),
                    curve: Curves.easeOut,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: _subtaskVerticalGap,
                      ),
                      child: Material(
                        color: identical(_reorderingSubtask, s)
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: .10)
                            : Theme.of(context).colorScheme.surface,
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () {
                            setState(() {
                              _editing
                                ..clear()
                                ..add(index);
                              controller.text = title;
                              controller.selection = TextSelection.collapsed(
                                offset: controller.text.length,
                              );
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                widget.onEditingChanged?.call(true);
                                focus.requestFocus();
                              });
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _toggleWithAnimation(s, index),
                                child: _SubtaskLeadingSlot(
                                  child: _FirstLineSubtaskBullet(
                                    completed: completed,
                                    color: widget.bulletColor ?? Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: IgnorePointer(
                                  child: TextField(
                                    key: ValueKey('subtask-display-$index'),
                                    controller: controller,
                                    focusNode: focus,
                                    readOnly: true,
                                    showCursor: false,
                                    enableInteractiveSelection: false,
                                    minLines: 1,
                                    maxLines: null,
                                    expands: false,
                                    cursorWidth: 2,
                                    style: _subtaskTextStyle.copyWith(
                                      color: completed
                                          ? const Color(0xFF9CA3AF)
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                    ),
                                    strutStyle: _subtaskStrutStyle,
                                    decoration: InputDecoration(
                                      hintText: S.of(context).subtaskTitle,
                                      border: InputBorder.none,
                                      isDense: true,
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.zero,
                                      hintStyle: _subtaskHintStyle,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width:
                                    _subtaskTrailingGap - _editableCaretMargin,
                              ),
                              _SubtaskTrailingSlot(
                                child: ReorderableDragStartListener(
                                  index: index,
                                  child: const Center(
                                    child: Icon(
                                      Icons.drag_handle_rounded,
                                      color: Colors.grey,
                                      size: 21,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _recentlyRemoved == null
                ? const SizedBox.shrink(key: ValueKey('undo-empty'))
                : Container(
                    key: const ValueKey('subtask-undo-panel'),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F5F7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE3E7EC)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          size: 19,
                          color: Color(0xFF68717D),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            S.of(context).subtaskDeleted,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF414852),
                            ),
                          ),
                        ),
                        TextButton(
                          key: const ValueKey('undo-subtask-delete'),
                          onPressed: _undoRemove,
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            foregroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                          child: Text(
                            S.of(context).undo,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // --- «Добавить подзадачу» ---
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -4, horizontal: -2),
            minVerticalPadding: 0,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.add, color: Colors.grey, size: 20),
            title: GestureDetector(
              onTap: _addEmptyAndFocus,
              child: Text(
                S.of(context).addSubtask,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            onTap: _addEmptyAndFocus,
          ),
        ],
      ),
    );
  }

  void _reindexAfterRemove(int removedIndex) {
    final newControllers = <int, TextEditingController>{};
    final newFocuses = <int, FocusNode>{};

    final sortedC = _controllers.keys.toList()..sort();
    for (final oldIdx in sortedC) {
      final c = _controllers[oldIdx]!;
      if (oldIdx < removedIndex) {
        newControllers[oldIdx] = c;
      } else if (oldIdx > removedIndex) {
        newControllers[oldIdx - 1] = c;
      }
    }

    final sortedF = _focuses.keys.toList()..sort();
    for (final oldIdx in sortedF) {
      final f = _focuses[oldIdx]!;
      if (oldIdx < removedIndex) {
        newFocuses[oldIdx] = f;
      } else if (oldIdx > removedIndex) {
        newFocuses[oldIdx - 1] = f;
      }
    }

    _controllers
      ..clear()
      ..addAll(newControllers);
    _focuses
      ..clear()
      ..addAll(newFocuses);

    final newEditing = <int>{};
    for (final oldIdx in _editing) {
      if (oldIdx < removedIndex) {
        newEditing.add(oldIdx);
      } else if (oldIdx > removedIndex) {
        newEditing.add(oldIdx - 1);
      }
    }
    _editing
      ..clear()
      ..addAll(newEditing);
  }
}

class _FirstLineSubtaskBullet extends StatelessWidget {
  const _FirstLineSubtaskBullet({
    required this.completed,
    required this.color,
  });

  final bool completed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Высота совпадает с первой строкой текста: 15.5 * 1.25.
    return SizedBox(
      width: 23,
      height: _subtaskLineHeight,
      child: Transform.translate(
        offset: const Offset(0, 2),
        child: OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: 23,
          maxHeight: 23,
          alignment: Alignment.center,
          child: completed
              ? SvgPicture.asset(
                  'assets/icons/check_icon.svg',
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  width: 18,
                  height: 18,
                )
              : Icon(
                  Icons.radio_button_unchecked,
                  color: color,
                  size: 23,
                ),
        ),
      ),
    );
  }
}

class _SubtaskLeadingSlot extends StatelessWidget {
  const _SubtaskLeadingSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _subtaskToggleWidth,
      height: _subtaskToggleHeight,
      child: Align(
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }
}

class _SubtaskTrailingSlot extends StatelessWidget {
  const _SubtaskTrailingSlot({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Close and drag controls occupy exactly the same box, so switching
    // between display and keyboard-editing modes never reflows the text.
    return SizedBox(
      width: 41,
      height: _subtaskLineHeight,
      child: child,
    );
  }
}
