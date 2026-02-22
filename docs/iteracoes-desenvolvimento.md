# Metodologia de Desenvolvimento por Iterações

**Template versão:** 1.0  
**Filosofia:** Desenvolvimento incremental e testável

---

## 🎯 Visão Geral

Desenvolver um projeto Forms → SharePoint → Power Automate em **iterações pequenas e testáveis**, cada uma adicionando funcionalidade específica.

**Benefícios:**
- ✅ Validação frequente
- ✅ Redução de riscos
- ✅ Feedback rápido
- ✅ Fácil debugging
- ✅ Progresso visível

---

## 📋 Estrutura de uma Iteração

### Duração Típica
- **Simples:** 1-2 horas
- **Média:** 2-4 horas
- **Complexa:** 4-8 horas (dividir se possível)

### Fases

```
1. Planeamento → 2. Desenvolvimento → 3. Testes → 4. Documentação → 5. Deploy
     (15min)          (60-70%)           (20%)         (10%)           (5min)
```

---

## 🗺️ Roadmap de Iterações Típico

### Iteração 0: Setup Inicial ✅
**Objetivo:** Preparar ambiente de trabalho

**Tasks:**
- [ ] Azure AD App Registration
- [ ] Guardar Client Secret
- [ ] Criar SharePoint List (campos base)
- [ ] Criar Microsoft Forms
- [ ] Criar Power Platform Solution
- [ ] Testar conectividades
- [ ] Git repository setup

**Entrega:** Ambiente funcional, pronto para desenvolvimento

**Documentação:** Atualizar [ESTADO-ATUAL.md](ESTADO-ATUAL.md)

**Tempo:** 2-3 horas

---

### Iteração 1: Forms → SharePoint (Básico) 🎯
**Objetivo:** Conectar Forms a SharePoint List

**Tasks:**
1. [ ] Criar flow no Power Automate UI
   - Trigger: "When a new response is submitted"
   - Form: Selecionar formulário criado
2. [ ] Adicionar ação: "Get response details"
3. [ ] Adicionar ação: "Create item" (SharePoint)
4. [ ] Mapear campos básicos (5-10 campos principais)
5. [ ] Salvar flow e ativar

**Testes:**
- [ ] Submeter formulário de teste
- [ ] Verificar item criado em SharePoint
- [ ] Validar dados mapeados corretamente
- [ ] Verificar Run History (sucesso)

**Entrega:**
- Flow funcional Forms → SharePoint
- Dados base mapeados
- Workflow básico completo

**Documentação:**
- Criar: `docs/ITERACAO-1-FORMS-SHAREPOINT.md`
- Atualizar: `docs/ESTADO-ATUAL.md`
- Atualizar: `README.md` (estado atual)

**Tempo:** 1-2 horas

---

### Iteração 2: Notificações (Teams/Email) 📧
**Objetivo:** Adicionar alertas quando formulário é submetido

**Opção A: Teams Alert**

**Tasks:**
1. [ ] Abrir flow em edição
2. [ ] Adicionar ação: "Post message in a chat or channel"
3. [ ] Configurar connection a Teams
4. [ ] Selecionar channel/chat
5. [ ] Criar mensagem com dynamic content:
   ```
   Novo formulário submetido!
   Fornecedor: [Nome]
   Data: [DataSubmissao]
   ```
6. [ ] Testar

**Opção B: Email Notification**

**Tasks:**
1. [ ] Adicionar ação: "Send an email (V2)"
2. [ ] Configurar destinatários
3. [ ] Criar assunto e corpo
4. [ ] Adicionar dynamic content
5. [ ] Testar

**Testes:**
- [ ] Submeter Forms
- [ ] Verificar notificação recebida
- [ ] Validar conteúdo correto

**Entrega:** Sistema de notificações funcionalautomatic

**Documentação:** `docs/ITERACAO-2-NOTIFICACOES.md`

**Tempo:** 1 hora

