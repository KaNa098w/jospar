import 'package:flutter/material.dart';
import 'package:jospar/app/screens/drawer/widgets/task_list_tile.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:provider/provider.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/services/task_list_service.dart';
import 'package:jospar/core/models/create_list_modal_sheet.dart';
import 'package:jospar/core/models/task_list_items_response.dart';

class TaskListsSection extends StatelessWidget {
  final double hpad;
  final String? selectedTaskListId;
  final ValueChanged<TaskListItems>? onTaskListTap;

  const TaskListsSection({
    super.key,
    required this.hpad,
    this.selectedTaskListId,
    this.onTaskListTap,
  });

  @override
  Widget build(BuildContext context) {
    final global = context.watch<GlobalProvider>();
    final taskLists = global.taskLists;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hpad),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                S.of(context).taskLists,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () async {
                  await showUpsertListModal(context);
                  final res = await TaskListService().getTaskLists(context);
                  if (res.items != null) {
                    global.setTaskLists(res.items!);
                  }
                },
                icon: const Icon(Icons.add, size: 24, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...taskLists.map((it) => TaskListTile(
              item: it,
              hpad: hpad,
              selected: it.id == selectedTaskListId,
              onTap: () => onTaskListTap?.call(it),
            )),
      ],
    );
  }
}
