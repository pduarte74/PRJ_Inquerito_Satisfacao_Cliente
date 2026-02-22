# 📝 Cheat Sheet - Referência Rápida

**Para:** Comandos e patterns frequentes durante o desenvolvimento.

---

## 🚀 Setup Inicial (One-Time)

### Copiar Template
```powershell
$dest = "C:\Projects\NovoProjeto"
Copy-Item -Path "TEMPLATE_Forms_SharePoint_PowerAutomate" -Dest $dest -Recurse
cd $dest
```

### Configuração Rápida
```powershell
# 1. Renomear README
Rename-Item "README-TEMPLATE.md" "README.md"

# 2. Copiar settings
Copy-Item "config\settings.json.template" "config\settings.json"

# 3. Editar settings
code config\settings.json

# 4. Guardar secret
.\scripts\Save-ClientSecret.ps1

# 5. Testar
.\scripts\Test-SharePointConnection.ps1
.\scripts\Test-PowerAutomateConnection.ps1
```

---

## 🔐 Autenticação

### SharePoint / Graph API (App Registration)
```powershell
Import-Module .\scripts\ConfigHelper.psm1

$settings = Get-ProjectSettings
$secret = Get-SavedClientSecret
$token = Get-GraphApiToken -ClientId $settings.clientId `
                           -ClientSecret $secret `
                           -TenantId $settings.tenantId

# Usar token
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/json"
}
```

### Power Automate (Delegada)
```powershell
# Autenticar (abre browser)
Add-PowerAppsAccount

# Listar flows
Get-Flow -EnvironmentName "Default-<tenant-id>"

# Exportar flow
Get-Flow -FlowName "<flow-id>" | Export-Flow -Destination "flows\"
```

---

## 📊 SharePoint Lists

### Criar Item
```powershell
$settings = Get-ProjectSettings
$token = Get-GraphApiToken -ClientId $settings.clientId `
                           -ClientSecret (Get-SavedClientSecret) `
                           -TenantId $settings.tenantId

$siteId = "<site-id>"
$listId = $settings.listId
$uri = "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$listId/items"

$body = @{
    fields = @{
        Title = "Teste"
        Campo1 = "Valor1"
    }
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri `
                  -Method POST `
                  -Headers @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" } `
                  -Body $body
```

### Listar Items
```powershell
$uri = "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$listId/items?expand=fields"
$items = Invoke-RestMethod -Uri $uri `
                            -Method GET `
                            -Headers @{ "Authorization" = "Bearer $token" }
$items.value | ForEach-Object { $_.fields }
```

### Atualizar Item
```powershell
$itemId = "<item-id>"
$uri = "https://graph.microsoft.com/v1.0/sites/$siteId/lists/$listId/items/$itemId/fields"

$body = @{
    Campo1 = "NovoValor"
} | ConvertTo-Json

Invoke-RestMethod -Uri $uri `
                  -Method PATCH `
                  -Headers @{ "Authorization" = "Bearer $token"; "Content-Type" = "application/json" } `
                  -Body $body
```

---

## 🔄 Power Automate Flows

### Listar Todos os Flows
```powershell
Add-PowerAppsAccount
$envName = "Default-<tenant-id>"
$flows = Get-Flow -EnvironmentName $envName
$flows | Select-Object DisplayName, FlowName, Enabled | Format-Table
```

### Exportar Flow Específico
```powershell
$flowId = "<flow-id>"
Get-Flow -FlowName $flowId | Export-Flow -Destination "flow-definitions-production\"
```

### Exportar Todos os Flows
```powershell
.\scripts\Export-ProductionFlows.ps1
# Flows salvos em flow-definitions-production\
```

### Atualizar Flow
```powershell
# 1. Exportar definição atual
Get-Flow -FlowName "<flow-id>" | Export-Flow -Destination "temp\"

# 2. Editar JSON (trocar properties.definition por definition)
$flow = Get-Content "temp\Flow.json" -Raw | ConvertFrom-Json
$definition = $flow.properties.definition
$definition | ConvertTo-Json -Depth 100 | Set-Content "flow-definitions\MyFlow.json"

# 3. Importar de volta
.\scripts\Import-FlowDefinitionToProduction.ps1 -FlowId "<flow-id>" -DefinitionPath "flow-definitions\MyFlow.json"
```

---

## 📝 Microsoft Forms

### Obter Question IDs
```javascript
// Abrir o Form, F12 (Dev Tools) → Console
// Preencher um campo e ver Network tab
// Procurar por POST /formapi/api/...
// Body do request tem question IDs

// Ou usar este script:
const questions = document.querySelectorAll('[data-automation-id="questionTitle"]');
questions.forEach((q, i) => {
    const id = q.closest('[data-automation-id]').getAttribute('data-automation-id');
    console.log(`${i+1}. ${q.textContent.trim()}: ${id}`);
});
```