---

### Iteração 3: Automações Adicionais 🔄

**Exemplos de funcionalidades:**

**Opção A: Criação Automática de Pastas**
- Criar pasta SharePoint por item
- Partilhar com utilizador específico
- Guardar link de partilha

**Opção B: Aprovação Workflow**
- Adicionar approval step
- Notificar aprovadores
- Atualizar status conforme resposta

**Opção C: Data Enrichment**
- Lookup adicional (ex: dados de outro sistema)
- Cálculos derivados
- Validações complexas

**Tasks:** (Específicas à funcionalidade escolhida)

**Testes:** Validar nova funcionalidade end-to-end

**Documentação:** `docs/ITERACAO-3-[NOME].md`

**Tempo:** 2-4 horas

---

### Iteração 4: Geração de Documentos 📄

**Objetivo:** Gerar documentos automaticamente (PDFs, Word, etc.)

**Abordagens:**

**A) Usar Word Template**
1. Criar template Word com placeholders
2. Upload para SharePoint
3. Flow: "Populate a Microsoft Word template"
4. Converter para PDF (opcional)

**B) Usar HTML to PDF**
1. Criar HTML template
2. Usar connector de conversão
3. Salvar em SharePoint

**C) Usar Power Apps / Power Automate**
1. Gerar via "Create file" com content
2. Formatar conforme necessário

**Tasks:**
- [ ] Criar template(s)
- [ ] Adicionar ações ao flow
- [ ] Mapear dados
- [ ] Salvar documento(s) em localização correta
- [ ] Testar geração

**Testes:**
- [ ] Documentos gerados corretamente
- [ ] Dados preenchidos
- [ ] Formato adequado

**Documentação:** `docs/ITERACAO-4-DOCUMENTOS.md`

**Tempo:** 3-6 horas (dependendo complexidade)

---

### Iteração 5: Email Personalizado ao Utilizador 📧

**Objetivo:** Enviar email personalizado ao utilizador após processamento

**Tasks:**
1. [ ] Adicionar ação "Send an email (V2)" no final do flow
2. [ ] Destinatário: Dynamic content (Email do Forms)
3. [ ] Criar template HTML para email:
   - Saudação personalizada
   - Links relevantes (ex: pasta SharePoint)
   - Instruções
   - Prazo (se aplicável)
   - Contacto para dúvidas
4. [ ] Adicionar dynamic content
5. [ ] Testar formatação HTML

**Testes:**
- [ ] Email enviado corretamente
- [ ] Destinatário correto
- [ ] Links funcionais
- [ ] Formatação OK

**Documentação:** `docs/ITERACAO-5-EMAIL-UTILIZADOR.md`

**Tempo:** 1-2 horas

---

## 📝 Template de Planeamento de Iteração

Copiar e preencher para cada iteração:

```markdown
# Iteração [N]: [Nome da Iteração]

**Data início:** [Data]  
**Objetivo:** [Descrição em 1 frase]

## 🎯 Objetivo Detalhado
[Descrição completa do que será implementado]

## 📋 Tasks
1. [ ] Task 1 específica
2. [ ] Task 2 específica
3. [ ] Task 3 específica
4. [ ] Task 4 específica
5. [ ] Task 5 específica

## 🔧 Detalhes Técnicos

### Ações a Adicionar ao Flow
- Ação 1: [Nome e configuração]
- Ação 2: [Nome e configuração]

### Campos/Dados Necessários
- Campo 1: [Origem e tipo]
- Campo 2: [Origem e tipo]

### Connectors Necessários
- [ ] Connector A (já configurado / a configurar)
- [ ] Connector B (já configurado / a configurar)

## ✅ Critérios de Sucesso
- [ ] Critério 1 verificável
- [ ] Critério 2 verificável
- [ ] Critério 3 verificável

## 🧪 Plano de Testes

### Teste 1: [Nome do Teste]
**Passos:**
1. Passo 1
2. Passo 2
3. Passo 3

**Resultado esperado:** [Descrição]

**Test run ID:** [Preencher após teste]  
**Status:** [✅ Passou / ❌ Falhou]

### Teste 2: [Nome do Teste]
...

## 📊 Resultados

**Data conclusão:** [Data]  
**Status:** [✅ Completa / ⏳ Em progresso / ❌ Bloqueada]

**Métricas:**
- Tempo desenvolvimento: [X horas]
- Flows modificados: [N]
- Ações adicionadas: [N]
- Testes executados: [N/N passaram]

## ⚠️ Issues e Decisões

### Issue 1
**Problema:** [Descrição]  
**Solução:** [Como foi resolvido]

### Decisão 1
**Contexto:** [Situação]  
**Decisão:** [O que foi decidido]  
**Razão:** [Por quê]

## 📚 Próxima Iteração

**Sugestões:**
- [Funcionalidade A]
- [Funcionalidade B]
- [Melhoria C]
```

