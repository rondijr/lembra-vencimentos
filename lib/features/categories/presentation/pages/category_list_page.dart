import 'package:flutter/material.dart';
import '../../domain/entities/category.dart' as domain;
import '../../data/repositories/category_repository_impl.dart';
import '../widgets/category_detail_dialog.dart';
import 'category_edit_page.dart';

/// Tela de listagem de categorias (CRUD - Read)
class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final _repository = CategoryRepositoryImpl();
  List<domain.Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _repository.getAll();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  void _showCategoryDetail(domain.Category category) {
    showDialog(
      context: context,
      builder: (context) => CategoryDetailDialog(
        category: category,
        onClose: () => Navigator.pop(context),
        onEdit: () {
          Navigator.pop(context);
          _navigateToEdit(category);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteCategory(category.id);
        },
      ),
    );
  }

  void _navigateToEdit(domain.Category category) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryEditPage(
          category: category,
          repository: _repository,
        ),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryEditPage(
          repository: _repository,
        ),
      ),
    );

    if (result == true) {
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await _repository.delete(id);
      _loadCategories();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoria removida com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover categoria: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorias'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma categoria cadastrada',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _navigateToCreate,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Categoria'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCategories,
                  child: ListView.builder(
                    itemCount: _categories.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Color(category.colorValue).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              IconData(category.iconCode, fontFamily: 'MaterialIcons'),
                              color: Color(category.colorValue),
                            ),
                          ),
                          title: Text(
                            category.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${category.subcategories.length} subcategorias',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: theme.iconTheme.color,
                          ),
                          onTap: () => _showCategoryDetail(category),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
