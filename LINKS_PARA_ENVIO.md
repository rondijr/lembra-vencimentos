# 🔗 Links para Envio - Arquitetura Completa

**Repositório**: https://github.com/rondijr/lembra-vencimentos

---

## 📋 Enunciado 1: Entity ≠ DTO + Mapper (4 Entidades)

### Category
1. **Entity**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/domain/entities/category.dart
2. **DTO**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/dtos/category_dto.dart
3. **Mapper**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/mappers/category_mapper.dart
4. **Tests**: https://github.com/rondijr/lembra-vencimentos/blob/main/test/features/categories/category_mapper_test.dart

### Notification
1. **Entity**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/notifications/domain/entities/notification.dart
2. **DTO**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/notifications/data/dtos/notification_dto.dart
3. **Mapper**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/notifications/data/mappers/notification_mapper.dart
4. **Tests**: https://github.com/rondijr/lembra-vencimentos/blob/main/test/features/notifications/notification_mapper_test.dart

### Reminder
1. **Entity**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/reminders/domain/entities/reminder.dart
2. **DTO**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/reminders/data/dtos/reminder_dto.dart
3. **Mapper**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/reminders/data/mappers/reminder_mapper.dart
4. **Tests**: https://github.com/rondijr/lembra-vencimentos/blob/main/test/features/reminders/reminder_mapper_test.dart

### Tag
1. **Entity**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/domain/entities/tag.dart
2. **DTO**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/data/dtos/tag_dto.dart
3. **Mapper**: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/data/mappers/tag_mapper.dart
4. **Tests**: https://github.com/rondijr/lembra-vencimentos/blob/main/test/features/tags/tag_mapper_test.dart

---

## 📋 Enunciado 2: CRUD com Clean Architecture (2 Entidades)

### Category - Arquitetura Completa
**Domain Layer:**
- Entity: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/domain/entities/category.dart
- Repository Interface: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/domain/repositories/category_repository.dart

**Data Layer:**
- DTO: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/dtos/category_dto.dart
- Mapper: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/mappers/category_mapper.dart
- Repository Impl: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/repositories/category_repository_impl.dart

**Presentation Layer:**
- List Page: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/presentation/pages/category_list_page.dart
- Edit Page: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/presentation/pages/category_edit_page.dart
- Detail Dialog: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/presentation/widgets/category_detail_dialog.dart

### Tag - Arquitetura Completa
**Domain Layer:**
- Entity: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/domain/entities/tag.dart
- Repository Interface: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/domain/repositories/tag_repository.dart

**Data Layer:**
- DTO: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/data/dtos/tag_dto.dart
- Mapper: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/data/mappers/tag_mapper.dart
- Repository Impl: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/data/repositories/tag_repository_impl.dart

**Presentation Layer:**
- List Page: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/presentation/pages/tag_list_page.dart
- Edit Page: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/presentation/pages/tag_edit_page.dart
- Detail Dialog: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/presentation/widgets/tag_detail_dialog.dart

### Navegação
- App Drawer: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/deadlines/presentation/widgets/app_drawer.dart
- Main Routes: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/main.dart

---

## 📋 Enunciado 3: Persistência Completa (Supabase + SharedPreferences)

### Category - Persistência com Sincronização

**SQL Schema (Supabase):**
- Setup SQL: https://github.com/rondijr/lembra-vencimentos/blob/main/supabase_categories_setup.sql

**Data Sources:**
- Remote DataSource (Supabase): https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/datasources/category_remote_datasource.dart
- Local DataSource (SharedPreferences): https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/datasources/category_local_datasource.dart

**Sync Repository:**
- CategorySyncRepository: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/repositories/category_sync_repository.dart

**Integração com UI:**
- CategoryListPage (usando sync): https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/presentation/pages/category_list_page.dart

---

## 📚 Documentação

### Documentação Completa do Projeto:
- **DOCUMENTACAO_CRUD.md**: https://github.com/rondijr/lembra-vencimentos/blob/main/DOCUMENTACAO_CRUD.md
  - Explicação da Clean Architecture
  - Responsabilidades de cada camada
  - Arquitetura de persistência (Supabase + Cache)
  - Estratégia de sincronização
  - Todos os links organizados

### Roteiro de Apresentação:
- **ROTEIRO_APRESENTACAO.md**: https://github.com/rondijr/lembra-vencimentos/blob/main/ROTEIRO_APRESENTACAO.md
  - Script passo-a-passo para apresentação oral
  - Demonstrações práticas
  - Perguntas e respostas preparadas

---

## ✅ Checklist de Entregas

### Enunciado 1 (Entity ≠ DTO + Mapper):
- ✅ 4 Entities implementadas (Category, Notification, Reminder, Tag)
- ✅ 4 DTOs com serialização JSON (snake_case)
- ✅ 4 Mappers com conversões bidirecionais
- ✅ 4 arquivos de testes unitários

### Enunciado 2 (CRUD com Clean Architecture):
- ✅ 2 entidades com CRUD completo (Category, Tag)
- ✅ Separação em 3 camadas (domain/data/presentation)
- ✅ Interface de repositório no domain
- ✅ Implementação de repositório no data
- ✅ UI completa: List Page, Edit Page, Detail Dialog
- ✅ Navegação via Drawer
- ✅ Rotas configuradas

### Enunciado 3 (Persistência Completa):
- ✅ SQL schema para Supabase (categories table)
- ✅ Remote DataSource com CRUD no Supabase
- ✅ Local DataSource com cache SharedPreferences
- ✅ Sync Repository com estratégia cache-first
- ✅ Sincronização em background (syncFromServer)
- ✅ Suporte offline (usa cache quando sem conexão)
- ✅ Debug logs detalhados em todo fluxo
- ✅ Error handling com fallback para cache
- ✅ Integração com UI existente

---

## 🎯 Arquitetura Implementada

```
Category Entity (domain)
    ↓
CategoryRepository Interface (domain)
    ↓
CategorySyncRepository (data) ← Implementa interface
    ↓
    ├─ CategoryRemoteDataSource (Supabase)
    │   └─ CategoryDto (snake_case) ↔ CategoryMapper ↔ Category (camelCase)
    │
    └─ CategoryLocalDataSource (SharedPreferences)
        └─ CategoryDto (JSON) ↔ CategoryMapper ↔ Category (Entity)
    ↓
CategoryListPage (presentation)
    └─ UI com Material Design 3
```

**Fluxo de Dados**:
1. UI chama `repository.getAll()`
2. Repository carrega do cache (resposta rápida)
3. Repository sincroniza com Supabase em background
4. Repository atualiza cache com dados do servidor
5. UI mostra dados atualizados
6. Se offline: usa apenas cache (sem erro)

---

**Desenvolvido por**: Rondi Jr  
**Repositório**: https://github.com/rondijr/lembra-vencimentos  
**Data**: Dezembro 2025
