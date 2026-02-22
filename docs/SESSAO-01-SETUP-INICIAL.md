# 🚀 Sessão #1 - Setup Inicial
## Projeto: Inquérito Satisfação Cliente

**Data:** 22/02/2026  
**Responsável:** pduarte  
**Tempo estimado:** 2-3 horas  
**Objetivo:** Configurar todos os componentes base do projeto

---

## 📋 Progresso da Sessão

**Status:** � 85% Completo

- [x] Template estruturado
- [x] `settings.json` criado e configurado
- [x] Documentação preparada
- [x] Azure AD configurado (credenciais copiadas)
- [x] Client Secret copiado e validado
- [x] SharePoint List criada
- [x] 15 campos personalizados adicionados
- [x] Forms mapeado (já existente)
- [x] Testes de conectividade SharePoint validados
- [ ] Power Platform Solution criada
- [ ] Testes de conectividade Power Automate

---

## 📝 Checklist Detalhado

### ✅ Fase 0: Preparação (COMPLETO)
- [x] Projeto estruturado com template
- [x] Ficheiro `config/settings.json` criado
- [x] Documentação copiada e adaptada
- [x] Git configurado (se aplicável)

---

### 🔐 Fase 1: Azure AD - App Registration (30 min)

#### 1.1 Criar App Registration

**Portal:** https://portal.azure.com

**Navegação:**
```
Azure Active Directory → App registrations → + New registration
```

**Configuração:**
```yaml
Name: InqueritoSatisfacao-Automation
Supported account types: Accounts in this organizational directory only (Single tenant)
Redirect URI: (deixar vazio por agora)
```

**Ação:** Clicar em **Register**

✅ **Checkpoint:** Aplicação criada. Vai ver a página Overview.

---

#### 1.2 Anotar IDs Principais

Na página **Overview**, copiar os seguintes valores:

```yaml
Application (client) ID: [GUID]
Directory (tenant) ID:   [GUID]
```

**Ação:** Guardar temporariamente num bloco de notas. Vamos usar já a seguir.

✅ **Checkpoint:** Dois GUIDs copiados.

---

#### 1.3 Configurar Permissões API

**Navegação:**
```
API permissions → + Add a permission
```

**Microsoft Graph:**
```
Application permissions:
  ✓ Sites.ReadWrite.All
  ✓ User.Read.All
  ✓ Mail.Send (opcional - para notificações)
```

**SharePoint:**
```
Application permissions:
  ✓ Sites.FullControl.All
```

**⚠️ IMPORTANTE:** Após adicionar todas as permissões, clicar em:
```
✅ Grant admin consent for [Your Organization]
```

Confirmar quando pedido.

✅ **Checkpoint:** Status de todas as permissões deve mostrar "✓ Granted for [Org]" (verde).

---

#### 1.4 Criar Client Secret

**Navegação:**
```
Certificates & secrets → Client secrets → + New client secret
```

**Configuração:**
```yaml
Description: InqueritoSatisfacao-Secret-2026
Expires: 24 months (recomendado)
```

**Ação:** Clicar em **Add**

**⚠️ CRÍTICO:** 
- Copiar o **Value** (não o "Secret ID") IMEDIATAMENTE
- Só aparece uma vez!
- Não fechar a página até guardar

✅ **Checkpoint:** Client Secret copiado para clipboard.

---

#### 1.5 Guardar Client Secret de Forma Segura

**No PowerShell (executar na raiz do projeto):**

```powershell
# Navegar para o projeto
cd "c:\Users\pduarte\OneDrive - ProdOut\PRJ\PRJ_Inquerito_Satisfação_Cliente"

# Executar script de guardar secret
.\scripts\Save-ClientSecret.ps1
```

**O script vai pedir:**
1. Colar o Client Secret
2. Confirmar

O secret será guardado encriptado em: `config/client-secret.encrypted`

✅ **Checkpoint:** Ficheiro `client-secret.encrypted` criado. Agora pode fechar a página do Azure Portal.

---

#### 1.6 Atualizar settings.json

**Editar:** `config/settings.json`

