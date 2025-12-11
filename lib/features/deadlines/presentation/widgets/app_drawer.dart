import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/domain/entities/user.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _userService = UserService();
  final _storageService = StorageService();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userId = await _storageService.getString('user_id');
      if (userId != null) {
        final user = await _userService.getUser(userId);
        
        // Se usuário foi deletado do Supabase, limpa dados e volta para criação
        if (user == null) {
          await _storageService.clear();
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/create_user',
              (route) => false,
            );
          }
          return;
        }
        
        if (mounted) {
          setState(() {
            _user = user;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Erro ao carregar usuário: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();
    final isAuthenticated = supabaseService.isAuthenticated;

    return Drawer(
      backgroundColor: AppColors.slate,
      child: SafeArea(
        child: Column(
          children: [
            // Header com perfil
            RepaintBoundary(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.blue,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Foto do usuário
                        _user?.photoUrl != null
                            ? CircleAvatar(
                                radius: 40,
                                backgroundImage: _user!.photoUrl!.startsWith('http')
                                    ? NetworkImage(_user!.photoUrl!)
                                    : FileImage(File(_user!.photoUrl!)) as ImageProvider,
                                backgroundColor: AppColors.blue,
                              )
                            : CircleAvatar(
                                radius: 40,
                                backgroundColor: AppColors.blue,
                                child: Text(
                                  _user?.name.substring(0, 1).toUpperCase() ?? 'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),
                        // Nome do usuário
                        Text(
                          _user?.name ?? 'Usuário',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSlate,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Idade do usuário
                        Text(
                          _user != null ? '${_user!.age} anos' : 'Carregando...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSlate.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
              ),
            ),
            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'Perfil',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.settings_outlined,
                    title: 'Configurações',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  const Divider(
                    color: Colors.white24,
                    height: 32,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Ajuda',
                    onTap: () {
                      Navigator.pop(context);
                      _showHelpDialog(context);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'Sobre',
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.description_outlined,
                    title: 'Termos de Uso',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/terms');
                    },
                  ),
                ],
              ),
            ),
            // Footer com versão
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (isAuthenticated)
                    TextButton.icon(
                      onPressed: () async {
                        await supabaseService.signOut();
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Desconectado com sucesso'),
                              backgroundColor: AppColors.blue,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'Sair',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Lembra Vencimentos v0.1.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSlate.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.blue,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.onSlate,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: AppColors.onSlate.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: AppColors.onSlate.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text(
          'Ajuda',
          style: TextStyle(color: AppColors.onSlate),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '''Como usar o app:

1. Adicione documentos clicando no botão +
2. Escolha título, categoria e data de vencimento
3. Receba notificações 1 dia antes do vencimento
4. Marque como concluído ou delete quando renovar

Dicas:
• Mantenha notificações habilitadas
• Sincronize com Supabase para backup
• Revise seus prazos regularmente''',
            style: TextStyle(
              color: AppColors.onSlate,
              height: 1.5,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Entendi',
              style: TextStyle(color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text(
          'Sobre',
          style: TextStyle(color: AppColors.onSlate),
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_today,
                size: 64,
                color: AppColors.blue,
              ),
              SizedBox(height: 16),
              Text(
                'Lembra Vencimentos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSlate,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Versão 0.1.0',
                style: TextStyle(
                  color: AppColors.amber,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'App para gerenciar prazos e vencimentos de documentos importantes como RG, CNH, carteirinhas e mais.',
                style: TextStyle(
                  color: AppColors.onSlate,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '© 2025 - Código Aberto',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSlate,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
