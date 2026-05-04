-- =====================================================
-- Migração: Criação de categorias e produtos
-- =====================================================

-- Limpeza de tabelas anteriores (garante que o novo schema seja aplicado)
DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;

-- 1. Criação do Bucket de Storage para imagens de produtos
INSERT INTO storage.buckets (id, name, public) VALUES ('product_images', 'product_images', true)
ON CONFLICT (id) DO NOTHING;

-- Políticas do Storage
CREATE POLICY "Imagens de produtos são públicas" ON storage.objects FOR SELECT USING (bucket_id = 'product_images');
CREATE POLICY "Usuário pode enviar imagens de produtos" ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'product_images' AND auth.role() = 'authenticated'
);

-- 2. Tabela de Categorias
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Popular Categorias
INSERT INTO public.categories (name, slug) VALUES 
  ('Ferramentas', 'ferramentas'),
  ('Eletrônicos', 'eletronicos'),
  ('Esportes e Lazer', 'esportes_lazer'),
  ('Festas e Eventos', 'festas_eventos'),
  ('Limpeza', 'limpeza')
ON CONFLICT (slug) DO NOTHING;

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Categorias são públicas para leitura" ON public.categories FOR SELECT USING (true);

-- 3. Tabela de Produtos
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES public.categories(id),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT NOT NULL,
    pricing_type TEXT NOT NULL CHECK (pricing_type IN ('DAILY', 'HOURLY')),
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INTEGER NOT NULL DEFAULT 1 CHECK (stock_quantity >= 1),
    pickup_locally BOOLEAN NOT NULL DEFAULT false,
    pickup_time_start TIME,
    pickup_time_end TIME,
    pickup_days TEXT CHECK (pickup_days IN ('ALL_DAYS', 'WEEKDAYS', 'WEEKENDS', NULL)),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_products_owner ON public.products(owner_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Produtos são públicos para leitura" 
    ON public.products FOR SELECT USING (true);

CREATE POLICY "Usuário insere seus próprios produtos" 
    ON public.products FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Usuário atualiza seus produtos sem mudar categoria" 
    ON public.products FOR UPDATE 
    USING (auth.uid() = owner_id)
    WITH CHECK (category_id = (SELECT category_id FROM public.products p WHERE p.id = id));

CREATE POLICY "Usuário deleta seus produtos" 
    ON public.products FOR DELETE USING (auth.uid() = owner_id);
