import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_datasource.dart';
import '../datasources/category_local_datasource.dart';
import '../mappers/category_mapper.dart';
import '../../../../core/services/storage_service.dart';

/// Repositório de sincronização de categorias com Supabase + Cache Local
/// 
/// Estratégia de sincronização:
/// 1. Carrega do cache local primeiro (resposta rápida)
/// 2. Sincroniza com Supabase em background
/// 3. Atualiza cache com dados do servidor
/// 4. Se offline, usa apenas cache local
class CategorySyncRepository implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  final CategoryLocalDataSource _localDataSource;
  final StorageService _storageService;

  CategorySyncRepository({
    required CategoryRemoteDataSource remoteDataSource,
    required CategoryLocalDataSource localDataSource,
    required StorageService storageService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _storageService = storageService;

  @override
  Future<List<Category>> getAll() async {
    print('🔄 Iniciando carregamento de categorias...');
    
    // Busca userId atual
    final userId = await _storageService.getString('user_id');
    print('👤 UserId: $userId');
    
    // 1. Carrega do cache local para resposta rápida
    final localCategories = await _localDataSource.getAll();
    print('📱 Categorias locais carregadas: ${localCategories.length}');

    // 2. Sempre tenta sincronizar com Supabase
    try {
      await syncFromServer();
      
      // 3. Recarrega do cache após sincronização
      final syncedCategories = await _localDataSource.getAll();
      print('📊 Usando ${syncedCategories.length} categorias sincronizadas');
      
      return syncedCategories;
    } catch (e) {
      // 4. Se falhar sincronização, retorna dados locais
      print('⚠️ Erro ao sincronizar com Supabase: $e');
      print('📱 Usando ${localCategories.length} categorias locais (offline)');
      return localCategories;
    }
  }

  @override
  Future<Category?> getById(String id) async {
    print('🔍 Buscando categoria: $id');
    
    final categories = await _localDataSource.getAll();
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      print('⚠️ Categoria $id não encontrada no cache');
      return null;
    }
  }

  @override
  Future<void> create(Category category) async {
    print('➕ Criando categoria: ${category.name}');
    
    // Busca userId atual
    final userId = await _storageService.getString('user_id');
    
    // 1. Salva localmente primeiro
    await _localDataSource.add(category);
    print('✅ Categoria salva localmente');

    // 2. Tenta sincronizar com Supabase
    try {
      await _remoteDataSource.insert(category, userId: userId);
      print('☁️ Categoria sincronizada com Supabase');
      
      // 3. Recarrega do servidor para garantir consistência
      await syncFromServer();
    } catch (e) {
      print('⚠️ Erro ao criar no Supabase: $e');
      print('📱 Categoria mantida apenas no cache local');
    }
  }

  @override
  Future<void> update(Category category) async {
    print('✏️ Atualizando categoria: ${category.name}');
    
    // 1. Atualiza localmente primeiro
    await _localDataSource.update(category);
    print('✅ Categoria atualizada localmente');

    // 2. Tenta sincronizar com Supabase
    try {
      await _remoteDataSource.update(category);
      print('☁️ Categoria atualizada no Supabase');
      
      // 3. Recarrega do servidor para garantir consistência
      await syncFromServer();
    } catch (e) {
      print('⚠️ Erro ao atualizar no Supabase: $e');
      print('📱 Categoria mantida apenas no cache local');
    }
  }

  @override
  Future<void> delete(String id) async {
    print('🗑️ Removendo categoria: $id');
    
    // 1. Remove localmente primeiro
    await _localDataSource.remove(id);
    print('✅ Categoria removida localmente');

    // 2. Tenta remover do Supabase
    try {
      await _remoteDataSource.delete(id);
      print('☁️ Categoria removida do Supabase');
    } catch (e) {
      print('⚠️ Erro ao remover do Supabase: $e');
    }
  }

  /// Sincroniza categorias do servidor para o cache local
  /// 
  /// O servidor é a fonte da verdade:
  /// - Busca todas as categorias do Supabase
  /// - Substitui completamente o cache local
  /// - Mantém consistência entre servidor e cliente
  Future<void> syncFromServer() async {
    print('🔄 Sincronizando categorias do servidor...');
    
    try {
      final userId = await _storageService.getString('user_id');
      final remoteDtos = await _remoteDataSource.fetchAll(userId: userId);
      print('☁️ Categorias remotas carregadas: ${remoteDtos.length}');
      
      // Converte DTOs para entities usando o mapper
      final remoteCategories = CategoryMapper.toEntityList(remoteDtos);
      
      // Ordena por nome
      final sorted = remoteCategories..sort((a, b) => a.name.compareTo(b.name));
      print('📊 Usando ${sorted.length} categorias do servidor');
      
      // Atualiza cache local com dados do servidor
      await _localDataSource.save(sorted);
      print('✅ Cache local atualizado com dados do servidor');
    } catch (e) {
      print('❌ Erro ao sincronizar do servidor: $e');
      rethrow;
    }
  }

  /// Limpa todo o cache local
  Future<void> clearCache() async {
    await _localDataSource.clear();
  }

  /// Stream de categorias em tempo real (requer conexão)
  Stream<List<Category>> watch() {
    try {
      final userId = _storageService.getString('user_id');
      return _remoteDataSource.watch(userId: userId as String?);
    } catch (e) {
      print('⚠️ Erro ao criar stream de categorias: $e');
      return Stream.value([]);
    }
  }
}
