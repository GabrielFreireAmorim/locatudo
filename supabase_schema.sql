-- ==========================================
-- Schema LocaTudo - PostgreSQL (Supabase)
-- ==========================================

-- 1. Criação da Tabela de Usuários (Public Users Profile)
-- Conecta com o sistema de autenticação auth.users do Supabase
CREATE TABLE public.users (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT,
  address TEXT,
  profile_image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 2. Criação da Tabela de Produtos
CREATE TABLE public.products (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  owner_id UUID REFERENCES public.users(id) NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  price_per_day NUMERIC(10, 2) NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  is_available BOOLEAN DEFAULT TRUE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. Criação da Tabela de Locações (Rentals)
CREATE TABLE public.rentals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id UUID REFERENCES public.products(id) NOT NULL,
  tenant_id UUID REFERENCES public.users(id) NOT NULL,
  landlord_id UUID REFERENCES public.users(id) NOT NULL,
  start_date TIMESTAMP WITH TIME ZONE NOT NULL,
  end_date TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT DEFAULT 'PENDING' NOT NULL, -- PENDING, CONFIRMED, CANCELLED, COMPLETED
  total_price NUMERIC(10, 2) NOT NULL,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ==========================================
-- Configuração de Segurança (Row Level Security - RLS)
-- ==========================================

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rentals ENABLE ROW LEVEL SECURITY;

-- Políticas para 'users'
-- Qualquer um pode ver os perfis dos outros (necessário para ver quem alugou)
CREATE POLICY "Public profiles are viewable by everyone." 
  ON public.users FOR SELECT 
  USING (true);

-- Apenas o próprio usuário pode editar seu perfil
CREATE POLICY "Users can insert their own profile." 
  ON public.users FOR INSERT 
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile." 
  ON public.users FOR UPDATE 
  USING (auth.uid() = id);

-- Políticas para 'products'
-- Qualquer um pode ver os produtos
CREATE POLICY "Products are viewable by everyone." 
  ON public.products FOR SELECT 
  USING (true);

-- Apenas usuários autenticados podem inserir produtos e devem ser os donos (owner_id)
CREATE POLICY "Users can create their own products." 
  ON public.products FOR INSERT 
  WITH CHECK (auth.uid() = owner_id);

-- Apenas o dono pode atualizar/deletar
CREATE POLICY "Users can update their own products." 
  ON public.products FOR UPDATE 
  USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own products." 
  ON public.products FOR DELETE 
  USING (auth.uid() = owner_id);

-- Políticas para 'rentals'
-- Um usuário só pode ver locações onde ele é o locatário (tenant) ou locador (landlord)
CREATE POLICY "Users can view their own rentals." 
  ON public.rentals FOR SELECT 
  USING (auth.uid() = tenant_id OR auth.uid() = landlord_id);

-- Locatários podem criar pedidos de locação
CREATE POLICY "Tenants can create rentals." 
  ON public.rentals FOR INSERT 
  WITH CHECK (auth.uid() = tenant_id);

-- Tanto locatário quanto locador podem atualizar o status (ex: locador confirma, locatário cancela)
CREATE POLICY "Users involved can update the rental." 
  ON public.rentals FOR UPDATE 
  USING (auth.uid() = tenant_id OR auth.uid() = landlord_id);

-- ==========================================
-- Triggers e Functions
-- ==========================================
-- Cria automaticamente uma linha na tabela 'users' quando um usuário se cadastra no Auth Supabase
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, name, email)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', 'Usuário'), 
    new.email
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
