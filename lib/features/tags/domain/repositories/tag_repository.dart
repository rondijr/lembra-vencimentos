import '../entities/tag.dart';

/// Repository abstrato para operações CRUD de Tag
abstract class TagRepository {
  Future<List<Tag>> getAll();
  Future<Tag?> getById(String id);
  Future<void> create(Tag tag);
  Future<void> update(Tag tag);
  Future<void> delete(String id);
}
