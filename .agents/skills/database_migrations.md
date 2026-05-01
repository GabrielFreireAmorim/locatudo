# Skill: Supabase & PostgreSQL Management
- **Naming**: Tabelas em snake_case e plural (ex: `products`, `rentals`).
- **Safety**: 
  - Toda tabela nova deve ter `enable row level security;`.
  - Use UUID para chaves primárias.
  - Sempre inclua as colunas `created_at` e `updated_at`.