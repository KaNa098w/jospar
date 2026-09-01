import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/models/tasks_response.dart';

bool shouldLeaveSharedTask(TaskItems task) =>
    task.isShared == true && task.collaborationRole != 'owner';

Future<bool> confirmLeaveSharedTask(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Выйти из задачи?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeColors.primary,
            ),
          ),
          content: const Text(
            'Вы получили эту совместную задачу от другого '
            'пользователя. Вы хотите выйти из неё?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Выйти'),
            ),
          ],
        ),
      ) ??
      false;
}

Future<bool> confirmDeleteTaskList(BuildContext context,
    {String? listName}) async {
  return await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            'Удалить список?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ThemeColors.primary,
            ),
          ),
          content: Text(
            listName == null || listName.isEmpty
                ? 'Ты действительно хочешь удалить этот список задач?'
                : 'Ты действительно хочешь удалить список «$listName»?',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Отмена',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('Удалить',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  )),
            ),
          ],
        ),
      ) ??
      false;
}
