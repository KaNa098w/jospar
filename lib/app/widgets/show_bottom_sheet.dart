import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

Future<void> showAllTrashedActionSheet({
  required BuildContext context,
  required int trashCount,
  required Future<void> Function() clearTrash, // пробрасываем экшен
  required VoidCallback reload, // пробрасываем перезагрузку
}) async {
  await showCupertinoModalPopup(
    context: context,
    builder: (sheetContext) => CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Theme.of(sheetContext).brightness,
        primaryColor: ThemeColors.primary,
      ),
      child: CupertinoActionSheet(
        message: Text('Все задачи в корзине ($trashCount) будут удалены'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(context).pop(); // закрыть sheet
              await clearTrash(); // await _taskService.clearTrash(context)
              reload(); // _loadTrashItems()
            },
            child: const Text('Удалить'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Отмена', style: TextStyle(color: ThemeColors.primary)),
        ),
      ),
    ),
  );
}
