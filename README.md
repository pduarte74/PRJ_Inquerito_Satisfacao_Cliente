# Inquérito de Satisfação de Clientes - Automação Microsoft 365

**Sistema automatizado de gestão de inquéritos de satisfação usando Microsoft Forms, SharePoint Online e Power Automate.**

**Baseado em:** Template Forms-SharePoint-PowerAutomate v1.0  
**Criado:** 22/02/2026  
**Estado Atual:** 🏗️ Em Setup (90% completo)

---

## 📋 Visão Geral

Sistema de 3 fluxos automatizados para gestão completa do ciclo de vida de inquéritos de satisfação:

1. **Envio Automatizado** - Gera links pré-preenchidos do Forms e envia emails personalizados
2. **Captura de Respostas** - Regista automaticamente as respostas no SharePoint e envia agradecimento
3. **Gestão de Reminders** - Envia lembretes automáticos para inquéritos não respondidos

**Dados:** 78 contactos importados | 24 campos na lista SharePoint | 15 questões no Forms

---

## 🚀 Quick Start

### 1. Setup Inicial
Ver **[docs/SESSAO-01-SETUP-INICIAL.md](docs/SESSAO-01-SETUP-INICIAL.md)** para configuração completa.

```powershell
# 1. Criar lista SharePoint
.\scripts\Create-InqueritoSharePointList.ps1

# 2. Adicionar campos de dados
.\scripts\Add-SharePointListFields.ps1
.\scripts\Add-NumericFields.ps1
.\scripts\Add-FuncaoEntidadeFields.ps1

# 3. Adicionar campos de workflow
.\scripts\Add-WorkflowFields.ps1

# 4. Importar contactos
.\scripts\Import-ContactosFromExcel.ps1

# 5. Testar conectividade
.\scripts\Test-SharePointConnection.ps1
```

### 2. Configuração dos Fluxos Power Automate
Ver documentação detalhada: **[docs/POWER-AUTOMATE-FLOWS.md](docs/POWER-AUTOMATE-FLOWS.md)**

---

## 📚 Documentação

**📖 [Índice Completo](docs/INDEX.md)** - Navegação de toda a documentação

### Essenciais para Começar
- **[00-LEIA-ME-PRIMEIRO.md](00-LEIA-ME-PRIMEIRO.md)** - ⭐ Visão geral e primeiros passos
- **[SESSAO-01-SETUP-INICIAL.md](docs/SESSAO-01-SETUP-INICIAL.md)** - Configuração inicial passo-a-passo
- **[ESTADO-ATUAL.md](docs/ESTADO-ATUAL.md)** - Estado atual do projeto (atualizado a cada sessão)
- **[AUTH-METHODS.md](docs/AUTH-METHODS.md)** - ⭐ Métodos de autenticação
- **[ESTRUTURA-PROJETO.md](docs/ESTRUTURA-PROJETO.md)** - Organização de pastas e ficheiros
- **[START-NEXT-SESSION.md](docs/START-NEXT-SESSION.md)** - Checklist para cada sessão

### Workflows e Processos
- [criar-flows-export-edit-import.md](docs/criar-flows-export-edit-import.md) - Criar/editar flows
- [forms-sharepoint-mapping.md](docs/forms-sharepoint-mapping.md) - Mapear campos Forms → SharePoint
- [iteracoes-desenvolvimento.md](docs/iteracoes-desenvolvimento.md) - Plano de iterações

### Referência
- [scripts/README.md](scripts/README.md) - Lista de scripts
- [docs/flows-principais.md](docs/flows-principais.md) - Descrição dos flows
- [docs/troubleshooting.md](docs/troubleshooting.md) - Resolução de problemas

---

## 🏗️ Arquitetura do Projeto

```
Microsoft Forms (Recolha)
         ↓
   [Flow Trigger]
         ↓
SharePoint List (Armazenamento)
         ↓
   [Flows Automáticos]
         ↓
    [Ações Finais]
(Email / Teams / Documentos)
```

### Componentes Principais

