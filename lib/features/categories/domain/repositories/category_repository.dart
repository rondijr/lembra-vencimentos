import '../entities/category.dart';

/// Repository abstrato para operações CRUD de Category
abstract class CategoryRepository {
  Future<List<Category>> getAll();
  Future<Category?> getById(String id);
  Future<void> create(Category category);
  Future<void> update(Category category);
  Future<void> delete(String id);
}
