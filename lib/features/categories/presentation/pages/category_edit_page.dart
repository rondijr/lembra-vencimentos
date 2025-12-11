import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/category.dart' as domain;
import '../../domain/repositories/category_repository.dart';

/// Tela de criação/edição de categoria (CRUD - Create/Update)
class CategoryEditPage extends StatefulWidget {
  final domain.Category? category;
  final CategoryRepository repository;

  const CategoryEditPage({
    super.key,
    this.category,
    required this.repository,
  });

  @override
  State<CategoryEditPage> createState() => _CategoryEditPageState();
}

class _CategoryEditPageState extends State<CategoryEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _subcategoryController;
  late List<String> _subcategories;
  late int _selectedIconCode;
  late int _selectedColorValue;
  bool _isSaving = false;

  // Ícones disponíveis para seleção
  final List<IconData> _availableIcons = [
    Icons.category,
    Icons.bookmark,
    Icons.label,
    Icons.folder,
    Icons.star,
    Icons.favorite,
    Icons.shopping_cart,
    Icons.work,
    Icons.school,
    Icons.home,
  ];

  // Cores disponíveis para seleção
  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _subcategoryController = TextEditingController();
    _subcategories = List.from(widget.category?.subcategories ?? []);
    _selectedIconCode = widget.category != null ? int.parse(widget.category!.iconCode) : Icons.category.codePoint;
    _selectedColorValue = widget.category?.colorValue ?? Colors.blue.value;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_subcategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos uma subcategoria')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final category = domain.Category(
        id: widget.category?.id ?? const Uuid().v4(),
        name: _nameController.text,
        iconCode: _selectedIconCode.toString(),
        colorValue: _selectedColorValue,
        subcategories: _subcategories,
        createdAt: widget.category?.createdAt ?? DateTime.now(),
        updatedAt: widget.category != null ? DateTime.now() : null,
      );

      if (widget.category == null) {
        await widget.repository.create(category);
      } else {
        await widget.repository.update(category);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    }
  }

  void _addSubcategory() {
    final text = _subcategoryController.text.trim();
    if (text.isEmpty) return;
    if (_subcategories.contains(text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subcategoria já existe')),
      );
      return;
    }

    setState(() {
      _subcategories.add(text);
      _subcategoryController.clear();
    });
  }

  void _removeSubcategory(String subcategory) {
    setState(() {
      _subcategories.remove(subcategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria'),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Nome
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nome é obrigatório';
                      }
                      if (value.trim().length > 50) {
                        return 'Nome deve ter no máximo 50 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Seletor de ícone
                  Text(
                    'Ícone',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableIcons.map((icon) {
                      final isSelected = icon.codePoint == _selectedIconCode;
                      return InkWell(
                        onTap: () => setState(() => _selectedIconCode = icon.codePoint),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary.withOpacity(0.2)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? theme.colorScheme.primary : Colors.grey[600],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Seletor de cor
                  Text(
                    'Cor',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableColors.map((color) {
                      final isSelected = color.value == _selectedColorValue;
                      return InkWell(
                        onTap: () => setState(() => _selectedColorValue = color.value),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Subcategorias
                  Text(
                    'Subcategorias',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subcategoryController,
                          decoration: const InputDecoration(
                            labelText: 'Nova Subcategoria',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addSubcategory(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _addSubcategory,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_subcategories.isEmpty)
                    Text(
                      'Nenhuma subcategoria adicionada',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _subcategories
                          .map(
                            (sub) => Chip(
                              label: Text(sub),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeSubcategory(sub),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 32),

                  // Botão salvar
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: Text(isEditing ? 'SALVAR ALTERAÇÕES' : 'CRIAR CATEGORIA'),
                  ),
                ],
              ),
            ),
    );
  }
}
