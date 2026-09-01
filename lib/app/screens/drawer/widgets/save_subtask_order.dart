import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> saveSubtasksOrder(List<Map<String, dynamic>> subtasks) async {
  final prefs = await SharedPreferences.getInstance();
  // сохраняем список как json-строку
  await prefs.setString('subtasks_order', jsonEncode(subtasks));
}

Future<List<Map<String, dynamic>>> loadSubtasksOrder() async {
  final prefs = await SharedPreferences.getInstance();
  final str = prefs.getString('subtasks_order');
  if (str == null) return [];
  final list = jsonDecode(str) as List;
  return list.cast<Map<String, dynamic>>();
}
