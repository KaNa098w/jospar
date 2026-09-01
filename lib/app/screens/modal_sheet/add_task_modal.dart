// add_task_modal.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jospar/core/constants/constants.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/app/screens/modal_sheet/task_list_dropdown.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:jospar/app/widgets/app_message_dialog.dart';
import 'package:provider/provider.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/app/widgets/accept_button.dart';
import 'package:jospar/core/services/reminder_service.dart';

import 'action_panel.dart';
import 'preview_task_list.dart';
import 'subtasks_section.dart';

/// Keeps the manual order within each group while placing completed subtasks
/// after all active ones.
void moveCompletedSubtasksToBottom(List<Map<String, dynamic>> subtasks) {
  final active = subtasks
      .where((subtask) => subtask['completed'] != true)
      .toList(growable: false);
  final completed = subtasks
      .where((subtask) => subtask['completed'] == true)
      .toList(growable: false);
  subtasks
    ..clear()
    ..addAll(active)
    ..addAll(completed);
}

List<Map<String, dynamic>> extractSubtasks(TaskItems? task) {
  try {
    final list = task?.children;
    if (list != null && list.isNotEmpty) {
      final result = list.map((c) {
        return {
          'title': (c.name ?? '').toString(),
          'completed': (c.isCompleted == true),
          'position': c.position,
          if (c.id != null) '_id': c.id,
        };
      }).toList();
      moveCompletedSubtasksToBottom(result);
      return result;
    }

    final raw = (task?.children?.isNotEmpty == true)
        ? task!.children!.first.name
        : null;
    if (raw == null || raw.trim().isEmpty) return <Map<String, dynamic>>[];

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      final result = decoded.whereType<Map>().map((e) {
        final m = Map<String, dynamic>.from(e);
        return {
          'title': (m['title'] ?? '').toString(),
          'completed': m['completed'] == true,
          'position': m['position'],
        };
      }).toList();
      moveCompletedSubtasksToBottom(result);
      return result;
    }
    return <Map<String, dynamic>>[];
  } catch (_) {
    return <Map<String, dynamic>>[];
  }
}

String encodeSubtasksToJson(List<Map<String, dynamic>> subtasks) {
  return jsonEncode(
    subtasks
        .map((e) => {
              'title': (e['title'] ?? '').toString(),
              'completed': e['completed'] == true,
            })
        .toList(),
  );
}

