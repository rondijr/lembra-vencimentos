import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/user.dart' as app_user;

class UserService {
  final _client = Supabase.instance.client;

  // Cria ou atualiza usuário
  Future<void> saveUser(app_user.User user) async {
    try {
      await _client.from('users').upsert(user.toMap());
      print('✅ Usuário salvo no Supabase: ${user.name}');
    } catch (e) {
      print('❌ Erro ao salvar usuário: $e');
      rethrow;
    }
  }

  // Busca usuário por ID
  Future<app_user.User?> getUser(String id) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      
      return app_user.User.fromMap(response);
    } catch (e) {
      print('❌ Erro ao buscar usuário: $e');
      return null;
    }
  }

  // Busca todos os usuários
  Future<List<app_user.User>> getAllUsers() async {
    try {
      final response = await _client.from('users').select();
      return (response as List)
          .map((json) => app_user.User.fromMap(json))
          .toList();
    } catch (e) {
      print('❌ Erro ao buscar usuários: $e');
      return [];
    }
  }

  // Atualiza usuário
  Future<void> updateUser(app_user.User user) async {
    try {
      await _client
          .from('users')
          .update(user.toMap())
          .eq('id', user.id);
      print('✅ Usuário atualizado: ${user.name}');
    } catch (e) {
      print('❌ Erro ao atualizar usuário: $e');
      rethrow;
    }
  }

  // Deleta usuário
  Future<void> deleteUser(String id) async {
    try {
      await _client.from('users').delete().eq('id', id);
      print('✅ Usuário deletado: $id');
    } catch (e) {
      print('❌ Erro ao deletar usuário: $e');
      rethrow;
    }
  }
}
