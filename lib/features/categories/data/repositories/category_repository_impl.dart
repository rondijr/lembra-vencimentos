import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

/// Implementação em memória do CategoryRepository
/// Para demonstração de CRUD sem banco de dados
class CategoryRepositoryImpl implements CategoryRepository {
  // Dados mockados em memória
  final List<Category> _categories = [];

  @override
  Future<List<Category>> getAll() async {
    // Simula delay de rede
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_categories);
  }

  @override
  Future<Category?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> create(Category category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories.add(category);
  }

  @override
  Future<void> update(Category category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _categories.removeWhere((c) => c.id == id);
  }
}
