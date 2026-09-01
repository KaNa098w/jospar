import 'package:flutter/material.dart';
import 'package:jospar/core/models/task_list_response.dart';
import 'package:jospar/core/models/tasks_response.dart';

abstract class ITaskService {
  Future<TaskResponse> getTasks(BuildContext context,
      {int? trash, int? only_parent});
  Future<TaskListResponse> fetchTaskLists(BuildContext context);

  Future<TaskItems> getTaskByHash(BuildContext context, String hash);

  Future<Map<String, dynamic>> createTask(
    BuildContext context, {
    required String name,
    required String date,
    int? position,
    required String taskListId,
    String? parentTaskId,
    String? urgency,
  });

  Future<Map<String, dynamic>> createSubtask(
    BuildContext context, {
    required String name,
    required String parentTaskId,
    required String taskListId,
    String? date,
    int? position,
  });

  Future<Map<String, dynamic>> updateTaskPut(
    BuildContext context, {
    required String id,
    String? name,
    String? note,
    String? notificationTime,
    String? date, // может быть null (очистка даты)
    bool clearDate = false,
    String? urgency,
    int? position,
    String? taskListId,
    String? parentTaskId,
    bool? isCompleted,
    List<Map<String, dynamic>>? children,
  });

  Future<Map<String, dynamic>> updateTask(BuildContext context,
      {required String id});

  Future<Map<String, dynamic>> setTaskCompleted(
    BuildContext context, {
    required String id,
    required bool isCompleted,
  });

  Future<void> deleteTask(BuildContext context, String id);

  Future<void> restoreTask(BuildContext context, {required String id});
  Future<void> clearTrash(BuildContext context);
}
