class TaskListItemsResponse {
  List<TaskListItems>? items;
  int? total;

  TaskListItemsResponse({this.items, this.total});

  TaskListItemsResponse.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <TaskListItems>[];
      json['items'].forEach((v) {
        items!.add(new TaskListItems.fromJson(v));
      });
    }
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.items != null) {
      data['items'] = this.items!.map((v) => v.toJson()).toList();
    }
    data['total'] = this.total;
    return data;
  }
}

class TaskListItems {
  String? id; // ← исправлено
  String? name;
  String? colorHex;
  bool? hidden;
  String? userId;
  String? createdAt;
  String? updatedAt;

  TaskListItems({
    this.id,
    this.name,
    this.colorHex,
    this.hidden,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  TaskListItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    colorHex = json['color_hex'];
    hidden = json['hidden'] ?? json['is_hidden'];
    userId = json['user_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color_hex': colorHex,
      'hidden': hidden,
      'is_hidden': hidden,
      'user_id': userId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
