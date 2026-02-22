# 🚀 Guia de Implementação - Fluxos Power Automate

**Projeto:** Inquérito Satisfação Cliente  
**Sessão #2:** Desenvolvimento dos Fluxos  
**Data:** 22/02/2026  

---

## 📦 O que foi criado

✅ **3 Definições JSON completas** prontas para usar:
1. `Inquerito-Satisfacao-Captura-Respostas.json` (Fluxo 2)
2. `Inquerito-Satisfacao-Envio-Inicial.json` (Fluxo 1)
3. `Inquerito-Satisfacao-Gestao-Reminders.json` (Fluxo 3)

📁 **Localização:** `scripts/flow-definitions/`

---

## 🎯 Opções de Implementação

### OPÇÃO A: Criação Manual (Recomendada)
✅ Maior controlo  
✅ Validação passo-a-passo  
✅ Melhor para primeira implementação  

### OPÇÃO B: Import via JSON
⚡ Mais rápido  
⚠️ Requer ajustes de conexões  
🔧 Usar scripts PowerShell  

---

## 📋 OPÇÃO A: Implementação Manual

### Pré-requisitos
- [x] Acesso ao Power Automate: https://make.powerautomate.com
- [x] Permissões de criador no environment
- [x] Conexões configuradas:
  - Microsoft Forms
  - SharePoint
  - Office 365 Outlook

---

## 🔹 FLUXO 2: Captura de Respostas (COMEÇAR AQUI)

> **Razão:** É o fluxo mais crítico. Sem ele, as respostas não são capturadas.

### Passo 1: Criar Flow
1. Aceder a https://make.powerautomate.com
2. **My flows** → **+ New flow** → **Automated cloud flow**
3. Nome: `Inquerito-Satisfacao-Captura-Respostas`
4. Trigger: Pesquisar "Forms" → **When a new response is submitted**
5. Click **Create**

### Passo 2: Configurar Trigger
```
Connector: Microsoft Forms
Action: When a new response is submitted

Form Id: 
8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu
```

💡 **Dica:** Colar o Form ID diretamente. Se não aparecer na lista, usar "Enter custom value".

### Passo 3: Get response details
```
+ New step → Pesquisar "Forms" → Get response details

Form Id: (mesmo do trigger)
Response Id: (Dynamic content) → Response Id
```

### Passo 4: Get items (SharePoint)
```
+ New step → Pesquisar "SharePoint" → Get items

Site Address: 
https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade

List Name: 
Recolha de Repostas Inquerito de Satisfação de Clientes

Filter Query:
EmailContacto eq '@{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}'

Top Count: 1
```

⚠️ **CRÍTICO:** Usar aspas simples no filtro OData: `eq '@{...}'`

### Passo 5: Condition - Item encontrado?
```
+ New step → Control → Condition

Condition Expression:
length(outputs('Get_items')?['body/value']) | is greater than | 0
```

### Passo 6: Ramo YES → Update item

#### 6.1 Adicionar Update item
```
+ Add an action → SharePoint → Update item

Site Address: (mesmo)
List Name: (mesmo)
Id: @{first(outputs('Get_items')?['body/value'])?['ID']}
```

#### 6.2 Mapear TODOS os 17 campos

**COPY/PASTE - Campos de Identificação:**
```
Title: r4a23b53b26c94fceb200c0bb59ca92d9
EmailContacto: r7b2bd52ed2764c57803595d6c3ca2bb7
Funcao: rd1db5d1cfeb04e50a01a18b4e4dc2bca
Entidade: r093e6f2fc8744c43990e68b5eda96adc
```

