---
description: >
---

# 🚀 Workflow: `/feature`

Quando o Gabriel digitar `/feature <ideia>`, execute as fases abaixo **em ordem**.
Cada agente usa sua skill dedicada (em `.agents/skills/`) e **para** para aprovação
antes de passar a tarefa para o próximo.

---

## Fase 1 — 📋 Especificação (`@pm`)

> **Skill utilizada:** nenhuma (análise de negócio pura).
> **Referência de persona:** `.agents/agents.md` → `@pm`

**O @pm deve:**
1. Analisar o pedido do Gabriel e identificar o problema de negócio.
2. Criar o **Functional Spec** com:
   - Descrição da funcionalidade em linguagem de usuário.
   - Lista de campos (nome, tipo, obrigatório?).
   - Regras de validação e casos de borda.
   - Fluxo de telas (de qual tela vem → o que acontece → para onde vai).
   - Restrições de acesso (quem pode ver/editar?).
3. Apresentar o spec formatado ao Gabriel.

> ⛔ **CHECKPOINT 1** — O @pm nunca escreve código.
> Perguntar: _"Gabriel, a especificação acima está correta? Posso passar para o @devops criar o schema?"_
> **Aguardar aprovação explícita antes de continuar.**

---

## Fase 2 — 🗄️ Schema de Banco (`@devops` + skill `database_migrations`)

> **Skill utilizada:** `.agents/skills/database_migrations.md`
> **Referência de persona:** `.agents/agents.md` → `@devops`

**O @devops deve, seguindo a skill `database_migrations`:**
1. Criar o script SQL (`DDL`) completo baseado no Functional Spec aprovado.
2. Aplicar **obrigatoriamente**:
   - Tabelas em `snake_case` e plural.
   - `UUID` como chave primária (`gen_random_uuid()`).
   - Colunas `created_at TIMESTAMPTZ DEFAULT now()` e `updated_at TIMESTAMPTZ DEFAULT now()`.
   - `ALTER TABLE <tabela> ENABLE ROW LEVEL SECURITY;`
   - Políticas RLS mínimas (SELECT, INSERT, UPDATE para o `auth.uid()` dono do registro).
   - Foreign keys referenciando `auth.users(id)` onde aplicável.
3. Apresentar o script SQL formatado em bloco de código.

> ⛔ **CHECKPOINT 2** — Perguntar:
> _"Gabriel, o schema SQL está correto? Posso passar para o @engineer implementar?"_
> **Aguardar aprovação explícita antes de continuar.**

---

## Fase 3 — 💻 Implementação Flutter (`@engineer` + skill `generate_code`)

> **Skill utilizada:** `.agents/skills/generate_code.md`
> **Referência de persona:** `.agents/agents.md` → `@engineer`

**O @engineer deve, seguindo a skill `generate_code`:**
1. Criar o **Model Dart** baseado no schema aprovado:
   - `fromJson` / `toJson` completos.
   - Campos `nullable` onde a coluna permitir NULL.
2. Criar o **Repository** (em `lib/repositories/`):
   - Métodos CRUD necessários para a feature.
   - Sempre com `try-catch` em chamadas ao Supabase.
3. Criar ou atualizar a **Screen** (em `lib/screens/`):
   - Loading state em todos os botões de ação.
   - Tratamento de erro com `ScaffoldMessenger.showSnackBar`.
   - Usar widgets existentes (`CustomButton`, `CustomInput`) antes de criar novos.
4. Registrar a rota nova em `lib/app_router.dart` (se for uma tela nova).
5. Apresentar todos os arquivos com caminhos explícitos.

> ℹ️ **Sem checkpoint aqui** — o código vai direto para auditoria do @qa.

---

## Fase 4 — 🛡️ Auditoria (`@qa` + skill `audit_security`)

> **Skill utilizada:** `.agents/skills/audit_security.md`
> **Referência de persona:** `.agents/agents.md` → `@qa`

**O @qa deve revisar tudo usando o checklist da skill `audit_security`:**

| # | Verificação | Status |
|---|-------------|--------|
| 1 | O usuário está autenticado antes de realizar a ação? | ✅/❌ |
| 2 | Existe política de RLS para a tabela afetada? | ✅/❌ |
| 3 | O código trata erros de rede e tokens expirados? | ✅/❌ |
| 4 | O `id_token` do Google está sendo validado corretamente (se aplicável)? | ✅/❌ |
| 5 | Happy path testado? | ✅/❌ |
| 6 | Edge cases cobertos? (campos nulos, internet offline, registro duplicado) | ✅/❌ |

Se encontrar problemas, listar cada um com:
- **Arquivo e linha** do problema.
- **Risco** (Baixo / Médio / Alto).
- **Correção sugerida** (trecho de código se aplicável).

> ⛔ **CHECKPOINT 3** — Apresentar o relatório de auditoria ao Gabriel.
> Se houver itens `❌`, o @engineer deve corrigir antes de finalizar.
> Perguntar: _"Gabriel, a auditoria foi aprovada. Posso finalizar a feature?"_

---

## Fase 5 — ✅ Finalização (`@devops`)

> **Referência de persona:** `.agents/agents.md` → `@devops`

**O @devops deve:**
1. Confirmar a lista de arquivos criados/modificados.
2. Listar os passos manuais que o Gabriel precisa executar, se houver:
   - Ex: rodar o SQL no Supabase Dashboard.
   - Ex: adicionar variáveis de ambiente.
3. Apresentar o **resumo final** da feature entregue.
4. Resumir o ajuste para o commit separando por novo recurso, correção, exclusão, banco, etc.. 
  -EX: [FEAT] - Nova feature de aceite de termos da plataforma

---

## 📌 Referências rápidas

| Agente | Persona | Skill |
|--------|---------|-------|
| @pm | `.agents/agents.md` | — |
| @devops | `.agents/agents.md` | `.agents/skills/database_migrations.md` |
| @engineer | `.agents/agents.md` | `.agents/skills/generate_code.md` |
| @qa | `.agents/agents.md` | `.agents/skills/audit_security.md` |