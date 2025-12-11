# 📱 Lembra Vencimentos

**Aplicativo Flutter para gerenciar vencimentos de documentos com conformidade LGPD**

[![Flutter](https://img.shields.io/badge/Flutter-3.35.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.0+-0175C2?logo=dart)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Material%203-Compliant-6200EA)](https://m3.material.io/)
[![LGPD](https://img.shields.io/badge/LGPD-Compliant-green)](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709.htm)

---

## 📋 Sobre o Projeto

**Lembra Vencimentos** é um aplicativo completo para gerenciar vencimentos de documentos pessoais (RG, CNH, carteirinhas, etc.) com:

- 🔔 **Notificações locais** personalizadas
- ☁️ **Backup em nuvem** (Supabase) criptografado
- 📁 **Categorização inteligente** com tags
- 🛡️ **Conformidade LGPD** total (opt-in, versionamento, revogação)
- ♿ **Acessibilidade A11Y** (WCAG AA)
- 🎨 **Material Design 3** com tema escuro/claro

---

## 🎯 Destaques da Implementação

### ✅ Jornada de Primeira Execução Completa

```
Splash (2s) → Políticas → Onboarding (4 telas) → Consentimento LGPD → Home
```

- **Políticas**: Visualizador de Markdown com barra de progresso de leitura
- **Onboarding**: 4 telas com dots animados e swipe
- **Consentimento**: Opt-in individual com versionamento
- **Revogação**: Confirmação + Snackbar "Desfazer" (5s)

### 🎨 Identidade Visual Material 3

- **Primary**: Blue `#2563EB` (confiança)
- **Secondary**: Amber `#F59E0B` (atenção)
- **Background Dark**: Slate `#0F172A`
- **Success**: Emerald `#10B981`
- **Warning**: Orange `#F97316`
- **Error**: Red `#EF4444`

### 🏗️ Arquitetura Clean

```
UI Layer (Presentation)
    ↓
Service Layer (Business Logic)
    ↓
Storage Layer (PrefsService + Supabase)
```

---

## 📦 Funcionalidades

### Core
- ✅ Cadastro de documentos com foto, categoria e tags
- ✅ Notificações locais (1, 7, 15, 30 dias antes)
- ✅ Sincronização automática com Supabase
- ✅ Busca/filtro avançado
- ✅ Pull-to-refresh

### Onboarding/LGPD
- ✅ Splash screen com lógica de navegação
- ✅ Termos de Uso e Política de Privacidade em Markdown
- ✅ Onboarding de 4 telas com dots animados
- ✅ Consentimentos LGPD opt-in com versionamento
- ✅ Gerenciamento de privacidade (Settings)
- ✅ Revogação de consentimentos com confirmação
- ✅ Direito ao esquecimento (excluir todos os dados)

### Perfil
- ✅ Avatar personalizado (foto ou gerado por IA)
- ✅ Edição de nome e email
- ✅ Tema escuro/claro

---

## 🚀 Como Executar

### Pré-requisitos

```bash
Flutter SDK >= 3.35.0
Dart SDK >= 3.9.0
Android Studio / VS Code
```

### Instalação

```bash
# 1. Clone o repositório
git clone https://github.com/rondijr/lembra-vencimentos.git
cd lembra-vencimentos

# 2. Instale as dependências
flutter pub get

# 3. Configure o Supabase (opcional, para backup em nuvem)
# Veja: GUIA_SUPABASE_DETALHADO.md

# 4. Execute o app
flutter run
```

### Resetar Onboarding (para testes)

No código, adicione temporariamente:

```dart
import 'package:lembra_vencimentos/core/services/prefs_service.dart';

// No initState ou antes de navegar:
await PrefsService.resetOnboarding();
```

---

## 📚 Documentação

- **[PRD_LEMBRA_VENCIMENTOS.md](PRD_LEMBRA_VENCIMENTOS.md)** - Product Requirements Document completo
- **[IMPLEMENTACAO_PRD.md](IMPLEMENTACAO_PRD.md)** - Guia de implementação e componentes
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Arquitetura detalhada do projeto
- **[GUIA_SUPABASE_DETALHADO.md](GUIA_SUPABASE_DETALHADO.md)** - Setup do Supabase

---

## 🧩 Componentes Principais

### PrefsService
Gerenciamento centralizado de SharedPreferences com versionamento:

```dart
await PrefsService.setPolicyAccepted(version: "1.0.0", timestamp: DateTime.now());
await PrefsService.setConsentVersion(version: "1.0.0", consents: {...});
Map<String, bool>? consents = await PrefsService.getConsents();
```

### MarkdownViewerWidget
Visualizador de Markdown com barra de progresso:

```dart
MarkdownViewerWidget(
  markdownContent: content,
  onProgressChanged: (progress) => print('${(progress * 100).toInt()}%'),
  onScrollEnd: (hasReadToEnd) => print('Leu tudo!'),
)
```

### AnimatedDotsIndicator
Dots de progresso paramétricos:

```dart
AnimatedDotsIndicator(
  pageCount: 4,
  currentPage: _currentPage,
  activeColor: theme.colorScheme.primary,
  inactiveColor: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
)
```

---

## 🧪 Testes

```bash
# Testes unitários
flutter test

# Testes de integração
flutter drive --target=test_driver/app.dart

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 🛡️ Conformidade LGPD

Este app implementa totalmente a **Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018)**:

- ✅ **Consentimento explícito** (opt-in individual)
- ✅ **Versionamento** de termos e políticas
- ✅ **Revogação** de consentimentos a qualquer momento
- ✅ **Direito de acesso** (visualizar dados coletados)
- ✅ **Direito de portabilidade** (exportar em JSON)
- ✅ **Direito ao esquecimento** (excluir todos os dados)
- ✅ **Transparência** (políticas claras em PT-BR)

---

## ♿ Acessibilidade (A11Y)

- ✅ Contraste mínimo **WCAG AA** (4.5:1)
- ✅ Áreas clicáveis ≥ **48x48dp**
- ✅ Suporte a **leitores de tela** (Semantics)
- ✅ Labels descritivos em ícones
- ✅ Tamanho de fonte ajustável

---

## 📱 Screenshots

> TODO: Adicionar prints dos estados-chave

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

---

## 📄 Licença

Este projeto é proprietário. Todos os direitos reservados © 2025 Lembra Vencimentos.

---

## 📞 Contato

- **Email**: suporte@lembravencimentos.app
- **GitHub**: [@rondijr](https://github.com/rondijr)
- **Issues**: [Reportar bug](https://github.com/rondijr/lembra-vencimentos/issues)

---

## 🙏 Agradecimentos

- [Flutter Team](https://flutter.dev) - Framework incrível
- [Supabase](https://supabase.com) - Backend as a Service
- [Material Design](https://m3.material.io/) - Sistema de design

---

**Desenvolvido com ❤️ usando Flutter**
