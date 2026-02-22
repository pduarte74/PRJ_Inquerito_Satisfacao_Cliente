# Setup Inicial - Projeto Forms → SharePoint → Power Automate

**Template versão:** 1.0  
**Tempo estimado:** 2-3 horas  
**Pré-requisitos:** Acesso a Microsoft 365, Azure AD, Power Platform

---

## 📋 Checklist de Setup

### Fase 1: Preparação (30 min)
- [ ] Copiar template para nova pasta de projeto
- [ ] Renomear ficheiros conforme projeto
- [ ] Configurar Git repository
- [ ] Configurar `.gitignore`
- [ ] Criar documentação inicial

### Fase 2: Azure AD / App Registration (30 min)
- [ ] Criar App Registration no Azure AD
- [ ] Configurar permissões SharePoint
- [ ] Configurar permissões Graph API
- [ ] Criar Client Secret
- [ ] Guardar credenciais de forma segura

### Fase 3: SharePoint (30 min)
- [ ] Criar SharePoint List
- [ ] Definir estrutura de campos
- [ ] Configurar views (All Items, Kanban, etc.)
- [ ] Testar permissões
- [ ] Documentar IDs e URLs

### Fase 4: Microsoft Forms (30 min)
- [ ] Criar formulário
- [ ] Configurar questões
- [ ] Mapear campos Forms → SharePoint
- [ ] Testar pre-fill com parâmetros URL
- [ ] Documentar Question IDs

### Fase 5: Power Platform (30 min)
- [ ] Criar solução em Dataverse
- [ ] Configurar connection references
- [ ] Configurar environment variables
- [ ] Testar autenticação PAC CLI
- [ ] Testar autenticação PowerShell

### Fase 6: Validação (30 min)
- [ ] Testar conexão SharePoint
- [ ] Testar conexão Power Automate
- [ ] Criar flow de teste
- [ ] Submeter formulário de teste
- [ ] Validar end-to-end básico

---

## 🔧 Passo-a-Passo Detalhado

### 1. Copiar Template

```powershell
# Copiar template para nova localização
$templatePath = "C:\Templates\Forms-SharePoint-PowerAutomate"
$projectPath = "C:\Projects\[NomeNovoProjeto]"

Copy-Item -Path $templatePath -Destination $projectPath -Recurse

# Renomear README
cd $projectPath
Rename-Item "README-TEMPLATE.md" "README.md"

# Editar README.md com detalhes do projeto
code README.md
```

### 2. Configurar Git Repository

```powershell
cd $projectPath

# Inicializar Git
git init

# Criar .gitignore
@"
# Credentials
config/client-secret.encrypted
config/settings.json

# PowerShell
*.ps1xml
*.log

# Solution exports (muito grandes)
solution-exports/*.zip

# Temporários
solution-working/
.DS_Store
Thumbs.db
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

# Primeiro commit
git add .
git commit -m "Initial commit from template"
```

### 3. Criar App Registration no Azure AD

**3.1 Aceder ao Azure Portal**
- URL: https://portal.azure.com
- Ir a: Azure Active Directory → App registrations → New registration

**3.2 Registar Aplicação**
```
Nome: [NomeProjeto]-Automation
Supported account types: Single tenant
Redirect URI: (deixar vazio)
```

**3.3 Configurar Permissões API**

Ir a: **API permissions** → **Add a permission**

**Microsoft Graph:**
- `Sites.ReadWrite.All` (Application)
- `User.Read.All` (Application)
- `Mail.Send` (Application) - se necessário

**SharePoint:**
- `Sites.FullControl.All` (Application)

**⚠️ Importante:** Clicar **"Grant admin consent"** após adicionar permissões

**3.4 Criar Client Secret**

Ir a: **Certificates & secrets** → **New client secret**
- Description: `[NomeProjeto]-Secret`
- Expires: 24 months (recomendado)

**⚠️ COPIAR O SECRET IMEDIATAMENTE** (não será mostrado novamente)

**3.5 Registar IDs**

Ir a: **Overview** e copiar:
- **Application (client) ID:** [GUID]
- **Directory (tenant) ID:** [GUID]

Guardar em ficheiro temporário (NÃO COMMIT):
```
config/temp-credentials.txt
---
ClientId: [Application ID]
TenantId: [Directory ID]
ClientSecret: [Secret copiado]
```

