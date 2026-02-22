# Guia de Migração: Projeto Existente → Template

## 🎯 Objetivo
Este guia ajuda a migrar um projeto Forms→SharePoint→PowerAutomate **já existente** para usar a estrutura e ferramentas deste template.

---

## 🤔 Quando Usar Este Guia

✅ **USE se:**
- Já tem Forms + SharePoint List + Power Automate Flows funcionais
- Quer organizar e documentar melhor o projeto
- Quer usar os scripts de gestão incluídos no template
- Precisa de troubleshooting e metodologia estruturada
- Quer facilitar onboarding de novos developers

❌ **NÃO USE se:**
- Está a começar um projeto novo (use `README-DO-TEMPLATE.md`)
- Projeto não usa Forms/SharePoint/Power Automate
- Projeto usa tecnologias incompatíveis

---

## 📋 Pré-Requisitos

### Informações Necessárias
- [ ] Form ID (url do Microsoft Form)
- [ ] SharePoint Site URL
- [ ] SharePoint List ID ou nome
- [ ] Power Automate Environment Name
- [ ] Azure AD Tenant ID
- [ ] App Registration (se existir) ou criar novo

### Acesso Necessário
- [ ] Admin do Microsoft Form
- [ ] Owner/Edit da SharePoint List
- [ ] Permissões para editar Power Automate Flows
- [ ] Admin Azure AD (para criar App Registration se necessário)

---

## 🔄 Processo de Migração

### FASE 1: Preparação (30 min)

#### 1.1 Backup do Projeto Existente
```powershell
# 1. Exportar flows existentes (se possível)
Add-PowerAppsAccount
$flows = Get-Flow -EnvironmentName "Default-<seu-tenant-id>"
$flows | Export-Flow -Destination "C:\Backup\flows"

# 2. Documentar configuração atual
# - URLs SharePoint
# - Nomes de listas
# - IDs de Forms
# - Nomes de Flows
# - ConnectionReferences
```

#### 1.2 Criar Estrutura do Projeto
```powershell
# Copiar template para pasta do projeto existente
$projectPath = "C:\Projects\MeuProjetoExistente"
$templatePath = "C:\...\TEMPLATE_Forms_SharePoint_PowerAutomate"

# Criar subpasta "infrastructure" no projeto
New-Item -Path "$projectPath\infrastructure" -ItemType Directory -Force

# Copiar estrutura do template
Copy-Item -Path "$templatePath\config" -Destination "$projectPath\infrastructure\config" -Recurse
Copy-Item -Path "$templatePath\scripts" -Destination "$projectPath\infrastructure\scripts" -Recurse
Copy-Item -Path "$templatePath\docs" -Destination "$projectPath\infrastructure\docs" -Recurse
Copy-Item -Path "$templatePath\.gitignore" -Destination "$projectPath\" -Force
Copy-Item -Path "$templatePath\.vscode" -Destination "$projectPath\" -Recurse -Force
```

**📁 Estrutura Resultante:**
```
MeuProjetoExistente/
├── [seus ficheiros existentes]
├── infrastructure/         ← NOVO
│   ├── config/
│   ├── scripts/
│   └── docs/
├── .gitignore             ← ATUALIZADO
└── .vscode/               ← NOVO
```

---

### FASE 2: Configuração (1 hora)

#### 2.1 Azure AD App Registration

**Opção A:** Já tem App Registration
```powershell
# Apenas anote as credenciais:
# - Client ID
# - Tenant ID
# - Client Secret

# Verifique permissões necessárias:
# - Sites.ReadWrite.All
# - User.Read.All
# - Sites.FullControl.All (se usar operações avançadas)
```

