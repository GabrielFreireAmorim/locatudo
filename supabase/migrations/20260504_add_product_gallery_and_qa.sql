-- ==========================================
-- 1. Tabela: product_images (Galeria)
-- ==========================================
CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;

-- Qualquer um pode visualizar as imagens
DO $$ BEGIN
    CREATE POLICY "Imagens visíveis para todos" 
    ON public.product_images FOR SELECT 
    USING (true);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Apenas o dono do produto associado pode gerenciar as imagens
DO $$ BEGIN
    CREATE POLICY "Dono pode gerenciar imagens"
    ON public.product_images FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.products p 
            WHERE p.id = product_images.product_id AND p.owner_id = auth.uid()
        )
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==========================================
-- 2. Tabela: product_questions (Q&A)
-- ==========================================
CREATE TABLE IF NOT EXISTS public.product_questions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    answer_text TEXT,
    upvotes INTEGER DEFAULT 0,
    downvotes INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.product_questions ENABLE ROW LEVEL SECURITY;

-- Qualquer um pode visualizar as perguntas
DO $$ BEGIN
    CREATE POLICY "Perguntas visíveis para todos" 
    ON public.product_questions FOR SELECT 
    USING (true);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Apenas o próprio usuário pode criar a sua pergunta
DO $$ BEGIN
    CREATE POLICY "Usuários autenticados podem perguntar" 
    ON public.product_questions FOR INSERT 
    WITH CHECK (auth.uid() = user_id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Apenas o dono do produto pode atualizar para responder à pergunta
DO $$ BEGIN
    CREATE POLICY "Apenas dono do produto pode responder" 
    ON public.product_questions FOR UPDATE 
    USING (
        EXISTS (
            SELECT 1 FROM public.products p 
            WHERE p.id = product_questions.product_id AND p.owner_id = auth.uid()
        )
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==========================================
-- 3. Tabela: question_votes (Votos Útil / Não Útil)
-- ==========================================
CREATE TABLE IF NOT EXISTS public.question_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES public.product_questions(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    vote_type TEXT NOT NULL CHECK (vote_type IN ('UP', 'DOWN')),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(question_id, user_id) -- Impede que a mesma pessoa vote 2 vezes na mesma pergunta
);

ALTER TABLE public.question_votes ENABLE ROW LEVEL SECURITY;

-- Qualquer um pode visualizar os votos
DO $$ BEGIN
    CREATE POLICY "Votos visíveis para todos" 
    ON public.question_votes FOR SELECT 
    USING (true);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- O usuário só pode criar/modificar/deletar o SEU PRÓPRIO voto
DO $$ BEGIN
    CREATE POLICY "Usuários gerenciam seus próprios votos" 
    ON public.question_votes FOR ALL 
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ==========================================
-- 4. Automação: Trigger para recontar votos
-- ==========================================
CREATE OR REPLACE FUNCTION update_question_votes_count()
RETURNS TRIGGER AS $$
BEGIN
  IF (TG_OP = 'INSERT') THEN
    IF (NEW.vote_type = 'UP') THEN
      UPDATE public.product_questions SET upvotes = upvotes + 1 WHERE id = NEW.question_id;
    ELSIF (NEW.vote_type = 'DOWN') THEN
      UPDATE public.product_questions SET downvotes = downvotes + 1 WHERE id = NEW.question_id;
    END IF;
  ELSIF (TG_OP = 'UPDATE') THEN
    IF (OLD.vote_type = 'UP' AND NEW.vote_type = 'DOWN') THEN
      UPDATE public.product_questions SET upvotes = upvotes - 1, downvotes = downvotes + 1 WHERE id = NEW.question_id;
    ELSIF (OLD.vote_type = 'DOWN' AND NEW.vote_type = 'UP') THEN
      UPDATE public.product_questions SET upvotes = upvotes + 1, downvotes = downvotes - 1 WHERE id = NEW.question_id;
    END IF;
  ELSIF (TG_OP = 'DELETE') THEN
    IF (OLD.vote_type = 'UP') THEN
      UPDATE public.product_questions SET upvotes = upvotes - 1 WHERE id = OLD.question_id;
    ELSIF (OLD.vote_type = 'DOWN') THEN
      UPDATE public.product_questions SET downvotes = downvotes - 1 WHERE id = OLD.question_id;
    END IF;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$ BEGIN
    CREATE TRIGGER trigger_update_question_votes
    AFTER INSERT OR UPDATE OR DELETE ON public.question_votes
    FOR EACH ROW EXECUTE FUNCTION update_question_votes_count();
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;