### 4. Guardar Client Secret de Forma Segura

```powershell
# Executar script de setup
.\scripts\Save-ClientSecret.ps1

# Introduzir o Client Secret quando solicitado
# Ficheiro criado: config/client-secret.encrypted

# APAGAR ficheiro temporário
Remove-Item "config\temp-credentials.txt"
```

### 5. Atualizar Configurações do Projeto

Editar: `config/settings.json`

```json
{
  "project": {
    "name": "[Nome do Projeto]",
    "version": "1.0.0",
    "environment": "development"
  },
  "azure": {
    "tenantId": "[Tenant ID]",
    "clientId": "[Application ID]",
    "clientSecretFile": "config/client-secret.encrypted"
  },
  "sharepoint": {
    "siteUrl": "https://[tenant].sharepoint.com/sites/[site]",
    "listName": "[Nome da Lista]",
    "listId": "[GUID - preencher depois]"
  },
  "powerPlatform": {
    "environmentName": "Default-[TenantId]",
    "dataverseUrl": "https://[org].crm4.dynamics.com/",
    "solutionName": "[nome-da-solucao]"
  },
  "forms": {
    "formId": "[Form ID - preencher depois]",
    "formUrl": "[URL completo do Forms]"
  }
}
```

### 6. Criar SharePoint List

**6.1 Criar Lista**
1. Ir ao SharePoint site
2. **Settings (gear icon)** → **Site contents**
3. **+ New** → **List**
4. Nome: `[Nome da Lista]`
5. Criar

**6.2 Adicionar Campos Base**

Campos obrigatórios (todos Text, exceto indicado):
- `Title` (já existe) - renomear label para "Código"
- `Nome` (Text, single line)
- `Email` (Text, single line)
- `Estado` (Choice: Em Preparação, Para Envio, Enviado, Submetido, Validado)
- `DataEnvio` (Date and Time)
- `DataSubmissao` (Date and Time)
- `DataCriacao` (Date and Time)

**Adicionar campos específicos do projeto conforme necessário**

**6.3 Configurar View "Board" (Kanban)**
1. Criar nova view: **Board**
2. Group by: `Estado`
3. Salvar

**6.4 Obter List ID**

```powershell
Import-Module .\scripts\ConfigHelper.psm1

$token = Get-GraphApiToken `
    -ClientId "[Client ID]" `
    -ClientSecret (Get-SavedClientSecret) `
    -TenantId "[Tenant ID]"

$siteUrl = "https://[tenant].sharepoint.com/sites/[site]"
$listName = "[Nome da Lista]"

# Obter site ID
$siteId = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/sites/$($siteUrl.Replace('https://',''))?`$select=id" -Headers @{Authorization="Bearer $token"}).id

# Obter list ID
$listId = (Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/sites/$siteId/lists?`$filter=displayName eq '$listName'" -Headers @{Authorization="Bearer $token"}).value[0].id

Write-Host "List ID: $listId"
# Copiar e adicionar a config/settings.json
```

### 7. Criar Microsoft Forms

**7.1 Criar Formulário**
1. Ir a: https://forms.office.com
2. **+ New Form**
3. Título: `[Nome do Formulário]`
4. Descrição: [Descrição do objetivo]

**7.2 Adicionar Questões**

Adicionar questões conforme necessário. Para cada questão:
- Definir tipo (Text, Choice, Rating, etc.)
- Marcar "Required" se obrigatória
- Configurar validação se necessário

**7.3 Obter Form ID e Question IDs**

```javascript
// No browser, abrir Developer Tools (F12)
// Ir ao Forms em modo edição
// Executar no Console:

// Obter Form ID
console.log("Form ID:", window.location.pathname.split('/')[4]);

// Obter Question IDs
const questions = document.querySelectorAll('[data-automation-id="questionId"]');
questions.forEach(q => {
    const title = q.closest('[role="group"]')?.querySelector('[data-automation-id="questionTitle"]')?.textContent;
    const id = q.textContent;
    console.log(`${title}: ${id}`);
});
```

Documentar em: `docs/forms-question-ids.md`

**7.4 Configurar Webhook (Connection to SharePoint)**

- Não é necessário configurar manualmente
- Flow automático fará isso via trigger "When a new response is submitted"

### 8. Criar Solução Power Platform

**8.1 Autenticar PAC CLI**

```powershell
# Verificar instalação
pac --version

