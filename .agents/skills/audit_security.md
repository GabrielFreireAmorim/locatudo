# Skill: Security & Quality Audit
- **Checklist**:
  1. O usuário está logado antes de realizar esta ação?
  2. Existe uma política de RLS (Row Level Security) no Supabase para esta tabela?
  3. O código trata erros de rede e tokens expirados?
  4. O `id_token` do Google está sendo validado corretamente?