**Atualizar os campos:**
```json
{
  "azure": {
    "tenantId": "[COLAR: Directory (tenant) ID]",
    "clientId": "[COLAR: Application (client) ID]",
    "clientSecretFile": "config/client-secret.encrypted"
  }
}
```

**Guardar o ficheiro.**

✅ **Checkpoint:** `settings.json` atualizado com IDs do Azure AD.

---

### 📊 Fase 2: SharePoint List (30 min)

#### 2.1 Aceder ao SharePoint Site

**Opção A - Criar Novo Site:**
```
https://[tenant]-admin.sharepoint.com/
→ Active sites → + Create → Team site
Nome: Inquéritos e Formulários
```

**Opção B - Usar Site Existente:**
```
https://[tenant].sharepoint.com/sites/[site-existente]
```

✅ **Checkpoint:** Site identificado. Copiar URL completo.

---

#### 2.2 Criar SharePoint List

**No site escolhido:**
```
Settings (⚙️) → Site contents → + New → List
```

**Configuração:**
```yaml
Name: Respostas Inquéritos
Description: Respostas dos inquéritos de satisfação de clientes
Template: Blank list
```

**Ação:** Clicar em **Create**

✅ **Checkpoint:** Lista criada e vazia.

---

#### 2.3 Obter List ID

**Método:**
1. Na lista, clicar em **⚙️ Settings** → **List settings**
2. Copiar o URL da página
3. Procurar o parâmetro `List={GUID}`

**Exemplo de URL:**
```
https://tenant.sharepoint.com/sites/SITE/_layouts/15/listedit.aspx?List=%7B12345678-ABCD-...%7D
```

**O GUID está entre `%7B` e `%7D` (URL encoded).**

Alternativamente, pode usar PowerShell:
```powershell
# Ver script Test-SharePointConnection.ps1 para obter List ID
```

✅ **Checkpoint:** List ID (GUID) copiado.

---

#### 2.4 Configurar Campos da Lista

**Campos base (o Power Automate pode criar automaticamente):**

Por agora, deixar apenas os campos padrão. Na próxima iteração vamos adicionar:
- Cliente (Text)
- Email (Text)  
- Classificação (Choice: 1-5)
- Comentários (Multiple lines)
- Data Submissão (Date)

✅ **Checkpoint:** Lista pronta para receber dados.

---

#### 2.5 Atualizar settings.json

**Editar:** `config/settings.json`

**Atualizar os campos:**
```json
{
  "sharepoint": {
    "siteUrl": "[COLAR: URL completo do site]",
    "siteName": "Inquéritos e Formulários",
    "listName": "Respostas Inquéritos",
    "listId": "[COLAR: GUID da lista]"
  }
}
```

**Guardar o ficheiro.**

✅ **Checkpoint:** `settings.json` atualizado com URLs e IDs do SharePoint.

---

### 📝 Fase 3: Microsoft Forms (20 min)

#### 3.1 Criar Formulário

**Portal:** https://forms.office.com

**Ação:**
```
+ New Form
```

**Nome:** `Inquérito de Satisfação do Cliente`

✅ **Checkpoint:** Formulário vazio criado.

---

#### 3.2 Adicionar Questões Base

**Questão 1:**
```yaml
Type: Text
Question: "Qual é o seu nome?"
Required: Yes
```

**Questão 2:**
```yaml
Type: Text  
Question: "Qual é o seu email?"
Required: Yes
```

**Questão 3:**
```yaml
Type: Choice (Rating)
Question: "Como classifica a sua experiência geral?"
Options: 1 - Muito Insatisfeito, 2, 3, 4, 5 - Muito Satisfeito
Required: Yes
```

**Questão 4:**
```yaml
Type: Long answer
Question: "Comentários ou sugestões adicionais"
Required: No
```

✅ **Checkpoint:** Formulário com 4 questões configuradas.

---

#### 3.3 Obter Form ID

**No Forms:**
1. Clicar em **Share**
2. Copiar o link gerado

**Exemplo de URL:**
```
https://forms.office.com/Pages/ResponsePage.aspx?id=XXXXXXXXXXXXXXXXXXXXXXXXXXX
```

**O Form ID é tudo depois de `?id=`**

Alternativamente:
1. Clicar em **Responses** tab
2. Copiar o URL
3. Procurar o parâmetro `id=`

