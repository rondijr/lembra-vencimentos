-- Execute este SQL no Supabase SQL Editor
-- Acesse: https://app.supabase.com > seu projeto > SQL Editor

-- 1. Cria a tabela de categorias
CREATE TABLE IF NOT EXISTS categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  icon_code INTEGER NOT NULL,
  color_value INTEGER NOT NULL,
  subcategories JSONB DEFAULT '[]'::jsonb,
  user_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Habilita Row Level Security (RLS) - mas com acesso público
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- 3. Políticas de segurança: permite acesso público (sem autenticação)
-- ATENÇÃO: Isso permite que qualquer um insira/leia/delete dados
-- Use apenas para desenvolvimento/teste ou apps pessoais

CREATE POLICY "Permitir leitura pública categories"
  ON categories FOR SELECT
  USING (true);

CREATE POLICY "Permitir inserção pública categories"
  ON categories FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Permitir atualização pública categories"
  ON categories FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Permitir deleção pública categories"
  ON categories FOR DELETE
  USING (true);

-- 4. Índices para melhor performance
CREATE INDEX IF NOT EXISTS categories_name_idx ON categories(name);
CREATE INDEX IF NOT EXISTS categories_user_id_idx ON categories(user_id);

-- 5. Trigger para atualizar updated_at automaticamente
CREATE OR REPLACE FUNCTION update_categories_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_categories_updated_at
  BEFORE UPDATE ON categories
  FOR EACH ROW
  EXECUTE FUNCTION update_categories_updated_at();

-- 6. Habilita realtime (para sincronização em tempo real)
ALTER PUBLICATION supabase_realtime ADD TABLE categories;
