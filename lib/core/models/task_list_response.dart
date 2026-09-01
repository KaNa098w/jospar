class TaskListResponse {
  final List<TaskItem>? items;
  final int? count;

  TaskListResponse({this.items, this.count});

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((e) => e.toJson()).toList(),
      'count': count,
    };
  }
}

class TaskItem {
  final String? id;
  final String? name;
  final String? note;
  final String? notificationTime;
  final String? date;
  final String? urgency;
  final int? position;
  final String? taskListId;
  final String? parentTaskId;
  final String? createdAt;
  final String? updatedAt;

  TaskItem({
    this.id,
    this.name,
    this.note,
    this.notificationTime,
    this.date,
    this.urgency,
    this.position,
    this.taskListId,
    this.parentTaskId,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as String?,
      name: json['name'] as String?,
      note: json['note'] as String?,
      notificationTime: json['notification_time'] as String?,
      date: json['date'] as String?,
      urgency: json['urgency'] as String?,
      position: json['position'] as int?,
      taskListId: json['task_list_id'] as String?,
      parentTaskId: json['parent_task_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
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
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
