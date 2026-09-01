import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:jospar/app/screens/drawer/custom_drawer.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/app/screens/tasks/utils/bucketing.dart' as bucketing;
import 'package:jospar/app/screens/tasks/utils/bucketing.dart';
import 'package:jospar/app/screens/tasks/utils/date_utils_ext.dart';
import 'package:jospar/app/screens/tasks/widgets/animated_calendar.dart';
import 'package:jospar/app/screens/tasks/widgets/animated_section.dart';
import 'package:jospar/app/screens/tasks/widgets/day_tasks_list.dart';
import 'package:provider/provider.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:jospar/app/screens/tasks/section/task_section_widget.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/services/collaboration_service.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jospar/app/screens/tasks/task_diary_screen.dart';
import 'package:jospar/app/widgets/app_message_dialog.dart';
import 'package:jospar/core/constants/router.dart';

Color? _calendarMarkerColor(String? hex) {
  final value = hex?.trim().replaceFirst('#', '');
  if (value == null || (value.length != 6 && value.length != 8)) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(value.length == 6 ? 0xFF000000 | parsed : parsed);
}

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final TaskService _taskService = TaskService();
  GlobalProvider? _globalProvider;
  bool _incomingShareScheduled = false;
  bool _handlingIncomingShare = false;

  late final SlidableController _drawerCtrl;
  late final Animation<double> _drawerAnim;
  bool _menuOpen = false;

  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime _currentDay = DateUtils.dateOnly(DateTime.now());
  Timer? _midnightTimer;
  Timer? _newTaskHighlightTimer;
  String? _newTaskHighlightId;
  bool _isCalendarVisible = false;

  double _scaleFactor = 1.0;
  String? _selectedTaskListId;
  String? _selectedTaskListName;
  final ScrollController _sectionsScrollController = ScrollController();
  final GlobalKey _sectionsViewportKey = GlobalKey();
  Timer? _dragScrollTimer;
  double _dragScrollDirection = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, GlobalKey<TaskSectionState>> _sectionKeys = {
    bucketing.kBucketToday: GlobalKey<TaskSectionState>(),
    bucketing.kBucketTomorrow: GlobalKey<TaskSectionState>(),
    bucketing.kBucketWeek: GlobalKey<TaskSectionState>(),
    bucketing.kBucketMonth: GlobalKey<TaskSectionState>(),
    bucketing.kBucketLater: GlobalKey<TaskSectionState>(),
    bucketing.kBucketNote: GlobalKey<TaskSectionState>(),
  };

  Future<void> _openTaskDiary() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TaskDiaryScreen()),
    );
    if (!mounted) return;

    // Re-read the local database after the diary route closes. This also
    // covers returning with the system back gesture, where the covered page
    // may not have rebuilt from the optimistic notification.
    await context.read<GlobalProvider>().refreshTasks(context, silent: true);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initializeDateFormatting('ru', null);
    _scheduleMidnightRefresh();

    _drawerCtrl = SlidableController(this);
    _drawerAnim = _drawerCtrl.animation;
    _drawerAnim.addListener(() {
      final isOpenNow = _drawerAnim.value > 0.001;
      if (isOpenNow != _menuOpen && mounted) {
        setState(() => _menuOpen = isOpenNow);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _inComingHashtoTask();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<GlobalProvider>();
    if (!identical(provider, _globalProvider)) {
      _globalProvider?.removeListener(_onGlobalProviderChanged);
      _globalProvider = provider;
      provider.addListener(_onGlobalProviderChanged);
    }
    _scheduleIncomingShare();
  }

  void _onGlobalProviderChanged() {
    if (_globalProvider?.inComingHash?.isNotEmpty == true) {
      debugPrint(
        '[ShareLink] queued: ${_globalProvider!.inComingHash}, '
        'busy=$_handlingIncomingShare',
      );
    }
    _scheduleIncomingShare();
  }

  void _scheduleIncomingShare() {
    if (!mounted ||
        _handlingIncomingShare ||
        _incomingShareScheduled ||
        _globalProvider?.inComingHash?.isNotEmpty != true) {
      return;
    }
    _incomingShareScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _incomingShareScheduled = false;
      if (mounted) _inComingHashtoTask();
    });
  }

  @override
  void dispose() {
    _globalProvider?.removeListener(_onGlobalProviderChanged);
    _newTaskHighlightTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    _stopAutoScroll();
    _sectionsScrollController.dispose();
    _drawerCtrl.dispose();
    super.dispose();
  }

  void _updateAutoScroll(Offset globalPosition) {
    final box =
        _sectionsViewportKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final localY = box.globalToLocal(globalPosition).dy;
    const edge = 88.0;
    final height = box.size.height;

    if (localY < edge) {
      _dragScrollDirection = -((edge - localY) / edge).clamp(.18, 1.0);
    } else if (localY > height - edge) {
      _dragScrollDirection =
          ((localY - (height - edge)) / edge).clamp(.18, 1.0);
    } else {
      _stopAutoScroll();
      return;
    }

    _dragScrollTimer ??= Timer.periodic(const Duration(milliseconds: 16), (_) {
      if (!_sectionsScrollController.hasClients) return;
      final position = _sectionsScrollController.position;
      final next = (_sectionsScrollController.offset + _dragScrollDirection * 9)
          .clamp(position.minScrollExtent, position.maxScrollExtent);
      _sectionsScrollController.jumpTo(next);
    });
  }

  void _stopAutoScroll() {
    _dragScrollDirection = 0;
    _dragScrollTimer?.cancel();
    _dragScrollTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshForCurrentDay();
    }
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextDay = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextDay.difference(now), _refreshForCurrentDay);
  }

  void _refreshForCurrentDay() {
    if (!mounted) return;
    final newDay = DateUtils.dateOnly(DateTime.now());
    final wasShowingToday = DateUtils.isSameDay(_selectedDay, _currentDay);

    if (!DateUtils.isSameDay(newDay, _currentDay)) {
      setState(() {
        _currentDay = newDay;
        if (wasShowingToday) {
          _selectedDay = newDay;
          _focusedDay = newDay;
        }
      });
    }
    _scheduleMidnightRefresh();
  }

  void _toggleCalendar() {
    setState(() {
      _isCalendarVisible = !_isCalendarVisible;
      final today = DateUtils.dateOnly(DateTime.now());
      _selectedDay = today;
      _focusedDay = today;
    });
  }

  void _setTaskEditorOpen(bool isOpen) {
    if (!mounted || usesDesktopTaskWindow(context)) return;
    setState(() => _scaleFactor = isOpen ? 0.88 : 1.0);
  }

  Future<void> _addTask() async {
    _setTaskEditorOpen(true);

    await showAddTaskModal(
      context: context,
      selectedDay: _selectedDay,
      taskId: '',
      onSaveTask: (title, subtasks, date, taskListId, urgency) async {
        return _saveTask(title, subtasks, date, taskListId, urgency);
      },
    );

    if (mounted) {
      context.read<GlobalProvider>().refreshTasks(context);
    }

    _setTaskEditorOpen(false);
  }

  Future<void> _inComingHashtoTask() async {
    if (_handlingIncomingShare) return;
    final global = context.read<GlobalProvider>();
    if (global.inComingHash?.isNotEmpty != true) return;

    final token = await AuthStorage().getToken();
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      // Приглашение не извлекаем: после входа оно будет обработано автоматически.
      context.go('/auth');
      return;
    }

    _handlingIncomingShare = true;
    final incoming = global.takeIncomingShare();
    if (incoming == null) {
      _handlingIncomingShare = false;
      return;
    }
    debugPrint('[ShareLink] processing: ${incoming.hash}');

    try {
      // Reopening an already accepted link must not call accept again. The
      // hydrated local tree also keeps all subtasks visible on every open.
      final existing = await _taskService.getLocalTaskByHash(incoming.hash);
      debugPrint('[ShareLink] local task found: ${existing != null}');
      if (existing != null) {
        await _openIncomingTask(existing);
        if (!mounted) return;
        await global.refreshTasks(context, silent: true);
        return;
      }

      final share = await CollaborationService().inviteInfo(incoming.hash);
      debugPrint('[ShareLink] invite info received');
      final backendMode = ShareDeliveryMode.fromValue(
        (share['mode'] ?? (share['data'] is Map ? share['data']['mode'] : null))
            ?.toString(),
      );
      if (backendMode == ShareDeliveryMode.duplicate) {
        await _duplicateSharedTask(incoming.hash);
        if (!mounted) return;
        await global.refreshTasks(context);
        if (!mounted) return;
        await showAppMessageDialog(
          context,
          title: S.of(context).done,
          message: S.of(context).sharedCopyAdded,
          buttonText: S.of(context).done,
          type: AppMessageDialogType.success,
        );
        return;
      }

      final task = await _taskService.getTaskByHash(context, incoming.hash);
      debugPrint('[ShareLink] invitation accepted: ${task.id}');
      await _openIncomingTask(task);

      if (!mounted) return;
      await global.refreshTasks(context, silent: true);
    } catch (e) {
      debugPrint('[ShareLink] failed: $e');
      if (!mounted) return;
      final dialogContext = AppRouter.navigatorKey.currentContext ?? context;
      await showAppMessageDialog(
        dialogContext,
        title: S.of(dialogContext).openShareFailedTitle,
        message: _incomingShareErrorMessage(e),
        buttonText: S.of(dialogContext).done,
      );
    } finally {
      // takeIncomingShare() already consumed this hash. Do not clear the
      // provider here: a second link may have arrived while this one was open.
      _handlingIncomingShare = false;
      _setTaskEditorOpen(false);
      _scheduleIncomingShare();
    }
  }

  Future<void> _openIncomingTask(TaskItems task) async {
    final id = task.id;
    if (!mounted || id == null || id.isEmpty) {
      throw StateError('В полученной задаче отсутствует ID');
    }
    _setTaskEditorOpen(true);
    await showAddTaskModal(
      context: context,
      selectedDay: DateTime.tryParse(task.date ?? '') ?? DateTime.now(),
      taskId: id,
      linkTask: true,
      existingTask: task,
      onSaveTask: (title, subtasks, date, taskListId, urgency) async {
        await _taskService.updateTaskPut(
          context,
          id: id,
          name: title,
          date: date == null ? null : fmtYmd(date),
          clearDate: date == null,
          urgency: urgency,
          taskListId: task.taskListId ?? taskListId,
        );
        return id;
      },
    );
  }

  String _incomingShareErrorMessage(Object error) {
    if (error is CollaborationException) {
      return switch (error.statusCode) {
        401 => S.of(context).shareSessionExpired,
        403 => S.of(context).shareAccessDenied,
        404 || 410 => S.of(context).shareLinkUnavailable,
        409 => S.of(context).shareAlreadyUsedMissingLocal,
        _ => error.message,
      };
    }
    final text = error.toString().replaceFirst('Bad state: ', '').trim();
    return text.isEmpty ? S.of(context).unknownRetryError : text;
  }

  Future<void> _duplicateSharedTask(String hash) async {
    final sourceJson = await CollaborationService().inviteTask(hash);
    if (!mounted) return;
    final source = TaskItems.fromJson(sourceJson);
    final lists = context.read<GlobalProvider>().taskLists;
    if (lists.isEmpty) {
      throw StateError('Нет списка, в который можно добавить копию');
    }

    final sourceListName = source.taskList?.name?.trim();
    final destinationList = lists.firstWhere(
      (list) =>
          sourceListName != null &&
          sourceListName.isNotEmpty &&
          list.name?.trim() == sourceListName,
      orElse: () => lists.first,
    );
    final listId = destinationList.id;
    if (listId == null || listId.isEmpty) {
      throw StateError('У списка задач отсутствует ID');
    }

    final copiedTaskId = await _copyTaskTree(source, listId: listId);
    await OfflineRuntime.store.recordSuccessfulShare(
      accountId: await AuthStorage().getAccountId(),
      taskId: copiedTaskId,
      collaborative: false,
      inviteHash: hash,
    );
    OfflineRuntime.requestSync();
  }

  Future<String> _copyTaskTree(
    TaskItems source, {
    required String listId,
    String? parentId,
  }) async {
    if (!mounted) {
      throw StateError('Экран задачи уже закрыт');
    }
    final created = await _taskService.createTask(
      context,
      name: (source.name ?? '').trim().isEmpty
          ? 'Задача без названия'
          : source.name!.trim(),
      date: source.date ?? '',
      position: source.position,
      taskListId: listId,
      parentTaskId: parentId,
      urgency: source.urgency,
    );
    final newId = created['id']?.toString();
    if (newId == null || newId.isEmpty) {
      throw StateError('Не удалось создать независимую копию');
    }

    if (source.note != null ||
        source.notificationTime != null ||
        source.isCompleted == true) {
      if (!mounted) {
        throw StateError('Экран задачи уже закрыт');
      }
      await _taskService.updateTaskPut(
        context,
        id: newId,
        note: source.note,
        notificationTime: source.notificationTime,
        isCompleted: source.isCompleted,
      );
    }

    for (final child in source.children ?? const <TaskItems>[]) {
      await _copyTaskTree(child, listId: listId, parentId: newId);
    }
    return newId;
  }

  Future<String?> _saveTask(
      String title, List subtasks, DateTime? date, String taskListId,
      [String? urgency]) async {
    if (taskListId.isEmpty) {
      if (!mounted) return null;
      await showAppMessageDialog(
        context,
        title: S.of(context).error,
        message: S.of(context).selectTaskListForSave,
        buttonText: S.of(context).done,
        type: AppMessageDialogType.info,
      );
      return null;
    }

    try {
      final created = await _taskService.createTask(
        context,
        name: title,
        date: date == null ? '' : fmtYmd(date),
        taskListId: taskListId,
        urgency: urgency ?? null,
      );

      final parentTaskId = created['id'] as String?;
      if (parentTaskId == null || parentTaskId.isEmpty) {
        throw Exception('Сервер не вернул id созданной задачи');
      }

      for (final entry in subtasks.asMap().entries) {
        final s = entry.value;
        final subTitle = (s['title'] as String?)?.trim();
        if (subTitle == null || subTitle.isEmpty) continue;

        try {
          await _taskService.createSubtask(
            context,
            name: subTitle,
            parentTaskId: parentTaskId,
            taskListId: taskListId,
            position: entry.key,
          );
          context.read<GlobalProvider>().refreshTasks(context);
        } catch (e, st) {
          debugPrint('createSubtask("$subTitle") failed: $e\n$st');
        }
      }

      if (mounted) {
        await context.read<GlobalProvider>().refreshTasks(context);
        setState(() => _newTaskHighlightId = parentTaskId);
        _newTaskHighlightTimer?.cancel();
        _newTaskHighlightTimer = Timer(const Duration(seconds: 1), () {
          if (mounted && _newTaskHighlightId == parentTaskId) {
            setState(() => _newTaskHighlightId = null);
          }
        });
      }
      return parentTaskId;
    } catch (e, st) {
      debugPrint('saveTask failed: $e\n$st');
      if (mounted) {
        await showAppMessageDialog(
          context,
          title: S.of(context).taskSaveFailedTitle,
          message: e.toString().replaceFirst('Bad state: ', ''),
          buttonText: S.of(context).done,
        );
      }
      return null;
    }
  }

  Future<void> _onTaskDropped(TaskItems task, String targetKey,
      [int targetIndex = 0]) async {
    _stopAutoScroll();
    final bool toNoDate = targetKey == kBucketNote;

    final DateTime? oldDate =
        (task.date == null || (task.date?.trim().isEmpty ?? true))
            ? null
            : parseApiDateOrYmd(task.date);
    var srcKey = (oldDate == null)
        ? kBucketNote
        : bucketing.bucketFor(oldDate, _selectedDay);
    if (srcKey == kBucketMonth) srcKey = kBucketLater;

    final DateTime? newDate = toNoDate
        ? null
        : bucketing.dateForBucket(targetKey, _selectedDay,
            current: oldDate ?? _selectedDay);

    final String? newDateStr = newDate == null ? null : fmtYmd(newDate);

    final src = _sectionKeys[srcKey]?.currentState;
    final dst = _sectionKeys[targetKey]?.currentState;
    final oldIndex = src?.tasks.indexWhere((item) => item.id == task.id) ?? 0;

    if (srcKey == targetKey) {
      src?.reorderTask(task, targetIndex);
      try {
        for (final item in src?.tasks ?? const <TaskItems>[]) {
          await _taskService.updateTaskPut(
            context,
            id: item.id ?? '',
            position: item.position,
            date: item.date,
          );
        }
        if (mounted) await context.read<GlobalProvider>().refreshTasks(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Не удалось сохранить порядок: $e')),
          );
        }
      }
      return;
    }

    final String? oldDateStr = task.date;
    task.date = newDateStr; // локально меняем на null или новую дату

    src?.removeTaskById(task.id ?? '');
    dst?.insertTask(task, targetIndex);

    try {
      await _taskService.updateTaskPut(
        context,
        id: task.id ?? '',
        date: newDateStr, // может быть null — сервер должен очистить дату
        clearDate: toNoDate,
        taskListId: task.taskListId,
        name: task.name,
      );
      for (final section in <TaskSectionState?>[src, dst]) {
        for (final item in section?.tasks ?? const <TaskItems>[]) {
          await _taskService.updateTaskPut(
            context,
            id: item.id ?? '',
            position: item.position,
            date: item.date,
          );
        }
      }
      await OfflineRuntime.syncEngine?.synchronize(ignoreStopped: true);
      if (!mounted) return;
      await context.read<GlobalProvider>().refreshTasks(context);
    } catch (e) {
      // откат
      task.date = oldDateStr;
      dst?.removeTaskById(task.id ?? '');
      src?.insertTask(task, oldIndex < 0 ? 0 : oldIndex);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось изменить дату: $e')),
      );
    }
  }

  Widget _dropTarget(
    String key,
    String title,
    List<TaskItems>? items, {
    int? diaryCompletedCount,
    int? diaryTotalCount,
  }) {
    final isEmpty = items == null || items.isEmpty;

    return DragTarget<TaskItems>(
      onWillAcceptWithDetails: (details) {
        final t = details.data;
        var srcKey = (t.date == null || (t.date?.trim().isEmpty ?? true))
            ? kBucketNote
            : bucketing.bucketFor(parseApiDateOrYmd(t.date), _selectedDay);
        if (srcKey == kBucketMonth) srcKey = kBucketLater;
        final accepted = srcKey != key;
        if (accepted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _sectionKeys[key]?.currentState?.setExpanded(true);
          });
        }
        return accepted;
      },
      onMove: (_) => _sectionKeys[key]?.currentState?.setExpanded(true),
      onAcceptWithDetails: (details) => _onTaskDropped(details.data, key),
      builder: (context, candidates, _) {
        final highlight = candidates.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: EdgeInsets.symmetric(vertical: highlight ? 6 : 0),
          padding: EdgeInsets.symmetric(
            horizontal: highlight ? 10 : 0,
            vertical: highlight ? 10 : 0,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Opacity(
            opacity: isEmpty && !highlight ? 0.5 : 1.0,
            child: TaskSection(
              key: _sectionKeys[key],
              title: title,
              tasksKey: key,
              items: items,
              bucketBaseDate: _selectedDay,
              highlightedTaskId: _newTaskHighlightId,
              initiallyExpanded: key != kBucketNote,
              showTaskCount: key == kBucketToday,
              showCompletedCount: key == kBucketToday,
              headerCompletedCount: diaryCompletedCount,
              headerTotalCount: diaryTotalCount,
              onHeaderCountTap: key == kBucketToday ? _openTaskDiary : null,
              titleColor: key == kBucketNote ? Colors.grey.shade500 : null,
              countColor: key == kBucketNote ? Colors.grey.shade500 : null,
              onBeforeOpenModal: () => _setTaskEditorOpen(true),
              onAfterCloseModal: () => _setTaskEditorOpen(false),
              onDragStart: () {},
              onDragEnd: _stopAutoScroll,
              onDragUpdate: _updateAutoScroll,
              onTaskDroppedOnSection: _onTaskDropped,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMacDesktop =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final rawApiTasks =
        context.select<GlobalProvider, List<TaskItems>>((g) => g.allApiTasks);
    final taskLists = context.select<GlobalProvider, List<TaskListItems>>(
      (g) => g.taskLists,
    );
    final listColorsById = <String, Color>{
      for (final list in taskLists)
        if ((list.id ?? '').isNotEmpty)
          list.id!: _calendarMarkerColor(list.colorHex) ?? Colors.grey,
    };
    final taskColorsByDay = <DateTime, List<Color>>{};
    for (final task in rawApiTasks) {
      final parsedDate = parseLocal(task.date);
      if (parsedDate == null) continue;
      final day = DateUtils.dateOnly(parsedDate);
      final listId = task.taskListId ?? task.taskList?.id;
      final color = _calendarMarkerColor(task.taskList?.colorHex) ??
          listColorsById[listId] ??
          Colors.grey;
      final colors = taskColorsByDay.putIfAbsent(day, () => <Color>[]);
      if (!colors.contains(color)) colors.add(color);
    }
    final allApiTasks = _selectedTaskListId == null
        ? rawApiTasks
        : rawApiTasks
            .where((task) =>
                (task.taskListId ?? task.taskList?.id) == _selectedTaskListId)
            .toList();

    final dayTasks = allApiTasks.where((t) {
      final td = parseLocal(t.date);
      return isSameDayLocal(td, _selectedDay);
    }).toList();

    List<TaskItems> _mergeUniqueTasks(List<TaskItems> a, List<TaskItems> b) {
      final seen = <String>{};
      final out = <TaskItems>[];
      void addAll(List<TaskItems> src) {
        for (final t in src) {
          final id = t.id ?? '';
          if (id.isEmpty) continue;
          if (seen.add(id)) out.add(t);
        }
      }

      addAll(a);
      addAll(b);
      return out;
    }

    final isTodaySelected = isSameDayLocal(_selectedDay, DateTime.now());
    // На главном экране показываем только активные задачи. Завершённые
    // остаются доступны в календаре при открытии конкретной даты.
    final activeMainTasks = allApiTasks
        .where((task) => task.isCompleted != true)
        .toList(growable: false);
    final today = DateUtils.dateOnly(DateTime.now());
    final tasksScheduledToday = allApiTasks.where((task) {
      final taskDate = parseLocal(task.date);
      return taskDate != null && DateUtils.isSameDay(taskDate, today);
    }).toList(growable: false);
    final todayTasksCount = tasksScheduledToday.length;
    final completedTodayTasksCount =
        tasksScheduledToday.where((task) => task.isCompleted == true).length;
    final groups = bucketing.groupByBuckets(activeMainTasks, _selectedDay);
    final todaySection = groups[kBucketToday] ?? const <TaskItems>[];
    final completedToday =
        bucketing.completedOnDay(allApiTasks, DateTime.now());
    final mergedForTodayView = isTodaySelected
        ? _mergeUniqueTasks(
            _mergeUniqueTasks(dayTasks, todaySection),
            completedToday,
          )
        : dayTasks;
    final undatedTasks = activeMainTasks.where((t) {
      final d = t.date;
      return d == null || d.trim().isEmpty;
    }).toList();

    // Базовый Scaffold
    final baseScaffold = AnnotatedRegion<SystemUiOverlayStyle>(
      value: _scaleFactor < 1.0
          ? SystemUiOverlayStyle.light
          : (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark),
      child: AnimatedScale(
        scale: _scaleFactor,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_scaleFactor < 1 ? 16 : 0),
          child: Scaffold(
            key: _scaffoldKey,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              centerTitle: true, // <<< важное
              automaticallyImplyLeading: false,
              leading: isMacDesktop
                  ? null
                  : IconButton(
                      icon: Image.asset(
                        'assets/icons/menu.png',
                        width: 28,
                        height: 28,
                        color: ThemeColors.primary,
                      ),
                      onPressed: () => _drawerCtrl.openStartActionPane(),
                    ),
              title: _isCalendarVisible
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        _monthTitle(context),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: ThemeColors.primary,
                        ),
                      ),
                    )
                  : _selectedTaskListName == null
                      ? null
                      : Text(
                          _selectedTaskListName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: ThemeColors.primary,
                          ),
                        ),

              actions: [
                IconButton(
                  onPressed: _toggleCalendar,
                  icon: _isCalendarVisible
                      ? Icon(Icons.arrow_upward_rounded,
                          color: ThemeColors.primary)
                      : SizedBox(
                          width: 32,
                          height: 32,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SvgPicture.asset('assets/icons/calendar.svg',
                                  width: 32,
                                  height: 32,
                                  color: ThemeColors.primary),
                              Transform.translate(
                                offset: const Offset(0, 0),
                                child: Text(
                                  '${DateTime.now().day}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeColors.primary,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  tooltip: '${DateTime.now().day}',
                ),
              ],
            ),
            body: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedCalendar(
                        isVisible: _isCalendarVisible,
                        selectedDay: _selectedDay,
                        focusedDay: _focusedDay,
                        taskColorsByDay: taskColorsByDay,
                        onDaySelected: (sel, foc) {
                          setState(() {
                            _selectedDay = DateUtils.dateOnly(sel);
                            _focusedDay = DateUtils.dateOnly(foc);
                          });
                        },
                        // <<< ДОБАВЬ ЭТО:
                        onMonthChanged: (month) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            setState(() {
                              _focusedDay = DateUtils.dateOnly(month);
                            });
                          });
                        },
                      ),
                      Expanded(
                        child: _isCalendarVisible
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 4, 20, 8),
                                    child: Text(
                                      formatDayHeader(context, _selectedDay),
                                      style: TextStyle(
                                        fontFamily: 'Roboto',
                                        fontWeight: FontWeight.w800,
                                        fontSize: 22,
                                        letterSpacing: -0.2,
                                        color: ThemeColors.primary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: DayTasksList(
                                            items: mergedForTodayView,
                                            selectedDay: _selectedDay,
                                            taskService: _taskService,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                key: _sectionsViewportKey,
                                child: ListView(
                                  controller: _sectionsScrollController,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  children: [
                                    AnimatedSection(
                                      hidden: _isCalendarVisible,
                                      child: _dropTarget(
                                        kBucketNote,
                                        (S.of(context).notes), // или 'Без даты'
                                        undatedTasks,
                                      ),
                                    ),
                                    AnimatedSection(
                                      hidden: _isCalendarVisible,
                                      child: _dropTarget(
                                          kBucketToday,
                                          S.of(context).today,
                                          groups[kBucketToday],
                                          diaryCompletedCount:
                                              completedTodayTasksCount,
                                          diaryTotalCount: todayTasksCount),
                                    ),
                                    AnimatedSection(
                                      hidden: _isCalendarVisible,
                                      child: _dropTarget(
                                          kBucketTomorrow,
                                          S.of(context).tomorrow,
                                          groups[kBucketTomorrow]),
                                    ),
                                    AnimatedSection(
                                      hidden: _isCalendarVisible,
                                      child: _dropTarget(
                                          kBucketWeek,
                                          S.of(context).thisWeek,
                                          groups[kBucketWeek]),
                                    ),
                                    AnimatedSection(
                                      hidden: _isCalendarVisible,
                                      child: _dropTarget(kBucketLater,
                                          S.of(context).later, <TaskItems>[
                                        ...?groups[kBucketMonth],
                                        ...?groups[kBucketLater],
                                      ]),
                                    ),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            floatingActionButton: SizedBox(
              width: isMacDesktop
                  ? (MediaQuery.of(context).size.width - 340)
                      .clamp(280.0, 720.0)
                  : MediaQuery.of(context).size.width * 0.9,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _addTask,
                label: Text(
                  S.of(context).addTask,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final pageScaffold = Stack(
      children: [
        baseScaffold,
        if (_menuOpen)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _drawerCtrl.close(),
            ),
          ),
      ],
    );

    if (isMacDesktop) {
      return Row(
        children: [
          SizedBox(
            width: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  right: BorderSide(
                    color: isDark
                        ? const Color(0xFF2B3039)
                        : const Color(0xFFE7E9ED),
                  ),
                ),
              ),
              child: CustomDrawer(
                selectedTaskListId: _selectedTaskListId,
                onHomeTap: () => setState(() {
                  _selectedTaskListId = null;
                  _selectedTaskListName = null;
                }),
                onTaskListTap: (item) => setState(() {
                  _selectedTaskListId = item.id;
                  _selectedTaskListName = item.name ?? 'Без названия';
                }),
              ),
            ),
          ),
          Expanded(child: baseScaffold),
        ],
      );
    }

    return Slidable(
      controller: _drawerCtrl,
      closeOnScroll: false,
      startActionPane: ActionPane(
        extentRatio: 0.8,
        motion: const DrawerMotion(),
        children: [
          CustomSlidableAction(
            padding: EdgeInsets.zero,
            autoClose: false,
            onPressed: (_) {},
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomDrawer(
                onAnyTap: () => _drawerCtrl.close(),
                selectedTaskListId: _selectedTaskListId,
                onHomeTap: () => setState(() {
                  _selectedTaskListId = null;
                  _selectedTaskListName = null;
                }),
                onTaskListTap: (item) => setState(() {
                  _selectedTaskListId = item.id;
                  _selectedTaskListName = item.name ?? 'Без названия';
                }),
              ),
            ),
          ),
        ],
      ),
      child: pageScaffold,
    );
  }

  String _monthTitle(BuildContext context) {
    final loc = Localizations.localeOf(context).languageCode;
    final m = DateFormat.MMMM(loc).format(_focusedDay);
    return m[0].toUpperCase() + m.substring(1);
  }
}
