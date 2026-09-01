import 'package:flutter/material.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:provider/provider.dart';

Color resolveTaskColor(BuildContext context, TaskItems task) {
  final gp = context.read<GlobalProvider>();

  final targetListId = task.taskListId ?? task.taskList?.id;
  final matchingIndex = gp.taskLists.indexWhere(
    (list) => list.id == targetListId,
  );
  final String? hex = matchingIndex >= 0
      ? gp.taskLists[matchingIndex].colorHex
      : task.taskList?.colorHex;
  if (hex == null || hex.isEmpty) return ThemeColors.primary;

  var s = hex.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';

  try {
    return Color(int.parse(s, radix: 16));
  } catch (_) {
    return ThemeColors.primary;
  }
}
