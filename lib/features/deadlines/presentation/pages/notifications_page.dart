import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notificationsEnabled = true;
  String _notificationTime = '09:00';
  int _daysBeforeNotification = 1;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _notificationTime = prefs.getString('notification_time') ?? '09:00';
      _daysBeforeNotification = prefs.getInt('days_before_notification') ?? 1;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('notification_time', _notificationTime);
    await prefs.setInt('days_before_notification', _daysBeforeNotification);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: ListView(
        children: [
          _buildSection(context, 'Configurações Gerais'),
          SwitchListTile(
            secondary: Icon(Icons.notifications, color: theme.colorScheme.primary),
            title: Text(
              'Habilitar Notificações',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Receba lembretes sobre vencimentos',
              style: theme.textTheme.bodyMedium,
            ),
            value: _notificationsEnabled,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 'Notificações ativadas' : 'Notificações desativadas'),
                  backgroundColor: theme.colorScheme.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          Divider(color: theme.dividerColor),
          _buildSection(context, 'Horário'),
          ListTile(
            leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
            title: Text(
              'Horário das Notificações',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              _notificationTime,
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            enabled: _notificationsEnabled,
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: int.parse(_notificationTime.split(':')[0]),
                  minute: int.parse(_notificationTime.split(':')[1]),
                ),
              );
              if (time != null) {
                setState(() {
                  _notificationTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                });
                _saveSettings();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Horário atualizado para $_notificationTime'),
                    backgroundColor: theme.colorScheme.primary,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          Divider(color: theme.dividerColor),
          _buildSection(context, 'Antecedência'),
          ListTile(
            leading: Icon(Icons.calendar_today, color: theme.colorScheme.primary),
            title: Text(
              'Notificar com Antecedência',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              '$_daysBeforeNotification ${_daysBeforeNotification == 1 ? "dia" : "dias"} antes do vencimento',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            enabled: _notificationsEnabled,
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              
              final result = await showDialog<int>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Dias de Antecedência'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildRadioOption(context, 'No mesmo dia', 0),
                      _buildRadioOption(context, '1 dia antes', 1),
                      _buildRadioOption(context, '2 dias antes', 2),
                      _buildRadioOption(context, '3 dias antes', 3),
                      _buildRadioOption(context, '7 dias antes (1 semana)', 7),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              );
              
              if (result != null) {
                setState(() => _daysBeforeNotification = result);
                _saveSettings();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Antecedência atualizada para $result ${result == 1 ? "dia" : "dias"}'),
                    backgroundColor: theme.colorScheme.primary,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Como Funciona',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Você receberá uma notificação no horário configurado, com a antecedência escolhida antes de cada vencimento.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Exemplo: Com 1 dia de antecedência às 09:00, você será notificado no dia anterior ao vencimento.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildRadioOption(BuildContext context, String title, int value) {
    final isSelected = _daysBeforeNotification == value;
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title)),
          ],
        ),
      ),
    );
  }
}
