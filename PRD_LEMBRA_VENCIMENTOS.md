# PRD - Lembra Vencimentos
**Product Requirements Document**

---

## 1. Visão Geral do Produto

### 1.1 Nome do Produto
**Lembra Vencimentos**

### 1.2 Descrição
Aplicativo móvel para gerenciamento inteligente de vencimentos de documentos pessoais (RG, CNH, carteirinhas, etc.), com notificações locais, backup em nuvem (Supabase), categorização avançada e total conformidade com LGPD.

### 1.3 Objetivo
Proporcionar uma experiência completa, acessível e segura para controle de vencimentos, desde o primeiro acesso (onboarding interativo + políticas de privacidade) até a gestão diária de documentos com lembretes personalizados.

---

## 2. Identidade Visual

### 2.1 Paleta de Cores (Material 3)

#### Cores Principais
- **Primary (Azul)**: `#2563EB` - Blue 600
  - Representa confiança, segurança e profissionalismo
  - Uso: AppBar, botões primários, links, elementos de destaque
  
- **Secondary (Âmbar)**: `#F59E0B` - Amber 500
  - Representa atenção, energia e alertas importantes
  - Uso: Badges de vencimento próximo, botões secundários, ícones de alerta

#### Cores de Superfície
- **Background (Claro)**: `#FFFFFF` - White
- **Background (Escuro)**: `#0F172A` - Slate 900
- **Surface (Claro)**: `#F8FAFC` - Slate 50
- **Surface (Escuro)**: `#1E293B` - Slate 800

#### Cores Semânticas
- **Success (Verde)**: `#10B981` - Emerald 500
  - Documentos válidos, ações concluídas
  
- **Warning (Laranja)**: `#F97316` - Orange 500
  - Vencimento próximo (7-30 dias)
  
- **Error (Vermelho)**: `#EF4444` - Red 500
  - Documentos vencidos, erros críticos
  
- **Info (Azul Claro)**: `#3B82F6` - Blue 500
  - Informações adicionais, dicas

#### Cores de Texto
- **Text Primary (Claro)**: `#0F172A` - Slate 900
- **Text Primary (Escuro)**: `#F8FAFC` - Slate 50
- **Text Secondary (Claro)**: `#64748B` - Slate 500
- **Text Secondary (Escuro)**: `#94A3B8` - Slate 400

### 2.2 Tipografia

#### Família de Fontes
- **Principal**: Roboto (nativa do Material Design)
- **Alternativa**: SF Pro (iOS), Segoe UI (Windows)

#### Hierarquia Tipográfica

| Estilo | Tamanho | Peso | Uso |
|--------|---------|------|-----|
| **Display Large** | 57sp | 400 | Títulos de splash/onboarding |
| **Headline Large** | 32sp | 700 | Títulos principais de tela |
| **Headline Medium** | 28sp | 600 | Subtítulos importantes |
| **Title Large** | 22sp | 500 | Títulos de cards/seções |
| **Title Medium** | 16sp | 500 | Títulos secundários |
| **Body Large** | 16sp | 400 | Textos principais |
| **Body Medium** | 14sp | 400 | Textos secundários |
| **Label Large** | 14sp | 500 | Botões, labels |
| **Label Medium** | 12sp | 500 | Labels pequenos |
| **Caption** | 12sp | 400 | Textos auxiliares |

### 2.3 Prompts de Imagens (Onboarding)

#### Tela 1: Bem-vindo
**Prompt**: "Modern flat illustration of a smiling person holding a smartphone with calendar notifications, colorful document icons floating around, minimalist style, blue and amber color scheme, positive vibes, 4k quality"

**Conceito**: Introdução amigável ao app, mostrando a centralização de documentos.

#### Tela 2: Organize seus Documentos
**Prompt**: "Flat design illustration of organized folders and documents neatly arranged on shelves, with color-coded labels (blue, amber, green), smartphone in the center showing app interface, clean and modern style, 4k"

**Conceito**: Enfatiza categorização e organização inteligente.

#### Tela 3: Nunca Mais Esqueça
**Prompt**: "Minimalist illustration of a large bell icon with notification waves, calendar with highlighted dates, person looking relieved and happy, blue and orange accent colors, modern flat style, 4k quality"

