import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/deadline.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
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
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    print('🔄 Carregando prazos...');
    try {
      final list = await _repository.loadDeadlines();
      print('📋 Prazos carregados: ${list.length}');
      for (var deadline in list) {
        print('  - ${deadline.title} (${deadline.category}) - ${deadline.date}');
      }
      setState(() {
        _items = list;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar prazos: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onAdd() async {
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
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        backgroundColor: AppColors.amber,
        child: const Icon(Icons.add),
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
                          child: const Center(
                            child: Text(
                              'Nenhum prazo. Toque em + para cadastrar o 1º prazo.\n\nArraste para baixo para atualizar.',
                              style: TextStyle(color: AppColors.onSlate),
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
