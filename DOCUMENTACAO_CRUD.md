# 📚 Documentação - CRUD com Clean Architecture

## 🏗️ Arquitetura Adotada

Este projeto utiliza **Clean Architecture** (Arquitetura Limpa), uma abordagem que separa responsabilidades em camadas bem definidas, promovendo:

- **Independência de frameworks**
- **Testabilidade**
- **Independência de UI**
- **Independência de banco de dados**
- **Manutenibilidade**

### 📂 Organização de Camadas

```
lib/
├── features/              # Funcionalidades do app
│   ├── categories/        # Feature de Categorias
│   │   ├── domain/       # CAMADA DE DOMÍNIO
│   │   │   ├── entities/           # Entidades de negócio
│   │   │   └── repositories/       # Interfaces dos repositórios
│   │   ├── data/         # CAMADA DE DADOS
│   │   │   ├── dtos/               # Data Transfer Objects
│   │   │   ├── mappers/            # Conversores Entity ↔ DTO
│   │   │   └── repositories/       # Implementações dos repositórios
│   │   └── presentation/ # CAMADA DE APRESENTAÇÃO
│   │       ├── pages/              # Telas do app
│   │       └── widgets/            # Componentes visuais
│   │
│   └── tags/             # Feature de Tags (mesma estrutura)
│       ├── domain/
│       ├── data/
│       └── presentation/
│
└── core/                 # Recursos compartilhados
    ├── config/
    ├── services/
    └── utils/
```

---

## 🎯 Responsabilidades das Camadas

### 1. **Domain (Domínio)** - `domain/`
**Responsabilidade**: Regras de negócio puras, independentes de framework

- **Entities** (`entities/`): Classes que representam conceitos de negócio
  - Contêm **invariantes** (validações que sempre devem ser verdadeiras)
  - Contêm **regras de negócio** (métodos como `isActive()`, `addSubcategory()`)
  - **NÃO dependem** de nenhuma outra camada

- **Repositories** (`repositories/`): Interfaces (contratos) para acesso a dados
  - Define **o que** o repositório deve fazer (CRUD)
  - **NÃO implementa** como os dados são salvos

**Exemplo**: `Category` entity valida que nome tem 1-50 caracteres, tem regra de negócio `isActive()` que verifica se foi atualizado nos últimos 365 dias.

---

### 2. **Data (Dados)** - `data/`
**Responsabilidade**: Implementação de acesso a dados

- **DTOs** (`dtos/`): Espelho exato da estrutura do backend/banco
  - Usa **snake_case** (padrão backend)
  - Serialização JSON (`toJson()`, `fromJson()`)
  - **SEM lógica de negócio**

- **Mappers** (`mappers/`): Conversores entre Entity ↔ DTO
  - Converte `Entity` (domínio) para `DTO` (dados) e vice-versa
  - Aplica **normalizações** (remove espaços, duplicatas)
  - **NÃO contém lógica de negócio**

- **Repositories** (`repositories/`): Implementação dos contratos do domínio
  - Implementa **como** os dados são salvos/lidos
  - Usa DTOs para comunicação com backend
  - Usa Mappers para converter Entity ↔ DTO

**Exemplo**: `CategoryDto` tem campo `color_value` (snake_case), `CategoryMapper` converte para `colorValue` (camelCase) na Entity.

---

### 3. **Presentation (Apresentação)** - `presentation/`
**Responsabilidade**: Interface com o usuário

- **Pages** (`pages/`): Telas completas do aplicativo
  - Gerenciam estado da tela
  - Chamam repositórios para buscar/salvar dados
  - Exibem widgets

- **Widgets** (`widgets/`): Componentes visuais reutilizáveis
  - Diálogos, cards, botões customizados
  - Recebem dados via parâmetros
  - Emitem eventos via callbacks

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- Flutter 3.38.3 ou superior
- Dart SDK
- Dispositivo/emulador Android/iOS ou Chrome (web)

### Passo a Passo

