// widgets/task_item.dart

import 'package:flutter/material.dart';
import 'package:jospar/constants/theme.dart';
import '../models/task_model.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const TaskItem({required this.task, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 4.0), // Уменьшаем отступ между задачами
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onToggle, // Переключение состояния задачи при нажатии
            child: Container(
              height: 24, // Размер квадрата
              width: 24,
              decoration: BoxDecoration(
                color: task.isCompleted
                    ? Colors.green
                    : Colors.white, // Цвет квадрата
                border: Border.all(
                  color: task.isCompleted
                      ? Colors.green
                      : Colors.grey, // Цвет границы
                  width: 2.0,
                ),
                borderRadius:
                    BorderRadius.circular(4), // Квадрат с закругленными углами
              ),
              child: task.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 18,
                      color: Colors.white, // Цвет галочки
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12), // Отступ между квадратом и текстом
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: task.isCompleted ? Colors.grey : Colors.black,
                decoration:
                    task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
