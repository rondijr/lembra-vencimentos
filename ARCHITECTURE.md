# Lembra Vencimentos - Clean Architecture

## 📋 Sobre o Projeto

App Flutter para lembrar vencimentos de documentos (RG, CNH, carteirinhas).  
**Persona**: Aluno com prazos dispersos.  
**Foco**: Avisos locais; sem dados sensíveis.  
**Paleta**: Blue #2563EB, Slate #0F172A, Amber #F59E0B.  
**Ícone**: Calendário com sino.

---

## 🏗️ Arquitetura Clean Architecture

O projeto foi refatorado para seguir os princípios de **Clean Architecture**, inspirado no repositório [runsafe-flutter-app](https://github.com/bolivia00/runsafe-flutter-app).

### Estrutura de Pastas

```
lib/
├── core/                              # Componentes compartilhados
│   ├── models/                        # (vazio - modelos movidos para features)
│   ├── services/                      # Serviços globais
│   │   ├── storage_service.dart       # Persistência com SharedPreferences
│   │   └── notification_service.dart  # Notificações locais
│   └── utils/                         # Utilitários e constantes
│       └── app_colors.dart            # Paleta de cores
│
├── features/                          # Features do app (modular)
│   ├── deadlines/                     # Feature de prazos/vencimentos
│   │   ├── domain/                    # Camada de domínio (regras de negócio)
│   │   │   ├── entities/              # Entidades do domínio
│   │   │   │   └── deadline.dart      # Entidade Deadline
│   │   │   └── repositories/          # Interfaces de repositórios
│   │   │       └── deadlines_repository.dart
│   │   ├── data/                      # Camada de dados (persistência)
│   │   │   ├── datasources/           # Fontes de dados (local/remota)
│   │   │   ├── repositories/          # Implementações de repositórios
│   │   │   │   └── deadlines_repository_impl.dart
│   │   │   └── mappers/               # Conversão entre DTOs e entidades
│   │   └── presentation/              # Camada de apresentação (UI)
│   │       ├── pages/                 # Telas
│   │       │   ├── home_screen.dart   # Tela principal (lista de prazos)
│   │       │   └── add_deadline_page.dart # Cadastro de prazo
│   │       └── widgets/               # Widgets reutilizáveis
│   │           └── deadline_list_item.dart # Item da lista
│   │
│   └── onboarding/                    # Feature de onboarding
│       └── presentation/
│           └── pages/
│               └── onboarding_page.dart # Primeira execução
│
└── main.dart                          # Entry point do app
```

---

## 🔄 Separação de Camadas

### 1. **Domain (Domínio)**
- **Entidades**: Objetos de negócio puros (sem dependências externas)
- **Repositórios**: Interfaces abstratas (contratos)
- **Regras de negócio**: Lógica independente de framework

### 2. **Data (Dados)**
- **Repositórios Impl**: Implementações concretas das interfaces do domínio
- **Datasources**: Acesso a fontes de dados (local: SharedPreferences, remota: API)
- **Mappers**: Conversão entre DTOs (Data Transfer Objects) e Entidades

### 3. **Presentation (Apresentação)**
- **Pages**: Telas do app
- **Widgets**: Componentes reutilizáveis de UI
- **Providers/BLoC**: Gerenciamento de estado (futuro)

---

## 📦 Dependências Principais

```yaml
dependencies:
  flutter_local_notifications: ^18.0.1  # Notificações locais
  shared_preferences: ^2.3.5            # Persistência local
  intl: ^0.19.0                         # Formatação de datas
  timezone: ^0.9.5                      # Fusos horários
  uuid: ^4.5.1                          # Geração de IDs únicos
```

---

## 🚀 Fluxo de Dados

```
[UI/Presentation] 
       ↓ (interage com)
[Repository Interface (Domain)]
       ↓ (implementado por)
[Repository Impl (Data)]
       ↓ (usa)
[DataSource (Storage/API)]
       ↓
[SharedPreferences/API externa]
```

**Benefícios**:
- ✅ Testabilidade: Cada camada pode ser testada isoladamente
- ✅ Manutenibilidade: Mudanças em uma camada não afetam as outras
- ✅ Escalabilidade: Fácil adicionar novos features
- ✅ Desacoplamento: UI não conhece detalhes de persistência

---

## 🎨 Onboarding (Primeira Execução)

- Verifica se é primeira execução via `SharedPreferences`
- Exibe página de boas-vindas com tema de aluno e paleta correta
- Ao clicar em "Cadastrar 1º prazo", navega para tela principal
- Marca `first_run = false` para não exibir onboarding novamente

---

## 🧪 Testes

Execute os testes com:
```bash
flutter test
```

---

## 📝 Próximos Passos

- [ ] Adicionar Provider/Riverpod para gerenciamento de estado
- [ ] Criar camada de mappers (DTO <-> Entity) se houver integração com API
- [ ] Adicionar testes unitários para repositórios e entidades
- [ ] Implementar dark/light theme toggle
- [ ] Adicionar filtros e busca na lista de prazos

---

## 📚 Referências

- [Clean Architecture (Uncle Bob)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [Repositório de referência: runsafe-flutter-app](https://github.com/bolivia00/runsafe-flutter-app)
