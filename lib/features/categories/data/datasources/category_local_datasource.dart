import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../dtos/category_dto.dart';
import '../../domain/entities/category.dart';
import '../mappers/category_mapper.dart';

/// Datasource local para categorias usando SharedPreferences
class CategoryLocalDataSource {
  static const _key = 'categories_cache';

  /// Carrega todas as categorias do cache local
  Future<List<Category>> getAll() async {
    try {
      print('📱 Carregando categorias do cache local...');
      
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_key);
      
      if (jsonString == null || jsonString.isEmpty) {
        print('📱 Cache local vazio');
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonString);
      final categories = jsonList
          .map((json) => CategoryMapper.toEntity(CategoryDto.fromJson(json)))
          .toList();
      
      print('📱 Categorias carregadas do cache: ${categories.length}');
      return categories;
    } catch (e) {
      print('❌ Erro ao carregar categorias do cache: $e');
      return [];
    }
  }

  /// Salva categorias no cache local
  Future<void> save(List<Category> categories) async {
    try {
      print('💾 Salvando ${categories.length} categorias no cache local...');
      
      final dtos = categories.map((c) => CategoryMapper.toDto(c)).toList();
      final jsonList = dtos.map((dto) => dto.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonString);
      
      print('✅ Categorias salvas no cache local: ${categories.length}');
    } catch (e) {
      print('❌ Erro ao salvar categorias no cache: $e');
      rethrow;
    }
  }

  /// Limpa o cache local de categorias
  Future<void> clear() async {
    try {
      print('🗑️ Limpando cache local de categorias...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      
      print('✅ Cache local limpo');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
      rethrow;
    }
  }

  /// Adiciona uma categoria ao cache
  Future<void> add(Category category) async {
    final categories = await getAll();
    categories.add(category);
    await save(categories);
  }

  /// Remove uma categoria do cache
  Future<void> remove(String id) async {
    final categories = await getAll();
    categories.removeWhere((c) => c.id == id);
    await save(categories);
  }

  /// Atualiza uma categoria no cache
  Future<void> update(Category category) async {
    final categories = await getAll();
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      categories[index] = category;
      await save(categories);
    }
  }
}
