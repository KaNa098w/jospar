// services/task_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task_model.dart';

class TaskService {
  static const String _tasksKey = 'tasks_key';

  Future<List<Task>> loadTasks(String tab) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('$tab-$_tasksKey');
    if (tasksJson != null) {
      final List<dynamic> decoded = json.decode(tasksJson);
      return decoded.map((task) => Task.fromJson(task)).toList();
    }
    return [];
  }

  Future<void> saveTasks(String tab, List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(tasks.map((task) => task.toJson()).toList());
    await prefs.setString('$tab-$_tasksKey', tasksJson);
  }
}
