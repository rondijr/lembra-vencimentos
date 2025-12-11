import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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

  // Método de teste para popular todas as categorias
  Future<void> _populateTestData() async {
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar Dados de Teste'),
        content: const Text('Isso criará 48 prazos de teste, um para cada subcategoria. Continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _isLoading = true);
    
    try {
      final uuid = Uuid();
      int count = 0;
      int daysOffset = 1;
      
      for (var category in Categories.all) {
        for (var subcategory in category.subcategories) {
          final deadline = Deadline(
            id: uuid.v4(),
            title: 'Teste $subcategory',
            category: subcategory,
            date: DateTime.now().add(Duration(days: daysOffset)),
          );
          
          await _repository.addDeadline(deadline);
          count++;
          daysOffset += 2;
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ $count prazos de teste criados!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAdd,
        backgroundColor: AppColors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Novo Prazo'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.blue,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.blue,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    // Header moderno
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Menu e título
                            Row(
                              children: [
                                Builder(
                                  builder: (context) => Container(
                                    decoration: BoxDecoration(
                                      color: textColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.menu, color: textColor),
                                      onPressed: () =>
                                          Scaffold.of(context).openDrawer(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onLongPress: _populateTestData,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lembra',
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            height: 1,
                                          ),
                                        ),
                                        Text(
                                          'Vencimentos',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w300,
                                            color: AppColors.blue,
                                            height: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Barra de busca moderna
                            Container(
                              decoration: BoxDecoration(
                                color: textColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: textColor.withValues(alpha: 0.1),
                                ),
                              ),
                              child: TextField(
                                onChanged: _onSearchChanged,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText: 'Buscar prazos...',
                                  hintStyle: TextStyle(
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.clear,
                                              color: textColor),
                                          onPressed: () => _onSearchChanged(''),
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Filtro de categorias
                    SliverToBoxAdapter(child: _buildCategoryFilter(textColor)),
                    // Estatísticas
                    SliverToBoxAdapter(child: _buildStats(textColor)),
                    // Lista de prazos
                    _buildDeadlinesList(textColor),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categorias',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip(
                    null, 'Todos', Icons.grid_view, Colors.grey, textColor),
                ...Categories.all.map((cat) => _buildCategoryChip(
                      cat.id,
                      cat.name,
                      cat.icon,
                      cat.color,
                      textColor,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
      String? id, String label, IconData icon, Color color, Color textColor) {
    final isSelected = _selectedCategoryFilter == id;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () => _onCategoryFilterChanged(id),
        child: Container(
          width: 85,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [color, color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isSelected ? Colors.white : color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : textColor.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(Color textColor) {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    'Hoje', vencidosHoje, Colors.red, Icons.today, textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('7 dias', proximos7, Colors.orange,
                    Icons.calendar_today, textColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('30 dias', proximos30, AppColors.blue,
                    Icons.event, textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, int count, Color color, IconData icon, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlinesList(Color textColor) {
    if (_filteredItems.isEmpty &&
        _searchQuery.isEmpty &&
        _selectedCategoryFilter == null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_note,
                  size: 80,
                  color: textColor.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 24),
                Text(
                  'Nenhum prazo cadastrado',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toque em "Novo Prazo" para começar',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: textColor.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum prazo encontrado',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategoryFilter = null;
                    _applyFilters();
                  });
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpar filtros'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final d = _filteredItems[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DeadlineListItem(
                deadline: d,
                onDelete: () => _remove(d.id),
              ),
            );
          },
          childCount: _filteredItems.length,
        ),
      ),
    );
  }
}
