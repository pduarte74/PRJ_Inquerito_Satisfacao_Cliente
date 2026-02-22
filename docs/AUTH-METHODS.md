# Métodos de Autenticação - Forms → SharePoint → Power Automate

**Última validação:** [Data]  
**Status:** ✅ Métodos testados e funcionais

---

## 📋 Sumário

Este projeto requer **2 métodos diferentes** de autenticação conforme o serviço:

| Serviço | Método | Quando Usar |
|---------|--------|-------------|
| **SharePoint Lists** | App Registration (Client Credentials) | Scripts PowerShell, operações CRUD |
| **Graph API** | App Registration (Client Credentials) | Operações em listas, users, mail |
| **Power Automate Flows** | Autenticação Delegada (Interactive) | Exportar, atualizar flows |
| **PAC CLI** | Autenticação Delegada (Interactive) | Operações em soluções (limitado) |

**⚠️ CRÍTICO:**
- **NÃO usar App Registration para Power Automate flows** (retorna 0 flows)
- **NÃO usar PAC CLI para exportar flows** (falha com ConnectionReferences permissions)
- **SEMPRE usar autenticação delegada para flows**

---

## 🔐 Método 1: App Registration (Client Credentials)

### Para: SharePoint Lists, Graph API

**✅ Funciona para:**
- SharePoint List operations (CRUD)
- Graph API (Users, Mail, Sites)
- Scripts automatizados (sem interação)

**❌ NÃO funciona para:**
- Power Automate flows (retorna 0 flows mesmo com permissões)
- PAC CLI flow operations

### Setup (Uma Vez)

**1. Criar App Registration no Azure AD**

Portal: https://portal.azure.com  
Azure AD → App registrations → New registration

```
Nome: [NomeProjeto]-Automation
Supported account types: Single tenant
Redirect URI: (deixar vazio)
```

**2. Configurar Permissões**

API permissions → Add a permission:

**Microsoft Graph:**
- `Sites.ReadWrite.All` (Application)
- `User.Read.All` (Application)
- `Mail.Send` (Application) - opcional

**SharePoint:**
- `Sites.FullControl.All` (Application)

**⚠️ Importante:** Grant admin consent para todas as permissões

**3. Criar Client Secret**

Certificates & secrets → New client secret:
- Description: `[NomeProjeto]-Secret`
- Expires: 24 months

**⚠️ COPIAR SECRET IMEDIATAMENTE** (não será mostrado novamente)

**4. Registar IDs**

Overview tab:
- Application (client) ID: `[GUID]`
- Directory (tenant) ID: `[GUID]`

### Guardar Secret de Forma Segura

```powershell
# Executar uma vez
.\scripts\Save-ClientSecret.ps1

# Introduzir secret quando solicitado
# Ficheiro criado: config/client-secret.encrypted
```

**⚠️ NUNCA commit client-secret.encrypted no Git!**

Adicionar a `.gitignore`:
```
config/client-secret.encrypted
config/settings.json
```

### Usar em Scripts

**Exemplo: Obter token Graph API**

```powershell
Import-Module .\scripts\ConfigHelper.psm1

# Carregar secret do ficheiro encriptado
$clientSecret = Get-SavedClientSecret

# Obter token
$token = Get-GraphApiToken `
    -ClientId "483c7be8-cc1b-48c0-a2b0-3f734b9bd521" `
    -ClientSecret $clientSecret `
    -TenantId "019607f2-cbbd-425e-a7b1-bc8d0d97a3e4"

# Usar token em requests
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

$response = Invoke-RestMethod `
    -Uri "https://graph.microsoft.com/v1.0/sites/..." `
    -Headers $headers `
    -Method GET
```

**Exemplo: Operações SharePoint**

```powershell
Import-Module .\scripts\ConfigHelper.psm1
Import-Module .\scripts\SharePointListHelper.psm1

# Obter token
$token = Get-GraphApiToken -ClientId "..." -ClientSecret (Get-SavedClientSecret) -TenantId "..."

# Obter itens da lista
$items = Get-SharePointListItems `
    -SiteUrl "https://[tenant].sharepoint.com/sites/[site]" `
    -ListName "[Nome da Lista]" `
    -Token $token

# Adicionar item
Add-SharePointListItem `
    -SiteUrl "..." `
    -ListName "..." `
    -Token $token `
    -Fields @{
        "Title" = "Teste"
        "Campo1" = "Valor1"
    }
```

### Verificar Permissões

```powershell
# Testar conexão
.\scripts\Test-SharePointConnection.ps1
```

Resultado esperado:
```
✓ ClientSecret carregado
✓ Token obtido com sucesso
✓ Lista encontrada: [Nome da Lista]
✓ [N] itens na lista
```

---

## 🔐 Método 2: Autenticação Delegada (Interactive)

### Para: Power Automate Flows, PAC CLI

**✅ Funciona para:**
- Exportar flows de produção
- Atualizar flows em produção
- Listar flows
- PAC CLI solution operations (limitado)

**❌ NÃO funciona para:**
- Scripts automatizados (requer interação do utilizador)
- CI/CD pipelines sem service principal

### Setup PowerShell Power Apps

**1. Instalar Módulo**

```powershell
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser
Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber -Scope CurrentUser
```

**2. Autenticar (Cada Sessão)**

```powershell
# Abre browser para login
Add-PowerAppsAccount

# Verificar autenticação
Get-PowerAppEnvironment
```

**3. Listar Flows**

```powershell
$environmentName = "Default-[TenantId]"
Get-Flow -EnvironmentName $environmentName