**Conceito**: Destaca o sistema de lembretes e notificações.

#### Tela 4: Backup Seguro
**Prompt**: "Clean illustration of a shield icon with lock symbol, cloud storage with encrypted files, secure connection lines, professional blue color scheme, trustworthy feel, modern flat design, 4k"

**Conceito**: Transmite segurança dos dados e backup em nuvem.

---

## 3. Jornada de Primeira Execução (First Run Experience)

### 3.1 Fluxo Completo
```
Splash Screen (2s)
    ↓
Tela de Políticas/Termos
    ↓ (aceite obrigatório)
Onboarding (4 telas com dots)
    ↓
Consentimento LGPD
    ↓ (opt-in obrigatório para funcionalidades)
Home (primeira execução)
```

### 3.2 Detalhamento por Etapa

#### 3.2.1 Splash Screen
**Duração**: 2 segundos  
**Elementos**:
- Logo centralizado do app
- Nome "Lembra Vencimentos"
- Gradiente de fundo (Blue 600 → Slate 900)
- Animação sutil de fade-in

**Lógica de Navegação**:
```dart
if (!hasAcceptedPolicies) → Políticas
else if (!hasSeenOnboarding) → Onboarding
else if (!hasAcceptedConsent) → Consentimento
else → Home
```

#### 3.2.2 Tela de Políticas/Termos
**Componentes**:
- Viewer de Markdown com scroll
- Barra de progresso de leitura (horizontal, topo)
- Checkbox "Li e aceito os Termos de Uso e Política de Privacidade"
- Botão "Continuar" (habilitado somente se rolou até o fim + checkbox marcado)

**Documentos**:
1. **Termos de Uso** (`assets/policies/terms_of_use.md`)
2. **Política de Privacidade** (`assets/policies/privacy_policy.md`)

**Persistência**:
```dart
PrefsService.setPolicyAccepted(version: "1.0.0", timestamp: DateTime.now())
```

#### 3.2.3 Onboarding (4 Telas)
**Navegação**: Swipe horizontal (PageView) + dots indicadores animados

**Tela 1**: Bem-vindo ao Lembra Vencimentos  
- Imagem ilustrativa (onboarding_1.png)
- Título: "Bem-vindo!"
- Descrição: "Gerencie todos os vencimentos de seus documentos em um só lugar"

**Tela 2**: Organize seus Documentos  
- Imagem ilustrativa (onboarding_2.png)
- Título: "Organize Tudo"
- Descrição: "Categorize documentos, adicione tags personalizadas e encontre rapidamente o que precisa"

**Tela 3**: Nunca Mais Esqueça  
- Imagem ilustrativa (onboarding_3.png)
- Título: "Lembretes Inteligentes"
- Descrição: "Receba notificações personalizadas antes dos vencimentos e fique sempre em dia"

**Tela 4**: Backup Seguro  
- Imagem ilustrativa (onboarding_4.png)
- Título: "Seus Dados Seguros"
- Descrição: "Backup automático em nuvem criptografada e acesso de qualquer dispositivo"
- Botão: "Começar" (em vez de "Próximo")

**Dots de Progresso**:
- Paramétricos (aceita número variável de páginas)
- Animação de transição suave entre dots
- Dot ativo: maior + cor Primary
- Dots inativos: menores + cor Secondary com opacidade

**Persistência**:
```dart
PrefsService.setOnboardingSeen(true)
```

#### 3.2.4 Consentimento LGPD
**Componentes**:
- Título: "Suas Escolhas, Sua Privacidade"
- Texto explicativo sobre coleta de dados
- Lista de consentimentos (opt-in individual):
  - [ ] **Essencial**: Armazenamento local de documentos (obrigatório)
  - [ ] **Backup em Nuvem**: Sincronização com Supabase
  - [ ] **Notificações**: Lembretes de vencimentos
  - [ ] **Análise de Uso**: Dados anônimos para melhorias (opcional)

**Ações**:
- Botão "Aceitar Selecionados" (primário)
- Link "Gerenciar Consentimentos" (disponível em Configurações)

