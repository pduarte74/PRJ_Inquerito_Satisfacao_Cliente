# Checklist - Iniciar Sessão de Trabalho

**Template versão:** 1.0  
**Tempo estimado:** 5-10 minutos

---

## 📋 Checklist Rápido

### Cada Sessão de Trabalho

- [ ] **Autenticação Power Automate** (se necessário)
  ```powershell
  Add-PowerAppsAccount
  ```

- [ ] **Verificar environment**
  ```powershell
  Get-PowerAppEnvironment | Where-Object { $_.EnvironmentName -eq "Default-[TenantId]" }
  ```

- [ ] **Carregar módulos PowerShell**
  ```powershell
  Import-Module .\scripts\ConfigHelper.psm1
  Import-Module .\scripts\SharePointListHelper.psm1
  ```

- [ ] **Ler estado atual**
  - Abrir: [ESTADO-ATUAL.md](ESTADO-ATUAL.md)
  - Verificar última iteração completa
  - Ver próximos passos

- [ ] **Verificar Git status**
  ```powershell
  git status
  git pull  # Se trabalho em equipa
  ```

- [ ] **Planear trabalho desta sessão**
  - Definir objetivo claro
  - Identificar tarefas
  - Estimar tempo

---

## 🔐 Autenticação Detalhada

### 1. Power Automate (Se vai trabalhar com flows)

```powershell
# Autenticar (abre browser)
Add-PowerAppsAccount

# Verificar autenticação funcionou
$env = "Default-[TenantId]"
$flows = Get-Flow -EnvironmentName $env

if ($flows.Count -gt 0) {
    Write-Host "✓ Autenticado! $($flows.Count) flows encontrados" -ForegroundColor Green
} else {
    Write-Host "⚠ Autenticação pode ter falhado ou sem flows" -ForegroundColor Yellow
}
```

### 2. SharePoint / Graph API (Se vai trabalhar com listas)

```powershell
Import-Module .\scripts\ConfigHelper.psm1

# Testar conexão
.\scripts\Test-SharePointConnection.ps1

# Ou manualmente:
$token = Get-GraphApiToken `
    -ClientId "[ClientId]" `
    -ClientSecret (Get-SavedClientSecret) `
    -TenantId "[TenantId]"

if ($token) {
    Write-Host "✓ Token obtido com sucesso" -ForegroundColor Green
}
```

### 3. PAC CLI (Raramente necessário)

```powershell
# Verificar autenticação existente
pac auth list

# Se não autenticado:
# pac auth create --url https://[org].crm4.dynamics.com/
```

---

## 📚 Ler Estado Atual

### Documentos a Revisar

1. **[ESTADO-ATUAL.md](ESTADO-ATUAL.md)**
   - Iteração atual
   - Componentes implementados
   - Próximos passos

2. **[README.md](../README.md)**
   - Quick start commands
   - Links úteis

3. **Última iteração:** `ITERACAO-[N]-[NOME].md`
   - O que foi feito
   - Testes realizados
   - Issues conhecidos

### Verificar Flows em Produção

```powershell
# Listar flows
$env = "Default-[TenantId]"
Get-Flow -EnvironmentName $env | Select-Object DisplayName, State, LastModifiedTime | Format-Table

# Ver detalhes de um flow específico
$flow = Get-Flow -EnvironmentName $env -FlowName "[FlowName]"
$flow.Properties | Select-Object DisplayName, State, LastModifiedTime
```

### Verificar SharePoint List

```powershell
Import-Module .\scripts\ConfigHelper.psm1
Import-Module .\scripts\SharePointListHelper.psm1

$token = Get-GraphApiToken -ClientId "..." -ClientSecret (Get-SavedClientSecret) -TenantId "..."

# Contar itens na lista
$items = Get-SharePointListItems `
    -SiteUrl "https://[tenant].sharepoint.com/sites/[site]" `
    -ListName "[Nome da Lista]" `
    -Token $token

Write-Host "Itens na lista: $($items.Count)"
```

---

## 🎯 Planear Trabalho

### Definir Objetivo da Sessão

**Exemplo:**
- [ ] Completar Iteração 2: Adicionar alerta Teams
- [ ] Debugging: Flow falha em parse JSON
- [ ] Documentação: Atualizar mapping Forms → SharePoint
- [ ] Teste: Validar flow end-to-end com 5 submissões

### Identificar Tarefas

**Break down em steps pequenos e testáveis:**

