import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/domain/entities/user.dart';
import 'user_avatar_widget.dart';

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
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Drawer(
      backgroundColor: bgColor,
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
                        // Avatar com foto do usuário (substituindo iniciais)
                        UserAvatarWidget(
                          userName: _user?.name ?? 'Usuário',
                          radius: 40,
                          showEditButton: true,
                          onAvatarChanged: () {
                            // Recarrega drawer para atualizar foto
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 16),
                        // Nome do usuário
                        Text(
                          _user?.name ?? 'Usuário',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Idade do usuário
                        Text(
                          _user != null ? '${_user!.age} anos' : 'Carregando...',
                          style: TextStyle(
                            fontSize: 12,
                            color: textColor.withValues(alpha: 0.7),
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
                  const Divider(
                    color: Colors.white24,
                    height: 32,
                    indent: 16,
                    endIndent: 16,
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.category_outlined,
                    title: 'Categorias',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/categories');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.label_outlined,
                    title: 'Tags',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/tags');
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
                      color: textColor.withValues(alpha: 0.5),
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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.blue,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: textColor.withValues(alpha: 0.3),
      ),
      onTap: onTap,
    );
  }

  void _showHelpDialog(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(
          'Ajuda',
          style: TextStyle(color: textColor),
        ),
        content: SingleChildScrollView(
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
              color: textColor,
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
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgColor,
        title: Text(
          'Sobre',
          style: TextStyle(color: textColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.calendar_today,
                size: 64,
                color: AppColors.blue,
              ),
              const SizedBox(height: 16),
              Text(
                'Lembra Vencimentos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Versão 0.1.0',
                style: TextStyle(
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'App para gerenciar prazos e vencimentos de documentos importantes como RG, CNH, carteirinhas e mais.',
                style: TextStyle(
                  color: textColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '© 2025 - Código Aberto',
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
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