1. **Microsoft Forms**
   - Formulário de recolha de dados
   - Pre-fill com parâmetros URL
   - Webhook automático ao submeter

2. **SharePoint List**
   - Armazenamento central de dados
   - Campos mapeados do Forms
   - Views personalizadas (Kanban, etc.)

3. **Power Automate Flows**
   - Processing automático de respostas
   - Envio de notificações
   - Geração de documentos
   - Automação de tarefas

4. **Integrações**
   - Teams (alertas)
   - Outlook (emails)
   - SharePoint (documentos/pastas)
   - Dataverse (soluções)

---

## 📁 Estrutura do Projeto

```
📦 [Nome do Projeto]
├── README.md                        # Este ficheiro
├── config/
│   ├── client-secret.encrypted      # Credenciais seguras (nunca commit!)
│   └── settings.json                # Configurações do projeto
├── docs/
│   ├── INDEX.md                     # Índice navegação completa
│   ├── SETUP-INICIAL.md             # Setup do projeto
│   ├── AUTH-METHODS.md              # Métodos autenticação
│   ├── START-NEXT-SESSION.md        # Checklist sessões
│   ├── criar-flows-export-edit-import.md
│   ├── forms-sharepoint-mapping.md
│   ├── flows-principais.md
│   └── archive/                     # Histórico de documentos
├── scripts/
│   ├── README.md                    # Índice scripts
│   ├── ConfigHelper.psm1            # Auth SharePoint/Graph
│   ├── SharePointListHelper.psm1    # Helpers SharePoint
│   ├── Export-ProductionFlows.ps1   # Exportar flows
│   ├── Import-FlowDefinitionToProduction.ps1
│   ├── Test-SharePointConnection.ps1
│   ├── Test-PowerAutomateConnection.ps1
│   ├── Save-ClientSecret.ps1
│   ├── flow-definitions/            # Definições development
│   ├── flow-definitions-production/ # Backup produção
│   └── solution-working/            # ZIP extraído para edição
├── solution-exports/                # Backups de soluções
│   └── prod/                        # Exportações produção
├── solutions/                       # Power Platform solutions
└── tests/                           # Scripts de teste
```

---

## 🔐 Segurança e Autenticação

### App Registration (Azure AD)

**Para:** SharePoint Lists, Graph API  
**Método:** Client Credentials

```powershell
# Configurar uma vez
.\scripts\Save-ClientSecret.ps1

# Usar sempre que necessário
Import-Module .\scripts\ConfigHelper.psm1
$token = Get-GraphApiToken -ClientId $clientId -ClientSecret (Get-SavedClientSecret) -TenantId $tenantId
```

### Power Automate

**Para:** Flows (exportar, atualizar)  
**Método:** Autenticação Delegada (Interactive)

```powershell
Add-PowerAppsAccount  # Abre browser
Get-Flow -EnvironmentName "Default-[TenantId]"
```

**⚠️ Importante:**
- NUNCA commit `client-secret.encrypted` no Git
- Adicionar `.gitignore` apropriado
- Usar variáveis de ambiente quando possível

Ver detalhes: [docs/AUTH-METHODS.md](docs/AUTH-METHODS.md)

---

## 🔄 Workflow de Desenvolvimento

### Metodologia: Iterações Incrementais

Desenvolver em iterações pequenas e testáveis:

**Iteração 1:** Forms → SharePoint (básico)
**Iteração 2:** Adicionar notificações (Teams/Email)
**Iteração 3:** Automações adicionais (pastas, etc.)
**Iteração N:** Features avançadas

### Processo por Iteração

1. **Planeamento**
   - Definir objetivo claro
   - Listar ações necessárias
   - Identificar dependencies

2. **Desenvolvimento**
   - Criar flow mínimo no UI (se necessário)
   - Desenvolver definição JSON
   - Usar método Export-Edit-Import

3. **Teste**
   - Teste unitário (ação isolada)
   - Teste integração (flow completo)
   - Validar com dados reais

4. **Documentação**
   - Atualizar docs/[ITERACAO-N].md
   - Registar test runs
   - Atualizar checklist