**Exemplo - Iteração 2: Teams Alert**
1. [ ] Adicionar action "Post message in a chat or channel" ao flow
2. [ ] Configurar connection a Teams
3. [ ] Testar com dados hardcoded
4. [ ] Adicionar dynamic content (fornecedor, data)
5. [ ] Testar com submissão real Forms
6. [ ] Documentar em ITERACAO-2-TEAMS-ALERT.md
7. [ ] Atualizar ESTADO-ATUAL.md

### Estimar Tempo

- Desenvolvimento simples: 30-60 min
- Iteração média: 1-2 horas
- Iteração complexa: 2-4 horas
- Debugging: ??? (pode variar)

### Criar Checklist de Trabalho

Pode usar este ficheiro ou criar ficheiro dedicado:

```markdown
## Sessão [Data] - [Objetivo]

### Tarefas
- [ ] Tarefa 1
- [ ] Tarefa 2
- [ ] Tarefa 3

### Testes
- [ ] Teste unitário: [descrição]
- [ ] Teste integração: [descrição]

### Documentação
- [ ] Atualizar: [ficheiro]
- [ ] Criar: [ficheiro]
```

---

## 🔧 Preparar Ambiente

### Verificar Git

```powershell
# Status atual
git status

# Pull (se trabalho em equipa)
git pull origin main

# Criar branch (opcional, boas práticas)
git checkout -b feature/iteracao-N
```

### Abrir Ficheiros Relevantes

**VS Code:**
```powershell
# Abrir workspace
code .

# Abrir ficheiros específicos
code docs/ESTADO-ATUAL.md
code docs/ITERACAO-[N].md
code scripts/Export-ProductionFlows.ps1
```

### Backup de Segurança (Recomendado antes de mudanças grandes)

```powershell
# Exportar flows atuais
.\scripts\Export-ProductionFlows.ps1

# Commit Git antes de mudanças
git add .
git commit -m "Checkpoint antes de [mudança]"
```

---

## ✅ Checklist de Encerramento

### No Final da Sessão

- [ ] **Testar mudanças**
  - Teste unitário (ação isolada)
  - Teste integração (flow completo)

- [ ] **Documentar**
  - Atualizar ITERACAO-[N].md com resultados
  - Atualizar ESTADO-ATUAL.md se completou iteração
  - Registar test run IDs e outcomes

- [ ] **Exportar flows alterados**
  ```powershell
  .\scripts\Export-ProductionFlows.ps1
  ```

- [ ] **Commit Git**
  ```powershell
  git add .
  git commit -m "Iteração N: [Descrição curta]"
  git push origin [branch]
  ```

- [ ] **Atualizar README** (se necessário)
  - Estado atual
  - Quick start commands

- [ ] **Registar próximos passos**
  - Em ESTADO-ATUAL.md
  - Issues conhecidos
  - To-do para próxima sessão

---

## 🆘 Se Algo Correu Mal

### Restaurar Estado Anterior

```powershell
# Ver commits recentes
git log --oneline -5

# Restaurar ficheiro específico
git checkout HEAD~1 -- [ficheiro]

# Ou restaurar tudo
git reset --hard HEAD~1
```

### Re-importar Flow de Backup

```powershell
# Copiar backup para working
Copy-Item "flow-definitions-production/FLX_[Flow].json" -Destination "flow-definitions/FLX_[Flow].json"

# Importar
.\scripts\Import-FlowDefinitionToProduction.ps1 -FlowName "FLX_[Flow]"
```

### Pedir Ajuda

1. Verificar: [troubleshooting.md](troubleshooting.md)
2. Procurar em docs/ por palavra-chave
3. Ver logs de erro completos
4. Documentar erro para futura referência

---

## 📊 Template de Sessão (Copiar e usar)

```markdown
# Sessão [Data]

## 🎯 Objetivo
[Descrever objetivo principal]

## 📋 Checklist Início
- [ ] Autenticação Power Automate
- [ ] Carregar módulos PowerShell
- [ ] Ler ESTADO-ATUAL.md
- [ ] Git pull

## 🔧 Tarefas
1. [ ] Tarefa 1
2. [ ] Tarefa 2
3. [ ] Tarefa 3

## ✅ Testes
- [ ] Teste 1: [descrição]
- [ ] Teste 2: [descrição]

## 📝 Notas
[Decisões, problemas encontrados, soluções]

## 📚 Documentação Atualizada
- [ ] ITERACAO-N.md
- [ ] ESTADO-ATUAL.md
- [ ] README.md

## 🔚 Checklist Encerramento
- [ ] Testes passaram
- [ ] Documentação atualizada
- [ ] Flows exportados
- [ ] Git commit
- [ ] Próximos passos registados
```

---

**Próximo:** Começar desenvolvimento! Ver [iteracoes-desenvolvimento.md](iteracoes-desenvolvimento.md)
