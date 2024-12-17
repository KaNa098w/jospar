// widgets/task_section.dart

import 'package:flutter/material.dart';
import 'package:jospar/constants/theme.dart';
import 'package:jospar/services/task_services.dart';
import 'package:jospar/widgets/task_item_widget.dart';
import '../models/task_model.dart';

class TaskSection extends StatefulWidget {
  final String title;
  final String tasksKey;

  const TaskSection({required this.title, required this.tasksKey});

  @override
  _TaskSectionState createState() => _TaskSectionState();
}

class _TaskSectionState extends State<TaskSection>
    with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  List<Task> tasks = [];
  bool isExpanded = false; // Контролирует отображение задач

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final loadedTasks = await _taskService.loadTasks(widget.tasksKey);
    setState(() {
      tasks = loadedTasks;
    });
  }

  Future<void> _saveTasks() async {
    await _taskService.saveTasks(widget.tasksKey, tasks);
  }

  void _toggleTask(int index) {
    setState(() {
      tasks[index] = Task(
        title: tasks[index].title,
        isCompleted: !tasks[index].isCompleted,
      );
    });
    _saveTasks();
  }

  int get completedTaskCount {
    return tasks.where((task) => task.isCompleted).length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded; // Переключаем состояние секции
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.w900, // Толстый шрифт
                  fontSize: 25, // Размер шрифта
                  letterSpacing: -1, // Уменьшаем расстояние между буквами
                  height: 1.2, // Увеличиваем высоту текста
                  color: isExpanded
                      ? ThemeColors.primary // Синий цвет для активной секции
                      : ThemeColors.grey, // Серый цвет для неактивной секции
                ),
              ),
              Text(
                '(${completedTaskCount}/${tasks.length})',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: ThemeColors.primary, // Цвет текста с количеством
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut, // Плавная анимация
          child: isExpanded
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskItem(
                      task: tasks[index],
                      onToggle: () => _toggleTask(index),
                    );
                  },
                )
              : const SizedBox.shrink(), // Пустой виджет, если секция скрыта
        ),
      ],
    );
  }
}
