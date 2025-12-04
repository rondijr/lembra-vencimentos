import '../../domain/entities/deadline.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/supabase_service.dart';

class DeadlinesSyncRepository {
  final StorageService _storageService;
  final SupabaseService _supabaseService;

  DeadlinesSyncRepository({
    required StorageService storageService,
    required SupabaseService supabaseService,
  })  : _storageService = storageService,
        _supabaseService = supabaseService;

  // Carrega do cache local primeiro, depois sincroniza com Supabase
  Future<List<Deadline>> loadDeadlines() async {
    print('🔄 Iniciando carregamento de prazos...');
    
    // Busca userId atual
    final userId = await _storageService.getString('user_id');
    print('👤 UserId: $userId');
    
    // Carrega do cache local para resposta rápida
    final localDeadlines = await _storageService.loadDeadlines();
    print('📱 Prazos locais carregados: ${localDeadlines.length}');

    // Sempre tenta sincronizar com Supabase
    try {
      final remoteDeadlines = await _supabaseService.fetchDeadlines(userId: userId);
      print('☁️ Prazos remotos carregados: ${remoteDeadlines.length}');
      
      // Servidor é a fonte da verdade - usa APENAS dados remotos
      final sorted = remoteDeadlines..sort((a, b) => a.date.compareTo(b.date));
      print('📊 Usando ${sorted.length} prazos do servidor');
      
      // Atualiza cache local com dados do servidor
      await _storageService.saveDeadlines(sorted);
      
      return sorted;
    } catch (e) {
      // Se falhar sincronização, retorna dados locais
      print('⚠️ Erro ao sincronizar com Supabase: $e');
      print('📱 Usando ${localDeadlines.length} prazos locais (offline)');
      return localDeadlines;
    }
  }

  Future<void> addDeadline(Deadline deadline) async {
    print('➕ Adicionando prazo: ${deadline.title}');
    
    // Busca userId atual
    final userId = await _storageService.getString('user_id');
    
    // Adiciona localmente
    await _storageService.addDeadline(deadline);
    print('✅ Prazo salvo localmente');

    // Sempre tenta adicionar no Supabase
    try {
      await _supabaseService.addDeadline(deadline, userId: userId);
      print('☁️ Prazo sincronizado com Supabase');
    } catch (e) {
      print('⚠️ Erro ao adicionar no Supabase: $e');
      // Continua mesmo com erro - dados estão salvos localmente
    }
  }

  Future<void> removeDeadline(String id) async {
    print('🗑️ Removendo prazo: $id');
    
    // Remove localmente
    await _storageService.removeDeadline(id);
    print('✅ Prazo removido localmente');

    // Sempre tenta remover do Supabase
    try {
      await _supabaseService.deleteDeadline(id);
      print('☁️ Prazo removido do Supabase');
    } catch (e) {
      print('⚠️ Erro ao remover do Supabase: $e');
    }
  }

  Future<void> updateDeadline(Deadline deadline) async {
    print('✏️ Atualizando prazo: ${deadline.title}');
    
    // Atualiza localmente
    final deadlines = await _storageService.loadDeadlines();
    final index = deadlines.indexWhere((d) => d.id == deadline.id);
    if (index != -1) {
      deadlines[index] = deadline;
      await _storageService.saveDeadlines(deadlines);
      print('✅ Prazo atualizado localmente');
    }

    // Sempre tenta atualizar no Supabase
    try {
      await _supabaseService.updateDeadline(deadline);
      print('☁️ Prazo atualizado no Supabase');
    } catch (e) {
      print('⚠️ Erro ao atualizar no Supabase: $e');
    }
  }

  // Stream de atualizações em tempo real
  Stream<List<Deadline>> watchDeadlines() {
    try {
      return _supabaseService.watchDeadlines();
    } catch (e) {
      print('⚠️ Erro ao criar stream de prazos: $e');
      return Stream.value([]);
    }
  }
}
