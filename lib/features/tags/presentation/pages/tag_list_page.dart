import 'package:flutter/material.dart';
import '../../domain/entities/tag.dart' as domain;
import '../../data/repositories/tag_repository_impl.dart';
import '../widgets/tag_detail_dialog.dart';
import 'tag_edit_page.dart';

/// Tela de listagem de tags (CRUD - Read)
class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  final _repository = TagRepositoryImpl();
  List<domain.Tag> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    try {
      final tags = await _repository.getAll();
      setState(() {
        _tags = tags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar tags: $e')),
        );
      }
    }
  }

  void _showTagDetail(domain.Tag tag) {
    showDialog(
      context: context,
      builder: (context) => TagDetailDialog(
        tag: tag,
        onClose: () => Navigator.pop(context),
        onEdit: () {
          Navigator.pop(context);
          _navigateToEdit(tag);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteTag(tag.id);
        },
      ),
    );
  }

  void _navigateToEdit(domain.Tag tag) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TagEditPage(
          tag: tag,
          repository: _repository,
        ),
      ),
    );

    if (result == true) {
      _loadTags();
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => TagEditPage(
          repository: _repository,
        ),
      ),
    );

    if (result == true) {
      _loadTags();
    }
  }

  Future<void> _deleteTag(String id) async {
    try {
      await _repository.delete(id);
      _loadTags();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tag removida com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover tag: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreate,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tags.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.label_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nenhuma tag cadastrada',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _navigateToCreate,
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Tag'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadTags,
                  child: ListView.builder(
                    itemCount: _tags.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      final color = _parseColor(tag.colorHex);
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.label,
                              color: color,
                            ),
                          ),
                          title: Text(
                            tag.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${tag.deadlineIds.length} prazos vinculados',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: theme.iconTheme.color,
                          ),
                          onTap: () => _showTagDetail(tag),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return Colors.grey;
    }
  }
}
