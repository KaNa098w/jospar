// models/task_model.dart

class Task {
  final String title;
  final bool isCompleted;

  Task({required this.title, this.isCompleted = false});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}
