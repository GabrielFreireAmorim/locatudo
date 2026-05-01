-- =============================================================
-- LocaTudo — Migration 002
-- Migra os campos de `profiles` para a tabela `users` já existente,
-- unificando as tabelas e apagando a antiga `profiles`.
-- =============================================================

-- -------------------------------------------------------------
-- 1. AJUSTA A TABELA users
-- -------------------------------------------------------------
-- Adiciona as colunas necessárias na tabela public.users
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS cpf               TEXT,
  ADD COLUMN IF NOT EXISTS address           TEXT,
  ADD COLUMN IF NOT EXISTS profile_image_url TEXT,
  ADD COLUMN IF NOT EXISTS updated_at        TIMESTAMPTZ DEFAULT NOW();

-- Comentários
COMMENT ON TABLE  public.users                    IS 'Tabela principal de usuários (unificada)';
COMMENT ON COLUMN public.users.cpf               IS 'CPF ou CNPJ do usuário (com máscara)';
COMMENT ON COLUMN public.users.address           IS 'Endereço completo montado pelo app';
COMMENT ON COLUMN public.users.profile_image_url IS 'URL pública do avatar no Storage (bucket avatars)';

-- -------------------------------------------------------------
-- 2. MIGRA OS DADOS E EXCLUI A TABELA profiles
-- -------------------------------------------------------------
-- (Opcional) Se houver dados em profiles, você poderia copiá-arlos para users:
-- UPDATE public.users u
-- SET cpf = p.cpf, address = p.address, profile_image_url = p.profile_image_url, updated_at = p.updated_at
-- FROM public.profiles p
-- WHERE u.id = p.id;

-- Exclui a tabela profiles, pois não será mais usada
DROP TABLE IF EXISTS public.profiles CASCADE;

-- -------------------------------------------------------------
-- 3. ROW LEVEL SECURITY (RLS) — users
-- -------------------------------------------------------------
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Usuário autenticado pode ler todos os usuários
DROP POLICY IF EXISTS "users_select_authenticated" ON public.users;
CREATE POLICY "users_select_authenticated"
  ON public.users FOR SELECT
  USING (auth.role() = 'authenticated');

-- Cada usuário só pode inserir o seu próprio registro
DROP POLICY IF EXISTS "users_insert_own" ON public.users;
CREATE POLICY "users_insert_own"
  ON public.users FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Cada usuário só pode atualizar o seu próprio registro
DROP POLICY IF EXISTS "users_update_own" ON public.users;
CREATE POLICY "users_update_own"
  ON public.users FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Cada usuário só pode deletar o seu próprio registro
DROP POLICY IF EXISTS "users_delete_own" ON public.users;
CREATE POLICY "users_delete_own"
  ON public.users FOR DELETE
  USING (auth.uid() = id);

-- -------------------------------------------------------------
-- 4. TRIGGER — atualiza updated_at automaticamente na users
-- -------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_users_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_users_updated_at ON public.users;
CREATE TRIGGER trg_users_updated_at
  BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_users_updated_at();

-- -------------------------------------------------------------
-- 5. TRIGGER — cria registro em public.users ao cadastrar em auth.users
-- -------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.users (id, name, email, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- O trigger trg_on_auth_user_created já existe (criado na migration anterior), 
-- mas a função handle_new_user foi substituída para inserir em public.users.
