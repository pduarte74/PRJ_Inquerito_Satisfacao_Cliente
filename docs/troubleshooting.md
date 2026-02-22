# Troubleshooting - [Nome do Projeto]

**Última atualização:** [Data]

---

## 🔐 Problemas de Autenticação

### Erro: "Insufficient privileges to complete the operation"

**Sintomas:**
- Erro ao obter lista SharePoint
- Erro ao criar item em lista
- HTTP 403 Forbidden

**Causas possíveis:**
1. Permissões API não foram granted admin consent
2. Client Secret expirou
3. Utilizador sem permissões no SharePoint

**Soluções:**

```powershell
# 1. Verificar permissões no Azure AD
# Portal → App Registration → API permissions
# Garantir que todas têm checkmark verde (Granted)

# 2. Grant admin consent
# Clicar "Grant admin consent for [Org]"
# Aguardar 5-10 minutos para propagação

# 3. Verificar secret não expirou
# Portal → App Registration → Certificates & secrets
# Ver "Expires" date

# 4. Criar novo secret se necessário
# New client secret → Copiar secret
.\Save-ClientSecret.ps1
```

### Erro: "Get-Flow returns 0 flows" apesar de existirem flows

**Sintomas:**
- `Get-Flow` não retorna flows
- Flows visíveis no Power Automate UI

**Causa:**
- Autenticação com App Registration (não funciona para flows)

**Solução:**

```powershell
# ✅ Usar autenticação delegada
Add-PowerAppsAccount  # Abre browser

# ❌ NÃO usar App Registration token
# Get-Flow requer autenticação delegada (user context)
```

### Erro: "Connection not authenticated" no flow

**Sintomas:**
- Flow falha em ação específica
- Mensagem: "Connection not authenticated"

**Solução:**

1. Abrir flow no Power Automate UI
2. Ir a: Settings → Connections
3. Para cada connection com ⚠️:
   - Clicar "Fix connection"
   - Re-autenticar
   - Salvar flow

---

## 📋 Problemas com SharePoint Lists

### Erro: "List not found" ou lista vazia

**Sintomas:**
- Script não encontra lista
- `Get-SharePointListItems` retorna array vazio

**Verificações:**

```powershell
# 1. Verificar nome exato da lista
# Nome em settings.json deve corresponder exatamente (case-sensitive)

# 2. Obter lista manualmente
Import-Module .\scripts\ConfigHelper.psm1
$token = Get-GraphApiToken -ClientId "..." -ClientSecret (Get-SavedClientSecret) -TenantId "..."

$headers = @{ "Authorization" = "Bearer $token" }
$siteUrl = "https://graph.microsoft.com/v1.0/sites/[tennant].sharepoint.com:/sites/[site]"
$site = Invoke-RestMethod -Uri $siteUrl -Headers $headers

$listsUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists"
$lists = Invoke-RestMethod -Uri $listsUrl -Headers $headers

# Listar todas as listas
$lists.value | ForEach-Object { Write-Host $_.displayName }
```

### Erro: "Column 'X' does not exist"

**Sintomas:**
- Erro ao adicionar/atualizar item
- Mensagem sobre campo inexistente

**Solução:**

```powershell
# 1. Listar todos os campos da lista
$listId = "[List ID]"
$columnsUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/columns"
$columns = Invoke-RestMethod -Uri $columnsUrl -Headers $headers

$columns.value | ForEach-Object { 
    Write-Host "$($_.displayName) (Internal: $($_.name))" 
}

# 2. Usar nome interno correto
# Forms: "Nome do Campo"
# SharePoint internal: "Title", "NomeDoCampo" (sem espaços)
```

---

## ⚡ Problemas com Power Automate Flows

### Flow não executa após Forms submission

**Sintomas:**
- Formulário submetido mas flow não dispara
- Sem entrada em Run history

**Verificações:**

1. **Flow está ligado (Started)?**
   ```
   Power Automate UI → Flow → Estado = "On"
   ```

2. **Trigger está configurado corretamente?**
   ```
   Trigger: "When a new response is submitted"
   Form ID correto?
   ```

3. **Webhook do Forms está ativo?**
   ```
   Executar flow manualmente (Test)
   Se funciona: problema é no webhook
   Recriar conexão Forms no flow
   ```

### Flow falha em parse JSON

**Sintomas:**
- Flow para na ação "Parse JSON"
- Erro: "Invalid JSON"

**Soluções:**

```json
// 1. Validar schema JSON
// Usar: https://jsonschema.net/

// 2. Adicionar verificação de null
{
  "type": "object",
  "properties": {
    "campo": {
      "type": ["string", "null"]  // Permitir null
    }
  }
}

// 3. Usar Compose antes de Parse JSON para debug
// Action: Compose
// Inputs: @{outputs('Get_response_details')?['body']}
// Ver output e ajustar schema
```

### Flow falha com "Connection not found"

**Sintomas:**
- Erro em ação de connector
- Mensagem sobre connection missing

**Causa:**
- Flow importado sem re-autenticar connections

