// action_panel.dart
import 'package:flutter/material.dart';
import 'package:jospar/app/screens/auth/phone_input_modul.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/constants/constants.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/collaboration_service.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/offline/sync_engine.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/app/screens/shared/share_delivery_sheet.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/task_share_message.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:provider/provider.dart';
import 'package:jospar/app/widgets/app_message_dialog.dart';
import 'package:jospar/app/screens/modal_sheet/reminder_picker_sheet.dart';

class ActionPanel extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final TimeOfDay? reminderTime;
  final ValueChanged<TimeOfDay?>? onReminderChanged;
  final VoidCallback onSave;
  final bool isSaving;
  final String? taskId;
  final bool shareAllowed;
  final Future<String?> Function()? onPrepareShare;
  final TaskItems Function()? shareTask;
  final Urgency? urgency;
  final ValueChanged<Urgency?> onChangeUrgency;

  const ActionPanel({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    this.reminderTime,
    this.onReminderChanged,
    required this.onSave,
    required this.taskId,
    this.shareAllowed = true,
    this.onPrepareShare,
    this.shareTask,
    required this.urgency, // NEW
    required this.onChangeUrgency,
    this.isSaving = false,
  });

  @override
  State<ActionPanel> createState() => _ActionPanelState();
}

class _ActionPanelState extends State<ActionPanel> {
  bool _sharing = false;

