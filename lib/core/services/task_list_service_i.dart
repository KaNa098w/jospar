import 'package:flutter/material.dart';
import 'package:jospar/core/models/task_list_items_response.dart';

abstract class ITaskListService {
  Future<Map<String, dynamic>> createTaskList(
    BuildContext context, {
    required String name,
    required String colorHex,
    bool hidden = false,
    String? userId,
  });

  Future<TaskListItemsResponse> getTaskLists(BuildContext context);

  Future<Map<String, dynamic>> getTaskListById(BuildContext context, String id);

  Future<Map<String, dynamic>> updateTaskList(
    BuildContext context, {
    required String id,
    String? name,
    String? colorHex,
    bool? hidden,
    String? userId,
  });

  Future<void> deleteTaskList(BuildContext context, String id);
}
