-- =====================================================
-- Tabela: user_consents
-- Registra o aceite dos Termos de Uso por cada usuário.
-- =====================================================

CREATE TABLE IF NOT EXISTS public.user_consents (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    terms_version  TEXT NOT NULL,                           -- Ex: 'v1.0'
    accepted_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    ip_address     TEXT,                                    -- IP capturado no cliente (nullable)

    -- Garante que cada usuário aceite cada versão apenas uma vez
    CONSTRAINT uq_user_terms UNIQUE (user_id, terms_version)
);

-- Índice para acelerar as consultas de verificação de aceite
CREATE INDEX IF NOT EXISTS idx_user_consents_user_version
    ON public.user_consents (user_id, terms_version);

-- =====================================================
-- Row Level Security (RLS)
-- =====================================================

ALTER TABLE public.user_consents ENABLE ROW LEVEL SECURITY;

-- Usuário autenticado pode ler seus próprios registros
CREATE POLICY "Usuário lê seus próprios consentimentos"
    ON public.user_consents
    FOR SELECT
    USING (auth.uid() = user_id);

-- Usuário autenticado pode inserir seu próprio registro de aceite
CREATE POLICY "Usuário insere seu próprio consentimento"
    ON public.user_consents
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Nenhum usuário pode atualizar ou deletar registros de aceite
-- (imutabilidade de auditoria — somente admins via service_role key)
