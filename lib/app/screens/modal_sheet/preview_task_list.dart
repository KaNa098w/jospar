import 'package:flutter/material.dart';
import 'package:jospar/app/utils/utils.dart';
import 'package:jospar/core/models/tasks_response.dart';

class PreviewTaskList extends StatelessWidget {
  final List<TaskItems> previewTasks;
  final bool? linkTasks;

  const PreviewTaskList({
    super.key,
    required this.previewTasks,
    this.linkTasks = false,
  });

  @override
  Widget build(BuildContext context) {
    if (previewTasks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Задачи в выбранном списке:',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: previewTasks.length,
          separatorBuilder: (_, __) =>
              Divider(color: Colors.grey.shade300, height: 1),
          itemBuilder: (context, i) {
            final t = previewTasks[i];
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.check_circle_outline, size: 18),
              title: Text(
                t.name ?? 'Без названия',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: (t.createdAt != null)
                  ? Text(humanizeRu(context, DateTime.parse(t.createdAt!)))
                  : null,
            );
          },
        ),
      ],
    );
  }
}