**Versionamento**:
```dart
PrefsService.setConsentVersion(
  version: "1.0.0",
  timestamp: DateTime.now(),
  consents: {
    'essential': true,
    'cloud_backup': true,
    'notifications': true,
    'analytics': false,
  }
)
```

**Revogação**:
- Disponível em Configurações > Privacidade
- Modal de confirmação: "Tem certeza? Isso pode afetar funcionalidades do app"
- Snackbar com ação "Desfazer" (5 segundos)

---

## 4. Requisitos Funcionais (RF)

### RF01 - Gestão de Vencimentos
- [ ] Criar, editar, excluir documentos/vencimentos
- [ ] Campos: nome, categoria, data de vencimento, imagem (opcional), tags
- [ ] Upload de foto do documento (até 5MB, otimizada)
- [ ] Busca/filtro por nome, categoria, tag, status

### RF02 - Categorização
- [ ] Categorias pré-definidas: RG, CNH, Carteira de Trabalho, Planos de Saúde, Outros
- [ ] Criar categorias personalizadas
- [ ] Ícones e cores distintos por categoria

### RF03 - Sistema de Notificações
- [ ] Notificações locais (flutter_local_notifications)
- [ ] Configuração de antecedência: 1, 7, 15, 30 dias antes
- [ ] Horário padrão: 9h00 (personalizável)
- [ ] Snooze de notificação (1h, 1 dia)

### RF04 - Backup em Nuvem
- [ ] Sincronização automática com Supabase
- [ ] Sincronização manual sob demanda
- [ ] Indicador de status de sincronização
- [ ] Conflito de dados: última modificação prevalece

### RF05 - Perfil de Usuário
- [ ] Avatar personalizado (foto ou gerado por IA)
- [ ] Nome de exibição
- [ ] E-mail (opcional, para backup)
- [ ] Edição de perfil

### RF06 - Configurações
- [ ] Modo escuro/claro
- [ ] Idioma (PT-BR)
- [ ] Notificações (ativar/desativar, horário)
- [ ] Gerenciamento de consentimentos LGPD
- [ ] Limpar dados locais
- [ ] Exportar dados (JSON)

### RF07 - Onboarding/Políticas
- [ ] Splash screen com verificação de primeiro acesso
- [ ] Viewer de políticas em Markdown com barra de leitura
- [ ] Onboarding de 4 telas com dots animados
- [ ] Consentimento LGPD com versionamento
- [ ] Opção de rever políticas nas Configurações

---

## 5. Requisitos Não Funcionais (RNF)

### RNF01 - Material Design 3
- Seguir guidelines do Material 3 (Material You)
- Componentes: Cards, FAB, AppBar, BottomSheet, Dialogs
- Elevação e sombras consistentes
- Ripple effect em interações

### RNF02 - Acessibilidade (A11Y)
- Contraste mínimo WCAG AA (4.5:1 para texto normal)
- Todos os elementos clicáveis: área mínima 48x48dp
- Suporte a leitores de tela (Semantics)
- Labels descritivos em ícones e botões
- Navegação por teclado (web/desktop)
- Tamanho de fonte ajustável (respeitar configuração do sistema)

### RNF03 - Performance
- Tempo de carregamento do splash: máx. 2s
- Transições de tela: 300ms (suaves)
- Imagens otimizadas (compressão 85%, max 1080p)
- Listagens: paginação/lazy loading para +100 itens
- Cache de imagens (cached_network_image)

### RNF04 - Segurança/LGPD
- Dados sensíveis criptografados localmente (AES-256)
- Conexões HTTPS obrigatórias (Supabase)
- Remoção de metadados EXIF de fotos
- Política de retenção: dados excluídos permanentemente em 30 dias
- Consentimento opt-in explícito
- Direito de portabilidade (exportação JSON)
- Direito ao esquecimento (limpar todos os dados)

### RNF05 - Usabilidade
- Máximo 3 toques para alcançar qualquer funcionalidade
- Feedback visual em todas as ações (loading, sucesso, erro)
- Mensagens de erro claras e acionáveis
- Confirmação para ações destrutivas (excluir)
- Desfazer ações críticas (snackbar com "Desfazer")

