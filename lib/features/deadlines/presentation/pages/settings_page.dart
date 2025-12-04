import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = true;
  String _notificationTime = '09:00';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _darkMode = prefs.getBool('dark_mode') ?? true;
      _notificationTime = prefs.getString('notification_time') ?? '09:00';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('dark_mode', _darkMode);
    await prefs.setString('notification_time', _notificationTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate,
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: AppColors.blue,
      ),
      body: ListView(
        children: [
          _buildSection('Notificações'),
          SwitchListTile(
            title: const Text(
              'Habilitar Notificações',
              style: TextStyle(color: AppColors.onSlate),
            ),
            subtitle: Text(
              'Receba lembretes sobre vencimentos',
              style: TextStyle(color: AppColors.onSlate.withOpacity(0.6)),
            ),
            value: _notificationsEnabled,
            activeColor: AppColors.blue,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
            },
          ),
          ListTile(
            leading: const Icon(Icons.access_time, color: AppColors.blue),
            title: const Text(
              'Horário das Notificações',
              style: TextStyle(color: AppColors.onSlate),
            ),
            subtitle: Text(
              _notificationTime,
              style: TextStyle(color: AppColors.onSlate.withOpacity(0.6)),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.onSlate),
            onTap: () async {
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
              }
            },
          ),
          const Divider(color: Colors.white24),
          _buildSection('Aparência'),
          SwitchListTile(
            title: const Text(
              'Modo Escuro',
              style: TextStyle(color: AppColors.onSlate),
            ),
            subtitle: Text(
              'Ativar tema escuro',
              style: TextStyle(color: AppColors.onSlate.withOpacity(0.6)),
            ),
            value: _darkMode,
            activeColor: AppColors.blue,
            onChanged: (value) {
              setState(() => _darkMode = value);
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reinicie o app para aplicar o tema'),
                  backgroundColor: AppColors.blue,
                ),
              );
            },
          ),
          const Divider(color: Colors.white24),
          _buildSection('Dados'),
          ListTile(
            leading: const Icon(Icons.cloud_sync, color: AppColors.blue),
            title: const Text(
              'Sincronizar Agora',
              style: TextStyle(color: AppColors.onSlate),
            ),
            subtitle: Text(
              'Forçar sincronização com a nuvem',
              style: TextStyle(color: AppColors.onSlate.withOpacity(0.6)),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.onSlate),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sincronização iniciada...'),
                  backgroundColor: AppColors.blue,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.backup, color: AppColors.amber),
            title: const Text(
              'Fazer Backup',
              style: TextStyle(color: AppColors.onSlate),
            ),
            subtitle: Text(
              'Exportar dados locais',
              style: TextStyle(color: AppColors.onSlate.withOpacity(0.6)),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.onSlate),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Recurso em desenvolvimento'),
                  backgroundColor: AppColors.amber,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              'Resetar App (Dev)',
              style: TextStyle(color: Colors.redAccent),
            ),
            subtitle: Text(
              'Limpar tudo e voltar à tela inicial',
              style: TextStyle(color: AppColors.onSlate.withOpacity(0.6)),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
            onTap: () {
              Navigator.of(context).pushNamed('/clear_data');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.blue,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