**COPY/PASTE - Campos de Resposta:**
```
ConsentimentoRGPD: r8fe48e19d79549bf8cf1e1a1e2223d1c
CaracteristicasAssociadas: rc38c74906d884d51b8a93e3bbdd74aa9
AvaliacaoServicoIntegrado: ra86f09da48214fc19234c1ad8c2f3c49
AvaliacaoCertificacoes: re9e5802d0c844f069ee8bc4aaa5fb3c1
AvaliacaoExperiencia: r22e3f0fe5baa4e13beabcf6bfbdde8a1
AvaliacaoCompreensaoNecessidades: r18086fb5de1f4b8586a3ba862cd0f9df
AvaliacaoRapidezEficacia: r7b84c2aaac4143478cd929b5ca65e38e
AvaliacaoEntrega: r68afb7c83b6d43d293b9bb4bff20f063
AvaliacaoAcondicionamento: r9f37e98a33c44e638a0f1b9a62a20ff3
AvaliacaoImprevistos: r56fb5ac8d5fa48059f69f27a91f6e50b
SugestoesServicosProdutos: rf6a1ca933f214fcb874a92e02f61c9b5
SugestoesDesafios: rf5943b498a1241019699e87a12346f46
RecomendariaProdOut: rc39ade3652324f5696be166a8df5c2a3
```

**💡 Como mapear:**
1. Click no campo SharePoint (ex: "Title")
2. Click em "Dynamic content" (painel direito)
3. Na barra de pesquisa, procurar pelo Question ID (ex: `r4a23b53b26c94fceb200c0bb59ca92d9`)
4. Selecionar o campo correspondente

**Campos de Controlo (usar Expression):**
```
EstadoInquerito: "Respondido" (escolher da lista)
DataResposta: utcNow()
ResponseId: outputs('Get_response_details')?['body/responseId']
```

### Passo 7: Ramo YES → Send email (Agradecimento)
```
+ Add an action → Office 365 Outlook → Send an email (V2)

To: @{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}
Subject: Obrigado pela sua participação - ProdOut
Body: (ver template HTML abaixo)
```

**Template Email Agradecimento:**
```html
<html>
<body>
<p>Caro(a) <strong>@{outputs('Get_response_details')?['body/r4a23b53b26c94fceb200c0bb59ca92d9']}</strong>,</p>

<p>Muito obrigado por ter completado o nosso Inquérito de Satisfação!</p>

<p>A sua opinião é extremamente valiosa para nós e ajuda-nos a melhorar continuamente 
a qualidade dos nossos serviços.</p>

<p>Todas as sugestões e comentários serão cuidadosamente analisados pela nossa equipa 
no âmbito do Sistema de Gestão da Qualidade.</p>

<p>Continuamos ao seu dispor para qualquer questão ou esclarecimento adicional.</p>

<p>Com os melhores cumprimentos,<br>
<strong>Equipa ProdOut</strong></p>
</body>
</html>
```

### Passo 8: Ramo NO → Send email (Erro)
```
+ Add an action → Office 365 Outlook → Send an email (V2)

To: qualidade@prodout.pt
Subject: ERRO - Resposta Forms sem match no SharePoint
Body: (ver template HTML abaixo)
```

**Template Email Erro:**
```html
<p><strong>Erro ao processar resposta do Forms</strong></p>
<p><strong>Response ID:</strong> @{outputs('Get_response_details')?['body/responseId']}</p>
<p><strong>Email:</strong> @{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}</p>
<p><strong>Nome:</strong> @{outputs('Get_response_details')?['body/r4a23b53b26c94fceb200c0bb59ca92d9']}</p>
<p>Ação necessária: Verificar lista SharePoint e adicionar manualmente.</p>
```

### Passo 9: Guardar e Testar
1. Click em **Save** (topo)
2. Aceder ao Forms e submeter uma resposta de teste
3. Verificar se:
   - ✅ Flow executou com sucesso
   - ✅ Item no SharePoint foi atualizado
   - ✅ Email de agradecimento foi recebido

---

## 🔹 FLUXO 1: Envio de Inquéritos

> **Pré-requisito:** Fluxo 2 testado e funcional ✅

### Passo 1: Criar Flow
1. **My flows** → **+ New flow** → **Instant cloud flow**
2. Nome: `Inquerito-Satisfacao-Envio-Inicial`
3. Trigger: **Manually trigger a flow**
4. Click **Create**

