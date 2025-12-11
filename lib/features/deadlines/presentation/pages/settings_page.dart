import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          _buildSection(context, 'Aparência'),
          SwitchListTile(
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: theme.colorScheme.primary,
            ),
            title: Text(
              'Tema Escuro',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              themeProvider.isDarkMode ? 'Ativado' : 'Desativado',
              style: theme.textTheme.bodyMedium,
            ),
            value: themeProvider.isDarkMode,
            activeThumbColor: theme.colorScheme.primary,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
          Divider(color: theme.dividerColor),
          _buildSection(context, 'Notificações'),
          ListTile(
            leading: Icon(Icons.notifications, color: theme.colorScheme.primary),
            title: Text(
              'Gerenciar Notificações',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Horário, antecedência e preferências',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          Divider(color: theme.dividerColor),
          _buildSection(context, 'Conta'),
          ListTile(
            leading: Icon(Icons.person, color: theme.colorScheme.primary),
            title: Text(
              'Editar Perfil',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Altere seu nome e idade',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          ListTile(
            leading: Icon(Icons.lock, color: theme.colorScheme.primary),
            title: Text(
              'Privacidade',
              style: theme.textTheme.bodyLarge,
            ),
            subtitle: Text(
              'Seus dados são armazenados localmente',
              style: theme.textTheme.bodyMedium,
            ),
            trailing: Icon(Icons.chevron_right, color: theme.iconTheme.color),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacidade'),
                  content: const Text(
                    'Seus dados pessoais e vencimentos são armazenados no seu dispositivo e sincronizados de forma segura com o Supabase. '
                    'Você tem controle total sobre suas informações.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendi'),
                    ),
                  ],
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
              'Resetar App',
              style: TextStyle(color: Colors.redAccent),
            ),
            subtitle: Text(
              'Limpar todos os dados e recomeçar',
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
