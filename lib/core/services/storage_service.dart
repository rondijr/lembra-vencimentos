import 'package:shared_preferences/shared_preferences.dart';
import '../../features/deadlines/domain/entities/deadline.dart';

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
    print('📦 Prazos existentes antes de adicionar: ${list.length}');
    list.add(d);
    print('📦 Prazos após adicionar: ${list.length}');
    await saveDeadlines(list);
    print('💾 Prazo salvo no SharedPreferences');
  }

  Future<void> removeDeadline(String id) async {
    final list = await loadDeadlines();
    list.removeWhere((d) => d.id == id);
    await saveDeadlines(list);
  }

  // Métodos genéricos para armazenar strings
  Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
