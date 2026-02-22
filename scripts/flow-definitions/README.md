# Flow Definitions - Power Automate

Esta pasta contém as definições JSON dos 3 fluxos Power Automate do projeto.

---

## 📦 Ficheiros

### 1. `Inquerito-Satisfacao-Captura-Respostas.json`
**Fluxo 2 - Captura de Respostas**
- **Trigger:** When a new response is submitted (Microsoft Forms)
- **Função:** Captura automática de respostas do Forms para SharePoint
- **Prioridade:** 🔴 CRÍTICA - Implementar primeiro
- **Actions:** 
  - Get response details
  - Get items (SharePoint - match por email)
  - Update item (17 campos)
  - Send thank you email
  - Error handling

### 2. `Inquerito-Satisfacao-Envio-Inicial.json`
**Fluxo 1 - Envio de Inquéritos**
- **Trigger:** Manual / Instant
- **Função:** Gera links pré-preenchidos e envia emails aos contactos pendentes
- **Prioridade:** 🟡 ALTA - Implementar após Fluxo 2
- **Actions:**
  - Get items (EstadoInquerito = "Pendente")
  - Apply to each (concurrency: 5)
  - Compose prefill link (4 campos)
  - Send email
  - Update status

### 3. `Inquerito-Satisfacao-Gestao-Reminders.json`
**Fluxo 3 - Gestão de Reminders**
- **Trigger:** Recurrence (Daily, 09:00)
- **Função:** Envia reminders automáticos e marca inquéritos expirados
- **Prioridade:** 🟢 MÉDIA - Implementar após Fluxos 1 e 2
- **Actions:**
  - Get eligible reminders (≤ 3 dias, < 2 reminders)
  - Send reminder emails
  - Update counters
  - Mark expired surveys

---

## 🚀 Como Usar

### Opção A: Criação Manual (Recomendada)
1. Abrir o ficheiro JSON correspondente
2. Seguir o [GUIA-RAPIDO-IMPLEMENTACAO-FLOWS.md](../../GUIA-RAPIDO-IMPLEMENTACAO-FLOWS.md)
3. Criar flow manualmente no portal Power Automate
4. Usar JSON como referência para:
   - Estrutura de actions
   - Expressões
   - Mapeamento de campos

### Opção B: Import via PowerShell (Avançado)
```powershell
# Requer ajustes de conexões após import
.\Import-FlowDefinitionToProduction.ps1 -FlowName "Inquerito-Satisfacao-Captura-Respostas"
```

⚠️ **Nota:** Import direto de JSON requer configuração manual de conexões (Forms, SharePoint, Outlook).

---

## 📋 Informações Técnicas

### Conexões Requeridas
- **Microsoft Forms**
  - Connector: `shared_microsoftforms`
  - Operations: CreateFormWebhook, GetFormResponse
  
- **SharePoint Online**
  - Connector: `shared_sharepointonline`
  - Operations: GetItems, PatchItem
  - Site: `https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade`
  - List ID: `af4ef457-b004-4838-b917-8720346b9a8f`
  
- **Office 365 Outlook**
  - Connector: `shared_office365`
  - Operation: SendEmailV2

### Form ID
```
8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu
```

### Question IDs (Mapeamento)
Ver ficheiro completo: [FORMS-SHAREPOINT-MAPPING.md](../../docs/FORMS-SHAREPOINT-MAPPING.md)

**Campos Principais:**
- `r4a23b53b26c94fceb200c0bb59ca92d9` - Title (Nome)
- `r7b2bd52ed2764c57803595d6c3ca2bb7` - EmailContacto
- `rd1db5d1cfeb04e50a01a18b4e4dc2bca` - Funcao
- `r093e6f2fc8744c43990e68b5eda96adc` - Entidade
- (+ 13 campos de resposta)

---

## 🔧 Validação

Após criar os flows no Power Automate:
1. Testar cada flow individualmente
2. Validar mapeamento de campos
3. Confirmar envio de emails
4. Exportar versões de produção para `../flow-definitions-production/`

---

## 📚 Documentação Relacionada

- [GUIA-RAPIDO-IMPLEMENTACAO-FLOWS.md](../../GUIA-RAPIDO-IMPLEMENTACAO-FLOWS.md) - Passo-a-passo completo
- [GUIA-IMPLEMENTACAO-FLOWS.md](../../docs/GUIA-IMPLEMENTACAO-FLOWS.md) - Guia original detalhado
- [POWER-AUTOMATE-FLOWS.md](../../docs/POWER-AUTOMATE-FLOWS.md) - Especificação técnica
- [SESSAO-02-DESENVOLVIMENTO-FLOWS.md](../../docs/SESSAO-02-DESENVOLVIMENTO-FLOWS.md) - Plano da sessão

---

**Criado em:** 22/02/2026  
**Sessão:** #2 - Desenvolvimento dos Fluxos  
**Status:** 📦 Definições prontas para implementação