### Passo 2: Get items (Pendentes)
```
+ New step → SharePoint → Get items

Site Address: 
https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade

List Name: 
Recolha de Repostas Inquerito de Satisfação de Clientes

Filter Query:
EstadoInquerito eq 'Pendente'
```

### Passo 3: Apply to each
```
+ New step → Control → Apply to each

Select output from previous step: value (do Get items)
```

#### 3.1 Compose - Link Pré-preenchido
```
+ Add an action → Data Operations → Compose

Nome: LinkFormulario

Inputs (Expression):
concat('https://forms.office.com/Pages/ResponsePage.aspx?id=8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu',
'&r4a23b53b26c94fceb200c0bb59ca92d9=', encodeUriComponent(items('Apply_to_each')?['Title']),
'&r7b2bd52ed2764c57803595d6c3ca2bb7=', encodeUriComponent(items('Apply_to_each')?['EmailContacto']),
'&rd1db5d1cfeb04e50a01a18b4e4dc2bca=', encodeUriComponent(items('Apply_to_each')?['Funcao']),
'&r093e6f2fc8744c43990e68b5eda96adc=', encodeUriComponent(items('Apply_to_each')?['Entidade']))
```

#### 3.2 Compose - Prazo
```
+ Add an action → Data Operations → Compose

Nome: PrazoResposta

Inputs (Expression):
addDays(utcNow(), 15)
```

#### 3.3 Send email
```
+ Add an action → Office 365 Outlook → Send an email (V2)

To: @{items('Apply_to_each')?['EmailContacto']}
Subject: Inquérito de Satisfação - ProdOut
Body: (ver template HTML abaixo)
```

**Template Email Envio:**
```html
<html>
<body>
<p>Caro(a) <strong>@{items('Apply_to_each')?['Title']}</strong>,</p>

<p>No âmbito do nosso Sistema de Gestão da Qualidade e compromisso com a melhoria contínua, 
solicitamos a sua colaboração no preenchimento de um breve inquérito de satisfação sobre 
os serviços prestados pela ProdOut.</p>

<p>A sua opinião é fundamental para aprimorarmos os nossos processos e garantirmos que continuamos 
a corresponder às suas expectativas.</p>

<p style="margin: 25px 0;">
<a href="@{outputs('Compose_LinkFormulario')}" 
   style="background-color: #0078d4; color: white; padding: 12px 24px; 
          text-decoration: none; border-radius: 4px; display: inline-block;">
   Preencher Inquérito
</a>
</p>

<p><strong>Prazo de resposta:</strong> até @{formatDateTime(outputs('Compose_PrazoResposta'), 'dd/MM/yyyy')}</p>

<p>O inquérito demora aproximadamente 5 minutos a preencher e as suas respostas são tratadas 
com total confidencialidade de acordo com o RGPD.</p>

<p>Agradecemos antecipadamente a sua colaboração.</p>

<p>Com os melhores cumprimentos,<br>
<strong>Equipa ProdOut</strong></p>
</body>
</html>
```

#### 3.4 Update item
```
+ Add an action → SharePoint → Update item

Site Address: (mesmo)
List Name: (mesmo)
Id: @{items('Apply_to_each')?['ID']}

Campos:
EstadoInquerito: "Email Enviado"
DataEnvioInicial: @{utcNow()}
PrazoResposta: @{outputs('Compose_PrazoResposta')}
LinkFormularioPrefill: @{outputs('Compose_LinkFormulario')}
NumeroReminders: 0
```

#### 3.5 Delay
```
+ Add an action → Schedule → Delay

Count: 2
Unit: Second
```

### Passo 4: Configurar Concurrency
```
Apply to each → Settings (⋯) → Settings
Concurrency Control: ON
Degree of Parallelism: 5
```

### Passo 5: Guardar e Testar
1. **Save**
2. **Test** → Manually
3. Verificar que emails foram enviados
4. Verificar estados atualizados no SharePoint

