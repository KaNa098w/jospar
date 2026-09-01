import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/app/widgets/accept_button.dart';

/// Информ-строка (иконка + текст) без карточек, без фона и бордера.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  final bool copyable;
  final bool dense;
  final Widget? trailing;
  final int? maxValueLines;
  final Color? iconColor;
  final List<TaskListItems> taskList;

  const InfoRow({
    super.key,
    required this.icon,
    required this.value,
    this.copyable = false,
    this.dense = false,
    this.trailing,
    this.maxValueLines,
    this.iconColor,
    this.taskList = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final valueStyle =
        (dense ? textTheme.bodyMedium : textTheme.titleSmall)?.copyWith(
      fontWeight: FontWeight.w500,
      height: 1.3,
    );

    Color? colorFromHex(String? hex) {
      if (hex == null || hex.isEmpty) return null;
      var v = hex.replaceAll('#', '');
      if (v.length == 6) v = 'ff$v'; // → AARRGGBB
      if (v.length != 8) return null;
      final intColor = int.parse(v, radix: 16);
      return Color(intColor);
    }

    final task = taskList.isEmpty ? null : taskList.first;
    final taskColor = colorFromHex(task?.colorHex) ?? Colors.grey;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: dense ? 4 : 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: dense ? 16 : 20,
                color: iconColor ?? ThemeColors.primary,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  value.isEmpty ? '—' : value,
                  style: valueStyle,
                  maxLines: maxValueLines,
                  overflow: maxValueLines != null
                      ? TextOverflow.ellipsis
                      : TextOverflow.visible,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 15),
                DefaultTextStyle.merge(
                  style: valueStyle ?? const TextStyle(),
                  child: trailing!,
                ),
              ],
            ],
          ),
          if (task != null) ...[
            const SizedBox(height: 15),
            AcceptButton(
              text: task.name ?? '',
              onPressed: () {},
              color: taskColor,
            ),
          ],
        ],
      ),
    );
  }
}
