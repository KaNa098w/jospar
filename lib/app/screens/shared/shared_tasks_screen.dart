import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jospar/app/screens/modal_sheet/add_task_modal.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:provider/provider.dart';
import 'package:jospar/app/screens/shared/collaborators_sheet.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/offline/realtime_sync.dart';
import 'package:jospar/core/services/offline/sync_engine.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/l10n/s.dart';

class SharedTasksScreen extends StatefulWidget {
  const SharedTasksScreen({super.key});

  @override
  State<SharedTasksScreen> createState() => _SharedTasksScreenState();
}

class _SharedSummary extends StatelessWidget {
  const _SharedSummary({required this.total, required this.completed});

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.primary,
            ThemeColors.primary.withValues(alpha: .72),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ThemeColors.primary.withValues(alpha: .2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_2_outlined, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                S.of(context).sharedProgress,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween(end: progress),
            duration: const Duration(milliseconds: 550),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 8,
                backgroundColor: Colors.white24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            S.of(context).sharedProgressCount(completed, total),
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SharedTaskCard extends StatelessWidget {
  const _SharedTaskCard({
    super.key,
    required this.task,
    required this.canEdit,
    required this.onToggle,
    required this.onToggleSubtask,
    required this.onEdit,
    required this.onParticipants,
  });

  final TaskItems task;
  final bool canEdit;
  final VoidCallback onToggle;
  final void Function(TaskItems parent, TaskItems subtask) onToggleSubtask;
  final VoidCallback onEdit;
  final VoidCallback onParticipants;

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted == true;
    final sourceSubtasks = task.children ?? const <TaskItems>[];
    final subtasks = <TaskItems>[
      ...sourceSubtasks.where((item) => item.isCompleted != true),
      ...sourceSubtasks.where((item) => item.isCompleted == true),
    ];
    final done = subtasks.where((task) => task.isCompleted == true).length;
    final progress = subtasks.isEmpty ? 0.0 : done / subtasks.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFF0FAF3) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed ? const Color(0xFFBDE8C9) : const Color(0xFFE8ECF3),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D17233C),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          type: MaterialType.transparency,
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              leading: _AnimatedCheck(
                checked: completed,
                enabled: canEdit,
                onTap: onToggle,
              ),
              title: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: completed
                      ? const Color(0xFF718078)
                      : const Color(0xFF1D2735),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  decoration: completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
                child: Text(task.name ?? S.of(context).untitled),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _RoleChip(role: task.collaborationRole),
                        const SizedBox(width: 8),
                        _ParticipantStack(
                            items: task.collaborators ?? const []),
                      ],
                    ),
                    if (subtasks.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      TweenAnimationBuilder<double>(
                        tween: Tween(end: progress),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOut,
                        builder: (_, value, __) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 5,
                            backgroundColor: const Color(0xFFE9EDF3),
                            color: const Color(0xFF34C759),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        S.of(context).subtasksProgress(done, subtasks.length),
                        style: const TextStyle(
                          color: Color(0xFF8A94A3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              children: [
                for (final subtask in subtasks)
                  _SubtaskRow(
                    task: subtask,
                    enabled: canEdit,
                    onTap: () => onToggleSubtask(task, subtask),
                  ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onParticipants,
                      icon: const Icon(Icons.group_outlined, size: 20),
                      label: Text(S.of(context).participants),
                    ),
                    if (canEdit)
                      IconButton(
                        tooltip: S.of(context).edit,
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedCheck extends StatelessWidget {
  const _AnimatedCheck({
    required this.checked,
    required this.enabled,
    required this.onTap,
  });

  final bool checked;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      customBorder: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: checked ? const Color(0xFF34C759) : Colors.transparent,
          border: Border.all(
            color: checked ? const Color(0xFF34C759) : const Color(0xFFB8C0CC),
            width: 2,
          ),
        ),
        child: AnimatedScale(
          scale: checked ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow({
    required this.task,
    required this.enabled,
    required this.onTap,
  });

  final TaskItems task;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final completed = task.isCompleted == true;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(top: 6),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFEAF8EE) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(13),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          titleAlignment: ListTileTitleAlignment.top,
          onTap: enabled ? onTap : null,
          leading: Transform.translate(
            offset: const Offset(0, 10),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(completed),
                size: 21,
                color: completed
                    ? const Color(0xFF34C759)
                    : const Color(0xFFAAB2BE),
              ),
            ),
          ),
          title: Text(
            task.name ?? S.of(context).untitled,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w400,
              color:
                  completed ? const Color(0xFF78827B) : const Color(0xFF374151),
              decoration:
                  completed ? TextDecoration.lineThrough : TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.role});

  final String? role;

  @override
  Widget build(BuildContext context) {
    final owner = role == 'owner';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: owner ? const Color(0xFFE8F1FF) : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        owner
            ? S.of(context).owner
            : role == 'viewer'
                ? S.of(context).viewer
                : S.of(context).editor,
        style: TextStyle(
          color: owner ? const Color(0xFF2B63F3) : const Color(0xFF667085),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ParticipantStack extends StatelessWidget {
  const _ParticipantStack({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.select<GlobalProvider, String?>(
      (provider) => provider.authResponse?.user?.id,
    );
    final otherParticipants = items
        .where((item) =>
            currentUserId == null ||
            _sharedParticipantId(item) != currentUserId)
        .toList(growable: false);
    if (otherParticipants.isEmpty) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group_outlined, size: 16, color: Color(0xFF8A94A3)),
          const SizedBox(width: 4),
          Text(S.of(context).participants,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A94A3))),
        ],
      );
    }
    final visible = otherParticipants.take(3).toList(growable: false);
    return SizedBox(
      width: visible.length * 21 + (otherParticipants.length > 3 ? 26 : 7),
      height: 28,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 20,
              child: _ParticipantAvatar(item: visible[i]),
            ),
          if (otherParticipants.length > 3)
            Positioned(
              left: visible.length * 20,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: const Color(0xFFE8ECF3),
                child: Text(
                  '+${otherParticipants.length - 3}',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String? _sharedParticipantId(Map<String, dynamic> item) {
  final nestedUser = item['user'];
  final user = nestedUser is Map ? nestedUser : const <String, dynamic>{};
  return (item['user_id'] ?? item['id'] ?? user['id'])?.toString();
}

class _ParticipantAvatar extends StatelessWidget {
  const _ParticipantAvatar({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final nestedUser = item['user'];
    final user = nestedUser is Map ? nestedUser : const <String, dynamic>{};
    final fullName =
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final name = (item['name'] ??
            item['display_name'] ??
            user['name'] ??
            (fullName.isEmpty ? null : fullName) ??
            item['email'] ??
            user['email'] ??
            '?')
        .toString();
    final avatarUrl = (item['avatar_url'] ??
            item['photo_url'] ??
            item['picture'] ??
            item['avatar'] ??
            user['avatar_url'] ??
            user['photo_url'] ??
            user['picture'] ??
            user['avatar'])
        ?.toString();
    final avatarColor = _sharedParticipantColor(
      (item['user_id'] ?? item['id'] ?? user['id'] ?? name).toString(),
    );
    final online = item['is_online'] == true ||
        item['online'] == true ||
        item['presence'] == 'online';
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 26,
          height: 26,
          padding: const EdgeInsets.all(1.5),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: ClipOval(
            child: avatarUrl == null || avatarUrl.isEmpty
                ? _avatarInitial(name, avatarColor)
                : Image.network(
                    avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _avatarInitial(name, avatarColor),
                  ),
          ),
        ),
        if (online)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: const Color(0xFF34C759),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _avatarInitial(String name, Color color) => Container(
        color: color,
        alignment: Alignment.center,
        child: Text(
          name.isEmpty ? '?' : name[0].toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
}

Color _sharedParticipantColor(String seed) {
  const colors = <Color>[
    Color(0xFF5B6EE1),
    Color(0xFFDB5A6B),
    Color(0xFF2F9E73),
    Color(0xFFE08433),
    Color(0xFF8B5CC7),
    Color(0xFF2589A8),
    Color(0xFFB56A9B),
  ];
  final hash = seed.codeUnits.fold<int>(0, (value, unit) => value * 31 + unit);
  return colors[hash.abs() % colors.length];
}

class _RealtimeConsoleLine {
  const _RealtimeConsoleLine({
    required this.timestamp,
    required this.source,
    required this.message,
    required this.isError,
    required this.isSuccess,
  });

  final DateTime timestamp;
  final String source;
  final String message;
  final bool isError;
  final bool isSuccess;
}

class _RealtimeConsole extends StatelessWidget {
  const _RealtimeConsole({
    required this.connected,
    required this.subscribed,
    required this.fastSyncEnabled,
    required this.syncRunning,
    required this.expanded,
    required this.lines,
    required this.onToggleExpanded,
  });

  final bool connected;
  final bool subscribed;
  final bool fastSyncEnabled;
  final bool syncRunning;
  final bool expanded;
  final List<_RealtimeConsoleLine> lines;
  final VoidCallback onToggleExpanded;

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF111820);
    const border = Color(0xFF2A3744);
    final live = connected && subscribed;
    final statusColor = live
        ? const Color(0xFF4DD58A)
        : connected
            ? const Color(0xFFFFC857)
            : const Color(0xFFFF6B6B);

    return Container(
      key: const ValueKey('shared-realtime-console'),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: onToggleExpanded,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 10, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: .45),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          S.of(context).realtimeConsole,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (syncRunning)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: Color(0xFF67B7FF),
                            ),
                          ),
                        ),
                      Icon(
                        expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF9FB0C0),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 11),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _ConsoleStatusChip(
                      key: const ValueKey('shared-ws-status'),
                      label: connected
                          ? S.of(context).websocketConnected
                          : S.of(context).websocketDisconnected,
                      color: connected
                          ? const Color(0xFF4DD58A)
                          : const Color(0xFFFF6B6B),
                    ),
                    _ConsoleStatusChip(
                      label: subscribed
                          ? S.of(context).channelSubscribed
                          : S.of(context).channelNotSubscribed,
                      color: subscribed
                          ? const Color(0xFF4DD58A)
                          : const Color(0xFFFFC857),
                    ),
                    _ConsoleStatusChip(
                      label: fastSyncEnabled ? 'POLL 2s' : 'POLL 30s',
                      color: fastSyncEnabled
                          ? const Color(0xFFFFC857)
                          : const Color(0xFF67B7FF),
                    ),
                  ],
                ),
              ),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 180),
                crossFadeState: expanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 220),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: border)),
                  ),
                  child: lines.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            S.of(context).realtimeHistoryEmpty,
                            style: const TextStyle(
                              color: Color(0xFF7F92A4),
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          itemCount: lines.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            color: Color(0xFF202C37),
                          ),
                          itemBuilder: (context, index) =>
                              _ConsoleLogRow(line: lines[index]),
                        ),
                ),
                secondChild: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsoleStatusChip extends StatelessWidget {
  const _ConsoleStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .38)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontFamily: 'monospace',
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ConsoleLogRow extends StatelessWidget {
  const _ConsoleLogRow({required this.line});

  final _RealtimeConsoleLine line;

  @override
  Widget build(BuildContext context) {
    final color = line.isError
        ? const Color(0xFFFF7B7B)
        : line.isSuccess
            ? const Color(0xFF62D99B)
            : const Color(0xFFB8C7D5);
    final time = '${line.timestamp.hour.toString().padLeft(2, '0')}:'
        '${line.timestamp.minute.toString().padLeft(2, '0')}:'
        '${line.timestamp.second.toString().padLeft(2, '0')}';
    final message = line.message.replaceAll(RegExp(r'\s+'), ' ').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$time  ',
              style: const TextStyle(color: Color(0xFF708294)),
            ),
            TextSpan(
              text: '${line.source.padRight(4)} ',
              style: TextStyle(
                color: line.source == 'WS'
                    ? const Color(0xFFC792EA)
                    : const Color(0xFF67B7FF),
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(text: message, style: TextStyle(color: color)),
          ],
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 11.5,
          height: 1.3,
        ),
      ),
    );
  }
}