1. **Clone o repositório**
```bash
git clone https://github.com/rondijr/lembra-vencimentos.git
cd lembra_vencimentos
```

2. **Instale as dependências**
```bash
flutter pub get
```

3. **Execute o aplicativo**
```bash
flutter run
```

4. **Navegue até as telas de CRUD**
   - Abra o app
   - Clique no **menu lateral (≡)** no topo esquerdo
   - Escolha **"Categorias"** ou **"Tags"**

---

## 📦 Entidades Implementadas

### 1. **Category** (Categoria)

**Propósito**: Organizar prazos em categorias com subcategorias

**Estrutura**:
```dart
class Category {
  final String id;
  final String name;           // Nome da categoria (1-50 caracteres)
  final int iconCode;          // Código do ícone MaterialIcons
  final int colorValue;        // Valor da cor (0xFFRRGGBB)
  final List<String> subcategories;  // Lista de subcategorias (1-20 itens)
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

**Invariantes** (validações):
- ID não pode ser vazio
- Nome: 1-50 caracteres
- Subcategorias: 1-20 itens únicos
- `updatedAt` não pode ser anterior a `createdAt`

**Regras de Negócio**:
- `isActive`: verdadeiro se atualizado nos últimos 365 dias
- `hasMinimumSubcategories`: verdadeiro se tem pelo menos 3 subcategorias
- `addSubcategory()`: adiciona subcategoria verificando duplicatas

**CRUD Implementado**:
- ✅ **Listagem**: Exibe todas categorias com ícone, nome e quantidade de subcategorias
- ✅ **Detalhes**: Mostra informações completas em diálogo (ID, subcategorias, datas)
- ✅ **Criação**: Formulário para criar nova categoria com seletor de ícone/cor
- ✅ **Edição**: Permite alterar nome, ícone, cor e subcategorias
- ✅ **Remoção**: Confirmação antes de deletar

---

### 2. **Tag** (Etiqueta)

**Propósito**: Organizar e rotular prazos com tags coloridas

**Estrutura**:
```dart
class Tag {
  final String id;
  final String name;           // Nome da tag (1-30 caracteres)
  final String colorHex;       // Cor em formato hexadecimal (#RRGGBB)
  final String userId;         // ID do usuário dono da tag
  final List<String> deadlineIds;  // IDs dos prazos vinculados (máx 1000)
  final DateTime createdAt;
  final DateTime? updatedAt;
}
```

**Invariantes** (validações):
- ID não pode ser vazio
- Nome: 1-30 caracteres
- `colorHex`: formato válido (#RRGGBB ou #AARRGGBB)
- Máximo 1000 prazos vinculados
- `updatedAt` não pode ser anterior a `createdAt`

**Regras de Negócio**:
- `hasDeadlines`: verdadeiro se tem prazos vinculados
- `isPopular`: verdadeiro se tem 10+ prazos vinculados
- `isRecentlyUpdated`: verdadeiro se atualizado nos últimos 7 dias
- `addDeadline()`: adiciona prazo verificando duplicatas
- `removeDeadline()`: remove prazo da tag
- `rename()`: renomeia a tag
- `changeColor()`: altera a cor

**CRUD Implementado**:
- ✅ **Listagem**: Exibe todas tags com cor, nome e quantidade de prazos
- ✅ **Detalhes**: Mostra cor hexadecimal, prazos vinculados, datas
- ✅ **Criação**: Formulário com seletor de cor e preview ao vivo
- ✅ **Edição**: Permite alterar nome e cor com preview
- ✅ **Remoção**: Confirmação antes de deletar

---

## 🔄 Fluxo de Navegação

### Acesso via Drawer (Menu Lateral)

1. **Tela Inicial** → Clique no ícone **≡** (menu)
2. **Menu Lateral** aparece com opções:
   - Perfil
   - **Categorias** ← Primeira entidade
   - **Tags** ← Segunda entidade
   - Notificações
   - Configurações
   - Ajuda, Sobre, Termos

### Fluxo Category (Categorias)

```
Menu → Categorias
  ↓
