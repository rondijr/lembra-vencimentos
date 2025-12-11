import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';

/// Implementação em memória do TagRepository
class TagRepositoryImpl implements TagRepository {
  final List<Tag> _tags = [];

  @override
  Future<List<Tag>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tags);
  }

  @override
  Future<Tag?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _tags.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> create(Tag tag) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tags.add(tag);
  }

  @override
  Future<void> update(Tag tag) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tags.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      _tags[index] = tag;
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tags.removeWhere((t) => t.id == id);
  }
}
