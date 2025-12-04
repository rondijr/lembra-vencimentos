# 🚀 GUIA COMPLETO: Configurar Supabase para o App

## ✅ PASSO 1: Habilitar Autenticação Anônima

### 1.1 Acessar o Supabase
- Abra o navegador e vá para: **https://app.supabase.com**
- Faça login na sua conta
- Você verá uma lista de projetos

### 1.2 Selecionar seu Projeto
- Clique no card do seu projeto (o nome aparece no card)
- Você será levado para o Dashboard do projeto

### 1.3 Ir para Authentication
- No menu lateral ESQUERDO, procure o ícone de **pessoa/usuário** 🔐
- Clique em **Authentication** (Autenticação)
- Um submenu vai abrir

### 1.4 Configurar Providers
- No submenu de Authentication, clique em **Providers**
- Você verá uma lista de métodos de autenticação (Email, Google, GitHub, etc.)
- **Role a página para baixo** até encontrar **"Anonymous"**

### 1.5 Habilitar Anonymous
- Clique na linha **"Anonymous"** para expandir
- Você verá um toggle/switch com texto "Enable Anonymous sign-ins"
- **Clique para ATIVAR** o toggle (deve ficar verde/azul)
- Clique no botão **"Save"** no canto inferior direito
- ✅ Pronto! Autenticação anônima habilitada

---

## ✅ PASSO 2: Criar a Tabela no Banco de Dados

### 2.1 Ir para SQL Editor
- No menu lateral ESQUERDO, procure o ícone **</> SQL Editor**
- Clique em **SQL Editor**

### 2.2 Criar Nova Query
- No topo da página, clique no botão **"+ New query"** (ou "+ Nova consulta")
- Uma área de texto em branco vai aparecer

### 2.3 Copiar o SQL
- Abra o arquivo `supabase_setup.sql` na raiz do seu projeto
- **Selecione TODO o conteúdo** (Ctrl+A)
- **Copie** (Ctrl+C)

### 2.4 Colar e Executar
- Volte para o Supabase SQL Editor
- **Cole** o SQL na área de texto (Ctrl+V)
- Clique no botão **"Run"** (ou "Executar") no canto inferior direito
- Você verá uma mensagem: **"Success. No rows returned"** ✅

### 2.5 Verificar a Tabela
- No menu lateral ESQUERDO, clique em **"Table Editor"** (Editor de Tabelas)
- Você deve ver uma tabela chamada **"deadlines"** na lista
- Clique nela para ver a estrutura (id, user_id, title, category, date, etc.)

---

## ✅ PASSO 3: Testar o App

### 3.1 Reiniciar o App
- No terminal do VS Code, pressione **"R"** (hot restart)
- Ou pare o app (Ctrl+C) e execute: `flutter run`

### 3.2 Verificar nos Logs
Você deve ver no terminal:
```
✅ Autenticado anonimamente no Supabase
📦 Prazos existentes antes de adicionar: X
💾 Prazo salvo no SharedPreferences
✅ Prazo salvo: [nome] - [categoria] - [data]
✅ Notificação agendada para: [data]
```

### 3.3 Adicionar um Prazo de Teste
- No app, clique no botão **"+"** (amarelo)
- Preencha:
  - Descrição: "Teste Supabase"
  - Categoria: "RG"
  - Data: qualquer data futura
- Clique em **"Salvar Prazo"**
- Você verá: "Prazo 'Teste Supabase' salvo com sucesso!"

### 3.4 Verificar no Supabase
- Volte para o Supabase
- Vá em **Table Editor** > **deadlines**
- Clique no botão **"Refresh"** (🔄) se necessário
- Você deve ver o prazo "Teste Supabase" na tabela! 🎉

---

## 🆘 TROUBLESHOOTING (Resolução de Problemas)

### ❌ Erro: "Anonymous sign-ins are disabled"
**Solução:** Volte ao PASSO 1 e certifique-se de:
1. Ter clicado em Authentication > Providers
2. Encontrado "Anonymous" na lista
3. ATIVADO o toggle
4. Clicado em "Save"

### ❌ Erro: "relation deadlines does not exist"
**Solução:** Volte ao PASSO 2 e:
1. Copie TODO o conteúdo de `supabase_setup.sql`
2. Cole no SQL Editor
3. Clique em "Run"
4. Verifique se diz "Success"

### ❌ Erro: "permission denied for table deadlines"
**Solução:** As políticas RLS não foram criadas. Execute o SQL novamente (PASSO 2).

### ❌ App salva mas não aparece no Supabase
**Verifique:**
1. Autenticação anônima está habilitada? (PASSO 1.5)
2. O app mostrou "✅ Autenticado anonimamente" nos logs?
3. Tem conexão com internet?
4. As credenciais em `lib/core/config/supabase_config.dart` estão corretas?

---

## 📱 Verificar se Está Funcionando

Execute este checklist:

- [ ] No Supabase: Authentication > Providers > Anonymous está HABILITADO
- [ ] No Supabase: Table Editor mostra a tabela "deadlines"
- [ ] No app: Logs mostram "✅ Autenticado anonimamente no Supabase"
- [ ] No app: Consegue adicionar um prazo sem erros
- [ ] No Supabase: Table Editor > deadlines mostra o prazo adicionado

Se todos os itens estiverem marcados, **ESTÁ FUNCIONANDO!** 🎉

---

## 📞 Ainda Não Funcionou?

Me envie uma captura de tela de:
1. Supabase > Authentication > Providers (mostrando Anonymous)
2. Supabase > Table Editor (mostrando se tem a tabela deadlines)
3. Terminal do VS Code (mostrando os logs quando você adiciona um prazo)

Ou me diga qual erro específico está aparecendo!