**Opção B:** Criar novo App Registration
1. Abrir [Azure Portal](https://portal.azure.com)
2. Azure Active Directory → App registrations → New registration
3. Nome: `[SeuProjeto]-Automation`
4. Supported account types: `Single tenant`
5. Redirect URI: (deixar vazio)
6. **Register**
7. Anotar **Application (client) ID** e **Directory (tenant) ID**
8. Certificates & secrets → New client secret
9. Anotar o **Value** (só aparece agora!)
10. API permissions → Add permission → Microsoft Graph:
    - `Sites.ReadWrite.All`
    - `User.Read.All`
11. Grant admin consent

#### 2.2 Configurar Settings
```powershell
cd "$projectPath\infrastructure"

# Copiar template
Copy-Item "config\settings.json.template" "config\settings.json"

# Editar config\settings.json com seus valores:
# - tenantId
# - clientId
# - siteUrl
# - listId
# - formId
# - environmentName
# - solutionName (se usar Power Platform Solutions)
```

#### 2.3 Guardar Client Secret
```powershell
cd "$projectPath\infrastructure"
.\scripts\Save-ClientSecret.ps1
# Colar o Client Secret quando pedido
# Será guardado encriptado em config\client-secret.encrypted
```

#### 2.4 Testar Conectividade
```powershell
# Testar SharePoint/Graph API
.\scripts\Test-SharePointConnection.ps1

# Testar Power Automate
.\scripts\Test-PowerAutomateConnection.ps1
```

✅ **Checkpoint:** Todos os testes devem passar antes de continuar.

---

### FASE 3: Documentação (2-3 horas)

#### 3.1 Criar README do Projeto
```powershell
# Copiar template
Copy-Item "infrastructure\docs\..\README-TEMPLATE.md" "README.md"

# Editar README.md:
# - Nome do projeto
# - Descrição
# - Contexto de negócio
# - Links relevantes
```

#### 3.2 Documentar Estado Atual
```powershell
# Copiar template de estado
Copy-Item "infrastructure\docs\ESTADO-ATUAL.md" "ESTADO-ATUAL.md"

# Preencher com informações do projeto:
# - O que já está implementado
# - O que funciona
# - Problemas conhecidos
# - Próximos passos
```

#### 3.3 Documentar Flows Existentes

**Para cada flow:**
1. Abrir flow no Power Automate
2. Exportar definição JSON:
   ```powershell
   cd "$projectPath\infrastructure"
   .\scripts\Export-ProductionFlows.ps1
   ```
3. Guardar em `infrastructure\flow-definitions\[NomeDoFlow].json`
4. Documentar em `FLOWS.md`:
   - Nome
   - Trigger
   - Ações principais
   - Dependências (listas, connections)
   - Inputs/Outputs

#### 3.4 Mapear Forms ↔ SharePoint

Criar `MAPEAMENTO-CAMPOS.md`:
```markdown
# Mapeamento Forms → SharePoint

| Pergunta Form | Question ID | Campo SharePoint | Tipo | Notas |
|---------------|-------------|------------------|------|-------|
| Nome Completo | r123abc...  | Title            | Text | Campo padrão |
| Email         | r456def...  | Email            | Text | ... |
```

**Como obter Question IDs:**
1. Ver `infrastructure\docs\extract-forms-questions.js` (se disponível)
2. Ou usar Network tab do browser ao preencher o Form
3. Documentar em `MAPEAMENTO-CAMPOS.md`

---

### FASE 4: Integração com Scripts (1 hora)

#### 4.1 Testar Export de Flows
```powershell
cd "$projectPath\infrastructure"

# Exportar flows atuais
.\scripts\Export-ProductionFlows.ps1

# Verificar ficheiros criados em flow-definitions-production\
```

#### 4.2 Testar Update de Flow (Opcional)
```powershell
# CUIDADO: Isto atualiza flow em produção!
# Apenas testar se tiver backup

# Fazer pequena mudança num flow de teste
# Exportar JSON
# Tentar importar de volta:
.\scripts\Import-FlowDefinitionToProduction.ps1 -FlowId "..." -DefinitionPath "..."
```

#### 4.3 Adicionar Scripts Custom

Se tem scripts PowerShell existentes:
```powershell
# Mover para infrastructure\scripts\
Move-Item ".\MeuScript.ps1" "infrastructure\scripts\custom\"

# Atualizar infrastructure\scripts\README.md com:
# - Nome do script
# - Descrição
# - Uso
# - Exemplo
```

---

### FASE 5: Git Setup (30 min)

#### 5.1 Verificar .gitignore
```powershell
# .gitignore já copiado na FASE 1
# Verificar que inclui:
# - config/settings.json
# - config/*.encrypted
# - *.log
# - flow-runs/
```

#### 5.2 Commit Inicial (se novo repo)
```powershell
cd $projectPath
git init
git add .
git commit -m "feat: migração para estrutura do template"
git branch -M main
git remote add origin [seu-repo-url]
git push -u origin main
```

#### 5.3 Commit Documentação (se repo existente)
```powershell
git add infrastructure/ .gitignore .vscode/ README.md ESTADO-ATUAL.md
git commit -m "docs: adicionar estrutura de documentação e scripts"
git push
```

---

## 📊 Checklist de Validação Pós-Migração

### ✅ Estrutura
- [ ] Pasta `infrastructure/` criada com config, scripts, docs
- [ ] `.gitignore` configurado
- [ ] `.vscode/settings.json` criado
- [ ] `README.md` personalizado criado

### ✅ Configuração
- [ ] `config/settings.json` preenchido com valores corretos
- [ ] `config/client-secret.encrypted` criado e funcional
- [ ] App Registration configurado com permissões
- [ ] Testes de conectividade passam (SharePoint + Power Automate)

### ✅ Documentação
- [ ] `ESTADO-ATUAL.md` documenta estado do projeto
- [ ] `FLOWS.md` lista todos os flows
- [ ] `MAPEAMENTO-CAMPOS.md` documenta Forms ↔ SharePoint
- [ ] Flows exportados para `flow-definitions-production/`

### ✅ Scripts
- [ ] Export de flows funciona
- [ ] Scripts custom (se existirem) movidos para `infrastructure/scripts/`
- [ ] `infrastructure/scripts/README.md` atualizado

### ✅ Git
- [ ] Secrets não commitados (verificar `.gitignore`)
- [ ] Commit inicial ou documentação commitada
- [ ] Estrutura versionada

---

## 🎯 Próximos Passos

Após migração completa:

1. **Usar Checklist de Sessões**
   - `infrastructure\docs\START-NEXT-SESSION.md`
   - Usar em cada sessão de trabalho

2. **Seguir Metodologia Iterativa**
   - `infrastructure\docs\iteracoes-desenvolvimento.md`
   - Planear próximas features em iterações

3. **Consultar Troubleshooting**
   - `infrastructure\docs\troubleshooting.md`
   - Quando surgir problemas

4. **Atualizar Documentação**
   - `ESTADO-ATUAL.md` regularmente
   - Adicionar novos problemas/soluções ao troubleshooting

---

## 🚨 Problemas Comuns

### "Testes de conectividade falham"
**Causa:** Permissões ou credenciais incorretas  
**Solução:**
1. Verificar `config/settings.json` (Client ID, Tenant ID corretos?)
2. Re-guardar Client Secret: `.\scripts\Save-ClientSecret.ps1`
3. Verificar permissões no Azure Portal (grant admin consent?)
4. Ver `infrastructure\docs\troubleshooting.md` → "Autenticação"

### "Scripts não encontram módulos"
**Causa:** Path relativo incorreto  
**Solução:**
```powershell
# Sempre executar scripts de dentro da pasta infrastructure
cd "$projectPath\infrastructure"
.\scripts\[NomeDoScript].ps1
```

### "Flows não exportam"
**Causa:** Autenticação delegada não configurada  
**Solução:**
```powershell
# Autenticar interactivamente
Add-PowerAppsAccount
# Depois executar export
.\scripts\Export-ProductionFlows.ps1
```

### "Git está a commitar secrets"
**Causa:** `.gitignore` não aplicado a ficheiros já tracked  
**Solução:**
```powershell
# Remover do tracking
git rm --cached config/settings.json
git rm --cached config/*.encrypted
git commit -m "fix: remover secrets do tracking"

# Verificar .gitignore inclui estes ficheiros
```

---

## 📚 Recursos Adicionais

### Dentro do Template
- [README-DO-TEMPLATE.md](README-DO-TEMPLATE.md) - Criar projeto novo
- [docs/SETUP-INICIAL.md](docs/SETUP-INICIAL.md) - Setup detalhado
- [docs/troubleshooting.md](docs/troubleshooting.md) - Resolução de problemas
- [CHECKLIST-VALIDACAO.md](CHECKLIST-VALIDACAO.md) - Validação completa

### Microsoft Docs
- [Power Automate Management Connector](https://learn.microsoft.com/connectors/flowmanagement/)
- [Microsoft Graph SharePoint API](https://learn.microsoft.com/graph/api/resources/sharepoint)
- [Azure AD App Registration](https://learn.microsoft.com/azure/active-directory/develop/quickstart-register-app)

---

## ✅ Status Final

Depois de seguir este guia:
- ✅ Projeto existente organizado com estrutura do template
- ✅ Documentação estruturada e versionada
- ✅ Scripts de gestão funcionais
- ✅ Troubleshooting e metodologia disponíveis
- ✅ Onboarding facilitado para novos developers
- ✅ Preparado para crescimento e manutenção

**Tempo Total Estimado:** 4-5 horas

---

**Última atualização:** 21 de Fevereiro de 2026  
**Versão Template:** 1.0
