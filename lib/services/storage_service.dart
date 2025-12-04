import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deadline.dart';

class StorageService {
  static const _key = 'deadlines';

  Future<List<Deadline>> loadDeadlines() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? <String>[];
    return raw.map((s) => Deadline.fromJson(s)).toList();
  }

  Future<void> saveDeadlines(List<Deadline> deadlines) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = deadlines.map((d) => d.toJson()).toList();
    await prefs.setStringList(_key, raw);
  }

  Future<void> addDeadline(Deadline d) async {
    final list = await loadDeadlines();
    list.add(d);
    await saveDeadlines(list);
  }

  Future<void> removeDeadline(String id) async {
    final list = await loadDeadlines();
    list.removeWhere((d) => d.id == id);
    await saveDeadlines(list);
  }
}
