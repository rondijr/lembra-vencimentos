import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/deadlines/domain/entities/deadline.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Autenticação anônima (sem login)
  Future<void> signInAnonymously() async {
    // Não precisa mais de autenticação - acesso público habilitado
    return;
  }

  // Autenticação com email (opcional)
  Future<void> signInWithEmail(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signUpWithEmail(String email, String password) async {
    await _client.auth.signUp(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  String? get userId => _client.auth.currentUser?.id;

  bool get isAuthenticated => _client.auth.currentUser != null;

  // CRUD de Deadlines
  Future<List<Deadline>> fetchDeadlines({String? userId}) async {
    try {
      var query = _client.from('deadlines').select();
      
      // Filtra por usuário se fornecido
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query.order('date', ascending: true);

      print('📥 Dados recebidos do Supabase: ${response.length} prazos');
      
      return (response as List)
          .map((json) => Deadline.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar do Supabase: $e');
      return [];
    }
  }

  Future<void> addDeadline(Deadline deadline, {String? userId}) async {
    try {
      final data = {
        'id': deadline.id,
        'user_id': userId ?? 'anonymous',
        'title': deadline.title,
        'category': deadline.category,
        'date': deadline.date.toIso8601String(),
      };
      print('📤 Tentando inserir no Supabase: $data');
      
      final response = await _client.from('deadlines').insert(data).select();
      
      print('✅ Prazo inserido no Supabase: ${deadline.title}');
      print('📥 Resposta do Supabase: $response');
    } catch (e, stackTrace) {
      print('❌ ERRO ao inserir no Supabase: $e');
      print('📍 Stack trace: $stackTrace');
      // Não lança exceção, continua funcionando localmente
    }
  }

  Future<void> updateDeadline(Deadline deadline) async {
    try {
      await _client.from('deadlines').update({
        'title': deadline.title,
        'category': deadline.category,
        'date': deadline.date.toIso8601String(),
      }).eq('id', deadline.id);
      print('✅ Prazo atualizado no Supabase: ${deadline.title}');
    } catch (e) {
      print('⚠️ Erro ao atualizar no Supabase (dados atualizados localmente): $e');
      // Não lança exceção, continua funcionando localmente
    }
  }

  Future<void> deleteDeadline(String id) async {
    try {
      await _client
          .from('deadlines')
          .delete()
          .eq('id', id);
      print('✅ Prazo deletado no Supabase: $id');
    } catch (e) {
      print('⚠️ Erro ao deletar no Supabase (dados deletados localmente): $e');
      // Não lança exceção, continua funcionando localmente
    }
  }

  // Sincronização
  Stream<List<Deadline>> watchDeadlines() {
    try {
      return _client
          .from('deadlines')
          .stream(primaryKey: ['id'])
          .map((list) => list.map((json) => Deadline.fromMap(json)).toList());
    } catch (e) {
      print('⚠️ Erro ao criar stream do Supabase: $e');
      return Stream.value([]);
    }
  }
}
