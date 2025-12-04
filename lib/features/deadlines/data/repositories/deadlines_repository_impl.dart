import '../../domain/entities/deadline.dart';
import '../../domain/repositories/deadlines_repository.dart';
import '../../../../core/services/storage_service.dart';

/// Implementação concreta do repositório de Deadlines.
///
/// Usa StorageService para persistência local via SharedPreferences.
/// Esta implementação é desacoplada da UI e pode ser testada isoladamente.
class DeadlinesRepositoryImpl implements DeadlinesRepository {
  final StorageService _storage;

  DeadlinesRepositoryImpl(this._storage);

  @override
  Future<List<Deadline>> loadFromCache() async {
    return await _storage.loadDeadlines();
  }

  @override
  Future<List<Deadline>> listAll() async {
    final all = await loadFromCache();
    // Ordena por data (mais próximos primeiro)
    all.sort((a, b) => a.date.compareTo(b.date));
    return all;
  }

  @override
  Future<void> add(Deadline deadline) async {
    await _storage.addDeadline(deadline);
  }

  @override
  Future<void> remove(String id) async {
    await _storage.removeDeadline(id);
  }

  @override
  Future<Deadline?> getById(String id) async {
    final all = await loadFromCache();
    try {
      return all.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Deadline>> listUpcoming() async {
    final all = await listAll();
    final now = DateTime.now();
    final upcoming = all.where((d) {
      final daysUntil = d.date.difference(now).inDays;
      return daysUntil >= 0 && daysUntil <= 7;
    }).toList();
    return upcoming;
  }
}