### Criar URL Pre-fill
```
https://forms.office.com/Pages/ResponsePage.aspx?id={FormId}&entry={questionId}={valor}&entry={questionId2}={valor2}
```

**Exemplo:**
```
https://forms.office.com/Pages/ResponsePage.aspx?id=abc123&entry=r100=João&entry=r101=joao@example.com
```

---

## 🗂️ Git Workflow

### Inicializar Repo
```powershell
git init
git add .
git commit -m "feat: initial setup from template v1.0"
git branch -M main
git remote add origin <repo-url>
git push -u origin main
```

### Commit Diário
```powershell
# Ver mudanças
git status

# Adicionar ficheiros específicos
git add scripts\MyNewScript.ps1
git add docs\MyDoc.md

# Commit
git commit -m "feat: add new script for X"

# Push
git push
```

### Verificar Secrets Não Estão no Repo
```powershell
git status
# NÃO deve aparecer:
# - config/settings.json
# - config/*.encrypted
# Se aparecerem: adicionar ao .gitignore e remover tracking

# Remover do tracking se já committed
git rm --cached config/settings.json
git commit -m "fix: remove secrets from repo"
```

---

## 🧪 Testes

### Testar Conectividade SharePoint
```powershell
.\scripts\Test-SharePointConnection.ps1
# Deve retornar: ✅ Conexão SharePoint bem sucedida
```

### Testar Conectividade Power Automate
```powershell
.\scripts\Test-PowerAutomateConnection.ps1
# Deve retornar: ✅ Conexão Power Automate bem sucedida
```

### Testar Flow Manualmente
1. Abrir Power Automate: https://make.powerautomate.com
2. My flows → [Nome do Flow]
3. **Test** → **Manually** → **Run flow**
4. Ver resultado em "28-day run history"

---

## 📚 Comandos PowerShell Úteis

### Navegação
```powershell
# Ir para raiz do projeto
cd C:\Projects\MeuProjeto

# Listar estrutura
Get-ChildItem -Recurse -Directory | Select-Object FullName

# Procurar ficheiros
Get-ChildItem -Recurse -Filter "*.ps1"
```

### JSON
```powershell
# Ler JSON
$data = Get-Content "config\settings.json" -Raw | ConvertFrom-Json

# Escrever JSON
$data | ConvertTo-Json -Depth 100 | Set-Content "output.json" -Encoding UTF8

# IMPORTANTE: Usar -Depth 100 para flows!
```

### Módulos
```powershell
# Importar módulo
Import-Module .\scripts\ConfigHelper.psm1

# Ver funções disponíveis
Get-Command -Module ConfigHelper

# Ver help de função
Get-Help Get-GraphApiToken -Detailed
```

---

## 🔍 Troubleshooting Rápido

### Erro: "Access Denied"
```powershell
# 1. Verificar permissões no Azure Portal
# 2. Grant admin consent
# 3. Esperar 2-3 minutos
# 4. Testar novamente
.\scripts\Test-SharePointConnection.ps1
```

### Erro: "Invalid client secret"
```powershell
# Re-guardar secret
.\scripts\Save-ClientSecret.ps1
# Cole o secret COMPLETO (sem espaços extra)
```

### Erro: "Cannot find module"
```powershell
# Verificar path relativo
Get-Location  # Deve estar na raiz do projeto

# Executar de dentro do projeto
cd C:\Projects\MeuProjeto
.\scripts\[script].ps1
```

### Flow não aparece na lista
```powershell
# Não usar App Registration para flows!
# Usar autenticação delegada:
Add-PowerAppsAccount
Get-Flow -EnvironmentName "Default-<tenant-id>"
```

### JSON truncado no Export
```powershell
# Sempre usar -Depth 100
$data | ConvertTo-Json -Depth 100 | Set-Content "output.json"
```

---

## 📋 Checklist Desenvolvimento Diário

### Início da Sessão
```powershell
# 1. Abrir projeto
cd C:\Projects\MeuProjeto
code .

# 2. Ver estado
git status
cat docs\ESTADO-ATUAL.md

# 3. Planear tasks (ver START-NEXT-SESSION.md)
```

### Durante Desenvolvimento
```powershell
# 1. Testar frequentemente
.\scripts\Test-SharePointConnection.ps1

# 2. Exportar flows antes de editar
.\scripts\Export-ProductionFlows.ps1

# 3. Commit incremental
git add .
git commit -m "feat: add X"
```