Future<void> showAddTaskModal({
  required BuildContext context,
  required DateTime selectedDay,
  required String
      taskId, // не используется прямо сейчас, оставил для совместимости
  bool linkTask = false,
  required Future<String?> Function(
    String title,
    List subtasks,
    DateTime? date,
    String taskListId,
    String urgency,
  ) onSaveTask,
  TaskItems? existingTask,
}) {
  String newTaskTitle = (existingTask?.name ?? '').trim();
  final isCreatingNewTask = existingTask == null;
  final titleController = TextEditingController(text: newTaskTitle);
  final focusNode = FocusNode();
  final taskService = TaskService();
  bool isEditingSubtask = false;
  bool _didFocusTitleOnce = false;
  String? persistedTaskId =
      (existingTask?.id?.isNotEmpty == true ? existingTask?.id : taskId);

  DateTime selectedDate = DateUtils.dateOnly(selectedDay);
  // Tasks in the Notes section intentionally have no date. Keep that state
  // until the user explicitly chooses a date in the editor.
  bool hasDate = existingTask == null ||
      (existingTask.date != null && existingTask.date!.trim().isNotEmpty);
  TimeOfDay? reminderTime =
      ReminderService.tryParseTime(existingTask?.notificationTime);
  final initialReminderTime = ReminderService.formatTime(reminderTime);

  final List<Map<String, dynamic>> subtasks = extractSubtasks(existingTask);

  final subtaskController = TextEditingController();
  final subtaskFocusNode = FocusNode();

  final gp = context.read<GlobalProvider>();
  final lists = gp.taskLists;

  // данные списка из existingTask
  final String? _taskListId =
      existingTask?.taskList?.id ?? existingTask?.taskListId;
  final String? _taskListName = existingTask?.taskList?.name;

  bool _listExists(String? id) =>
      id != null && id.isNotEmpty && lists.any((e) => (e.id ?? '') == id);

  // выбранный список
// вместо текущей инициализации selectedListId:
  String? selectedListId = linkTask
      ? (lists.isNotEmpty ? lists.first.id : null)
      : (_listExists(_taskListId)
          ? _taskListId
          : (lists.isNotEmpty ? lists.first.id : null));

  String? selectedListColor = (() {
    if (selectedListId == null) return null;
    final idx = lists.indexWhere((e) => (e.id ?? '') == selectedListId);
    return idx >= 0 ? lists[idx].colorHex : null;
  })();

  // превью задач выбранного списка
  final pageController = PageController(initialPage: 0);
  final editorScrollController = ScrollController();

  const double _panelKeyboardGap = 4;
  const double _panelHeight = 46;
  const double reservedBottomForPanel = _panelHeight + _panelKeyboardGap;

  Urgency? urgency = urgencyFromApi(existingTask?.urgency);
  bool allowClose = false;
  bool closing = false;
  Future<void> Function()? requestClose;

  String draftSignature() => jsonEncode({
        'title': titleController.text.trim(),
        'date':
            hasDate ? DateUtils.dateOnly(selectedDate).toIso8601String() : null,
        'task_list_id': selectedListId,
        'urgency': urgencyToApi(urgency) ?? '',
        'notification_time': ReminderService.formatTime(reminderTime),
        'subtasks': subtasks,
      });

  final initialDraftSignature = draftSignature();
  var lastAppliedDraftSignature = initialDraftSignature;
  String? lastAppliedRealtimeSignature;
  bool realtimeApplyScheduled = false;

  String realtimeSignature(TaskItems task) => jsonEncode({
        'name': task.name,
        'date': task.date,
        'task_list_id': task.taskListId ?? task.taskList?.id,
        'urgency': task.urgency,
        'notification_time': task.notificationTime,
        'is_completed': task.isCompleted,
        'subtasks': (task.children ?? const <TaskItems>[])
            .map((child) => {
                  'id': child.id,
                  'name': child.name,
                  'completed': child.isCompleted,
                  'position': child.position,
                })
            .toList(growable: false),
      });

  Widget buildTaskEditor(BuildContext context, {required bool isDesktop}) {
    bool _saving = false; // локальный флаг загрузки

    double dragStartY = 0;

    final content = StatefulBuilder(
      builder: (context, setState) {
        final provider = context.watch<GlobalProvider>();
        final openTaskId = persistedTaskId;
        TaskItems? realtimeTask;
        if (openTaskId != null && openTaskId.isNotEmpty) {
          for (final task in provider.allApiTasks) {
            if (task.id == openTaskId) {
              realtimeTask = task;
              break;
            }
          }
        }

        if (realtimeTask != null) {
          final remoteTask = realtimeTask;
          final remoteSignature = realtimeSignature(remoteTask);
          final hasNewRealtimeData =
              remoteSignature != lastAppliedRealtimeSignature;
          final editorHasNoLocalChanges =
              draftSignature() == lastAppliedDraftSignature;
          if (hasNewRealtimeData &&
              editorHasNoLocalChanges &&
              !realtimeApplyScheduled) {
            realtimeApplyScheduled = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              realtimeApplyScheduled = false;
              if (!context.mounted ||
                  draftSignature() != lastAppliedDraftSignature) {
                return;
              }
              setState(() {
                titleController.text = remoteTask.name ?? '';
                final remoteDate = DateTime.tryParse(remoteTask.date ?? '');
                hasDate = remoteDate != null;
                if (remoteDate != null) {
                  selectedDate = DateUtils.dateOnly(remoteDate);
                }
                reminderTime =
                    ReminderService.tryParseTime(remoteTask.notificationTime);
                urgency = urgencyFromApi(remoteTask.urgency);
                selectedListId =
                    remoteTask.taskListId ?? remoteTask.taskList?.id;
                final listIndex = lists.indexWhere(
                  (item) => item.id == selectedListId,
                );
                selectedListColor =
                    listIndex >= 0 ? lists[listIndex].colorHex : null;
                subtasks
                  ..clear()
                  ..addAll(extractSubtasks(remoteTask));
                existingTask?.isCompleted = remoteTask.isCompleted;
                existingTask?.notificationTime = remoteTask.notificationTime;
                existingTask?.isShared = remoteTask.isShared;
                existingTask?.collaborationRole = remoteTask.collaborationRole;
                lastAppliedRealtimeSignature = remoteSignature;
                lastAppliedDraftSignature = draftSignature();
              });
            });
          }
        }

        Future<String?> _persist({
          required bool closeAfterSave,
        }) async {
          if (_saving) return null;
          final title = titleController.text.trim();
          if (title.isEmpty) {
            await showAppMessageDialog(
              context,
              title: S.of(context).error,
              message: S.of(context).taskTitleRequired,
              buttonText: S.of(context).done,
              type: AppMessageDialogType.info,
            );
            return null;
          }

          if (lists.isEmpty ||
              (selectedListId == null || selectedListId!.isEmpty)) {
            await showAppMessageDialog(
              context,
              title: S.of(context).error,
              message: S.of(context).selectTaskListForSave,
              buttonText: S.of(context).done,
              type: AppMessageDialogType.info,
            );
            return null;
          }

          setState(() => _saving = true);
          try {
            final savedTaskId = await onSaveTask(
              title,
              subtasks,
              hasDate ? selectedDate : null,
              selectedListId!,
              urgencyToApi(urgency) ?? '',
            );
            if (savedTaskId == null || savedTaskId.isEmpty) return null;
            persistedTaskId = savedTaskId;

            final savedReminderTime = ReminderService.formatTime(reminderTime);
            if (savedReminderTime != initialReminderTime) {
              await taskService.updateTaskPut(
                context,
                id: savedTaskId,
                notificationTime: savedReminderTime,
                date: hasDate ? _formatApiDate(selectedDate) : null,
              );
              existingTask?.notificationTime = savedReminderTime;
            }
            try {
              if (reminderTime == null || !hasDate) {
                await ReminderService.instance.cancel(savedTaskId);
              } else {
                await ReminderService.instance.schedule(
                  taskId: savedTaskId,
                  taskTitle: title,
                  date: selectedDate,
                  time: reminderTime!,
                );
              }
            } catch (error) {
              debugPrint('[Reminder] Не удалось запланировать: $error');
            }
            if (closeAfterSave && context.mounted) {
              allowClose = true;
              Navigator.pop(context);
            }
            return savedTaskId;
          } finally {
            if (context.mounted) setState(() => _saving = false);
          }
        }

        Future<void> _save() async {
          await _persist(closeAfterSave: true);
        }

        Future<void> _closeAndSaveChanges() async {
          if (closing || _saving) return;
          FocusManager.instance.primaryFocus?.unfocus();
          final hasChanges = draftSignature() != initialDraftSignature;
          final hasNewTaskContent = titleController.text.trim().isNotEmpty ||
              subtasks.any(
                (item) => (item['title'] ?? '').toString().trim().isNotEmpty,
              );
          if (!hasChanges || (isCreatingNewTask && !hasNewTaskContent)) {
            allowClose = true;
            if (context.mounted) Navigator.pop(context);
            return;
          }

          closing = true;
          final savedId = await _persist(closeAfterSave: false);
          closing = false;
          if (savedId != null && context.mounted) {
            allowClose = true;
            Navigator.pop(context);
          }
        }

        requestClose = _closeAndSaveChanges;

        if (isCreatingNewTask && !_didFocusTitleOnce) {
          _didFocusTitleOnce = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) focusNode.requestFocus();
          });
        }

        final previewTasks =
            (!linkTask && selectedListId != null && selectedListId!.isNotEmpty)
                ? (gp.tasksByList[selectedListId] ?? []).take(5).toList()
                : const <TaskItems>[];

        String currentListTitle() {
          // 1) если выбран id — берём его имя
          if (selectedListId != null && selectedListId!.isNotEmpty) {
            final idx = lists.indexWhere((e) => (e.id ?? '') == selectedListId);
            if (idx >= 0) {
              final name = (lists[idx].name ?? 'Без названия').trim();
              return name.isEmpty ? 'Без названия' : name;
            }
          }

          // 2) если из задачи что-то пришло
          final fromTask = (_taskListName ?? '').trim();
          if (fromTask.isNotEmpty) return fromTask;

          // 3) дефолт
          if (lists.isEmpty) return 'Нет списков';
          final name = (lists.first.name ?? 'Без названия').trim();
          return name.isEmpty ? 'Без названия' : name;
        }

        Widget buildActionPanel() {
          return ActionPanel(
            selectedDate: selectedDate,
            onDateChanged: (d) => setState(() {
              selectedDate = d;
              hasDate = true;
            }),
            reminderTime: reminderTime,
            onReminderChanged: (time) => setState(() => reminderTime = time),
            onSave: _save,
            isSaving: _saving,
            taskId: persistedTaskId,
            shareAllowed: existingTask?.isShared != true ||
                existingTask?.collaborationRole == 'owner',
            shareTask: () => TaskItems(
              id: persistedTaskId,
              name: titleController.text,
              date: hasDate ? selectedDate.toString() : null,
              urgency: urgencyToApi(urgency),
              notificationTime: ReminderService.formatTime(reminderTime),
              children: subtasks
                  .map(
                    (item) => TaskItems(
                      id: item['_id']?.toString(),
                      name: item['title']?.toString(),
                      isCompleted: item['completed'] == true,
                    ),
                  )
                  .toList(growable: false),
            ),
            onPrepareShare: () async {
              final existingId = existingTask?.id;
              if (existingId != null && existingId.isNotEmpty) {
                return existingId;
              }
              return _persist(closeAfterSave: false);
            },
            urgency: urgency,
            onChangeUrgency: (u) => setState(() => urgency = u),
          );
        }

        return PopScope(
          canPop: allowClose,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _closeAndSaveChanges();
          },
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  allowImplicitScrolling: false,
                  reverse: true,
                  children: [
                    SafeArea(
                      top: false,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 8,
                              bottom: isDesktop
                                  ? 20
                                  : reservedBottomForPanel +
                                      MediaQuery.viewInsetsOf(context).bottom +
                                      8,
                            ),
                            child: _desktopTaskScrollbar(
                              enabled: isDesktop,
                              controller: editorScrollController,
                              child: SingleChildScrollView(
                                controller:
                                    isDesktop ? editorScrollController : null,
                                physics: const ClampingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: isDesktop
                                          ? Alignment.centerRight
                                          : Alignment.center,
                                      child: IconButton(
                                        tooltip: isDesktop
                                            ? MaterialLocalizations.of(context)
                                                .closeButtonTooltip
                                            : null,
                                        padding: EdgeInsets.zero,
                                        icon: isDesktop
                                            ? const Icon(Icons.close, size: 24)
                                            : Image.asset(
                                                'assets/icons/arrow_down.png',
                                                width: 28,
                                                height: 28,
                                              ),
                                        onPressed: _closeAndSaveChanges,
                                      ),
                                    ),
                                    TextField(
                                      controller: titleController,
                                      focusNode: focusNode,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      minLines: 1,
                                      maxLines: null,
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.done,
                                      onChanged: (v) => newTaskTitle = v,
                                      onSubmitted: (_) => _save(),
                                      onEditingComplete: _save,
                                      style: TextStyle(
                                        fontSize: 18.5,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: S.of(context).taskTitle,
                                        hintStyle: const TextStyle(
                                          fontSize: 18.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      autofocus: isCreatingNewTask,
                                    ),
                                    SubtasksSection(
                                      subtasks: subtasks,
                                      showSubtaskInput: false,
                                      subtaskController: subtaskController,
                                      subtaskFocusNode: subtaskFocusNode,
                                      onToggleInput: (_) {},
                                      onEditingChanged: (hasFocus) {
                                        if (isEditingSubtask != hasFocus) {
                                          setState(() =>
                                              isEditingSubtask = hasFocus);
                                        }
                                      },
                                      onToggleComplete: (i) {
                                        final toggledSubtask = subtasks[i];
                                        final prev =
                                            toggledSubtask['completed'] == true;
                                        setState(() {
                                          toggledSubtask['completed'] = !prev;
                                          moveCompletedSubtasksToBottom(
                                            subtasks,
                                          );
                                        });
                                        final allCompleted = subtasks
                                                .isNotEmpty &&
                                            subtasks.every((subtask) =>
                                                subtask['completed'] == true);

                                        final String? childId =
                                            toggledSubtask['_id'] as String?;
                                        if (childId == null ||
                                            childId.isEmpty) {
                                          return;
                                        }

                                        () async {
                                          try {
                                            await taskService.updateTask(
                                              context,
                                              id: childId,
                                            );
                                            final parentId = persistedTaskId;
                                            if (parentId != null &&
                                                parentId.isNotEmpty &&
                                                existingTask?.isCompleted !=
                                                    allCompleted) {
                                              await taskService.updateTaskPut(
                                                context,
                                                id: parentId,
                                                isCompleted: allCompleted,
                                                date: existingTask?.date,
                                              );
                                              existingTask?.isCompleted =
                                                  allCompleted;
                                            }
                                            await context
                                                .read<GlobalProvider>()
                                                .refreshTasks(context);
                                          } catch (e) {
                                            if (context.mounted) {
                                              // откат флага
                                              setState(() {
                                                toggledSubtask['completed'] =
                                                    prev;
                                                moveCompletedSubtasksToBottom(
                                                  subtasks,
                                                );
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Не удалось обновить подзадачу: $e',
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        }();
                                      },
                                      onAdd: (title) => setState(() {
                                        final insertIndex = subtasks.indexWhere(
                                          (item) => item['completed'] == true,
                                        );
                                        final newSubtask = {
                                          'title': title,
                                          'completed': false
                                        };
                                        if (insertIndex < 0) {
                                          subtasks.add(newSubtask);
                                        } else {
                                          subtasks.insert(
                                              insertIndex, newSubtask);
                                        }
                                      }),
                                      onInsertAfter: (index, title) =>
                                          setState(() {
                                        subtasks.insert(index + 1, {
                                          'title': title,
                                          'completed': false,
                                        });
                                      }),
                                      bulletColor: _parseHex(
                                        selectedListColor ?? '#CCCCCC',
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      child: AcceptButton(
                                        color: _parseHex(
                                            selectedListColor ?? '#CCCCCC'),
                                        text: currentListTitle(),
                                        onPressed: () =>
                                            pageController.animateToPage(
                                          1,
                                          duration:
                                              const Duration(milliseconds: 240),
                                          curve: Curves.easeOutCubic,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    PreviewTaskList(
                                      linkTasks: linkTask,
                                      previewTasks: previewTasks,
                                    ),
                                    Divider(color: Colors.grey.shade300),
                                    if (isDesktop) ...[
                                      const SizedBox(height: 10),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          minHeight: _panelHeight,
                                        ),
                                        child: buildActionPanel(),
                                      ),
                                      const SizedBox(height: 18),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!isDesktop)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: MediaQuery.of(context).viewInsets.bottom +
                                  _panelKeyboardGap,
                              child: SafeArea(
                                top: false,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: _panelHeight,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 0,
                                        ),
                                        child: buildActionPanel(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SafeArea(
                      top: !isDesktop,
                      child: TaskListSelectionView(
                        lists: lists,
                        selectedListId: selectedListId,
                        onBack: () => pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                        ),
                        onPick: (id, colorHex) {
                          setState(() {
                            selectedListId = id;
                            selectedListColor = colorHex;
                          });
                          pageController.animateToPage(
                            0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
        );
      },
    );

    final desktopSize = MediaQuery.sizeOf(context);
    final body = isDesktop
        ? SizedBox(
            width: (desktopSize.width * 0.7).clamp(680.0, 1080.0),
            height: (desktopSize.height * 0.86).clamp(520.0, 900.0),
            child: content,
          )
        : FractionallySizedBox(
            heightFactor: 0.92,
            child: content,
          );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      onVerticalDragStart:
          isDesktop ? null : (d) => dragStartY = d.globalPosition.dy,
      onVerticalDragUpdate: isDesktop
          ? null
          : (d) {
              final dragDistance = d.globalPosition.dy - dragStartY;
              final velocity = d.primaryDelta ?? 0;
              if (dragDistance > 100 && velocity > 10) {
                requestClose?.call();
              }
            },
      child: body,
    );
  }

  final useDesktopDialog = usesDesktopTaskWindow(context);
  final Future<void> presentation;
  if (useDesktopDialog) {
    presentation = showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => Dialog(
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 32,
                spreadRadius: 3,
                offset: Offset.zero,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Material(
            color: Theme.of(dialogContext).colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: buildTaskEditor(dialogContext, isDesktop: true),
          ),
        ),
      ),
    );
  } else {
    presentation = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) =>
          buildTaskEditor(sheetContext, isDesktop: false),
    );
  }

  // The route's future completes before its closing animation is fully
  // removed from the overlay. Disposing these controllers here would leave
  // the still-mounted editor referring to already disposed objects.
  return presentation;
}

bool usesDesktopTaskWindow(BuildContext context) {
  if (kIsWeb) return MediaQuery.sizeOf(context).width >= 800;
  return defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;
}

Widget _desktopTaskScrollbar({
  required bool enabled,
  required ScrollController controller,
  required Widget child,
}) {
  if (!enabled) return child;
  return Scrollbar(
    controller: controller,
    thumbVisibility: true,
    trackVisibility: true,
    interactive: true,
    thickness: 8,
    radius: const Radius.circular(8),
    child: child,
  );
}

String _formatApiDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

Color _parseHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFFCCCCCC);
  var s = hex.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  try {
    return Color(int.parse(s, radix: 16));
  } catch (_) {
    return const Color(0xFFCCCCCC);
  }
}
