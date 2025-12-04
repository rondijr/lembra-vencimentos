# Lembra Vencimentos

**Aplicativo Flutter para gerenciar vencimentos de documentos**

## 📋 Sobre o Projeto

Propósito: lembrar vencimentos (RG, CNH, carteirinhas).  
Persona: aluno com prazos dispersos.  
Foco: avisos locais + sincronização com Supabase.

## 🎨 Design

- **Paleta de Cores**: 
  - Blue `#2563EB`
  - Slate `#0F172A`
  - Amber `#F59E0B`
- **Ícone**: Calendário com sino

## 🏗️ Arquitetura

O projeto segue Clean Architecture com separação em camadas:
- **Domain**: Entidades e repositórios
- **Data**: Implementação dos repositórios
- **Presentation**: UI e widgets

## 🚀 Primeiros Passos

1. Instale dependências: `flutter pub get`
2. Configure o Supabase (veja `SUPABASE_SETUP.md`)
3. Rode o app: `flutter run`
4. Na primeira execução, crie seu perfil

## 📦 Funcionalidades

- ✅ Cadastro de prazos com categoria
- ✅ Notificações locais 1 dia antes
- ✅ Perfil com foto
- ✅ Sincronização com Supabase
- ✅ Pull-to-refresh
- ✅ Clean Architecture
