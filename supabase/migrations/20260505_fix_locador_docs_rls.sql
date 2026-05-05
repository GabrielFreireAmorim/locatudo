-- Corrige as políticas de RLS para o bucket locador_docs
-- Baseado no formato de caminho: {userId}/locador_doc.{ext}

DROP POLICY IF EXISTS "locador_docs_insert_own" ON storage.objects;
CREATE POLICY "locador_docs_insert_own"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'locador_docs'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "locador_docs_select_own" ON storage.objects;
CREATE POLICY "locador_docs_select_own"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'locador_docs'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );
