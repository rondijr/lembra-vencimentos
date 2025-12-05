import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/theme_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
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
      _notificationTime = prefs.getString('notification_time') ?? '09:00';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setString('notification_time', _notificationTime);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        children: [
          _buildSection(context, 'Notificações'),
          SwitchListTile(
            title: Text(
              'Habilitar Notificações',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Receba lembretes sobre vencimentos',
              style: theme.textTheme.bodyMedium,
            ),
            value: _notificationsEnabled,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveSettings();
            },
          ),
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
          Divider(color: theme.dividerColor),
          _buildSection(context, 'Aparência'),
          SwitchListTile(
            title: Text(
              themeProvider.isDarkMode ? 'Mudar para Tema Claro' : 'Mudar para Tema Escuro',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              themeProvider.isDarkMode ? 'Ativar tema claro' : 'Ativar tema escuro',
              style: theme.textTheme.bodyMedium,
            ),
            value: themeProvider.isDarkMode,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) {
              themeProvider.toggleTheme();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tema ${value ? "escuro" : "claro"} ativado'),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
          ),
          Divider(color: theme.dividerColor),
          _buildSection(context, 'Dados'),
          ListTile(
            leading: Icon(Icons.backup, color: theme.colorScheme.secondary),
            title: Text(
              'Fazer Backup',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Exportar dados locais',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Recurso em desenvolvimento'),
                  backgroundColor: theme.colorScheme.secondary,
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
              style: theme.textTheme.bodyMedium,
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
}
