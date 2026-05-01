---
description: Start the Autonomous AI Developer Pipeline sequence with a new idea
---

When the user types '/agentes <idea>', orchestrate the development process strictly using
.agents/agents.md' and '.agents/skills/'.

Passos do Processo:

1. **Ideação (@pm):** 
   - Analisa o pedido do Gabriel.
   - Cria o "Functional Spec": lista de campos, regras de validação e fluxo de telas.
   - **Check:** O Gabriel aprovou a regra de negócio?

2. **Arquitetura de Dados (@devops):**
   - Com base na spec, gera o script SQL (DDL).
   - Define chaves primárias (UUID), chaves estrangeiras e ativa o RLS.
   - Fornece o schema para o @engineer.

3. **Codificação (@engineer):**
   - Cria os Models (Dart) baseados no schema do @devops.
   - Implementa o Repository e a UI no Flutter seguindo Clean Architecture.
   - Usa o `webClientId` para autenticação Google.

4. **Auditoria (@qa):**
   - Revisa o código e o SQL.
   - Testa "Happy Path" e "Edge Cases" (ex: internet offline, campos nulos).
   - Valida se o RLS impede que um usuário edite o anúncio de outro.

5. **Deploy Simulado (@devops):**
   - Finaliza a tarefa.