---

## 🔹 FLUXO 3: Gestão de Reminders

> **Pré-requisito:** Fluxos 1 e 2 operacionais ✅

### Passo 1: Criar Flow
1. **My flows** → **+ New flow** → **Scheduled cloud flow**
2. Nome: `Inquerito-Satisfacao-Gestao-Reminders`
3. Trigger: **Recurrence**
4. Configurar:
   - Interval: 1
   - Frequency: Day
   - Time zone: (GMT+00:00) GMT Standard Time
   - At these hours: 9
   - At these minutes: 0
5. Click **Create**

### Passo 2: Compose - Data Limite
```
+ New step → Data Operations → Compose

Nome: DataLimiteReminder

Inputs (Expression):
addDays(utcNow(), 3)
```

### Passo 3: Get items (Elegíveis para Reminder)
```
+ New step → SharePoint → Get items

Site Address: (mesmo)
List Name: (mesmo)

Filter Query:
(EstadoInquerito eq 'Email Enviado') and (PrazoResposta le '@{outputs('Compose_DataLimiteReminder')}') and (NumeroReminders lt 2)

Order By: PrazoResposta
```

### Passo 4: Condition - Tem reminders?
```
+ New step → Control → Condition

Expression:
length(outputs('Get_items')?['body/value']) | is greater than | 0
```

### Passo 5: Ramo YES → Apply to each

#### 5.1 Compose - Dias Restantes
```
+ Add an action → Data Operations → Compose

Nome: DiasRestantes

Inputs (Expression):
div(sub(ticks(items('Apply_to_each')?['PrazoResposta']), ticks(utcNow())), 864000000000)
```

#### 5.2 Send email (Reminder)
```
+ Add an action → Office 365 Outlook → Send an email (V2)

To: @{items('Apply_to_each')?['EmailContacto']}
Subject: Lembrete: Inquérito de Satisfação - ProdOut
Body: (ver template HTML abaixo)
```

**Template Email Reminder:**
```html
<html>
<body>
<p>Caro(a) <strong>@{items('Apply_to_each')?['Title']}</strong>,</p>

<p>Este é um lembrete amigável sobre o Inquérito de Satisfação da ProdOut que lhe enviámos.</p>

<p><strong>⏰ Prazo:</strong> @{formatDateTime(items('Apply_to_each')?['PrazoResposta'], 'dd/MM/yyyy')} 
<em>(faltam @{outputs('Compose_DiasRestantes')} dias)</em></p>

<p>Se já preencheu o inquérito, por favor ignore esta mensagem. 
Caso contrário, agradecemos que disponibilize alguns minutos para nos dar o seu feedback.</p>

<p style="margin: 25px 0;">
<a href="@{items('Apply_to_each')?['LinkFormularioPrefill']}" 
   style="background-color: #0078d4; color: white; padding: 12px 24px; 
          text-decoration: none; border-radius: 4px; display: inline-block;">
   Preencher Inquérito
</a>
</p>

<p>A sua opinião é muito importante para nós!</p>

<p>Com os melhores cumprimentos,<br>
<strong>Equipa ProdOut</strong></p>
</body>
</html>
```

#### 5.3 Update item (Contadores)
```
+ Add an action → SharePoint → Update item

Id: @{items('Apply_to_each')?['ID']}

Campos:
NumeroReminders: @{add(items('Apply_to_each')?['NumeroReminders'], 1)}
DataUltimoReminder: @{utcNow()}
```

#### 5.4 Delay
```
+ Add an action → Schedule → Delay

Count: 3
Unit: Second
```

### Passo 6: (Após Condition) Get items - Expirados
```
+ New step → SharePoint → Get items

Filter Query:
(EstadoInquerito eq 'Email Enviado') and (PrazoResposta lt '@{utcNow()}')
```

### Passo 7: Condition - Tem expirados?
```
+ New step → Control → Condition

Expression:
length(outputs('Get_items_2')?['body/value']) | is greater than | 0
```