  Future<void> _pickReminder(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await showReminderPickerSheet(
      context,
      initialTime: widget.reminderTime,
    );
    if (result == null) return;
    widget.onReminderChanged?.call(result.remove ? null : result.time);
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(DateTime.now());
    final init = DateUtils.dateOnly(widget.selectedDate);

    // не даём initialDate быть раньше firstDate
    final safeInit = init.isBefore(today) ? today : init;

    final picked = await showDatePicker(
      context: context,
      initialDate: safeInit, // ← было selectedDate
      firstDate: today,
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ru'),
      builder: (context, child) {
        final primary = ThemeColors.primary;
        final colors = Theme.of(context).colorScheme;
        final weekdayGrey = colors.onSurfaceVariant;
        final outlineGrey = colors.outlineVariant;

        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primary,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: primary,
                  onPrimary: colors.onPrimary,
                  surface: colors.surface,
                  onSurface: colors.onSurface,
                ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: colors.surface,
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: outlineGrey),
              ),
              headerBackgroundColor: colors.surface,
              headerForegroundColor: colors.onSurface,
              headerHeadlineStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              headerHelpStyle: TextStyle(
                fontSize: 12,
                color: weekdayGrey,
                fontWeight: FontWeight.w500,
              ),
              dayStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              weekdayStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: weekdayGrey,
              ),
              yearStyle:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              dayForegroundColor:
                  MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.selected)) {
                  return colors.onPrimary;
                }
                if (states.contains(MaterialState.disabled)) {
                  return colors.onSurface.withValues(alpha: .26);
                }
                return colors.onSurface;
              }),
              dayBackgroundColor:
                  MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.selected)) return primary;
                if (states.contains(MaterialState.hovered)) {
                  return primary.withOpacity(0.06);
                }
                return Colors.transparent;
              }),
              todayBorder:
                  const BorderSide(color: Color(0xFFCBD5E1)), // slate-300
              todayForegroundColor: MaterialStateProperty.all(primary),
              todayBackgroundColor:
                  MaterialStateProperty.all(primary.withOpacity(0.06)),
              dayOverlayColor:
                  MaterialStateProperty.all(primary.withOpacity(0.08)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateChanged(DateUtils.dateOnly(picked));
    }
  }

  Future<void> _share(BuildContext context) async {
    if (_sharing || widget.isSaving) return;
    final wasNewTask = widget.taskId == null || widget.taskId!.isEmpty;
    var taskPrepared = false;
    debugPrint(
      '[Share] Начало: taskId=${widget.taskId ?? 'new'}, '
      'isNew=$wasNewTask',
    );

    var token = await AuthStorage().getToken();
    var userId = await AuthStorage().getUserId();
    if (token == null || userId == null || userId.isEmpty) {
      debugPrint('[Share] Авторизация отсутствует, открываем экран входа');
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => AuthPage()),
      );
      if (!context.mounted) return;
      token = await AuthStorage().getToken();
      userId = await AuthStorage().getUserId();
      if (token == null || userId == null || userId.isEmpty) {
        debugPrint('[Share] Пользователь отменил вход или токен не сохранён');
        if (!context.mounted) return;
        await _showMessage(
          context,
          S.of(context).signInToShare,
        );
        return;
      }
    }

    if (!context.mounted) return;
    final deliveryMode = await _selectDeliveryMode(context);
    if (deliveryMode == null || !context.mounted) return;

    setState(() => _sharing = true);
    try {
      final preparedId =
          await widget.onPrepareShare?.call() ?? widget.taskId?.trim();
      if (preparedId == null || preparedId.isEmpty) {
        debugPrint('[Share] Сохранение не вернуло ID задачи');
        return;
      }
      taskPrepared = true;
      debugPrint('[Share] Задача подготовлена: taskId=$preparedId');

      final taskTreeIds = await _taskTreeIds(userId, preparedId);
      final rowBefore = await OfflineRuntime.store.taskById(userId, preparedId);
      final localRowId = rowBefore?.localId;
      final syncEngine = OfflineRuntime.syncEngine;
      if (syncEngine == null) {
        throw _SharePreparationException(S.of(context).syncNotReady);
      }

      debugPrint('[Share] Запуск синхронизации: taskId=$preparedId');
      final pendingTreeIds = await _synchronizeTaskForSharing(
        syncEngine: syncEngine,
        accountId: userId,
        rootId: preparedId,
        rootLocalRowId: localRowId,
        initialTreeIds: taskTreeIds,
      );
      if (pendingTreeIds.isNotEmpty) {
        debugPrint(
          '[Share] Операции дерева остались в очереди: '
          'taskId=$preparedId, pendingTreeIds=$pendingTreeIds',
        );
        throw _SharePreparationException(S.of(context).tasksPendingSync);
      }
      final syncError = syncEngine.lastError;
      if (syncError != null) {
        _logShareError('Синхронизация', syncError, StackTrace.current);
        debugPrint(
          '[Share][WARN] Задача синхронизирована, но другая операция '
          'завершилась ошибкой. Продолжаем создание приглашения.',
        );
      } else {
        debugPrint('[Share] Синхронизация завершена: taskId=$preparedId');
      }

      final rowAfter = localRowId == null
          ? await OfflineRuntime.store.taskById(userId, preparedId)
          : await OfflineRuntime.store.taskByLocalId(userId, localRowId);
      final serverTaskId = rowAfter?.serverId ?? preparedId;

      debugPrint(
        '[Share] Создание приглашения: serverTaskId=$serverTaskId',
      );
      final invite = await CollaborationService().createInvite(
        serverTaskId,
        mode: deliveryMode,
      );
      final url = invite['url']?.toString();
      final hash = invite['hash']?.toString();
      if ((url == null || url.isEmpty) && (hash == null || hash.isEmpty)) {
        throw _SharePreparationException(S.of(context).inviteLinkMissing);
      }
      await OfflineRuntime.store.recordSuccessfulShare(
        accountId: userId,
        taskId: serverTaskId,
        collaborative: deliveryMode == ShareDeliveryMode.collaborate,
        inviteHash: hash,
      );
      if (context.mounted) {
        await context.read<GlobalProvider>().refreshTasks(
              context,
              silent: true,
            );
      }
      final baseShareUrl =
          url != null && url.isNotEmpty ? url : 'https://jospar.kz/s/$hash';
      final responseMode = ShareDeliveryMode.fromValue(
        invite['mode']?.toString(),
      );
      final taskToShare = widget.shareTask?.call() ?? TaskItems(name: 'Задача');
      final message = buildTaskShareMessage(
        task: taskToShare,
        shareUrl: baseShareUrl,
        mode: responseMode,
      );
      if (!context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          // `title` supplies iOS link-preview metadata without turning the
          // task name into a competing email subject payload.
          title: taskToShare.name,
          sharePositionOrigin: _sharePositionOrigin(context),
        ),
      );
      debugPrint('[Share] Системное меню отправки открыто');
    } on CollaborationException catch (error, stackTrace) {
      _logShareError('Создание приглашения', error, stackTrace);
      if (!context.mounted) return;
      final message = error.statusCode == 401
          ? S.of(context).sessionExpired
          : S.of(context).inviteCreationFailed(error.message);
      await _showMessage(
        context,
        taskPrepared && wasNewTask
            ? S.of(context).taskSavedMessage(message)
            : message,
      );
    } on _SharePreparationException catch (error, stackTrace) {
      _logShareError('Подготовка задачи', error, stackTrace);
      if (context.mounted) {
        await _showMessage(
          context,
          taskPrepared && wasNewTask
              ? S.of(context).taskSavedMessage(error.message)
              : error.message,
        );
      }
    } catch (error, stackTrace) {
      _logShareError('Неизвестная ошибка', error, stackTrace);
      if (!context.mounted) return;
      await _showMessage(
        context,
        taskPrepared && wasNewTask
            ? S.of(context).taskSavedShareFailed
            : S.of(context).shareTaskFailed,
      );
    } finally {
      if (context.mounted) {
        setState(() => _sharing = false);
        if (taskPrepared && wasNewTask) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Rect? _sharePositionOrigin(BuildContext context) {
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox ||
        !renderObject.hasSize ||
        renderObject.size.isEmpty) {
      return null;
    }
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  Future<Set<String>> _taskTreeIds(
    String accountId,
    String rootId,
  ) async {
    final rows = await OfflineRuntime.store.allTaskRows(
      accountId: accountId,
      trashed: false,
    );
    final result = <String>{rootId};
    var changed = true;
    while (changed) {
      changed = false;
      for (final row in rows) {
        final id = row.serverId;
        if (id == null || result.contains(id)) continue;
        if (row.parentServerId != null && result.contains(row.parentServerId)) {
          result.add(id);
          changed = true;
        }
      }
    }
    return result;
  }

  Future<Set<String>> _synchronizeTaskForSharing({
    required SyncEngine syncEngine,
    required String accountId,
    required String rootId,
    required int? rootLocalRowId,
    required Set<String> initialTreeIds,
  }) async {
    final trackedIds = <String>{...initialTreeIds};
    Set<String> pendingTreeIds = const <String>{};
    const retryDelays = <Duration>[
      Duration(milliseconds: 500),
      Duration(milliseconds: 1200),
    ];

    for (var attempt = 0; attempt <= retryDelays.length; attempt++) {
      if (rootLocalRowId != null) {
        final currentRoot = await OfflineRuntime.store.taskByLocalId(
          accountId,
          rootLocalRowId,
        );
        final currentRootId = currentRoot?.serverId;
        if (currentRootId != null && currentRootId.isNotEmpty) {
          trackedIds.addAll(await _taskTreeIds(accountId, currentRootId));
        }
      } else {
        trackedIds.addAll(await _taskTreeIds(accountId, rootId));
      }

      await OfflineRuntime.outbox.retryEntitiesNow(accountId, trackedIds);
      await syncEngine.synchronize(ignoreStopped: true);

      final pendingIds =
          await OfflineRuntime.outbox.pendingEntityIds(accountId);
      pendingTreeIds = pendingIds.intersection(trackedIds);
      if (pendingTreeIds.isEmpty) return pendingTreeIds;
      if (attempt < retryDelays.length) {
        await Future<void>.delayed(retryDelays[attempt]);
      }
    }
    return pendingTreeIds;
  }

  Future<ShareDeliveryMode?> _selectDeliveryMode(
    BuildContext context,
  ) {
    return showShareDeliverySheet(context);
  }

  Future<void> _showMessage(BuildContext context, String message) {
    return showAppMessageDialog(
      context,
      title: S.of(context).error,
      message: message,
      buttonText: S.of(context).done,
    );
  }

  void _logShareError(String stage, Object error, StackTrace stackTrace) {
    if (error is SyncException) {
      debugPrint(
        '[Share][ERROR][$stage] status=${error.statusCode}, '
        'code=${error.code}, message=${error.message}, body=${error.body}',
      );
    } else if (error is CollaborationException) {
      debugPrint(
        '[Share][ERROR][$stage] status=${error.statusCode}, '
        'code=${error.code}, message=${error.message}, '
        'body=${error.responseBody}',
      );
    } else {
      debugPrint('[Share][ERROR][$stage] $error');
    }
    debugPrintStack(
      label: '[Share][STACK][$stage]',
      stackTrace: stackTrace,
    );
  }

  @override
  Widget build(BuildContext context) {
    final canShare =
        widget.shareAllowed && widget.taskId?.trim().isNotEmpty == true;
    final busy = widget.isSaving || _sharing;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AbsorbPointer(
          absorbing: busy,
          child: Opacity(
            opacity: busy ? 0.6 : 1.0,
            child: IconButton(
              constraints: const BoxConstraints.tightFor(
                width: 44,
                height: 44,
              ),
              onPressed: () => _pickDate(context),
              tooltip: '${widget.selectedDate.day}',
              icon: SizedBox(
                width: 32,
                height: 32,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/calendar.svg',
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        ThemeColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    Text(
                      '${widget.selectedDate.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.primary,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          onPressed: busy ? null : () => _pickReminder(context),
          tooltip:
              Localizations.of<S>(context, S)?.reminderTooltip ?? 'Напоминание',
          icon: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.reminderTime == null
                  ? Colors.transparent
                  : ThemeColors.primary.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.reminderTime == null
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
              size: 28,
              color: widget.reminderTime == null
                  ? const Color(0xFFC6C6D1)
                  : ThemeColors.primary,
            ),
          ),
        ),
        IconButton(
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          onPressed: busy
              ? null
              : () => widget.onChangeUrgency(nextUrgency(widget.urgency)),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: .72, end: 1).animate(animation),
                child: child,
              ),
            ),
            child: SvgPicture.asset(
              _urgencyAsset(widget.urgency),
              key: ValueKey(widget.urgency),
              width: 27,
              height: 27,
            ),
          ),
          tooltip: urgencyToApi(widget.urgency) ?? 'no urgency',
        ),
        IconButton(
          constraints: const BoxConstraints.tightFor(width: 44, height: 44),
          onPressed: canShare && !busy ? () => _share(context) : null,
          icon: _sharing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/share.svg',
                      width: 27,
                      height: 27,
                      colorFilter: ColorFilter.mode(
                        canShare && !busy
                            ? ThemeColors.primary
                            : ThemeColors.primary.withValues(alpha: .38),
                        BlendMode.srcIn,
                      ),
                    ),
                    const Icon(Icons.send, size: 0, color: Colors.transparent),
                  ],
                ),
          tooltip: Localizations.of<S>(context, S)?.share ?? 'Поделиться',
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.all(6),
          ),
          onPressed: busy ? null : widget.onSave,
          child: widget.isSaving
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ThemeColors.primary,
                  ),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/accept.svg',
                      width: 32,
                      height: 32,
                      colorFilter: ColorFilter.mode(
                        busy
                            ? ThemeColors.primary.withValues(alpha: .38)
                            : ThemeColors.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_upward,
                      size: 0,
                      color: Colors.transparent,
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  String _urgencyAsset(Urgency? urgency) {
    switch (urgency) {
      case Urgency.low:
        return 'assets/icons/exclude2.svg';
      case Urgency.medium:
        return 'assets/icons/exclude3.svg';
      case Urgency.high:
        return 'assets/icons/exclude4.svg';
      case null:
        return 'assets/icons/exclude1.svg';
    }
  }
}

class _SharePreparationException implements Exception {
  const _SharePreparationException(this.message);

  final String message;

  @override
  String toString() => message;
}
