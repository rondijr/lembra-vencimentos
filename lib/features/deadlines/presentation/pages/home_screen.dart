import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';
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
  bool _isLoading = true;

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
      
      // Se usuário foi deletado do Supabase, limpa dados e volta para criação
      if (user == null) {
        await prefs.clear();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/create_user',
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
        print('  - ${deadline.title} (${deadline.category}) - ${deadline.date}');
      }
      if (!mounted) return;
      setState(() {
        _items = list;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar prazos: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
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
            : _items.isEmpty
                ? LayoutBuilder(
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
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (_, i) {
                      final d = _items[i];
                      return DeadlineListItem(
                        deadline: d,
                        onDelete: () => _remove(d.id),
                      );
                    },
                  ),
      ),
    );
  }
}