**Solução:**

1. Abrir flow em edição
2. Para cada ação com ⚠️:
   - Clicar na ação
   - Selecionar/criar connection
   - Autenticar
3. Salvar flow

---

## 🔧 Problemas com PAC CLI

### Erro: "Missing privilege: prvAppendConnectionOwningTeam"

**Sintomas:**
- `pac solution export` falha
- Mensagem sobre permissões

**Causa:**
- PAC CLI não tem permissões para exportar ConnectionReferences

**Solução:**

```powershell
# ✅ NÃO usar PAC CLI para exportar flows
# Usar método PowerShell delegado:
.\scripts\Export-ProductionFlows.ps1

# PAC CLI serve apenas para:
# - Listar soluções
# - Exportar soluções SEM flows
# - Operações Dataverse básicas
```

### PAC CLI não autentica

**Sintomas:**
- `pac auth create` falha
- Browser não abre

**Soluções:**

```powershell
# 1. Limpar autenticações existentes
pac auth clear

# 2. Re-autenticar
pac auth create --url https://[org].crm4.dynamics.com/

# 3. Verificar browser default está configurado

# 4. Usar modo device code (alternativa)
pac auth create --url https://[org].crm4.dynamics.com/ --deviceCode
```

---

## 📝 Problemas com Scripts PowerShell

### Script não encontra módulo

**Sintomas:**
```
Import-Module : The specified module '...' was not loaded
```

**Solução:**

```powershell
# 1. Verificar caminho relativo correto
# Scripts devem estar na pasta scripts/
# Módulos: .\ConfigHelper.psm1 (relativo)

# 2. Usar caminho absoluto se necessário
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Import-Module "$scriptDir\ConfigHelper.psm1" -Force

# 3. Verificar ExecutionPolicy
Get-ExecutionPolicy
# Se Restricted:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Token expira durante execução

**Sintomas:**
- Script funciona inicialmente
- Depois falha com erro de autenticação

**Causa:**
- Token Graph API válido ~1 hora

**Solução:**

```powershell
# Obter novo token antes de operações longas
$token = Get-GraphApiToken -ClientId "..." -ClientSecret (Get-SavedClientSecret) -TenantId "..."

# Para loops longos, refresh token periodicamente:
foreach ($item in $items) {
    if ((Get-Date) -gt $tokenExpiry) {
        $token = Get-GraphApiToken -ClientId "..." -ClientSecret (Get-SavedClientSecret) -TenantId "..."
        $tokenExpiry = (Get-Date).AddMinutes(50)
    }
    # ... operações
}
```

---

## 🐛 Debugging Steps Gerais

### 1. Isolar o Problema

```powershell
# Testar cada componente individualmente
.\scripts\Test-SharePointConnection.ps1
.\scripts\Test-PowerAutomateConnection.ps1

# Se ambos OK, problema é na integração
```

### 2. Verificar Logs

**Power Automate:**
- Flow → Run history
- Ver detalhes de runs falhados
- Expandir cada ação para ver inputs/outputs

**SharePoint:**
- Site → Settings → Site contents → Lista → Settings → Version history
- Verificar últimas modificações

### 3. Simplificar e Testar

**Para flows:**
1. Criar flow minimalista (só trigger + 1 ação)
2. Testar
3. Adicionar ações incrementalmente
4. Identificar onde falha

**Para scripts:**
1. Comentar código complexo
2. Testar partes individuais
3. Adicionar Write-Host para debug
4. Verificar valores de variáveis

### 4. Verificar Dados

```powershell
# Output de objetos para análise
$objeto | ConvertTo-Json -Depth 5 | Out-File "debug.json"

# Verificar tipo de dados
$variavel.GetType()

# Inspecionar propriedades
$variavel | Get-Member
```

---

## 📞 Quando Pedir Ajuda

Se após troubleshooting o problema persiste:

1. **Documentar o problema:**
   - O que tentou fazer?
   - O que esperava?
   - O que aconteceu?
   - Mensagem de erro completa
   - Steps to reproduce

2. **Recolher informação:**
   - Versões (PowerShell, PAC CLI, módulos)
   - Configurações (settings.json - sem secrets!)
   - Run history ID (flows)
   - Screenshots se apropriado

3. **Tentar pesquisar:**
   - Microsoft Docs
   - Power Platform Community
   - Stack Overflow
   - GitHub Issues de projetos similares

4. **Consultar equipa/suporte:**
   - Com documentação completa do problema
   - Histórico do que já tentou

---

## 📚 Recursos Úteis

- [Microsoft Power Automate Docs](https://docs.microsoft.com/power-automate/)
- [Microsoft Graph API Docs](https://docs.microsoft.com/graph/)
- [SharePoint REST API Reference](https://docs.microsoft.com/sharepoint/dev/sp-add-ins/get-to-know-the-sharepoint-rest-service)
- [Power Platform Community](https://powerusers.microsoft.com/)

---

**Adicione problemas específicos conforme surgem no projeto!**
