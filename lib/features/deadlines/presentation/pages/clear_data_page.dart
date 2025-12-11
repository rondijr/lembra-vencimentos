import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/storage_service.dart';

class ClearDataPage extends StatelessWidget {
  const ClearDataPage({Key? key}) : super(key: key);

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final bgColor = Theme.of(context).scaffoldBackgroundColor;
        final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
        return AlertDialog(
          backgroundColor: bgColor,
          title: Text(
            'Limpar Todos os Dados?',
            style: TextStyle(color: textColor),
          ),
          content: Text(
            'Isso irá:\n• Apagar todos os prazos do Supabase e locais\n• Remover seu perfil do Supabase\n• Resetar o app para primeira execução\n\nEsta ação não pode ser desfeita!',
            style: TextStyle(color: textColor),
          ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar Tudo'),
          ),
        ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        // Busca userId antes de limpar
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id');
        
        // Deleta do Supabase
        if (userId != null) {
          final userService = UserService();
          final supabaseService = SupabaseService();
          final storageService = StorageService();
          
          // Deleta todos os prazos do usuário do Supabase
          final deadlines = await storageService.loadDeadlines();
          for (var deadline in deadlines) {
            try {
              await supabaseService.deleteDeadline(deadline.id);
            } catch (e) {
              print('⚠️ Erro ao deletar prazo ${deadline.id}: $e');
            }
          }
          
          // Deleta usuário do Supabase
          await userService.deleteUser(userId);
          print('✅ Dados deletados do Supabase');
        }
        
        // Limpa dados locais
        await prefs.clear();
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dados limpos! Reiniciando app...'),
              backgroundColor: Colors.green,
            ),
          );
          
          await Future.delayed(const Duration(seconds: 1));
          
          if (context.mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/terms',
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao limpar dados: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Limpar Dados'),
        backgroundColor: AppColors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.delete_forever,
                size: 100,
                color: Colors.red,
              ),
              const SizedBox(height: 32),
              const Text(
                'Limpar Todos os Dados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Use esta opção para resetar o app e testar o fluxo completo desde o início',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _clearAllData(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Limpar Todos os Dados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
