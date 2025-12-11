import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/categories.dart';
import '../../domain/entities/deadline.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/user_service.dart';
import '../../data/repositories/deadlines_sync_repository.dart';
import 'add_deadline_page.dart';
import '../widgets/deadline_list_item.dart';
import '../widgets/app_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DeadlinesSyncRepository _repository;
  List<Deadline> _items = [];
  List<Deadline> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _repository = DeadlinesSyncRepository(
      storageService: StorageService(),
      supabaseService: SupabaseService(),
    );
    _load();
    _checkUserExists();
  }

  Future<void> _checkUserExists() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId != null) {
      final userService = UserService();
      final user = await userService.getUser(userId);

      // Se usuário foi deletado do Supabase, limpa dados e volta para termos
      if (user == null) {
        await prefs.clear();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/terms',
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _load() async {
    // Verifica se usuário ainda existe antes de carregar
    await _checkUserExists();
    if (!mounted) return;

    setState(() => _isLoading = true);
    print('🔄 Carregando prazos...');
    try {
      final list = await _repository.loadDeadlines();
      print('📋 Prazos carregados: ${list.length}');
      for (var deadline in list) {
        print(
            '  - ${deadline.title} (${deadline.category}) - ${deadline.date}');
      }
      if (!mounted) return;
      setState(() {
        _items = list;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar prazos: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    var filtered = _items;

    // Filtro por categoria
    if (_selectedCategoryFilter != null) {
      final category = Categories.getById(_selectedCategoryFilter!);
      filtered = filtered.where((item) {
        return category.subcategories.contains(item.category);
      }).toList();
    }

    // Filtro por busca
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Ordenar por data
    filtered.sort((a, b) => a.date.compareTo(b.date));

    _filteredItems = filtered;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onCategoryFilterChanged(String? categoryId) {
    setState(() {
      _selectedCategoryFilter = categoryId;
      _applyFilters();
    });
  }

  void _onAdd() async {
    // Verifica se usuário ainda existe antes de adicionar
    await _checkUserExists();
    if (!mounted) return;

    final added = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddDeadlinePage()),
    );
    if (added == true) _load();
  }

  Future<void> _remove(String id) async {
    await _repository.removeDeadline(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Lembra Vencimentos'),
        backgroundColor: AppColors.blue,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: _onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar prazos...',
                hintStyle:
                    TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () => _onSearchChanged(''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: RepaintBoundary(
        child: FloatingActionButton(
          onPressed: _onAdd,
          backgroundColor: AppColors.amber,
          child: const Icon(Icons.add),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.blue,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.blue,
                ),
              )
            : Column(
                children: [
                  // Filtro de categorias
                  _buildCategoryFilter(),
                  // Estatísticas
                  _buildStats(),
                  // Lista de prazos
                  Expanded(child: _buildDeadlinesList()),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          _buildCategoryChip(null, 'Todos', Icons.grid_view, Colors.grey),
          ...Categories.all.map((cat) => _buildCategoryChip(
                cat.id,
                cat.name,
                cat.icon,
                cat.color,
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      String? id, String label, IconData icon, Color color) {
    final isSelected = _selectedCategoryFilter == id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (_) => _onCategoryFilterChanged(id),
        backgroundColor: color.withValues(alpha: 0.1),
        selectedColor: color,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final next7Days = today.add(const Duration(days: 7));
    final next30Days = today.add(const Duration(days: 30));

    final vencidosHoje = _filteredItems.where((d) {
      final dDate = DateTime(d.date.year, d.date.month, d.date.day);
      return dDate.isAtSameMomentAs(today);
    }).length;

    final proximos7 = _filteredItems.where((d) {
      final dDate = DateTime(d.date.year, d.date.month, d.date.day);
      return dDate.isAfter(today) && dDate.isBefore(next7Days);
    }).length;

    final proximos30 = _filteredItems.where((d) {
      final dDate = DateTime(d.date.year, d.date.month, d.date.day);
      return dDate.isAfter(today) && dDate.isBefore(next30Days);
    }).length;

    if (_filteredItems.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('Hoje', vencidosHoje, Colors.red),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('7 dias', proximos7, Colors.orange),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard('30 dias', proximos30, Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlinesList() {
    if (_filteredItems.isEmpty &&
        _searchQuery.isEmpty &&
        _selectedCategoryFilter == null) {
      return LayoutBuilder(
        builder: (context, constraints) => ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Text(
                  'Nenhum prazo. Toque em + para cadastrar o 1º prazo.\n\nArraste para baixo para atualizar.',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nenhum prazo encontrado',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategoryFilter = null;
                  _applyFilters();
                });
              },
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _filteredItems.length,
      itemBuilder: (_, i) {
        final d = _filteredItems[i];
        return DeadlineListItem(
          deadline: d,
          onDelete: () => _remove(d.id),
        );
      },
    );
  }
}
