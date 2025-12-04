import '../entities/deadline.dart';

/// Interface de repositório para a entidade Deadline.
///
/// O repositório define as operações de acesso e sincronização de dados,
/// separando a lógica de persistência da lógica de negócio.
/// Utilizar interfaces facilita a troca de implementações (ex.: local, remota)
/// e torna o código mais testável e modular.
///
/// ⚠️ Dicas práticas para evitar erros comuns:
/// - Certifique-se de que Deadline possui métodos de conversão robustos (fromJson/toJson).
/// - Ao implementar esta interface, adicione logs nos métodos principais para facilitar debug.
/// - Em métodos assíncronos usados na UI, sempre verifique se o widget está "mounted" antes de chamar setState.
/// - Para persistência local, considere usar SharedPreferences para dados simples.
abstract class DeadlinesRepository {
  
  /// Carrega prazos do cache local para exibição rápida
  /// Usado no render inicial da tela
  Future<List<Deadline>> loadFromCache();
  
  /// Lista todos os prazos ordenados por data
  Future<List<Deadline>> listAll();
  
  /// Adiciona um novo prazo
  Future<void> add(Deadline deadline);
  
  /// Remove um prazo por ID
  Future<void> remove(String id);
  
  /// Busca prazo por ID (retorna null se não encontrado)
  Future<Deadline?> getById(String id);
  
  /// Lista prazos próximos (próximos 7 dias)
  Future<List<Deadline>> listUpcoming();
}

/*
// Exemplo de uso:

// 1. Criar implementação
class DeadlinesRepositoryImpl implements DeadlinesRepository {
  final StorageService _storage;
  
  DeadlinesRepositoryImpl(this._storage);
  
  @override
  Future<List<Deadline>> loadFromCache() async {
    return await _storage.loadDeadlines();
  }
  
  @override
  Future<List<Deadline>> listAll() async {
    final all = await loadFromCache();
    all.sort((a, b) => a.date.compareTo(b.date));
    return all;
  }
  
  @override
  Future<void> add(Deadline deadline) async {
    await _storage.addDeadline(deadline);
  }
  
  // ... implementar outros métodos
}

// 2. Usar no Provider/ViewModel
class DeadlinesProvider extends ChangeNotifier {
  final DeadlinesRepository _repository;
  List<Deadline> _deadlines = [];
  bool _loading = false;
  
  DeadlinesProvider(this._repository);
  
  Future<void> load() async {
    _loading = true;
    notifyListeners();
    
    _deadlines = await _repository.listAll();
    
    _loading = false;
    notifyListeners();
  }
}

// 3. Para testes, criar mock
class MockDeadlinesRepository implements DeadlinesRepository {
  @override
  Future<List<Deadline>> loadFromCache() async {
    return [
      Deadline(
        id: '1', 
        title: 'RG de 2ª via', 
        category: 'RG',
        date: DateTime.now().add(const Duration(days: 30)),
      ),
    ];
  }
  
  @override
  Future<void> add(Deadline deadline) async {
    // mock: não faz nada
  }
  
  // ... implementar outros métodos retornando dados fixos
}

// Checklist de erros comuns e como evitar:
// - Erro de conversão de tipos: garanta que fromJson/toJson funciona corretamente
// - Falha ao atualizar UI após add/remove: sempre chame notifyListeners() após mudar estado
// - Dados não aparecem: verifique se loadFromCache() está lendo do local correto
// - Memory leak: sempre dispose controllers e cancel subscriptions
// - Context usado após unmount: verifique 'mounted' antes de usar context em callbacks assíncronos

// Referências úteis:
// - Clean Architecture: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
// - Repository Pattern: https://martinfowler.com/eaaCatalog/repository.html
*/
