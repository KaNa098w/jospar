class TaskItem {
  final String id;
  final String name;
  final String? note;
  final String? notificationTime;
  final String? date;
  final String? urgency;
  final int position;
  final String? taskListId;
  final String? parentTaskId;
  final String userId;
  final String? deviceId;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String hash;
  final dynamic taskList; // можешь заменить на модель если появится структура
  final List<TaskItem> children;

  TaskItem({
    required this.id,
    required this.name,
    this.note,
    this.notificationTime,
    this.date,
    this.urgency,
    required this.position,
    this.taskListId,
    this.parentTaskId,
    required this.userId,
    this.deviceId,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.hash,
    this.taskList,
    required this.children,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String,
      name: json['name'] as String,
      note: json['note'] as String?,
      notificationTime: json['notification_time'] as String?,
      date: json['date'] as String?,
      urgency: json['urgency'] as String?,
      position: json['position'] as int,
      taskListId: json['task_list_id'] as String?,
      parentTaskId: json['parent_task_id'] as String?,
      userId: json['user_id'] as String,
      deviceId: json['device_id'] as String?,
      isCompleted: json['is_completed'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
      hash: json['hash'] as String,
      taskList: json['task_list'],
      children: (json['children'] as List<dynamic>)
          .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'notification_time': notificationTime,
      'date': date,
      'urgency': urgency,
      'position': position,
      'task_list_id': taskListId,
      'parent_task_id': parentTaskId,
      'user_id': userId,
      'device_id': deviceId,
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'hash': hash,
      'task_list': taskList,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