Tela de Listagem (category_list_page.dart)
  ├─→ Clique em item → Diálogo de Detalhes (category_detail_dialog.dart)
  │                      ├─→ Botão FECHAR → Fecha diálogo
  │                      ├─→ Botão EDITAR → Tela de Edição
  │                      └─→ Botão REMOVER → Confirmação → Remove
  └─→ Botão FAB (+) → Tela de Criação (category_edit_page.dart)
                        └─→ Preenche formulário → Salva → Volta para lista
```

### Fluxo Tag (Tags)

```
Menu → Tags
  ↓
Tela de Listagem (tag_list_page.dart)
  ├─→ Clique em item → Diálogo de Detalhes (tag_detail_dialog.dart)
  │                      ├─→ Botão FECHAR → Fecha diálogo
  │                      ├─→ Botão EDITAR → Tela de Edição
  │                      └─→ Botão REMOVER → Confirmação → Remove
  └─→ Botão FAB (+) → Tela de Criação (tag_edit_page.dart)
                        └─→ Preenche formulário → Salva → Volta para lista
```

---

## 📱 Telas Implementadas

### Para **Category**:

1. **CategoryListPage** - Lista de categorias
   - Pull-to-refresh para atualizar
   - Estado vazio mostra mensagem
   - Card com ícone, nome e contador de subcategorias

2. **CategoryDetailDialog** - Detalhes em diálogo modal
   - Ícone grande com cor
   - Nome e ID
   - Chips com todas subcategorias
   - Datas de criação/atualização
   - 3 botões: FECHAR, EDITAR, REMOVER

3. **CategoryEditPage** - Criação/Edição
   - Campo de texto para nome
   - Grid de seleção de ícone (10 opções)
   - Grid de seleção de cor (10 cores)
   - Campo + botão para adicionar subcategorias
   - Preview das subcategorias em chips
   - Botão salvar

### Para **Tag**:

1. **TagListPage** - Lista de tags
   - Pull-to-refresh
   - Estado vazio
   - Card com cor, nome e contador de prazos

2. **TagDetailDialog** - Detalhes em diálogo modal
   - Ícone de label com cor
   - Nome, ID e cor hexadecimal
   - Lista de IDs dos prazos vinculados
   - Datas de criação/atualização
   - 3 botões: FECHAR, EDITAR, REMOVER

3. **TagEditPage** - Criação/Edição
   - Campo de texto para nome
   - Grid de seleção de cor (15 cores)
   - Preview ao vivo da tag
   - Botão salvar

---

## 🧪 Implementação de Repository

Ambas entidades usam **implementação em memória** (não persiste após fechar o app), adequada para demonstração de CRUD.

```dart
// Exemplo: CategoryRepositoryImpl
class CategoryRepositoryImpl implements CategoryRepository {
  final List<Category> _categories = []; // Dados em memória

  Future<List<Category>> getAll() async {
    await Future.delayed(Duration(milliseconds: 300)); // Simula latência
    return List.from(_categories);
  }

  Future<void> create(Category category) async {
    await Future.delayed(Duration(milliseconds: 300));
    _categories.add(category);
  }

  // ... update, delete, getById
}
```

Para produção, substituir por implementação com:
- Supabase (já configurado no projeto)
- SQLite local
- SharedPreferences (para dados simples)

---

## 🎨 Design System

- **Tema**: Material 3 com suporte a modo claro/escuro
- **Cores principais**:
  - Blue `#2563EB`
  - Slate `#0F172A`
  - Amber `#F59E0B`
- **Componentes**:
  - Cards com elevação
  - Botões filled e text
  - Diálogos modais
  - FAB para ações primárias
  - Chips para tags/subcategorias

---

## 📊 Estrutura de Arquivos (Completa)