# Filtrar por solução
Get-Flow -EnvironmentName $environmentName | Where-Object { $_.Properties.SolutionId -eq "[SolutionId]" }
```

### Exportar Flows

**⚠️ ÚNICO método funcional para exportar flows**

```powershell
.\scripts\Export-ProductionFlows.ps1
```

**O que faz:**
1. Autentica via `Add-PowerAppsAccount` (browser)
2. Lista flows no environment
3. Para cada flow:
   - Obtém definição completa
   - Salva em `flow-definitions-production/[FlowName].json`
4. Mostra resumo

Resultado:
```
✓ 3 flows exportados
  - FLX_Flow1.json (45 KB)
  - FLX_Flow2.json (38 KB)
  - FLX_Flow3.json (52 KB)
```

### Atualizar Flows

```powershell
.\scripts\Import-FlowDefinitionToProduction.ps1 -FlowName "FLX_[NomeDoFlow]"
```

**Processo:**
1. Autentica via `Add-PowerAppsAccount`
2. Obtém JWT token (Get-JwtToken)
3. Carrega definição de `flow-definitions/[FlowName].json`
4. PATCH request para atualizar flow
5. Verifica sucesso

**⚠️ Importante:**
- Usar **PATCH** (não PUT)
- Usar JWT token nos headers
- Validar JSON antes (-Depth 100)

### Setup PAC CLI

**1. Instalar PAC CLI**

Download: https://aka.ms/PowerAppsCLI

Verificar instalação:
```powershell
pac --version
# Microsoft PowerPlatform CLI
# Version: 1.29.6+ga19e838
```

**2. Autenticar**

```powershell
# Autenticar (abre browser)
pac auth create --url https://[org].crm4.dynamics.com/

# Listar autenticações
pac auth list

# Selecionar ativa
pac auth select --index 1
```

**3. Listar Soluções**

```powershell
pac solution list
```

### Limitações PAC CLI

**✅ Usar PAC CLI para:**
- Listar soluções
- Exportar soluções SEM flows (ou com flows simples)
- Operações básicas em Dataverse

**❌ NÃO usar PAC CLI para:**
- Exportar flows (falha com ConnectionReference permissions)
- Criar flows (comando não existe em v2.2.1)
- Import de flows complexos

**Erro típico ao exportar solução com flows:**
```
Error: Missing privilege: prvAppendConnectionOwningTeam
Solution export failed.
```

**Solução:** Usar método PowerShell (Export-ProductionFlows.ps1)

---

## 🔄 Workflow de Autenticação Típica

### Início de Sessão

```powershell
# 1. Autenticar Power Automate (interativo)
Add-PowerAppsAccount

# 2. Verificar environment
$env = "Default-[TenantId]"
Get-PowerAppEnvironment | Where-Object { $_.EnvironmentName -eq $env }

# 3. (Opcional) Autenticar PAC CLI
pac auth list  # Ver se ainda está autenticado
# Se não: pac auth create --url [URL]

# 4. Carregar módulos PowerShell
Import-Module .\scripts\ConfigHelper.psm1
Import-Module .\scripts\SharePointListHelper.psm1

# 5. Testar conectividades
.\scripts\Test-SharePointConnection.ps1
.\scripts\Test-PowerAutomateConnection.ps1
```

### Durante Desenvolvimento

**Para operações SharePoint:**
```powershell
$token = Get-GraphApiToken -ClientId "..." -ClientSecret (Get-SavedClientSecret) -TenantId "..."
# Usar $token em Invoke-RestMethod
```

**Para operações Flows:**
```powershell
# Já autenticado com Add-PowerAppsAccount
Get-Flow -EnvironmentName $env
```

### Troubleshooting

**Token expirado:**
```powershell
# SharePoint/Graph: obter novo token (válido ~1 hora)
$token = Get-GraphApiToken -ClientId "..." -ClientSecret (Get-SavedClientSecret) -TenantId "..."

# Power Automate: re-autenticar
Add-PowerAppsAccount
```

**"Get-Flow returns 0 flows" apesar de existirem:**
- ✅ Usar `Add-PowerAppsAccount` (delegada)
- ❌ NÃO usar App Registration token

**"Insufficient privileges":**
- Verificar permissões API
- Grant admin consent
- Esperar 5-10 minutos (propagação)

**"Connection not authenticated":**
- No flow, verificar Connection References
- Re-autenticar connection no Power Automate UI
- Flows: Settings → Connections → Fix

---

## 📚 Referências

### Scripts de Autenticação
- `scripts/ConfigHelper.psm1` - Funções helper (Get-GraphApiToken, Get-SavedClientSecret)
- `scripts/Save-ClientSecret.ps1` - Guardar secret seguro
- `scripts/Test-SharePointConnection.ps1` - Testar SharePoint/Graph
- `scripts/Test-PowerAutomateConnection.ps1` - Testar Power Automate

### Documentação Microsoft
- [App Registration](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)
- [Microsoft Graph Permissions](https://docs.microsoft.com/en-us/graph/permissions-reference)
- [Power Apps PowerShell](https://docs.microsoft.com/en-us/powerapps/developer/data-platform/powershell/overview)
- [PAC CLI](https://docs.microsoft.com/en-us/power-platform/developer/cli/introduction)

---

**Próximo:** [START-NEXT-SESSION.md](START-NEXT-SESSION.md) - Checklist para cada sessão
