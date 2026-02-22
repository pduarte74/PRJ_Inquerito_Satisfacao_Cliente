# ⚡ QUICKSTART - 30 Minutos para Começar

**Objetivo:** Setup mínimo funcional em 30 minutos para testar o template.

---

## ✅ Pré-Requisitos

- [ ] Acesso Admin a Microsoft 365 tenant
- [ ] Acesso ao Azure Portal
- [ ] PowerShell 5.1+ instalado
- [ ] Windows 10/11 (para DPAPI)

---

## 🚀 5 Passos Rápidos

### 1️⃣ Copiar Template (2 min)

```powershell
# Copiar para novo projeto
$dest = "C:\Projects\MeuProjTeste"
Copy-Item -Path "TEMPLATE_Forms_SharePoint_PowerAutomate" -Destination $dest -Recurse
cd $dest

# Limpar ficheiros template
Remove-Item "README-DO-TEMPLATE.md"
Rename-Item "README-TEMPLATE.md" "README.md"
```

### 2️⃣ Azure AD App Registration (10 min)

1. **Portal:** https://portal.azure.com
2. **Azure Active Directory** → **App registrations** → **New registration**
   - Name: `MeuProjTeste-Automation`
   - Supported types: **Single tenant**
   - Click **Register**
3. **Anotar:** Application (client) ID + Directory (tenant) ID
4. **Certificates & secrets** → **New client secret**
   - Description: `dev-secret`
   - Expires: 6 months
   - **Anotar o Value** (só aparece 1 vez!)
5. **API permissions** → **Add permission** → **Microsoft Graph**:
   - `Sites.ReadWrite.All` (Application)
   - `User.Read.All` (Application)
6. **Grant admin consent** ✅

### 3️⃣ Configurar Projeto (5 min)

```powershell
# Copiar template de configuração
Copy-Item "config\settings.json.template" "config\settings.json"

# Editar config\settings.json (usar Notepad ou VS Code)
code config\settings.json
```

**Preencher:**
```json
{
  "tenantId": "seu-tenant-id",
  "clientId": "seu-app-client-id",
  "siteUrl": "https://SEUTENANT.sharepoint.com/sites/SEUSITE",
  "listId": "00000000-0000-0000-0000-000000000000",
  "formId": "",
  "environmentName": "Default-seu-tenant-id",
  "solutionName": "MeuProjTeste"
}
```

**Guardar Client Secret:**
```powershell
.\scripts\Save-ClientSecret.ps1
# Colar Client Secret quando pedido
```

### 4️⃣ Criar SharePoint List (5 min)

1. Abrir SharePoint Site (do settings.json)
2. **Site contents** → **New** → **List**
   - Name: `Testes`
   - Template: Blank list
3. **Settings** → **List settings** → copiar ID do URL:
   ```
   https://...sharepoint.com/sites/SITE/_layouts/15/listedit.aspx?List={SEU-LIST-ID}
   ```
4. Colar `SEU-LIST-ID` em `config\settings.json` → `listId`

### 5️⃣ Testar Conectividade (3 min)

```powershell
# Testar SharePoint/Graph API
.\scripts\Test-SharePointConnection.ps1

# Testar Power Automate
.\scripts\Test-PowerAutomateConnection.ps1
```

✅ **Se ambos passarem:** Setup completo!

---

## 🎯 Próximos Passos

### Opção A: Criar Primeiro Flow (1-2h)
📖 Seguir **[docs/iteracoes-desenvolvimento.md](docs/iteracoes-desenvolvimento.md)** → Iteração 1

### Opção B: Ler Documentação Completa (30-60 min)
📖 Começar em **[00-LEIA-ME-PRIMEIRO.md](00-LEIA-ME-PRIMEIRO.md)**

### Opção C: Migrar Projeto Existente (4-5h)
📖 Seguir **[MIGRACAO-PROJETO-EXISTENTE.md](MIGRACAO-PROJETO-EXISTENTE.md)**

---

## 🚨 Troubleshooting Rápido

### Erro: "Access Denied" no Test-SharePointConnection
**Causa:** Permissões não concedidas  
**Solução:**
1. Azure Portal → App Registration → API Permissions
2. Verificar permissões adicionadas
3. Click "Grant admin consent"
4. Esperar 2-3 minutos e tentar novamente

