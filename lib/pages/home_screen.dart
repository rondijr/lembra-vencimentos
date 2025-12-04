import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../models/deadline.dart';
import '../services/storage_service.dart';
import 'add_deadline_page.dart';
import '../widgets/deadline_list_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Deadline> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _storage.loadDeadlines();
    setState(() => _items = list);
  }

  void _onAdd() async {
    final added = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddDeadlinePage()),
    );
    if (added == true) _load();
  }

  Future<void> _remove(String id) async {
    await _storage.removeDeadline(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lembra Vencimentos'),
        backgroundColor: AppColors.blue,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        backgroundColor: AppColors.amber,
        child: Icon(Icons.add, color: AppColors.slate),
      ),
      body: _items.isEmpty
          ? Center(
              child: Text(
                'Nenhum prazo. Toque em + para cadastrar o 1º prazo.',
                style: TextStyle(color: AppColors.onSlate),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final d = _items[i];
                return DeadlineListItem(
                  deadline: d,
                  onDelete: () => _remove(d.id),
                );
              },
            ),
    );
  }
}
