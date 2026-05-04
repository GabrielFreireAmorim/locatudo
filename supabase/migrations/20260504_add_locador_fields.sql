-- =============================================================
-- LocaTudo — Migration: Tornar-se Locador (Atualização de Users)
-- Adiciona os campos referentes ao perfil de locador na tabela users
-- =============================================================

-- 1. ADICIONA COLUNAS NA TABELA USERS
ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS locador_status TEXT DEFAULT 'inactive', -- 'inactive', 'pending', 'approved', 'rejected'
  ADD COLUMN IF NOT EXISTS person_type TEXT, -- 'Física' ou 'Jurídica'
  ADD COLUMN IF NOT EXISTS phone TEXT,
  ADD COLUMN IF NOT EXISTS whatsapp TEXT,
  ADD COLUMN IF NOT EXISTS document_url TEXT,
  ADD COLUMN IF NOT EXISTS store_name TEXT,
  ADD COLUMN IF NOT EXISTS store_description TEXT,
  ADD COLUMN IF NOT EXISTS store_category TEXT,
  ADD COLUMN IF NOT EXISTS accepted_locador_terms BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS address_cep TEXT,
  ADD COLUMN IF NOT EXISTS address_street TEXT,
  ADD COLUMN IF NOT EXISTS address_number TEXT,
  ADD COLUMN IF NOT EXISTS address_city TEXT,
  ADD COLUMN IF NOT EXISTS address_state TEXT,
  ADD COLUMN IF NOT EXISTS address_complement TEXT;

-- Comentários para documentação
COMMENT ON COLUMN public.users.locador_status IS 'Status da solicitação de locador (inactive, pending, approved, rejected)';
COMMENT ON COLUMN public.users.document_url IS 'URL do documento de verificação no bucket de locador_docs';

-- 2. STORAGE — BUCKET PARA DOCUMENTOS SENSÍVEIS (NÃO PÚBLICO)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'locador_docs',
  'locador_docs',
  FALSE,                             -- Privado: apenas admins e o próprio usuário
  5242880,                           -- limite de 5 MB
  ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
ON CONFLICT (id) DO UPDATE
  SET public            = FALSE,
      file_size_limit   = 5242880,
      allowed_mime_types = ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];

-- 3. ROW LEVEL SECURITY (RLS) — BUCKET locador_docs
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY; VALIDAR

-- Usuário pode inserir seu próprio documento
DROP POLICY IF EXISTS "locador_docs_insert_own" ON storage.objects;
CREATE POLICY "locador_docs_insert_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'locador_docs'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = 'locador_docs'
    AND starts_with(storage.filename(name), auth.uid()::text)
  );

-- Usuário pode ler seu próprio documento
DROP POLICY IF EXISTS "locador_docs_select_own" ON storage.objects;
CREATE POLICY "locador_docs_select_own"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'locador_docs'
    AND auth.role() = 'authenticated'
    AND starts_with(storage.filename(name), auth.uid()::text)
  );
