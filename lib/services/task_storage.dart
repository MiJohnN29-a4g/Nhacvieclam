import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskStorage {
  static const _key = 'tasks';

  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    try {
      return Task.decodeList(data);
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Task.encodeList(tasks));
  }
}