### RNF06 - Compatibilidade
- Android 5.0+ (API 21+)
- iOS 12.0+
- Responsivo (smartphones e tablets)
- Orientação: portrait (preferencial), landscape (suportado)

---

## 6. Arquitetura Técnica

### 6.1 Camadas
```
UI (Presentation Layer)
    ↓ (chama métodos)
Service Layer (Business Logic)
    ↓ (persiste dados)
Storage Layer (Data Persistence)
```

### 6.2 Componentes Principais

#### PrefsService
**Responsabilidade**: Gerenciar SharedPreferences de forma centralizada

**Métodos**:
```dart
// Onboarding
Future<void> setPolicyAccepted(String version, DateTime timestamp)
Future<bool> isPolicyAccepted()
Future<String?> getPolicyVersion()

Future<void> setOnboardingSeen(bool seen)
Future<bool> hasSeenOnboarding()

// Consentimento LGPD
Future<void> setConsentVersion(String version, Map<String, bool> consents, DateTime timestamp)
Future<Map<String, bool>?> getConsents()
Future<String?> getConsentVersion()
Future<void> revokeConsent(String consentKey)

// Tema
Future<void> setDarkMode(bool isDark)
Future<bool> isDarkMode()

// Usuário
Future<void> setUserId(String id)
Future<String?> getUserId()

// Notificações
Future<void> setNotificationsEnabled(bool enabled)
Future<bool> areNotificationsEnabled()
```

#### OnboardingService
**Responsabilidade**: Lógica de negócio do onboarding

**Métodos**:
```dart
Future<bool> shouldShowOnboarding()
Future<void> completeOnboarding()
Future<NavigationTarget> getInitialRoute()
```

#### MarkdownViewerWidget
**Responsabilidade**: Visualizar políticas em Markdown com barra de leitura

**Props**:
```dart
final String markdownContent;
final Function(bool hasReadToEnd) onScrollEnd;
final double readProgress; // 0.0 a 1.0
```

#### AnimatedDotsIndicator
**Responsabilidade**: Dots de progresso paramétricos/animados

**Props**:
```dart
final int pageCount;
final int currentPage;
final Color activeColor;
final Color inactiveColor;
final double activeDotSize;
final double inactiveDotSize;
final Duration animationDuration;
```

---

## 7. Especificação de Componentes

### 7.1 PrefsService (Storage)

**Arquivo**: `lib/core/services/prefs_service.dart`

**Responsabilidades**:
- Centralizar acesso ao SharedPreferences
- Prover métodos tipados para cada dado persistido
- Gerenciar versionamento de políticas e consentimentos

**Chaves de Armazenamento**:
```dart
static const String _keyPolicyAccepted = 'policy_accepted';
static const String _keyPolicyVersion = 'policy_version';
static const String _keyPolicyTimestamp = 'policy_timestamp';

static const String _keyOnboardingSeen = 'has_seen_onboarding';

static const String _keyConsentVersion = 'consent_version';
static const String _keyConsentTimestamp = 'consent_timestamp';
static const String _keyConsentData = 'consent_data'; // JSON Map

static const String _keyDarkMode = 'dark_mode';
static const String _keyUserId = 'user_id';
static const String _keyNotificationsEnabled = 'notifications_enabled';
```

### 7.2 Tela de Políticas

**Arquivo**: `lib/features/onboarding/presentation/pages/policies_page.dart`

**Componentes**:
- AppBar com título "Termos e Políticas"
- MarkdownViewerWidget (corpo da tela)
- LinearProgressIndicator (topo, mostra % de leitura)
- CheckboxListTile ("Li e aceito...")
- ElevatedButton ("Continuar", habilitado se lido 100% + checkbox)

**Regras**:
1. Carregar arquivo Markdown de `assets/policies/combined.md`
2. Listener de scroll para atualizar barra de progresso
3. Habilitar checkbox somente após scroll até o fim
4. Salvar versão, timestamp e aceite ao clicar "Continuar"

### 7.3 Tela de Onboarding

**Arquivo**: `lib/features/onboarding/presentation/pages/onboarding_page.dart`

