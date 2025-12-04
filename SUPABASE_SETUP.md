# Configuração do Supabase

## Passo 1: Criar conta e projeto no Supabase

1. Acesse https://app.supabase.com
2. Crie uma conta (gratuita)
3. Clique em "New Project"
4. Escolha um nome, senha do banco e região
5. Aguarde o projeto ser criado (~2 minutos)

## Passo 2: Obter credenciais

1. No painel do projeto, vá em **Settings** (ícone de engrenagem)
2. Clique em **API**
3. Copie:
   - **Project URL** (algo como: `https://xxxxx.supabase.co`)
   - **anon public** key (chave longa começando com `eyJ...`)

## Passo 3: Configurar no app

1. Abra o arquivo `lib/core/config/supabase_config.dart`
2. Substitua:
   ```dart
   static const String supabaseUrl = 'SUA_URL_AQUI';
   static const String supabaseAnonKey = 'SUA_ANON_KEY_AQUI';
   ```
   Por suas credenciais reais.

## Passo 4: Criar tabela no banco

1. No Supabase, vá em **SQL Editor** (ícone `</>`)
2. Clique em **New Query**
3. Copie todo o conteúdo do arquivo `supabase_setup.sql` (na raiz do projeto)
4. Cole no editor e clique em **Run**
5. Você deve ver: "Success. No rows returned"

## Passo 5: Testar instalação das dependências

```bash
cd c:\projeto\lembra_vencimentos
flutter pub get
```

## Passo 6: Executar o app

```bash
flutter run
```

## Como funciona

### Autenticação Anônima (padrão)
- O app usa autenticação anônima do Supabase
- Cada usuário recebe um ID único automaticamente
- Não precisa criar conta ou fazer login

### Sincronização Híbrida
- **Cache local (SharedPreferences)**: dados salvos no dispositivo para acesso offline
- **Supabase**: backup na nuvem e sincronização entre dispositivos
- Se a conexão falhar, o app continua funcionando com dados locais

### Segurança (Row Level Security)
- Cada usuário só acessa seus próprios deadlines
- Políticas RLS aplicadas automaticamente no banco
- Dados criptografados em trânsito (HTTPS)

## Recursos Avançados (Opcional)

### Habilitar autenticação com email

No arquivo `lib/features/onboarding/presentation/pages/onboarding_page.dart`, adicione:

```dart
final supabaseService = SupabaseService();
await supabaseService.signUpWithEmail('user@email.com', 'senha123');
```

### Sincronização em tempo real

Use `DeadlinesSyncRepository.watchDeadlines()` para receber atualizações instantâneas quando outro dispositivo modificar os dados.

## Troubleshooting

### "Invalid API key"
- Verifique se copiou a anon key corretamente (é uma string muito longa)
- Confirme que não há espaços extras no início/fim

### "relation deadlines does not exist"
- Execute o SQL do arquivo `supabase_setup.sql` no SQL Editor

### App funciona mas não sincroniza
- Verifique conexão com internet
- Confira se o Supabase URL está correto
- Veja logs no terminal: `flutter run -v`

## Custo

O plano gratuito do Supabase inclui:
- 500 MB de banco de dados
- 1 GB de armazenamento
- 2 GB de transferência/mês
- Projetos pausados após 1 semana de inatividade

Mais que suficiente para uso pessoal! 🎉