5. **Deploy**
   - Import para produção
   - Verificar flow ativo
   - Monitorizar primeiras execuções

Ver detalhes: [docs/iteracoes-desenvolvimento.md](docs/iteracoes-desenvolvimento.md)

---

## 🛠️ Criar e Editar Flows

### Método Recomendado: Export-Edit-Import

**Quando usar:** PAC CLI sem comando `pac flow create`

**Processo:**
1. Criar flow mínimo no Power Automate UI
2. Adicionar à solução
3. Exportar: `.\Create-Flow-Export-Edit-Import.ps1 -Step Export`
4. Extrair: `.\Create-Flow-Export-Edit-Import.ps1 -Step Extract`
5. Editar JSON (properties.definition)
6. Reempacotar: `.\Create-Flow-Export-Edit-Import.ps1 -Step Package`
7. Importar: `.\Create-Flow-Export-Edit-Import.ps1 -Step Import`

**⚠️ Importante:**
- Usar `-Depth 100` em `ConvertTo-Json`
- Formato novo designer: `OpenApiConnection` + `metadata.operationMetadataId`

Ver guia completo: [docs/criar-flows-export-edit-import.md](docs/criar-flows-export-edit-import.md)

---

## ✅ Princípios de Desenvolvimento

### Organização
- Uma feature por iteração
- Documentar antes de implementar
- Manter histórico em docs/archive/

### Código
- Scripts com `-WhatIf` quando aplicável
- Validação de inputs obrigatória
- Error handling robusto
- Logging adequado

### Segurança
- NUNCA commit secrets
- Usar client-secret.encrypted
- Validar permissões antes de operações

### Validação
- Registar test run IDs
- Validar com dados reais
- Testar edge cases

### Documentação
- Atualizar docs após mudanças
- Manter INDEX.md atualizado
- Arquivar docs obsoletos

### JSON
- Sempre usar `-Depth 100` para flows
- Validar JSON antes de import
- Backup antes de editar

---

## 📊 Estado do Projeto

**Ambiente:** [Development / Staging / Production]  
**Tenant:** [Tenant ID]  
**Dataverse:** [URL]  
**Solução:** [Nome da solução]

### Componentes Implementados
- [ ] Microsoft Forms criado
- [ ] SharePoint List criada
- [ ] Campos mapeados Forms → SharePoint
- [ ] Flow principal (Form submission)
- [ ] Flows auxiliares
- [ ] Testes unitários
- [ ] Testes integração
- [ ] Documentação completa

### Iterações
- [ ] Iteração 1: [Descrição]
- [ ] Iteração 2: [Descrição]
- [ ] Iteração 3: [Descrição]

Ver detalhes: [docs/ESTADO-ATUAL.md](docs/ESTADO-ATUAL.md)

---

## 🆘 Troubleshooting

### Problemas Comuns

**Autenticação falha:**
```powershell
# Re-autenticar PAC CLI
pac auth clear
pac auth create --url [URL Dataverse]

# Re-autenticar Power Automate
Add-PowerAppsAccount
```

**Flow não aparece em Get-Flow:**
- Verificar autenticação delegada (não usar App Registration)
- Confirmar environment correto
- Verificar permissões do utilizador

**Import de flow falha:**
- Validar JSON está bem formatado
- Verificar `-Depth 100` foi usado
- Confirmar ConnectionReferences existem

Ver guia completo: [docs/troubleshooting.md](docs/troubleshooting.md)

---

## 📞 Suporte e Contactos

**Equipa:** [Nome da equipa]  
**Email:** [email@empresa.com]  
**Documentação:** [Link SharePoint/Wiki]

---

## 📝 Licença e Notas

**Baseado em:** Template Forms-SharePoint-PowerAutomate  
**Origem:** Projeto Auditoria Documental FF 2026  
**Versão Template:** 1.0  
**Data Template:** Fevereiro 2026

**Nota:** Este template é baseado em conhecimento real de projeto em produção.
Adapte conforme necessário para seu caso de uso específico.