class _SharedEmptyState extends StatelessWidget {
  const _SharedEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFFE8F1FF),
              child: Icon(
                Icons.groups_2_outlined,
                size: 42,
                color: Color(0xFF2B63F3),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              S.of(context).emptySharedTasks,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).emptySharedTasksHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF7B8492), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SharedTasksScreenState extends State<SharedTasksScreen> {
  final TaskService _service = TaskService();
  Timer? _pollTimer;
  StreamSubscription<RealtimeLogEntry>? _realtimeLogSubscription;
  StreamSubscription<SyncLogEntry>? _syncLogSubscription;
  bool _syncing = false;
  bool _fastSyncEnabled = false;
  bool _consoleExpanded = true;

  @override
  void initState() {
    super.initState();
    _realtimeLogSubscription =
        OfflineRuntime.realtimeSync?.logStream.listen((_) {
      if (mounted) setState(() {});
    });
    _syncLogSubscription = OfflineRuntime.syncEngine?.logStream.listen((_) {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncNow());
    _startFallbackSync();
  }

  void _startFallbackSync() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollTimer = Timer.periodic(
      Duration(seconds: _fastSyncEnabled ? 2 : 30),
      (_) => _syncNow(),
    );
  }

  void _toggleFallbackSync() {
    setState(() => _fastSyncEnabled = !_fastSyncEnabled);
    _startFallbackSync();
    if (_fastSyncEnabled) unawaited(_syncNow());
    final message = _fastSyncEnabled
        ? S.of(context).fastSyncEnabled
        : S.of(context).defaultSyncEnabled;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _realtimeLogSubscription?.cancel();
    _syncLogSubscription?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    await context.read<GlobalProvider>().refreshTasks(context);
  }

  Future<void> _syncNow() async {
    if (!mounted || _syncing) return;
    final syncEngine = OfflineRuntime.syncEngine;
    if (syncEngine == null) return;
    _syncing = true;
    try {
      await syncEngine.synchronize();
      await _load();
    } finally {
      _syncing = false;
    }
  }

  Future<void> _toggle(TaskItems task) async {
    if (task.id == null) return;
    await _service.updateTask(context, id: task.id!);
    await _load();
  }

  Future<void> _edit(TaskItems task) async {
    await showAddTaskModal(
      context: context,
      selectedDay: DateTime.tryParse(task.date ?? '') ?? DateTime.now(),
      taskId: task.id ?? '',
      existingTask: task,
      onSaveTask: (title, subtasks, date, taskListId, urgency) async {
        await _saveTaskAndSubtasks(
          task: task,
          title: title,
          subtasks: List<Map<String, dynamic>>.from(subtasks),
          date: date,
          taskListId: task.taskListId ?? taskListId,
          urgency: urgency,
        );
        return task.id;
      },
    );
    await _syncNow();
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

    await _service.updateTaskPut(
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
        await _service.createSubtask(
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
        await _service.updateTaskPut(
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
      await _service.deleteTask(context, id);
    }

    final allSubtasksCompleted = subtasks.isNotEmpty &&
        subtasks.every((item) => item['completed'] == true);
    if (task.isCompleted != allSubtasksCompleted) {
      await _service.updateTaskPut(
        context,
        id: parentId,
        isCompleted: allSubtasksCompleted,
        date: date == null ? null : _ymd(date),
        clearDate: date == null,
      );
    }
  }

  Future<void> _toggleSubtask(TaskItems parent, TaskItems subtask) async {
    final id = subtask.id;
    if (id == null) return;
    final childWillBeCompleted = subtask.isCompleted != true;
    await _service.updateTask(context, id: id);
    final allCompleted = (parent.children ?? const <TaskItems>[]).isNotEmpty &&
        (parent.children ?? const <TaskItems>[]).every((child) =>
            child.id == id ? childWillBeCompleted : child.isCompleted == true);
    if (parent.id != null && parent.isCompleted != allCompleted) {
      await _service.updateTaskPut(
        context,
        id: parent.id!,
        isCompleted: allCompleted,
        date: parent.date,
      );
    }
    await _load();
  }

  List<_RealtimeConsoleLine> _consoleLines() {
    final lines = <_RealtimeConsoleLine>[
      ...?OfflineRuntime.realtimeSync?.logs.map(
        (entry) => _RealtimeConsoleLine(
          timestamp: entry.timestamp,
          source: 'WS',
          message: entry.message,
          isError: entry.isError,
          isSuccess: entry.message.contains('connected:') ||
              entry.message.contains('subscription succeeded') ||
              entry.message.contains('event received'),
        ),
      ),
      ...?OfflineRuntime.syncEngine?.logs.map(
        (entry) => _RealtimeConsoleLine(
          timestamp: entry.timestamp,
          source: 'SYNC',
          message: entry.details?.isNotEmpty == true
              ? '${entry.title} — ${entry.details}'
              : entry.title,
          isError: entry.kind == SyncLogKind.error,
          isSuccess: entry.kind == SyncLogKind.success ||
              entry.kind == SyncLogKind.received,
        ),
      ),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return lines.take(60).toList(growable: false);
  }

  String _ymd(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final tasks = context
        .watch<GlobalProvider>()
        .allApiTasks
        .where((task) => task.isShared == true)
        .toList(growable: false);
    final completed = tasks.where((task) => task.isCompleted == true).length;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: Text(
          S.of(context).sharedTasks,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF5F7FB),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            key: const ValueKey('shared-fallback-sync-toggle'),
            tooltip: _fastSyncEnabled
                ? S.of(context).defaultSyncEnabled
                : S.of(context).enableFastSync,
            onPressed: _toggleFallbackSync,
            icon: Icon(
              _fastSyncEnabled
                  ? Icons.speed_rounded
                  : Icons.cloud_sync_outlined,
              color: _fastSyncEnabled
                  ? const Color(0xFFF59E0B)
                  : ThemeColors.primary,
            ),
          ),
          IconButton(
            tooltip: S.of(context).refresh,
            onPressed: _syncing ? null : _syncNow,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _syncing
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync_rounded, key: ValueKey('sync')),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _syncNow,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          itemCount: tasks.isEmpty ? 2 : tasks.length + 2,
          itemBuilder: (context, index) {
            if (index == 0) {
              final realtime = OfflineRuntime.realtimeSync;
              return _RealtimeConsole(
                connected: realtime?.isConnected == true,
                subscribed: realtime?.isSubscribed == true,
                fastSyncEnabled: _fastSyncEnabled,
                syncRunning:
                    _syncing || OfflineRuntime.syncEngine?.isRunning == true,
                expanded: _consoleExpanded,
                lines: _consoleLines(),
                onToggleExpanded: () => setState(
                  () => _consoleExpanded = !_consoleExpanded,
                ),
              );
            }
            if (tasks.isEmpty) return const _SharedEmptyState();
            if (index == 1) {
              return _SharedSummary(
                total: tasks.length,
                completed: completed,
              );
            }
            final task = tasks[index - 2];
            final canEdit = task.collaborationRole != 'viewer';
            return _SharedTaskCard(
              key: ValueKey(task.id),
              task: task,
              canEdit: canEdit,
              onToggle: () => _toggle(task),
              onToggleSubtask: _toggleSubtask,
              onEdit: () => _edit(task),
              onParticipants: () => showCollaboratorsSheet(context, task),
            );
          },
        ),
      ),
    );
  }
}
