import 'package:supabase_flutter/supabase_flutter.dart';
import '../dtos/category_dto.dart';
import '../../domain/entities/category.dart';
import '../mappers/category_mapper.dart';

/// Datasource remoto para categorias usando Supabase
class CategoryRemoteDataSource {
  final SupabaseClient _client = Supabase.instance.client;

  /// Busca todas as categorias do Supabase
  Future<List<CategoryDto>> fetchAll({String? userId}) async {
    try {
      print('☁️ Buscando categorias do Supabase...');
      
      var query = _client.from('categories').select();
      
      // Filtra por usuário se fornecido
      if (userId != null) {
        query = query.eq('user_id', userId);
      }
      
      final response = await query.order('name', ascending: true);
      
      print('📥 Dados recebidos do Supabase: ${response.length} categorias');
      
      return (response as List).map((json) => CategoryDto.fromJson(json)).toList();
    } catch (e) {
      print('❌ Erro ao buscar categorias do Supabase: $e');
      rethrow;
    }
  }

  /// Busca uma categoria específica por ID
  Future<CategoryDto?> fetchById(String id) async {
    try {
      print('☁️ Buscando categoria $id do Supabase...');
      
      final response = await _client
          .from('categories')
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response == null) {
        print('⚠️ Categoria $id não encontrada no Supabase');
        return null;
      }
      
      print('📥 Categoria encontrada: ${response['name']}');
      return CategoryDto.fromJson(response);
    } catch (e) {
      print('❌ Erro ao buscar categoria do Supabase: $e');
      rethrow;
    }
  }

  /// Insere uma nova categoria no Supabase
  Future<void> insert(Category category, {String? userId}) async {
    try {
      print('☁️ Inserindo categoria no Supabase: ${category.name}');
      
      final dto = CategoryMapper.toDto(category);
      final json = dto.toJson();
      
      // Adiciona user_id se fornecido
      if (userId != null) {
        json['user_id'] = userId;
      }
      
      await _client.from('categories').insert(json);
      print('✅ Categoria inserida no Supabase: ${category.name}');
    } catch (e) {
      print('❌ Erro ao inserir categoria no Supabase: $e');
      rethrow;
    }
  }

  /// Atualiza uma categoria existente no Supabase
  Future<void> update(Category category) async {
    try {
      print('☁️ Atualizando categoria no Supabase: ${category.name}');
      
      final dto = CategoryMapper.toDto(category);
      final json = dto.toJson();
      
      await _client
          .from('categories')
          .update(json)
          .eq('id', category.id);
      
      print('✅ Categoria atualizada no Supabase: ${category.name}');
    } catch (e) {
      print('❌ Erro ao atualizar categoria no Supabase: $e');
      rethrow;
    }
  }

  /// Remove uma categoria do Supabase
  Future<void> delete(String id) async {
    try {
      print('☁️ Removendo categoria do Supabase: $id');
      
      await _client.from('categories').delete().eq('id', id);
      
      print('✅ Categoria removida do Supabase: $id');
    } catch (e) {
      print('❌ Erro ao remover categoria do Supabase: $e');
      rethrow;
    }
  }

  /// Stream de categorias em tempo real
  Stream<List<Category>> watch({String? userId}) {
    try {
      print('👁️ Configurando stream de categorias do Supabase...');
      
      return _client
          .from('categories')
          .stream(primaryKey: ['id'])
          .order('name')
          .map((data) {
            print('📡 Dados recebidos via stream: ${data.length} categorias');
            return data
                .map((json) => CategoryMapper.toEntity(CategoryDto.fromJson(json)))
                .toList();
          });
    } catch (e) {
      print('❌ Erro ao criar stream de categorias: $e');
      rethrow;
    }
  }
}
