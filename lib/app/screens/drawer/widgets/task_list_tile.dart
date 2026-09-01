import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:jospar/app/widgets/custom_alert_dialog.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/models/create_list_modal_sheet.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/services/task_list_service.dart';
import 'package:provider/provider.dart';

class TaskListTile extends StatelessWidget {
  final TaskListItems item;
  final double hpad;
  final VoidCallback? onTap;
  final bool selected;

  /// колбэки под действия
  final VoidCallback? onEdit;
  final Future<bool> Function()? onDeleteConfirm; // вернуть true для удаления
  final VoidCallback? onDelete; // реальное удаление

  const TaskListTile({
    super.key,
    required this.item,
    required this.hpad,
    this.onTap,
    this.selected = false,
    this.onEdit,
    this.onDeleteConfirm,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey('tasklist-${item.id ?? item.name ?? UniqueKey()}'),

      // свайп открывает панель действий, но полного удаления свайпом НЕТ
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.42, // две кнопки
        children: [
          // Редактировать
          SlidableAction(
            onPressed: (_) async {
              onEdit?.call();
              await showUpsertListModal(context, existing: item);
            },
            backgroundColor: const Color(0xFF1E88E5),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),

          // Удалить (только через кнопку)
          SlidableAction(
            onPressed: (_) async {
              try {
                bool ok;
                if (onDeleteConfirm != null) {
                  ok = await onDeleteConfirm!();
                } else {
                  ok =
                      await confirmDeleteTaskList(context, listName: item.name);
                }
                if (!ok) return;

                final service = TaskListService();
                await service.deleteTaskList(context, item.id ?? '');

                onDelete?.call();

                final gp = context.read<GlobalProvider>();
                await gp.refreshTaskLists(context);
              } catch (e) {
                // По желанию — показать уведомление об ошибке
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text('Не удалось удалить: $e')),
                // );
              }
            },
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
        ],
      ),

      child: InkWell(
        onTap: onTap,
        child: Container(
          color: selected ? Colors.lightBlue.shade50 : Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: hpad, vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _parseColor(item.colorHex),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name ?? 'Без названия',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return Colors.grey;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return Colors.grey;
    }
  }
}
