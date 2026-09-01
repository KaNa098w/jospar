// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:uuid/uuid.dart';

// import 'package:jospar/core/models/task_list_items_response.dart';
// import 'task_list_service_i.dart';

// class LocalTaskListService implements ITaskListService {
//   LocalTaskListService({Box? box}) : _box = box ?? Hive.box('task_lists_box');

//   final Box _box;
//   final _uuid = const Uuid();

//   static const _kListsKey = 'lists_json';

//   Future<void> _seedIfNeeded() async {
//     if (_box.containsKey(_kListsKey)) return;

//     await _box.put(_kListsKey, <String, dynamic>{
//       'items': [
//         {
//           'id': 'inbox',
//           'name': 'Inbox',
//           'color_hex': '#4F46E5',
//           'is_hidden': false,
//           'created_at': DateTime.now().toIso8601String(),
//           'updated_at': DateTime.now().toIso8601String(),
//         },
//         {
//           'id': '01990f5c-61fb-7289-a7ca-b229eca4ab5e',
//           'name': 'Работа',
//           'color_hex': '#dc3545',
//           'is_hidden': false,
//           'user_id': null,
//           'device_id': '01990f5c-61cb-70f0-9169-8d97079c25af',
//           'created_at': '2025-09-03 16:35:36',
//           'updated_at': '2025-09-03 16:35:36',
//         },
//         {
//           'id': '01990f5c-621f-7189-9f59-3de20918e247',
//           'name': 'Покупки',
//           'color_hex': '#ffc107',
//           'is_hidden': false,
//           'user_id': null,
//           'device_id': '01990f5c-61cb-70f0-9169-8d97079c25af',
//           'created_at': '2025-09-03 16:35:36',
//           'updated_at': '2025-09-03 16:35:36',
//         },
//         {
//           'id': '01990f5c-6242-7296-89f0-7c290b5d8265',
//           'name': 'Идеи',
//           'color_hex': '#198754',
//           'is_hidden': false,
//           'user_id': null,
//           'device_id': '01990f5c-61cb-70f0-9169-8d97079c25af',
//           'created_at': '2025-09-03 16:35:36',
//           'updated_at': '2025-09-03 16:35:36',
//         },
//         {
//           'id': '019b302f-9f82-722f-8f2b-c560469938e5',
//           'name': 'Дом',
//           'color_hex': '#fff44336',
//           'is_hidden': false,
//           'user_id': null,
//           'device_id': '01990f5c-61cb-70f0-9169-8d97079c25af',
//           'created_at': '2025-12-18 11:39:46',
//           'updated_at': '2025-12-18 11:39:46',
//         },
//       ],
//     });
//   }

//   Map<String, dynamic> _loadJson() {
//     final raw = _box.get(_kListsKey);
//     if (raw is Map) return Map<String, dynamic>.from(raw);
//     return <String, dynamic>{'items': <dynamic>[]};
//   }

//   Future<void> _saveJson(Map<String, dynamic> json) =>
//       _box.put(_kListsKey, json);

//   List<Map<String, dynamic>> _items(Map<String, dynamic> json) {
//     final raw = json['items'];
//     if (raw is List) {
//       return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
//     }
//     return <Map<String, dynamic>>[];
//   }

//   // ---------------- API ----------------

//   @override
//   Future<TaskListItemsResponse> getTaskLists(BuildContext context) async {
//     await _seedIfNeeded();
//     final json = _loadJson();
//     return TaskListItemsResponse.fromJson(json);
//   }

//   @override
//   Future<Map<String, dynamic>> getTaskListById(
//       BuildContext context, String id) async {
//     await _seedIfNeeded();
//     final json = _loadJson();
//     final items = _items(json);

//     final found = items.cast<Map<String, dynamic>?>().firstWhere(
//           (e) => (e?['id']?.toString() ?? '') == id,
//           orElse: () => null,
//         );

//     if (found == null) {
//       throw Exception('Список задач не найден локально: $id');
//     }

//     return found;
//   }

//   @override
//   Future<Map<String, dynamic>> createTaskList(
//     BuildContext context, {
//     required String name,
//     required String colorHex,
//     bool hidden = false,
//     String? userId,
//   }) async {
//     await _seedIfNeeded();
//     final json = _loadJson();
//     final items = _items(json);

//     final now = DateTime.now().toIso8601String();
//     final id = _uuid.v4();

//     final created = <String, dynamic>{
//       'id': id,
//       'name': name,
//       'color_hex': colorHex,
//       'is_hidden': hidden,
//       if (userId != null) 'user_id': userId,
//       'created_at': now,
//       'updated_at': now,
//     };

//     items.insert(0, created);
//     json['items'] = items;
//     await _saveJson(json);

//     return created;
//   }

//   @override
//   Future<Map<String, dynamic>> updateTaskList(
//     BuildContext context, {
//     required String id,
//     String? name,
//     String? colorHex,
//     bool? hidden,
//     String? userId,
//   }) async {
//     await _seedIfNeeded();
//     final json = _loadJson();
//     final items = _items(json);

//     final idx = items.indexWhere((e) => (e['id']?.toString() ?? '') == id);
//     if (idx == -1) throw Exception('Список задач не найден локально: $id');

//     final old = items[idx];
//     final updated = <String, dynamic>{
//       ...old,
//       if (name != null) 'name': name,
//       if (colorHex != null) 'color_hex': colorHex,
//       if (hidden != null) 'is_hidden': hidden,
//       if (userId != null) 'user_id': userId,
//       'updated_at': DateTime.now().toIso8601String(),
//     };

//     items[idx] = updated;
//     json['items'] = items;
//     await _saveJson(json);

//     return updated;
//   }

//   @override
//   Future<void> deleteTaskList(BuildContext context, String id) async {
//     await _seedIfNeeded();
//     final json = _loadJson();
//     final items = _items(json);

//     final before = items.length;
//     items.removeWhere((e) => (e['id']?.toString() ?? '') == id);

//     if (items.length == before) {
//       // Можно молча, но лучше явно:
//       throw Exception('Список задач не найден локально: $id');
//     }

//     json['items'] = items;
//     await _saveJson(json);
//   }
// }
