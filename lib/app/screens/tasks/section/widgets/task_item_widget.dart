import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:provider/provider.dart';

class TaskItem extends StatelessWidget {
  final TaskItems task;
  final VoidCallback onToggle;
  final Color colorHex;
  final String? urgency;
  final Color? completedColor;
  final bool keepCompletedTaskActiveStyle;
  final bool useLargeCheckboxTapTarget;
  final String? trailingText;

  const TaskItem({
    super.key, // Рекомендуется добавлять key в конструктор
    required this.task,
    required this.onToggle,
    required this.colorHex,
    this.urgency,
    this.completedColor,
    this.keepCompletedTaskActiveStyle = false,
    this.useLargeCheckboxTapTarget = false,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isCompleted = task.isCompleted ?? false;
    final bool useCompletedVisuals =
        isCompleted && !keepCompletedTaskActiveStyle;
    final Color resolvedCompletedColor = completedColor ?? Colors.grey.shade400;
    final isSharedPreview =
        (task.name ?? '').trim().toLowerCase() == 'test1234';
    final urgencyBackground = _urgencyBg(context, urgency, useCompletedVisuals);
    final currentUserId = context.select<GlobalProvider, String?>(
      (provider) => provider.authResponse?.user?.id,
    );
    final allParticipants = isSharedPreview
        ? const <Map<String, dynamic>>[
            {'name': 'Анна'},
            {'name': 'Бек'},
            {'name': 'София'},
            {'name': 'Данияр'},
            {'name': 'Мария'},
          ]
        : task.collaborators ?? const <Map<String, dynamic>>[];
    final participants = allParticipants
        .where((item) =>
            currentUserId == null || _participantId(item) != currentUserId)
        .toList(growable: false);
    // Use the exact same condition as the avatar stack below. A task receives
    // the collaboration background only when an avatar is actually visible.
    final hasVisibleParticipantAvatar = participants.isNotEmpty;

    final checkbox = Transform.translate(
      offset: const Offset(0, 2),
      child: SizedBox(
        width: 35,
        height: 20,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            height: 20,
            width: 20,
            decoration: BoxDecoration(
              color: isCompleted ? resolvedCompletedColor : Colors.transparent,
              border: Border.all(
                color: isCompleted ? resolvedCompletedColor : colorHex,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
      ),
    );

    final content = Container(
      padding: const EdgeInsets.symmetric(
          vertical: 6.0,
          horizontal: 6.0), // Добавлен и горизонтальный отступ для симметрии
      decoration: BoxDecoration(
        color: hasVisibleParticipantAvatar
            ? (isDark ? const Color(0xFF19324B) : const Color(0xFFD9EAFC))
            : urgencyBackground ??
                (isDark
                    ? Colors.transparent
                    : useCompletedVisuals
                        ? const Color(0xFFF3F4F6)
                        : colors.surface),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (useLargeCheckboxTapTarget)
            checkbox
          else
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: checkbox,
            ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: task.name ?? ''),
                        if (task.children != null && task.children!.isNotEmpty)
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: SvgPicture.asset(
                                'assets/icons/receipt.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  useCompletedVisuals
                                      ? Colors.grey[400]!
                                      : colors.onSurfaceVariant,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    softWrap: true,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16.5,
                      letterSpacing: -0.5,
                      color: useCompletedVisuals
                          ? colors.onSurface.withValues(alpha: .42)
                          : colors.onSurface,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                if (participants.isNotEmpty) ...[
                  const SizedBox(width: 7),
                  _TaskParticipantStack(
                    participants: participants,
                  ),
                ],
                if (trailingText?.isNotEmpty == true) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      trailingText!,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF8A8F98),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (!useLargeCheckboxTapTarget) return content;

    return Stack(
      children: [
        content,
        PositionedDirectional(
          start: 0,
          top: 0,
          bottom: 0,
          width: 48,
          child: GestureDetector(
            key: ValueKey('task-checkbox-hit-target-${task.id ?? task.name}'),
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
          ),
        ),
      ],
    );
  }
}

String? _participantId(Map<String, dynamic> item) {
  final nestedUser = item['user'];
  final user = nestedUser is Map ? nestedUser : const <String, dynamic>{};
  return (item['user_id'] ?? item['id'] ?? user['id'])?.toString();
}

class _TaskParticipantStack extends StatelessWidget {
  const _TaskParticipantStack({required this.participants});

  final List<Map<String, dynamic>> participants;

  @override
  Widget build(BuildContext context) {
    final visible = participants.take(3).toList(growable: false);
    final remaining = participants.length - visible.length;
    return SizedBox(
      width: visible.length * 17.0 + (remaining > 0 ? 25 : 7),
      height: 28,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 17,
              child: _TaskParticipantAvatar(item: visible[i]),
            ),
          if (remaining > 0)
            Positioned(
              left: visible.length * 17,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.surface,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '+$remaining',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF55555C),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskParticipantAvatar extends StatelessWidget {
  const _TaskParticipantAvatar({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final nestedUser = item['user'];
    final user = nestedUser is Map ? nestedUser : const <String, dynamic>{};
    final avatarUrl = (item['avatar_url'] ??
            item['photo_url'] ??
            item['picture'] ??
            item['avatar'] ??
            user['avatar_url'] ??
            user['photo_url'] ??
            user['picture'] ??
            user['avatar'])
        ?.toString();
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
    final avatarColor = _participantColor(
      (item['user_id'] ?? item['id'] ?? user['id'] ?? name).toString(),
    );

    final fallback = Container(
      color: avatarColor,
      alignment: Alignment.center,
      child: Text(
        name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );

    return Tooltip(
      message: name,
      child: Container(
        width: 26,
        height: 26,
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: avatarUrl == null || avatarUrl.isEmpty
              ? fallback
              : Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback,
                ),
        ),
      ),
    );
  }
}

Color _participantColor(String seed) {
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

// фон
// фон
Color? _urgencyBg(BuildContext context, String? u, bool isCompleted) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (isCompleted || u == null) return null;

  switch (u.toLowerCase()) {
    case 'low':
      return isDark ? const Color(0xFF3B3518) : Colors.yellow.shade100;
    case 'medium':
      return isDark ? const Color(0xFF402B18) : Colors.orange.shade100;
    case 'high':
    case 'hight':
      return isDark ? const Color(0xFF421F25) : Colors.red.shade100;
  }
  return null;
}

// бордер