# Autenticar
pac auth create --url https://[org].crm4.dynamics.com/

# Verificar
pac auth list
```

**8.2 Criar Solução**

```powershell
# Criar nova solução
pac solution init `
    --publisher-name "[Nome da Organização]" `
    --publisher-prefix "proj" `
    --outputDirectory ".\solutions\[nome-solucao]"

# OU criar via UI (recomendado):
# https://make.powerapps.com → Solutions → New solution
```

**Dados da solução:**
- Display name: `[Nome Projeto] Automation`
- Name: `[nomeprojetoautomation]`
- Publisher: [Selecionar/criar publisher]
- Version: 1.0.0.0

### 9. Testar Autenticação

**9.1 Testar SharePoint/Graph API**

```powershell
.\scripts\Test-SharePointConnection.ps1
```

Resultado esperado:
```
✓ ClientSecret carregado
✓ Token obtido com sucesso
✓ Lista encontrada: [Nome da Lista]
✓ [N] itens na lista
```

**9.2 Testar Power Automate**

```powershell
.\scripts\Test-PowerAutomateConnection.ps1
```

Resultado esperado:
```
✓ Autenticado com sucesso
✓ Environment encontrado: Default-[TenantId]
✓ [N] flows encontrados
```

### 10. Criar Flow de Teste

**10.1 Criar Flow Mínimo no UI**

1. Ir a: https://make.powerautomate.com
2. **+ Create** → **Automated cloud flow**
3. Nome: `TEST_[NomeProjeto]_FormResponse`
4. Trigger: **When a new response is submitted** (Microsoft Forms)
5. Selecionar o formulário criado
6. Adicionar ação: **Get response details** (Microsoft Forms)
7. Adicionar ação: **Create item** (SharePoint)
   - Site: [SharePoint site]
   - List: [Lista criada]
   - Mapear campos básicos
8. Salvar

**10.2 Adicionar à Solução**

1. Ir a "My flows"
2. Clicar **[...]** no flow
3. **Add to solution**
4. Selecionar solução criada

### 11. Teste End-to-End Inicial

**11.1 Submeter Formulário Teste**

1. Abrir Forms em modo preview
2. Preencher com dados de teste
3. Submeter

**11.2 Verificar Flow Execution**

1. Ir a flow no Power Automate
2. Ver **Run history**
3. Verificar status: ✓ Succeeded

**11.3 Verificar SharePoint**

1. Abrir lista SharePoint
2. Verificar novo item criado
3. Validar dados mapeados corretamente

---

## ✅ Verificação Final

Após completar todos os passos:

- [ ] App Registration criada e configurada
- [ ] Client Secret guardado de forma segura
- [ ] SharePoint List criada com campos base
- [ ] Microsoft Forms criado
- [ ] Question IDs documentados
- [ ] Power Platform Solution criada
- [ ] Flow de teste criado e funcional
- [ ] Teste end-to-end bem-sucedido
- [ ] Documentação atualizada com IDs e URLs
- [ ] Git repository configurado e primeiro commit feito

**Próximos passos:** Ver [docs/iteracoes-desenvolvimento.md](iteracoes-desenvolvimento.md)

---

## 🆘 Troubleshooting

### Erro: "Insufficient privileges to complete the operation"
- Verificar permissões API foram granted admin consent
- Esperar 5-10 minutos após grant (propagação)
- Verificar user tem permissões adequadas no SharePoint

### Erro: "Client secret has expired"
- Criar novo client secret no Azure AD
- Executar `.\scripts\Save-ClientSecret.ps1` novamente

### Flow não executa após submissão Forms
- Verificar webhook Forms → Flow está ativo
- Verificar trigger "When a new response is submitted" está configurado
- Testar manualmente: Run → Test → Manual → Trigger flow

### Token de autenticação inválido
```powershell
# Limpar e re-autenticar PAC CLI
pac auth clear
pac auth create --url [URL]

# Limpar e re-autenticar Power Automate
Add-PowerAppsAccount  # Abre browser
```

---

**Próximo:** [START-NEXT-SESSION.md](START-NEXT-SESSION.md) - Checklist para cada sessão de trabalho