✅ **Checkpoint:** Form ID copiado.

---

#### 3.4 Atualizar settings.json

**Editar:** `config/settings.json`

**Atualizar os campos:**
```json
{
  "forms": {
    "formId": "[COLAR: Form ID]",
    "formUrl": "https://forms.office.com/Pages/ResponsePage.aspx?id=[COLAR: Form ID]",
    "formName": "Inquérito de Satisfação do Cliente"
  }
}
```

**Guardar o ficheiro.**

✅ **Checkpoint:** `settings.json` atualizado com Form ID.

---

### ⚡ Fase 4: Power Platform (20 min)

#### 4.1 Identificar Environment

**No PowerShell:**

```powershell
# Autenticar (abre browser)
Add-PowerAppsAccount

# Listar environments
Get-PowerAppEnvironment | Select-Object DisplayName, EnvironmentName

# Copiar o EnvironmentName (geralmente Default-[TenantId])
```

✅ **Checkpoint:** Environment Name copiado.

---

#### 4.2 Atualizar settings.json

**Editar:** `config/settings.json`

**Atualizar o campo:**
```json
{
  "powerPlatform": {
    "environmentName": "[COLAR: Default-GUID ou outro]"
  }
}
```

**Guardar o ficheiro.**

✅ **Checkpoint:** `settings.json` completamente configurado!

---

### 🧪 Fase 5: Testes de Conectividade (15 min)

#### 5.1 Testar SharePoint / Graph API

**No PowerShell:**

```powershell
# Executar teste
.\scripts\Test-SharePointConnection.ps1
```

**Resultado esperado:**
```
✓ Token obtido com sucesso
✓ Site acessível  
✓ Lista encontrada
✓ Permissões validadas
```

✅ **Checkpoint:** SharePoint conectado e acessível.

---

#### 5.2 Testar Power Automate

**No PowerShell:**

```powershell
# Executar teste
.\scripts\Test-PowerAutomateConnection.ps1
```

**Resultado esperado:**
```
✓ Autenticação bem-sucedida
✓ Environment acessível
✓ Flows listados (pode estar vazio)
```

✅ **Checkpoint:** Power Automate conectado.

---

## 🎉 Setup Completo!

### ✅ Checklist Final

- [x] Azure AD App Registration criado
- [x] Permissões API configuradas
- [x] Client Secret guardado
- [x] SharePoint List criado
- [x] Microsoft Forms criado
- [x] Power Platform configurado
- [x] `settings.json` completo
- [x] Testes de conectividade ✅

---

## 📝 Resumo - Dados Configurados

**Para validar, verificar que `config/settings.json` tem todos estes campos preenchidos:**

```json
{
  "azure": {
    "tenantId": "[✓ GUID]",
    "clientId": "[✓ GUID]"
  },
  "sharepoint": {
    "siteUrl": "[✓ URL]",
    "listId": "[✓ GUID]"
  },
  "forms": {
    "formId": "[✓ ID]"
  },
  "powerPlatform": {
    "environmentName": "[✓ Default-GUID]"
  }
}
```

**E que existe:**
- `config/client-secret.encrypted` ✓

---

## 🚀 Próximos Passos

**Iteração 1 - Criar Flow Principal:**
1. Criar flow no Power Automate
2. Trigger: "When a new response is submitted" (Forms)
3. Action: "Create item" (SharePoint)
4. Mapear campos Forms → SharePoint
5. Testar end-to-end

**Ver:** [docs/ESTADO-ATUAL.md](ESTADO-ATUAL.md) para roadmap completo.

---

## 📚 Documentação Relacionada

- [SETUP-INICIAL.md](SETUP-INICIAL.md) - Guia detalhado de setup
- [AUTH-METHODS.md](AUTH-METHODS.md) - Métodos de autenticação
- [START-NEXT-SESSION.md](START-NEXT-SESSION.md) - Checklist para próximas sessões
- [ESTADO-ATUAL.md](ESTADO-ATUAL.md) - Estado atual do projeto

---

**Sessão encerrada:** [A preencher quando terminar]  
**Duração:** [A preencher]  
**Status final:** [A preencher: ✅ Completo / ⚠ Parcial / ❌ Bloqueado]
