-- Execute este SQL no Supabase SQL Editor
-- Acesse: https://app.supabase.com > seu projeto > SQL Editor

-- 1. Cria a tabela de usuários (perfis)
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  age INTEGER NOT NULL,
  photo_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Cria a tabela de deadlines
CREATE TABLE IF NOT EXISTS deadlines (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  date TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Habilita Row Level Security (RLS) - mas com acesso público
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE deadlines ENABLE ROW LEVEL SECURITY;

-- 4. Políticas de segurança: permite acesso público (sem autenticação)
-- ATENÇÃO: Isso permite que qualquer um insira/leia/delete dados
-- Use apenas para desenvolvimento/teste ou apps pessoais

-- Políticas para users
CREATE POLICY "Permitir leitura pública users"
  ON users FOR SELECT
  USING (true);

CREATE POLICY "Permitir inserção pública users"
  ON users FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Permitir atualização pública users"
  ON users FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Permitir deleção pública users"
  ON users FOR DELETE
  USING (true);

-- Políticas para deadlines
CREATE POLICY "Permitir leitura pública deadlines"
  ON deadlines FOR SELECT
  USING (true);

CREATE POLICY "Permitir inserção pública deadlines"
  ON deadlines FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Permitir atualização pública deadlines"
  ON deadlines FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Permitir deleção pública deadlines"
  ON deadlines FOR DELETE
  USING (true);

-- 5. Índices para melhor performance
CREATE INDEX IF NOT EXISTS users_name_idx ON users(name);
CREATE INDEX IF NOT EXISTS deadlines_user_id_idx ON deadlines(user_id);
CREATE INDEX IF NOT EXISTS deadlines_date_idx ON deadlines(date);

-- 6. Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deadlines_updated_at
  BEFORE UPDATE ON deadlines
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 7. Habilita realtime (para sincronização em tempo real)
ALTER PUBLICATION supabase_realtime ADD TABLE users;
ALTER PUBLICATION supabase_realtime ADD TABLE deadlines;