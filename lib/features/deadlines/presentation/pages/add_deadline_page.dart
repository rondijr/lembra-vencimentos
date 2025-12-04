import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/app_colors.dart';
import '../../domain/entities/deadline.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/repositories/deadlines_sync_repository.dart';

class AddDeadlinePage extends StatefulWidget {
  const AddDeadlinePage({Key? key}) : super(key: key);

  @override
  State<AddDeadlinePage> createState() => _AddDeadlinePageState();
}

class _AddDeadlinePageState extends State<AddDeadlinePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String _category = 'RG';
  DateTime _selected = DateTime.now().add(const Duration(days: 7));
  late final DeadlinesSyncRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = DeadlinesSyncRepository(
      storageService: StorageService(),
      supabaseService: SupabaseService(),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (d != null) setState(() => _selected = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      final id = const Uuid().v4();
      final deadline = Deadline(
        id: id,
        title: _titleCtrl.text.trim(),
        category: _category,
        date: _selected,
      );
      
      // Salva o prazo (local + Supabase)
      await _repository.addDeadline(deadline);
      print('✅ Prazo salvo: ${deadline.title} - ${deadline.category} - ${deadline.date}');

      // agenda notificação local: 1 dia antes às 09:00
      final notifyDate = DateTime(_selected.year, _selected.month, _selected.day)
        .subtract(const Duration(days: 1))
        .add(const Duration(hours: 9));
      final notifId = id.hashCode & 0x7FFFFFFF;
      await NotificationService().scheduleNotification(
        id: notifId,
        title: 'Vencimento: ${deadline.category}',
        body: '${deadline.title} vence em ${DateFormat.yMMMMd().format(deadline.date)}',
        scheduledDate: notifyDate.isBefore(DateTime.now()) ? DateTime.now().add(const Duration(seconds:5)) : notifyDate,
      );
      print('✅ Notificação agendada para: $notifyDate');

      if (!mounted) return;
      
      // Mostra feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Prazo "${deadline.title}" salvo com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Volta para tela anterior e indica que foi salvo
      Navigator.of(context).pop(true);
    } catch (e) {
      print('❌ Erro ao salvar prazo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate,
      appBar: AppBar(
        title: const Text('Cadastrar Prazo', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.blue,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone visual
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Campo de descrição
              const Text(
                'Descrição',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                style: const TextStyle(color: AppColors.onSlate, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Ex: RG de 2ª via',
                  hintStyle: TextStyle(color: AppColors.onSlate.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.blue, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Informe uma descrição' : null,
              ),
              const SizedBox(height: 24),
              
              // Campo de categoria
              const Text(
                'Categoria',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                dropdownColor: AppColors.slate,
                style: const TextStyle(color: AppColors.onSlate, fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.blue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'RG',
                    child: Row(
                      children: [
                        Icon(Icons.badge, color: AppColors.blue, size: 20),
                        SizedBox(width: 12),
                        Text('RG'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'CNH',
                    child: Row(
                      children: [
                        Icon(Icons.directions_car, color: AppColors.blue, size: 20),
                        SizedBox(width: 12),
                        Text('CNH'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Carteirinha',
                    child: Row(
                      children: [
                        Icon(Icons.card_membership, color: AppColors.blue, size: 20),
                        SizedBox(width: 12),
                        Text('Carteirinha'),
                      ],
                    ),
                  ),
                ],
                onChanged: (v) { if (v!=null) setState(()=>_category=v); },
              ),
              const SizedBox(height: 24),
              
              // Campo de data
              const Text(
                'Data de Vencimento',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: AppColors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selected),
                              style: const TextStyle(
                                color: AppColors.onSlate,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat.EEEE('pt_BR').format(_selected),
                              style: TextStyle(
                                color: AppColors.onSlate.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Botão de salvar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: AppColors.onSlate,
                    elevation: 4,
                    shadowColor: AppColors.blue.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _save,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Salvar Prazo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