### Erro: "Client Secret inválido"
**Causa:** Secret copiado incorretamente  
**Solução:**
```powershell
.\scripts\Save-ClientSecret.ps1
# Copiar secret COMPLETO (incluir inicio e fim)
```

### Erro: "List not found"
**Causa:** List ID incorreto  
**Solução:**
1. Abrir SharePoint List
2. Settings → List settings → URL tem `?List={ID}`
3. Copiar ID (incluir hífens)
4. Atualizar `config\settings.json`

### Erro: "Cannot find module"
**Causa:** Path relativo incorreto  
**Solução:**
```powershell
# Sempre executar de dentro do projeto
cd C:\Projects\MeuProjTeste
.\scripts\[script].ps1
```

---

## 📚 Documentação Completa

Se algo não funcionar, consultar:
- **[docs/troubleshooting.md](docs/troubleshooting.md)** - 10+ problemas comuns
- **[docs/SETUP-INICIAL.md](docs/SETUP-INICIAL.md)** - Setup detalhado
- **[docs/AUTH-METHODS.md](docs/AUTH-METHODS.md)** - Autenticação explicada

---

## ✅ Checklist Validação Rápida

- [ ] Azure AD App Registration criado
- [ ] Client Secret guardado e encriptado
- [ ] `config/settings.json` preenchido
- [ ] SharePoint List criado
- [ ] Test-SharePointConnection.ps1 ✅
- [ ] Test-PowerAutomateConnection.ps1 ✅
- [ ] Git inicializado (opcional)

**Se tudo ✅:** Pronto para desenvolvimento! 🎉

---

## 🎓 Aprender Mais

### Metodologia Iterativa (Recomendada)
**[docs/iteracoes-desenvolvimento.md](docs/iteracoes-desenvolvimento.md)**

Desenvolvimento em 5 iterações:
1. **Iteração 1:** Forms → SharePoint (1-2h) ⭐ Começar aqui
2. **Iteração 2:** Notificações Teams/Email (1h)
3. **Iteração 3:** Automation avançada (2-3h)
4. **Iteração 4:** Geração de documentos (3-4h)
5. **Iteração 5:** Personalização e refinamento (2-3h)

### Workflow Diário
**[docs/START-NEXT-SESSION.md](docs/START-NEXT-SESSION.md)**

Checklist para cada sessão:
- ✅ Review estado atual
- ✅ Planeamento tasks
- ✅ Desenvolvimento incremental
- ✅ Testar mudanças
- ✅ Documentar progresso
- ✅ Commit Git

---

## 💡 Dicas Rápidas

### Segurança
- ✅ NUNCA commitar `config/settings.json`
- ✅ NUNCA commitar `config/*.encrypted`
- ✅ `.gitignore` já configurado ← verificar antes do primeiro commit

### Scripts
- ✅ Sempre executar de dentro da pasta do projeto
- ✅ Usar paths relativos (`.\scripts\...`)
- ✅ Ler comentários no início de cada script

### Desenvolvimento
- ✅ Começar pequeno (Iteração 1)
- ✅ Testar frequentemente
- ✅ Documentar à medida que avança
- ✅ Commit incremental (não esperar pelo fim)

### Power Automate
- ✅ Usar autenticação delegada (não App Reg)
- ✅ Exportar flows antes de editar
- ✅ Testar em Dev antes de Prod
- ✅ PAC CLI não funciona para flows ← usar Export-ProductionFlows.ps1

---

## 🎯 Objetivo 30 Minutos

Ao fim de 30 minutos deve ter:
- ✅ Projeto copiado e personalizado
- ✅ Azure AD App Registration criado
- ✅ SharePoint List criado
- ✅ Testes de conectividade a passar
- ✅ Pronto para criar primeiro flow

**Tempo real:** Pode levar 40-45 minutos se for primeira vez. Normal!

---

## 🚀 Começar Agora!

```powershell
# Copy → Configure → Test → Develop
$dest = "C:\Projects\MeuProjTeste"
Copy-Item -Path "TEMPLATE_Forms_SharePoint_PowerAutomate" -Destination $dest -Recurse
cd $dest
code .
```

**Boa sorte! 🎉**

---

**Nota:** Este é um setup MÍNIMO para testar rapidamente. Para setup completo de produção, seguir **[docs/SETUP-INICIAL.md](docs/SETUP-INICIAL.md)** (2-3h).

---

**Última atualização:** 21 de Fevereiro de 2026  
**Versão Template:** 1.0
