import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../models/deadline.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AddDeadlinePage extends StatefulWidget {
  @override
  _AddDeadlinePageState createState() => _AddDeadlinePageState();
}

class _AddDeadlinePageState extends State<AddDeadlinePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  String _category = 'RG';
  DateTime _selected = DateTime.now().add(Duration(days: 7));
  final StorageService _storage = StorageService();

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 5)),
    );
    if (d != null) setState(() => _selected = d);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final id = Uuid().v4();
    final deadline = Deadline(
      id: id,
      title: _titleCtrl.text.trim(),
      category: _category,
      date: _selected,
    );
    await _storage.addDeadline(deadline);

    // agenda notificação local: 1 dia antes às 09:00
    final notifyDate = DateTime(_selected.year, _selected.month, _selected.day)
        .subtract(Duration(days: 1))
        .add(Duration(hours: 9));
    final notifId = id.hashCode & 0x7FFFFFFF;
    await NotificationService().scheduleNotification(
      id: notifId,
      title: 'Vencimento: ${deadline.category}',
      body: '${deadline.title} vence em ${DateFormat.yMMMMd().format(deadline.date)}',
      scheduledDate: notifyDate.isBefore(DateTime.now()) ? DateTime.now().add(Duration(seconds:5)) : notifyDate,
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar prazo'),
        backgroundColor: AppColors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(labelText: 'Descrição (ex: RG de 2ª via)'),
                validator: (v) => (v==null || v.trim().isEmpty) ? 'Informe uma descrição' : null,
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                items: ['RG','CNH','Carteirinha'].map((c) =>
                  DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) { if (v!=null) setState(()=>_category=v); },
                decoration: InputDecoration(labelText: 'Categoria'),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text('Data: ${DateFormat.yMMMMd().format(_selected)}', style: TextStyle(color: AppColors.onSlate))),
                  TextButton(onPressed: _pickDate, child: Text('Escolher'))
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: AppColors.slate,
                ),
                onPressed: _save,
                child: Text('Salvar prazo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
