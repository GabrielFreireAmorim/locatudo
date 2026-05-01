-- =============================================================
-- LocaTudo — Migration 001
-- Ajusta a tabela `profiles` e configura o bucket `avatars`
-- Execute este script no SQL Editor do Supabase Dashboard
-- =============================================================

-- -------------------------------------------------------------
-- 1. TABELA profiles
-- -------------------------------------------------------------

-- Cria a tabela caso ainda não exista
CREATE TABLE IF NOT EXISTS public.profiles (
  id               UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name             TEXT,
  email            TEXT,
  cpf              TEXT,
  address          TEXT,
  profile_image_url TEXT,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW()
);

-- Garante as colunas novas em tabelas já existentes (idempotente)
ALTER TABLE public.profiles
  ADD COLUMN IF NOT EXISTS cpf               TEXT,
  ADD COLUMN IF NOT EXISTS address           TEXT,
  ADD COLUMN IF NOT EXISTS profile_image_url TEXT,
  ADD COLUMN IF NOT EXISTS updated_at        TIMESTAMPTZ DEFAULT NOW();

-- Comentários para documentação
COMMENT ON TABLE  public.profiles                    IS 'Perfis dos usuários cadastrados no LocaTudo';
COMMENT ON COLUMN public.profiles.cpf               IS 'CPF ou CNPJ do usuário (com máscara)';
COMMENT ON COLUMN public.profiles.address           IS 'Endereço completo montado pelo app';
COMMENT ON COLUMN public.profiles.profile_image_url IS 'URL pública do avatar no Storage (bucket avatars)';

-- -------------------------------------------------------------
-- 2. ROW LEVEL SECURITY (RLS) — profiles
-- -------------------------------------------------------------

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Usuário autenticado pode ler todos os perfis (exibição de locadores/locatários)
DROP POLICY IF EXISTS "profiles_select_authenticated" ON public.profiles;
CREATE POLICY "profiles_select_authenticated"
  ON public.profiles FOR SELECT
  USING (auth.role() = 'authenticated');

-- Cada usuário só pode inserir/atualizar/deletar o seu próprio perfil
DROP POLICY IF EXISTS "profiles_insert_own" ON public.profiles;
CREATE POLICY "profiles_insert_own"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;
CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_delete_own" ON public.profiles;
CREATE POLICY "profiles_delete_own"
  ON public.profiles FOR DELETE
  USING (auth.uid() = id);

-- -------------------------------------------------------------
-- 3. TRIGGER — atualiza updated_at automaticamente
-- -------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profiles_updated_at ON public.profiles;
CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- -------------------------------------------------------------
-- 4. TRIGGER — cria registro em profiles ao cadastrar usuário
--    (cobre tanto e-mail/senha quanto Google Sign-In)
-- -------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, created_at, updated_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', ''),
    NEW.email,
    NOW(),
    NOW()
  )
  ON CONFLICT (id) DO NOTHING;   -- não sobrescreve se já existir
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_on_auth_user_created ON auth.users;
CREATE TRIGGER trg_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- -------------------------------------------------------------
-- 5. STORAGE — bucket `avatars`
-- -------------------------------------------------------------

-- Cria o bucket público (se ainda não existir)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  TRUE,                              -- acesso público para leitura via URL
  2097152,                           -- limite de 2 MB por arquivo
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE
  SET public            = TRUE,
      file_size_limit   = 2097152,
      allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

-- -------------------------------------------------------------
-- 6. ROW LEVEL SECURITY — bucket avatars
-- -------------------------------------------------------------

-- Leitura pública (necessário porque o bucket é público)
DROP POLICY IF EXISTS "avatars_public_select" ON storage.objects;
CREATE POLICY "avatars_public_select"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

-- Usuário autenticado pode fazer upload apenas no próprio diretório (avatars/{uid}.*)
DROP POLICY IF EXISTS "avatars_insert_own" ON storage.objects;
CREATE POLICY "avatars_insert_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = 'avatars'
    AND starts_with(storage.filename(name), auth.uid()::text)
  );

-- Usuário autenticado pode atualizar (upsert) apenas o seu próprio avatar
DROP POLICY IF EXISTS "avatars_update_own" ON storage.objects;
CREATE POLICY "avatars_update_own"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND starts_with(storage.filename(name), auth.uid()::text)
  );

-- Usuário autenticado pode deletar apenas o seu próprio avatar
DROP POLICY IF EXISTS "avatars_delete_own" ON storage.objects;
CREATE POLICY "avatars_delete_own"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'avatars'
    AND auth.role() = 'authenticated'
    AND starts_with(storage.filename(name), auth.uid()::text)
  );
