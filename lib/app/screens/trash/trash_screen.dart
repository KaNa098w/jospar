import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jospar/app/utils/custom_appbar.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:jospar/app/widgets/custom_button_restore.dart';
import 'package:jospar/app/widgets/custom_button_widget.dart';
import 'package:jospar/app/widgets/info_row_widget.dart';
import 'package:jospar/app/widgets/show_bottom_sheet.dart';
import 'package:provider/provider.dart'; // для ThemeColors.primary если нужно в других местах

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  List<TaskItems>? items;
  final TaskService _taskService = TaskService();
  final Set<String> _restoringTaskIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadTrashItems();
  }

  Future<void> _loadTrashItems() async {
    try {
      final trashItems =
          await _taskService.getTasks(context, trash: 1, only_parent: 1);
      if (!mounted) return;
      setState(() {
        items = trashItems.items;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке удаленных задач: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось загрузить корзину: $e')),
        );
      }
    }
  }

  Future<void> _restoreTask(String id, {bool closeDetails = false}) async {
    if (_restoringTaskIds.contains(id)) return;
    setState(() => _restoringTaskIds.add(id));
    try {
      await _taskService.restoreTask(context, id: id);
      await _loadTrashItems();
      if (!mounted) return;
      if (closeDetails) Navigator.of(context).maybePop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Задача восстановлена',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
        ),
      );

      await context.read<GlobalProvider>().refreshTasks(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось восстановить: $e')),
      );
    } finally {
      if (mounted) setState(() => _restoringTaskIds.remove(id));
    }
  }

  void _showTrashedTaskSheet(TaskItems task) {
    final created = task.createdAt != null
        ? DateFormat('dd.MM.yyyy HH:mm')
            .format(DateTime.parse(task.createdAt!).toLocal())
        : '—';
    final taskList = task.taskList;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        final media = MediaQuery.of(ctx);
        final bottomInset = media.viewInsets.bottom
            .clamp(0.0, media.size.height * 0.4)
            .toDouble();
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 8, 16, bottomInset + 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.name ?? 'Без названия',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                InfoRow(
                  icon: Icons.calendar_today,
                  value: created,
                  taskList: taskList != null ? [taskList] : const [],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButtonForRestore(
                    backgroundColor: colors.surfaceContainerHigh,
                    textColor: colors.onSurfaceVariant,
                    icon: Icons.restart_alt,
                    text: 'Восстановить',
                    onPressed: task.id == null
                        ? null
                        : () => _restoreTask(task.id!, closeDetails: true),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        );
      },
    );
  }

  Color? _colorFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    var v = hex.replaceAll('#', '');
    if (v.length == 6) v = 'ff$v'; // → AARRGGBB
    if (v.length != 8) return null;
    final intColor = int.parse(v, radix: 16);
    return Color(intColor);
  }

  @override
  Widget build(BuildContext context) {
    final list = items;
    final trashCount = list?.length ?? 0;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: S.of(context).screenCart),
      body: list == null
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? Center(
                  child: Text(
                    S.of(context).noTasksToday,
                    style: TextStyle(
                      fontSize: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  itemCount:
                      list.length + 1, // +1 для кнопки «Очистить корзину»
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color:
                        Colors.transparent, // не видимая разделительная линия
                  ),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Кнопка «Очистить корзину» → вызывает твой CupertinoActionSheet
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 0),
                        child: CustomButton(
                          text: S.of(context).clearTrash,
                          textColor: Colors.red,
                          backgroundColor:
                              Colors.redAccent.withValues(alpha: 0.12),
                          onPressed: () async {
                            await showAllTrashedActionSheet(
                              context: context,
                              trashCount: trashCount,
                              clearTrash: () async {
                                // твой реальный экшен очистки:
                                await _taskService.clearTrash(context);
                              },
                              reload: () {
                                _loadTrashItems();
                              },
                            );

                            // if (!mounted) return;
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   const SnackBar(
                            //     content: Text('Корзина очищена'),
                            //   ),
                            // );
                          },
                        ),
                      );
                    }

                    final task = list[index - 1];
                    final taskColor =
                        _colorFromHex(task.taskList?.colorHex) ?? Colors.grey;
                    final taskId = task.id;
                    final restoring =
                        taskId != null && _restoringTaskIds.contains(taskId);

                    return ListTile(
                      leading: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: taskColor.withValues(alpha: 0.10),
                          border: Border.all(color: taskColor, width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: (task.isCompleted ?? false)
                            ? Icon(Icons.check, size: 16, color: taskColor)
                            : null,
                      ),
                      title: Text(
                        task.name ?? 'Без названия',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          letterSpacing: -0.3,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        tooltip: 'Восстановить',
                        onPressed: taskId == null || restoring
                            ? null
                            : () => _restoreTask(taskId),
                        icon: restoring
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.restore_rounded),
                      ),
                      // subtitle: task.createdAt != null
                      //     ? Text(
                      //         'Создано: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(task.createdAt!).toLocal())}',
                      //         style: const TextStyle(color: Colors.grey),
                      //       )
                      //     : null,
                      onTap: () => _showTrashedTaskSheet(task),
                    );
                  },
                ),
    );
  }
}