**Componentes**:
- PageView.builder (swipe horizontal)
- AnimatedDotsIndicator (footer)
- Botão "Próximo" (páginas 1-3) / "Começar" (página 4)
- Botão "Pular" (canto superior direito, opcional)

**Páginas**:
```dart
List<OnboardingContent> pages = [
  OnboardingContent(
    image: 'assets/images/onboarding_1.png',
    title: 'Bem-vindo!',
    description: 'Gerencie todos os vencimentos de seus documentos em um só lugar',
  ),
  // ... (4 páginas no total)
];
```

**Animações**:
- Transição de página: Curves.easeInOut
- Dots: AnimatedContainer com duração 300ms

### 7.4 Tela de Consentimento LGPD

**Arquivo**: `lib/features/onboarding/presentation/pages/consent_page.dart`

**Componentes**:
- Título e texto explicativo
- Lista de SwitchListTile (uma para cada consentimento)
- Botão "Aceitar Selecionados"
- Link "Ver Política de Privacidade"

**Consentimentos**:
```dart
enum ConsentType {
  essential, // Obrigatório (sempre true, switch desabilitado)
  cloudBackup,
  notifications,
  analytics,
}
```

**Persistência**:
```dart
Map<String, bool> consents = {
  'essential': true,
  'cloud_backup': _switchBackup,
  'notifications': _switchNotifications,
  'analytics': _switchAnalytics,
};
await PrefsService.setConsentVersion('1.0.0', consents, DateTime.now());
```

### 7.5 Revogação de Consentimento (Settings)

**Arquivo**: `lib/features/settings/presentation/pages/privacy_settings_page.dart`

**Componentes**:
- Lista de consentimentos atuais (leitura de PrefsService)
- Botão "Revogar Consentimento X" (com modal de confirmação)
- Snackbar com "Desfazer" (5s de timeout)

**Fluxo de Revogação**:
1. Usuário clica "Revogar Backup em Nuvem"
2. Modal: "Tem certeza? Seus dados não serão mais sincronizados"
3. Se confirmar:
   - Atualizar PrefsService
   - Mostrar Snackbar com "Desfazer"
   - Timer de 5s: se não clicar "Desfazer", efetiva a revogação
   - Executar ação reversa (ex: desabilitar sync no SupabaseService)

---

## 8. Assets e Recursos

### 8.1 Políticas (Markdown)

**Arquivos**:
- `assets/policies/terms_of_use.md`
- `assets/policies/privacy_policy.md`

**Atualizar `pubspec.yaml`**:
```yaml
flutter:
  assets:
    - assets/policies/
    - assets/images/
    - assets/icons/
```

### 8.2 Imagens de Onboarding

**Localização**: `assets/images/`
- `onboarding_1.png` (1080x1080px, otimizada)
- `onboarding_2.png`
- `onboarding_3.png`
- `onboarding_4.png`

**Geração**: Usar DALL-E, Midjourney ou Ideogram com os prompts definidos na seção 2.3

### 8.3 Ícone do App

**Ferramenta**: `flutter_launcher_icons`