### Passo 8: Ramo YES → Apply to each → Update
```
+ Add an action → SharePoint → Update item

Id: @{items('Apply_to_each_2')?['ID']}

Campos:
EstadoInquerito: "Expirado"
```

### Passo 9: Guardar
1. **Save**
2. **Test** (opcional) - execução manual para validar lógica

---

## 📊 OPÇÃO B: Import via JSON

### Pré-requisitos
- PowerShell 7+
- Módulo: `Microsoft.PowerApps.PowerShell`
- Autenticação delegada configurada

### Comando PowerShell
```powershell
# Autenticar
Add-PowerAppsAccount

# Importar cada flow (método manual - requer ajustes)
# NOTA: Import direto de JSON requer criação de conexões primeiro
# Recomenda-se criar manualmente usando os ficheiros JSON como referência
```

⚠️ **Limitação:** Power Automate requer ajuste manual das conexões após import de JSON.

---

## ✅ Checklist de Validação

### Fluxo 2 - Captura
- [ ] Flow criado e guardado
- [ ] Trigger configurado com Form ID correto
- [ ] Todos os 17 campos mapeados
- [ ] Condition implementada (YES/NO)
- [ ] Email de agradecimento funcional
- [ ] Email de erro funcional
- [ ] **TESTE:** Submeter resposta de teste → Validar captura

### Fluxo 1 - Envio
- [ ] Flow criado e guardado
- [ ] Filtro "Pendente" configurado
- [ ] Link pré-preenchido com 4 campos
- [ ] Email com template correto
- [ ] Update de estado funcional
- [ ] Delay configurado (2 seg)
- [ ] Concurrency: 5 paralelos
- [ ] **TESTE:** Executar manualmente → Verificar emails

### Fluxo 3 - Reminders
- [ ] Flow criado e guardado
- [ ] Recurrence: Diário às 09:00
- [ ] Filtro reminders correto (≤ 3 dias, < 2 reminders)
- [ ] Email de reminder funcional
- [ ] Contadores atualizados
- [ ] Processo de expirados implementado
- [ ] **TESTE:** Execução manual → Validar lógica

---

## 🔧 Troubleshooting Comum

### Erro: "Form ID not found"
**Solução:** Verificar Form ID em `config/settings.json` ou copiar diretamente do Forms.

### Erro: "Filter query invalid"
**Solução:** Usar aspas simples: `eq '@{expression}'` (não aspas duplas).

### Erro: "Field not found" no Update item
**Solução:** Nomes de campos SharePoint são case-sensitive. Verificar nomes exatos.

### Emails não são enviados
**Solução:** Verificar conexão Office 365 Outlook está autorizada.

### Dynamic content não aparece
**Solução:** Guardar e reabrir o flow. Pesquisar pelo Question ID manualmente.

---

## 📚 Referências

- [GUIA-IMPLEMENTACAO-FLOWS.md](../docs/GUIA-IMPLEMENTACAO-FLOWS.md) - Guia original
- [POWER-AUTOMATE-FLOWS.md](../docs/POWER-AUTOMATE-FLOWS.md) - Especificação técnica
- [FORMS-SHAREPOINT-MAPPING.md](../docs/FORMS-SHAREPOINT-MAPPING.md) - Mapeamento de campos

---

## 🎯 Próximos Passos

Após implementar os 3 fluxos:

1. ✅ Testar cada fluxo individualmente
2. ✅ Executar teste end-to-end completo:
   - Enviar inquéritos (Fluxo 1)
   - Responder no Forms
   - Validar captura (Fluxo 2)
   - Simular reminder (Fluxo 3)
3. ✅ Documentar no [ESTADO-ATUAL.md](../docs/ESTADO-ATUAL.md)
4. ✅ Commit e push para GitHub
5. ✅ Exportar flows para `flow-definitions-production/`

---

**Última atualização:** 22/02/2026  
**Autor:** GitHub Copilot (Claude Sonnet 4.5)  
**Versão:** 1.0