### Fim da Sessão
```powershell
# 1. Atualizar documentação
code docs\ESTADO-ATUAL.md

# 2. Commit final
git add .
git commit -m "docs: update status"
git push

# 3. Exportar flows finais (backup)
.\scripts\Export-ProductionFlows.ps1
```

---

## 🎯 Patterns Comuns

### Iteração 1: Forms → SharePoint
1. Criar Forms
2. Criar SharePoint List (com campos matching)
3. Criar Flow:
   - Trigger: "When a new response is submitted" (Forms)
   - Action: "Create item" (SharePoint)
   - Map fields: Forms outputs → SharePoint columns

### Iteração 2: Notificações
1. Editar Flow da Iteração 1
2. Adicionar Action: "Post message in a chat or channel" (Teams)
3. Usar outputs do Forms para personalizar mensagem

### Iteração 3: Criação de Pastas
1. Criar nova Action: "Create new folder" (SharePoint)
2. Path: `/Shared Documents/[Nome do Item]`
3. Guardar Folder URL em campo da lista
4. Adicionar permissões (se necessário)

### Iteração 4: Geração de Documentos
1. Criar template Word/Excel com placeholders
2. Upload para SharePoint
3. Flow: "Populate template" (Word/Excel)
4. Convert to PDF
5. Save to folder criado na Iteração 3

### Iteração 5: Email Personalizado
1. Adicionar Action: "Send email" (Office 365 Outlook)
2. To: Email do Forms
3. Body: Usar outputs previousos (nome, link folder, etc.)
4. Attach PDFs da Iteração 4 (opcional)

---

## 📖 Links Rápidos

### Documentação do Template
- [README.md](README.md) - Principal
- [QUICKSTART.md](QUICKSTART.md) - Setup 30 min
- [00-LEIA-ME-PRIMEIRO.md](00-LEIA-ME-PRIMEIRO.md) - Visão geral
- [docs/INDEX.md](docs/INDEX.md) - Índice completo
- [docs/troubleshooting.md](docs/troubleshooting.md) - Problemas comuns

### Microsoft Docs
- [Power Automate](https://docs.microsoft.com/power-automate/)
- [Microsoft Graph](https://docs.microsoft.com/graph/)
- [SharePoint REST API](https://docs.microsoft.com/sharepoint/dev/)
- [Azure AD App Registration](https://learn.microsoft.com/azure/active-directory/develop/)

### Ferramentas Online
- [Power Automate Portal](https://make.powerautomate.com)
- [Azure Portal](https://portal.azure.com)
- [Microsoft Forms](https://forms.office.com)
- [SharePoint](https://[tenant].sharepoint.com)

---

## ⚡ One-Liners Úteis

### Exportar todos os flows
```powershell
Add-PowerAppsAccount; .\scripts\Export-ProductionFlows.ps1
```

### Ver último commit
```powershell
git log -1 --oneline
```

### Contar linhas de código
```powershell
(Get-ChildItem -Recurse -Include "*.ps1","*.psm1" | Get-Content | Measure-Object -Line).Lines
```

### Listar todos os settings
```powershell
Get-Content config\settings.json -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 10
```

### Backup rápido
```powershell
$date = Get-Date -Format "yyyyMMdd-HHmm"
Copy-Item -Path . -Destination "..\Backup-$date" -Recurse -Exclude ".git","flow-definitions-production"
```

---

## 🎓 Dicas Pro

### JSON Depth (IMPORTANTE!)
**Sempre** usar `-Depth 100` ao exportar flows:
```powershell
$flow | ConvertTo-Json -Depth 100 | Set-Content "flow.json"
```
Depth padrão (2) trunca definições complexas.

### Autenticação
- **SharePoint/Graph:** App Registration (Client Credentials)
- **Power Automate:** Delegação (Interactive)
- **Nunca misturar:** Cada serviço tem o seu método!

### PAC CLI
❌ **NÃO usar** para exportar flows com ConnectionReferences  
✅ **Usar** `Export-ProductionFlows.ps1` em vez disso

### Git
- Sempre verificar `.gitignore` antes do primeiro commit
- Nunca commitar `config/settings.json` ou `*.encrypted`
- Commit frequente (incremental melhor que grande)

### Desenvolvimento
- Começar pequeno (Iteração 1)
- Testar frequentemente
- Documentar à medida que avança
- Exportar flows antes de editar (backup!)

---

**Última atualização:** 21 de Fevereiro de 2026  
**Versão Template:** 1.0  
**Para mais detalhes:** Ver documentação completa em [docs/INDEX.md](docs/INDEX.md)
