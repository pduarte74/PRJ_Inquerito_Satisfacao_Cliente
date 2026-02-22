# Scripts - [Nome do Projeto]

**Template versão:** 1.0

---

## 📋 Scripts Essenciais

### 🔐 Autenticação e Configuração

**Save-ClientSecret.ps1**
```powershell
.\Save-ClientSecret.ps1
```
Guarda Client Secret de forma segura. **Executar uma vez no setup inicial.**

**Test-SharePointConnection.ps1**
```powershell
.\Test-SharePointConnection.ps1
```
Testa autenticação e acesso à lista SharePoint.

**Test-PowerAutomateConnection.ps1**
```powershell
.\Test-PowerAutomateConnection.ps1
```
Testa autenticação Power Automate e lista flows disponíveis.

---

### ⚡ Gestão de Flows

**Export-ProductionFlows.ps1**
```powershell
.\Export-ProductionFlows.ps1
```
Exporta todos os flows da solução para `flow-definitions-production/`.

**⚠️ Único método funcional para exportar flows!**

**Import-FlowDefinitionToProduction.ps1**
```powershell
.\Import-FlowDefinitionToProduction.ps1 -FlowName "FLX_[NomeDoFlow]"
```
Atualiza definição de um flow em produção a partir de `flow-definitions/`.

---

### 📚 Módulos PowerShell

**ConfigHelper.psm1**

Funções helper para autenticação:
- `Get-SavedClientSecret` - Carregar Client Secret seguro
- `Get-GraphApiToken` - Obter token Graph API
- `Get-ProjectSettings` - Carregar config/settings.json
- `Test-GraphApiConnection` - Testar conexão Graph API

**Exemplo de uso:**
```powershell
Import-Module .\ConfigHelper.psm1

$token = Get-GraphApiToken `
    -ClientId "..." `
    -ClientSecret (Get-SavedClientSecret) `
    -TenantId "..."
```

**SharePointListHelper.psm1** *(a criar conforme necessário)*

Funções helper para SharePoint:
- `Get-SharePointListItems` - Obter itens de lista
- `Add-SharePointListItem` - Adicionar item
- `Update-SharePointListItem` - Atualizar item
- `Remove-SharePointListItem` - Remover item

---

## 📂 Estrutura de Pastas

```
scripts/
├── README.md                        # Este ficheiro
├── ConfigHelper.psm1                # Módulo autenticação
├── SharePointListHelper.psm1        # Módulo SharePoint (criar)
├── Save-ClientSecret.ps1            # Setup inicial
├── Test-SharePointConnection.ps1    # Teste SharePoint
├── Test-PowerAutomateConnection.ps1 # Teste Power Automate
├── Export-ProductionFlows.ps1       # Exportar flows
├── Import-FlowDefinitionToProduction.ps1  # Atualizar flows
├── flow-definitions/                # Definições development
│   └── FLX_*.json
├── flow-definitions-production/     # Backups produção
│   └── FLX_*.json
└── solution-working/                # Temporário (gitignored)
```

---

## 🔄 Workflows Comuns

### Setup Inicial (Uma Vez)

```powershell
# 1. Guardar Client Secret
.\Save-ClientSecret.ps1

# 2. Testar SharePoint
.\Test-SharePointConnection.ps1

# 3. Testar Power Automate
.\Test-PowerAutomateConnection.ps1
```

### Início de Cada Sessão

```powershell
# 1. Autenticar Power Automate (se necessário)
Add-PowerAppsAccount

# 2. Carregar módulos
Import-Module .\ConfigHelper.psm1
Import-Module .\SharePointListHelper.psm1
```

### Desenvolvimento de Flows

```powershell
# 1. Exportar flows atuais (backup)
.\Export-ProductionFlows.ps1

# 2. Editar definição em flow-definitions/

# 3. Importar para produção
.\Import-FlowDefinitionToProduction.ps1 -FlowName "FLX_[Nome]"

# 4. Testar flow no Power Automate UI
```

---

## 🛠️ Scripts a Criar Conforme Necessário

Adicione scripts específicos do projeto conforme surgem necessidades:

**Exemplos:**
- `Add-[Campo]ToList.ps1` - Adicionar campo à lista SharePoint
- `Send-InitialFormLink.ps1` - Enviar link Forms em lote
- `Generate-FormPrefillUrls.ps1` - Gerar URLs pré-preenchidas
- `Backup-Solution.ps1` - Backup automático de solução
- `Deploy-ToProduction.ps1` - Deploy completo

---

## 📚 Referências

- [../docs/AUTH-METHODS.md](../docs/AUTH-METHODS.md) - Métodos de autenticação
- [../docs/criar-flows-export-edit-import.md](../docs/criar-flows-export-edit-import.md) - Criar/editar flows
- [../docs/troubleshooting.md](../docs/troubleshooting.md) - Resolução de problemas

---

**Última atualização:** [Data]