**Configuração** (já presente em `pubspec.yaml`):
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#0F172A"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"
```

**Design do Ícone**:
- Conceito: Sino + calendário + notificação
- Cores: Gradiente Blue 600 → Amber 500
- Estilo: Flat, minimalista, reconhecível em 48x48px

**Comando para gerar**:
```bash
flutter pub run flutter_launcher_icons
```

---

## 9. Dependências do Projeto

### Principais
- `shared_preferences: ^2.0.15` - Armazenamento local
- `flutter_local_notifications: ^17.2.3` - Notificações
- `supabase_flutter: ^2.5.1` - Backend/sincronização
- `provider: ^6.1.1` - Gerenciamento de estado
- `intl: ^0.18.0` - Formatação de datas
- `dots_indicator: ^3.0.0` - Dots de onboarding
- `flutter_markdown: ^0.6.14` - Viewer de políticas *(adicionar)*
- `image: ^4.1.7` - Otimização de imagens

### Dev
- `flutter_launcher_icons: ^0.13.1` - Geração de ícones
- `flutter_test` - Testes unitários

---

## 10. Fluxo de Testes/Evidências

### 10.1 Estados-Chave para Capturar

1. **Splash Screen** (durante animação)
2. **Tela de Políticas** (início, meio scroll, fim + checkbox habilitado)
3. **Onboarding** (cada uma das 4 telas + dots)
4. **Consentimento LGPD** (lista de consentimentos)
5. **Home (primeira vez)** (vazia, com FAB)
6. **Modal de Revogação** (confirmação)
7. **Snackbar de Desfazer** (após revogação)
8. **Configurações > Privacidade** (lista de consentimentos atuais)

### 10.2 Checklist de Validação

- [ ] Splash redireciona corretamente baseado em flags de PrefsService
- [ ] Políticas: barra de progresso atualiza, botão habilita somente após 100% + checkbox
- [ ] Onboarding: swipe funciona, dots animam, "Começar" na última página
- [ ] Consentimento: valores salvos corretamente, essencial obrigatório
- [ ] Revogação: modal confirma, snackbar com "Desfazer" aparece, timeout funciona
- [ ] Tema escuro/claro aplica cores corretas da paleta
- [ ] Acessibilidade: VoiceOver/TalkBack lê todos os elementos
- [ ] Performance: splash máx 2s, transições suaves 300ms

---

## 11. Critérios de Aceitação

### 11.1 Identidade Visual
- [x] Paleta de cores Material 3 definida e documentada
- [x] Tipografia hierárquica estabelecida
- [x] Prompts de imagens criados para onboarding

### 11.2 Jornada de Primeira Execução
- [ ] Splash com animação e lógica de navegação
- [ ] Viewer de políticas com barra de leitura funcional
- [ ] Onboarding de 4 telas com dots animados
- [ ] Consentimento LGPD com versionamento e persistência

### 11.3 Arquitetura e Código
- [ ] PrefsService implementado e centralizado
- [ ] Componentes reutilizáveis (MarkdownViewer, AnimatedDots)
- [ ] Navegação fluída entre telas
- [ ] Código limpo, comentado e seguindo boas práticas

### 11.4 Acessibilidade e LGPD
- [ ] Contraste WCAG AA em todos os textos
- [ ] Áreas clicáveis ≥ 48x48dp
- [ ] Labels semânticos para leitores de tela
- [ ] Consentimento opt-in explícito
- [ ] Revogação com confirmação e "Desfazer"

### 11.5 Entregáveis
- [x] PRD completo (este documento)
- [ ] Código-fonte funcional
- [ ] Ícone do app gerado
- [ ] Screenshots/evidências dos estados-chave
- [ ] README com instruções de build e execução

---

## 12. Roadmap de Implementação

### Fase 1: Fundação (Semana 1)
- [x] Definir PRD e identidade visual
- [ ] Criar PrefsService
- [ ] Implementar Splash Screen com lógica de navegação
- [ ] Criar arquivos de políticas em Markdown

### Fase 2: Onboarding (Semana 2)
- [ ] Desenvolver MarkdownViewerWidget
- [ ] Implementar tela de Políticas
- [ ] Criar AnimatedDotsIndicator
- [ ] Desenvolver tela de Onboarding (4 páginas)

### Fase 3: Consentimento LGPD (Semana 3)
- [ ] Implementar tela de Consentimento
- [ ] Criar página de Privacidade em Configurações
- [ ] Desenvolver fluxo de revogação com "Desfazer"
- [ ] Testes de versionamento

### Fase 4: Polimento (Semana 4)
- [ ] Gerar ícone do app (flutter_launcher_icons)
- [ ] Criar imagens de onboarding (DALL-E/Midjourney)
- [ ] Testes de acessibilidade (VoiceOver, TalkBack)
- [ ] Capturar evidências (screenshots)
- [ ] Documentação final

---

## 13. Referências

- [Material Design 3](https://m3.material.io/)
- [Flutter Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [LGPD - Lei Geral de Proteção de Dados](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material You Color System](https://m3.material.io/styles/color/overview)

---

**Versão do Documento**: 1.0.0  
**Data de Criação**: 11 de dezembro de 2025  
**Autor**: GitHub Copilot (Agente de IA)  
**Status**: ✅ Completo e Pronto para Implementação