```
lib/features/
├── categories/
│   ├── domain/
│   │   ├── entities/
│   │   │   └── category.dart              # Entity com invariantes e regras
│   │   └── repositories/
│   │       └── category_repository.dart    # Interface do repositório
│   ├── data/
│   │   ├── dtos/
│   │   │   └── category_dto.dart          # DTO para backend
│   │   ├── mappers/
│   │   │   └── category_mapper.dart       # Conversões Entity ↔ DTO
│   │   └── repositories/
│   │       └── category_repository_impl.dart  # Implementação em memória
│   └── presentation/
│       ├── pages/
│       │   ├── category_list_page.dart    # Tela de listagem
│       │   └── category_edit_page.dart    # Tela de criação/edição
│       └── widgets/
│           └── category_detail_dialog.dart # Diálogo de detalhes
│
└── tags/
    ├── domain/
    │   ├── entities/
    │   │   └── tag.dart
    │   └── repositories/
    │       └── tag_repository.dart
    ├── data/
    │   ├── dtos/
    │   │   └── tag_dto.dart
    │   ├── mappers/
    │   │   └── tag_mapper.dart
    │   └── repositories/
    │       └── tag_repository_impl.dart
    └── presentation/
        ├── pages/
        │   ├── tag_list_page.dart
        │   └── tag_edit_page.dart
        └── widgets/
            └── tag_detail_dialog.dart
```

---

## ✅ Checklist de Implementação

### Category (Primeira Entidade)
- [x] Entity com invariantes e regras de negócio
- [x] DTO com serialização JSON
- [x] Mapper para conversões
- [x] Repository interface (domain)
- [x] Repository implementação (data)
- [x] Tela de listagem (presentation)
- [x] Diálogo de detalhes com 3 botões (presentation)
- [x] Tela de edição/criação (presentation)
- [x] Funcionalidade de remoção integrada
- [x] Navegação via Drawer
- [x] Rota configurada em main.dart

### Tag (Segunda Entidade)
- [x] Entity com invariantes e regras de negócio
- [x] DTO com serialização JSON
- [x] Mapper para conversões
- [x] Repository interface (domain)
- [x] Repository implementação (data)
- [x] Tela de listagem (presentation)
- [x] Diálogo de detalhes com 3 botões (presentation)
- [x] Tela de edição/criação (presentation)
- [x] Funcionalidade de remoção integrada
- [x] Navegação via Drawer
- [x] Rota configurada em main.dart

---

## 🔗 Links do Repositório GitHub

**Repositório**: https://github.com/rondijr/lembra-vencimentos

### Category CRUD:
1. Lista: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/presentation/pages/category_list_page.dart
2. Diálogo: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/presentation/widgets/category_detail_dialog.dart
3. Edição: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/presentation/pages/category_edit_page.dart
4. Repository: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/categories/data/repositories/category_repository_impl.dart

### Tag CRUD:
1. Lista: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/presentation/pages/tag_list_page.dart
2. Diálogo: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/presentation/widgets/tag_detail_dialog.dart
3. Edição: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/presentation/pages/tag_edit_page.dart
4. Repository: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/tags/data/repositories/tag_repository_impl.dart

### Navegação:
- Drawer: https://github.com/rondijr/lembra-vencimentos/blob/main/lib/features/deadlines/presentation/widgets/app_drawer.dart

---

## 📝 Observações Finais

- **Arquitetura**: Clean Architecture pura, separação clara de responsabilidades
- **Padrões**: Repository Pattern, DTO Pattern, Mapper Pattern
- **Testabilidade**: Camadas isoladas permitem testes unitários sem dependências
- **Escalabilidade**: Fácil adicionar novas entidades seguindo o mesmo padrão
- **Manutenibilidade**: Código organizado, fácil localizar e modificar funcionalidades

---

**Desenvolvido por**: Rondi Jr  
**Data**: Dezembro 2025  
**Disciplina**: Desenvolvimento Mobile com Flutter  
**Tema**: CRUD com Clean Architecture