---

## 🔄 Workflow Durante Iteração

### 1. Início
```powershell
# Checklist de início (START-NEXT-SESSION.md)
Add-PowerAppsAccount
Import-Module .\scripts\ConfigHelper.psm1

# Criar branch Git (opcional)
git checkout -b iteracao-N
```

### 2. Desenvolvimento
- Seguir tasks do plano
- Salvar frequentemente
- Commit pequenos incrementos

### 3. Testes
- Teste unitário (ação isolada)
- Teste integração (flow completo)
- Registar run IDs

### 4. Documentação
- Criar/atualizar ITERACAO-N.md
- Atualizar ESTADO-ATUAL.md
- Screenshots se útil

### 5. Deploy
```powershell
# Exportar flow atualizado
.\scripts\Export-ProductionFlows.ps1

# Commit
git add .
git commit -m "Iteração N: [Descrição]"
git push

# Merge (se usar branches)
git checkout main
git merge iteracao-N
```

---

## ✅ Checklist de Iteração Completa

Antes de considerar iteração completa:

- [ ] **Todos os tasks completos**
- [ ] **Testes passaram**
  - [ ] Teste unitário
  - [ ] Teste integração
  - [ ] Teste com dados reais
- [ ] **Documentação atualizada**
  - [ ] ITERACAO-N.md criado
  - [ ] ESTADO-ATUAL.md atualizado
  - [ ] README.md atualizado
- [ ] **Flow exportado** (backup)
- [ ] **Git commit** feito
- [ ] **Próximos passos** identificados

---

## 🎓 Dicas e Boas Práticas

### Planeamento
- ✅ Iterações pequenas (1 objetivo claro)
- ✅ Dependências identificadas
- ✅ Tempo estimado realistic
- ❌ Evitar scope creep

### Desenvolvimento
- ✅ Salvar frequentemente
- ✅ Testar incrementalmente
- ✅ Usar Test button do Power Automate
- ❌ Não adicionar tudo de uma vez

### Testes
- ✅ Testar com dados reais
- ✅ Testar edge cases
- ✅ Registar run IDs
- ❌ Não assumir funciona

### Documentação
- ✅ Documentar enquanto desenvolve
- ✅ Screenshots úteis
- ✅ Decisões registadas
- ❌ Não deixar para depois

---

## 📚 Exemplos de Projetos

### Projeto Simples (3-4 Iterações)
1. Setup inicial
2. Forms → SharePoint
3. Email notification
4. Refinamentos

### Projeto Médio (5-7 Iterações)
1. Setup inicial
2. Forms → SharePoint
3. Teams alert
4. Pasta automation
5. Document generation
6. Email personalizado
7. Reporting/dashboard

### Projeto Complexo (8+ Iterações)
- Começar com base simples
- Adicionar features progressivamente
- Considerar dividir em fases

---

**Próximo:** Começar [Iteração 0: Setup Inicial](SETUP-INICIAL.md)!
