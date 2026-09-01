import 'package:jospar/core/models/task_list_items_response.dart';

class TaskResponse {
  List<TaskItems>? items;
  int? count;

  TaskResponse({this.items, this.count});

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    return TaskResponse(
      items: (json['items'] as List<dynamic>?)
          ?.map((v) => TaskItems.fromJson(v as Map<String, dynamic>))
          .toList(),
      count: json['count'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (items != null) 'items': items!.map((v) => v.toJson()).toList(),
      'count': count,
    };
  }
}

class TaskItems {
  String? id;
  String? name;
  String? note;
  String? notificationTime;
  String? date;
  String? urgency;
  int? position;
  String? taskListId;
  String? parentTaskId;
  String? createdAt;
  String? updatedAt;
  bool? isCompleted;
  String? hash;
  bool? isShared;
  String? collaborationRole;
  List<Map<String, dynamic>>? collaborators;
  bool? trashed;
  int? version;
  String? deletedAt;

  /// ВАЖНО: один объект, не список
  TaskListItems? taskList;

  /// Дочерние задачи (рекурсивная модель)
  List<TaskItems>? children;

  TaskItems({
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
    this.isCompleted,
    this.taskList,
    this.children,
    this.hash,
    this.isShared,
    this.collaborationRole,
    this.collaborators,
    this.trashed,
    this.version,
    this.deletedAt,
  });

  factory TaskItems.fromJson(Map<String, dynamic> json) {
    return TaskItems(
      id: json['id'] as String?,
      name: json['name'] as String?,
      note: json['note'] as String?,
      notificationTime: json['notification_time'] as String?,
      date: json['date'] as String?,
      urgency: json['urgency'] as String?,
      position: json['position'] as int?,
      taskListId: json['task_list_id'] as String?,
      parentTaskId: json['parent_task_id'] as String?,
      hash: json['hash'] as String?,
      isShared: json['is_shared'] as bool?,
      collaborationRole: json['collaboration_role'] as String?,
      collaborators: (json['collaborators'] as List<dynamic>?)
          ?.whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList(),
      trashed: json['trashed'] as bool?,
      version: json['version'] as int?,
      deletedAt: json['deleted_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      isCompleted: json['is_completed'] as bool?,
      taskList: json['task_list'] != null
          ? TaskListItems.fromJson(json['task_list'] as Map<String, dynamic>)
          : null,
      children: (json['children'] as List<dynamic>?)
          ?.map((v) => TaskItems.fromJson(v as Map<String, dynamic>))
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
      'hash': hash,
      'is_shared': isShared,
      'collaboration_role': collaborationRole,
      'collaborators': collaborators,
      'trashed': trashed,
      'version': version,
      'deleted_at': deletedAt,
      'parent_task_id': parentTaskId,
      'created_at': createdAt, // ← если не нужно отправлять — убери
      'updated_at': updatedAt, // ← если не нужно отправлять — убери
      'is_completed': isCompleted,
      if (taskList != null)
        'task_list': taskList!.toJson(), // объект, не массив
      if (children != null)
        'children': children!.map((v) => v.toJson()).toList(),
    };
  }

  DateTime? get createdAtDt =>
      createdAt != null ? DateTime.parse(createdAt!) : null;
  DateTime? get updatedAtDt =>
      updatedAt != null ? DateTime.parse(updatedAt!) : null;
}
