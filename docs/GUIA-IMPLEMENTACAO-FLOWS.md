# Guia Prático de Implementação - Power Automate Flows

**Projeto:** Inquérito Satisfação Cliente  
**Data:** 22/02/2026  
**Objetivo:** Implementar os 3 fluxos automatizados

---

## 🎯 Ordem de Implementação Recomendada

```
1️⃣ FLUXO 2 (Captura) → Testar → ✅
2️⃣ FLUXO 1 (Envio)   → Testar → ✅
3️⃣ FLUXO 3 (Reminders) → Testar → ✅
```

**Razão:** O Fluxo 2 é o mais crítico - sem ele, as respostas não são capturadas. Implementá-lo primeiro permite validar o mapeamento completo.

---

## 🔧 Pré-requisitos

- [x] SharePoint List criada (af4ef457-b004-4838-b917-8720346b9a8f) ✅
- [x] 24 campos configurados ✅
- [x] 78 contactos importados ✅
- [x] Microsoft Forms configurado ✅
- [x] Mapeamento de campos documentado ✅
- [x] Acesso ao Power Automate
- [x] Permissões de criador de flows no environment

---

## 📍 FLUXO 2: Captura de Respostas (COMEÇAR AQUI)

### **Nome:** `Inquerito-Satisfacao-Captura-Respostas`

### 🚀 Passos de Implementação

#### 1. Aceder ao Power Automate
```
URL: https://make.powerautomate.com
Environment: Default-019607f2-cbbd-425e-a7b1-bc8d0d97a3e4
```

#### 2. Criar Novo Flow
- **My flows** → **+ New flow** → **Automated cloud flow**
- Nome: `Inquerito-Satisfacao-Captura-Respostas`
- Trigger: Pesquisar "Forms" → **When a new response is submitted**
- Click **Create**

#### 3. Configurar Trigger
```
Connector: Microsoft Forms
Trigger: When a new response is submitted
Form Id: 8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu
```

💡 **Dica:** Colar o Form ID diretamente. Se não aparecer, usar "Enter custom value".

#### 4. Adicionar Action: Get response details
```
+ New step → Pesquisar "Forms" → Get response details

Form Id: (mesmo do trigger)
Response Id: (Dynamic content) → Response Id
```

#### 5. Adicionar Action: Get items (SharePoint)
```
+ New step → Pesquisar "SharePoint" → Get items

Site Address: https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade
List Name: Recolha de Repostas Inquerito de Satisfação de Clientes

Filter Query:
EmailContacto eq '@{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}'

Top Count: 1
```

⚠️ **IMPORTANTE:** Usar aspas simples no filtro OData: `eq '@{...}'`

#### 6. Adicionar Condition: Item encontrado?
```
+ New step → Control → Condition

Condition:
length(outputs('Get_items')?['body/value']) | is greater than | 0
```

#### 7. Ramo YES → Update item (SharePoint)

##### 7.1 Adicionar Update item
```
+ Add an action → SharePoint → Update item

Site Address: (mesmo)
List Name: (mesmo)
Id: @{first(outputs('Get_items')?['body/value'])?['ID']}
```

##### 7.2 Mapear TODOS os 15 campos + controlo

**Referência completa:** [FORMS-SHAREPOINT-MAPPING.md](FORMS-SHAREPOINT-MAPPING.md)

**Campos obrigatórios (copiar/colar):**

| Campo SharePoint | Expressão Dynamic Content |
|------------------|---------------------------|
| Title | `r4a23b53b26c94fceb200c0bb59ca92d9` |
| EmailContacto | `r7b2bd52ed2764c57803595d6c3ca2bb7` |
| Funcao | `rd1db5d1cfeb04e50a01a18b4e4dc2bca` |
| Entidade | `r093e6f2fc8744c43990e68b5eda96adc` |
| ConsentimentoRGPD | `r8fe48e19d79549bf8cf1e1a1e2223d1c` |
| CaracteristicasAssociadas | `rc38c74906d884d51b8a93e3bbdd74aa9` |
| AvaliacaoServicoIntegrado | `ra86f09da48214fc19234c1ad8c2f3c49` |
| AvaliacaoCertificacoes | `re9e5802d0c844f069ee8bc4aaa5fb3c1` |
| AvaliacaoExperiencia | `r22e3f0fe5baa4e13beabcf6bfbdde8a1` |
| AvaliacaoCompreensaoNecessidades | `r18086fb5de1f4b8586a3ba862cd0f9df` |
| AvaliacaoRapidezEficacia | `r7b84c2aaac4143478cd929b5ca65e38e` |
| AvaliacaoEntrega | `r68afb7c83b6d43d293b9bb4bff20f063` |
| AvaliacaoAcondicionamento | `r9f37e98a33c44e638a0f1b9a62a20ff3` |
| AvaliacaoImprevistos | `r56fb5ac8d5fa48059f69f27a91f6e50b` |
| SugestoesServicosProdutos | `rf6a1ca933f214fcb874a92e02f61c9b5` |
| SugestoesDesafios | `rf5943b498a1241019699e87a12346f46` |
| RecomendariaProdOut | `rc39ade3652324f5696be166a8df5c2a3` |

**Campos de Controlo:**
```
EstadoInquerito: Respondido
DataResposta: @{utcNow()}
ResponseId: @{outputs('Get_response_details')?['body/responseId']}
```

💡 **Como mapear no Power Automate:**
1. Click no campo SharePoint
2. Click em "Dynamic content"
3. Procurar pelo Question ID (ex: `r4a23b53b26c94fceb200c0bb59ca92d9`)
4. Selecionar o campo correspondente

#### 8. Ramo YES → Send email (Agradecimento)
```
+ Add an action → Office 365 Outlook → Send an email (V2)

To: @{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}

Subject: Obrigado pela sua participação - ProdOut

Body: (copiar HTML completo abaixo)
```

**HTML do Email:**
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

#### 9. Ramo NO → Send email (Erro Interno)
```
+ Add an action → Office 365 Outlook → Send an email (V2)

To: qualidade@prodout.pt

Subject: ERRO - Resposta Forms sem match no SharePoint

Body:
Response ID: @{outputs('Get_response_details')?['body/responseId']}
Email: @{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}
Nome: @{outputs('Get_response_details')?['body/r4a23b53b26c94fceb200c0bb59ca92d9']}

Ação necessária: Verificar lista SharePoint e adicionar manualmente.
```

#### 10. Configurações Avançadas do Flow
```
Settings → Enable → Concurrency Control: ON
Settings → Retry Policy: Exponential Interval (4 attempts)
```

#### 11. GUARDAR e TESTAR
- **Save** (canto superior direito)
- Submeter formulário de teste
- Verificar Run History
- Validar dados no SharePoint

---

## 📍 FLUXO 1: Envio de Inquéritos

### **Nome:** `Inquerito-Satisfacao-Envio-Inicial`

### 🚀 Passos de Implementação

#### 1. Criar Flow Manual
```
+ New flow → Instant cloud flow
Nome: Inquerito-Satisfacao-Envio-Inicial
Trigger: Manually trigger a flow
```

#### 2. Get items (SharePoint)
```
+ New step → SharePoint → Get items

Filter Query: EstadoInquerito eq 'Pendente'
Order By: Created (ascending)
Limit: 100
```

#### 3. Apply to each (Loop)
```
+ New step → Control → Apply to each
Input: value (do Get items)
```

#### 4. Dentro do Loop:

##### 4.1 Compose: Link Pré-preenchido
```
+ Add an action → Compose
Nome: LinkFormulario

Inputs:
https://forms.office.com/Pages/ResponsePage.aspx?id=8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu&r4a23b53b26c94fceb200c0bb59ca92d9=@{items('Apply_to_each')?['Title']}&r7b2bd52ed2764c57803595d6c3ca2bb7=@{items('Apply_to_each')?['EmailContacto']}&rd1db5d1cfeb04e50a01a18b4e4dc2bca=@{items('Apply_to_each')?['Funcao']}&r093e6f2fc8744c43990e68b5eda96adc=@{items('Apply_to_each')?['Entidade']}
```

⚠️ **NOTA:** Power Automate faz URL encoding automaticamente.

##### 4.2 Compose: Prazo Resposta
```
+ Add an action → Compose
Nome: PrazoResposta

Inputs: @{addDays(utcNow(), 15)}
```

##### 4.3 Send email
```
+ Add an action → Office 365 Outlook → Send an email (V2)

To: @{items('Apply_to_each')?['EmailContacto']}
Subject: Inquérito de Satisfação - ProdOut

Body: (copiar HTML completo do POWER-AUTOMATE-FLOWS.md)
```

**Variáveis importantes no HTML:**
- `@{items('Apply_to_each')?['Title']}` - Nome
- `@{outputs('LinkFormulario')}` - Link do formulário
- `@{formatDateTime(outputs('PrazoResposta'), 'dd/MM/yyyy')}` - Data formatada

##### 4.4 Update item (SharePoint)
```
+ Add an action → SharePoint → Update item

Id: @{items('Apply_to_each')?['ID']}

Campos:
EstadoInquerito: Email Enviado
DataEnvioInicial: @{utcNow()}
PrazoResposta: @{outputs('PrazoResposta')}
LinkFormularioPrefill: @{outputs('LinkFormulario')}
NumeroReminders: 0
```

##### 4.5 Delay
```
+ Add an action → Delay
Count: 2
Unit: Second
```

#### 5. Configurações
```
Settings → Apply to each → Concurrency: 5 (envia 5 emails em paralelo)
```

---

## 📍 FLUXO 3: Gestão de Reminders

### **Nome:** `Inquerito-Satisfacao-Reminders`

### 🚀 Passos de Implementação

#### 1. Criar Flow Agendado
```
+ New flow → Scheduled cloud flow
Nome: Inquerito-Satisfacao-Reminders
Frequency: Day
Interval: 1
At: 09:00 AM
Time zone: (UTC+00:00) Dublin, Edinburgh, Lisbon, London
```

#### 2. Compose: Data Limite Reminder
```
+ New step → Compose
Nome: DataLimiteReminder

Inputs: @{addDays(utcNow(), 3)}
```

#### 3. Get items: Contactos Elegíveis
```
+ New step → SharePoint → Get items

Filter Query:
(EstadoInquerito eq 'Email Enviado') and (PrazoResposta le '@{outputs('DataLimiteReminder')}') and (NumeroReminders lt 2)

Order By: PrazoResposta (ascending)
```

#### 4. Condition: Existem contactos?
```
+ New step → Condition

length(outputs('Get_items')?['body/value']) | is greater than | 0
```

#### 5. Ramo YES → Apply to each

##### 5.1 Compose: Dias Restantes
```
Nome: DiasRestantes

Inputs:
@{div(sub(ticks(items('Apply_to_each')?['PrazoResposta']),ticks(utcNow())),864000000000)}
```

##### 5.2 Send email (Reminder)
```
To: @{items('Apply_to_each')?['EmailContacto']}
Subject: Lembrete: Inquérito de Satisfação - ProdOut

Body: (copiar HTML do POWER-AUTOMATE-FLOWS.md)
```

##### 5.3 Update item
```
Id: @{items('Apply_to_each')?['ID']}

NumeroReminders: @{add(items('Apply_to_each')?['NumeroReminders'], 1)}
DataUltimoReminder: @{utcNow()}
```

##### 5.4 Delay
```
Count: 3
Unit: Second
```

#### 6. Após o Apply to each → Marcar Expirados

##### 6.1 Get items: Expirados
```
+ New step → SharePoint → Get items

Filter Query:
(EstadoInquerito eq 'Email Enviado') and (PrazoResposta lt '@{utcNow()}')
```

##### 6.2 Apply to each → Update
```
Apply to each: value (do Get items anterior)

+ Update item
EstadoInquerito: Expirado
```

---

## ✅ Checklist de Validação

### Fluxo 2 (Captura)
- [ ] Trigger configurado (Forms response)
- [ ] Get response details funciona
- [ ] Filtro SharePoint encontra contacto por email
- [ ] Todos os 15 campos mapeados corretamente
- [ ] Campos de controlo preenchidos (EstadoInquerito, DataResposta, ResponseId)
- [ ] Email de agradecimento enviado
- [ ] Email de erro enviado quando não encontra contacto
- [ ] Teste real: submeter Forms e verificar SharePoint

### Fluxo 1 (Envio)
- [ ] Trigger manual configurado
- [ ] Get items filtra corretamente (EstadoInquerito = Pendente)
- [ ] Link pré-preenchido gerado corretamente
- [ ] Email enviado com formatação correta
- [ ] SharePoint atualizado (EstadoInquerito = Email Enviado)
- [ ] Campos DataEnvioInicial, PrazoResposta, LinkFormularioPrefill preenchidos
- [ ] Teste real: executar e verificar email recebido

### Fluxo 3 (Reminders)
- [ ] Trigger agendado (diário às 09:00)
- [ ] Filtro correto (Email Enviado + Prazo <= hoje+3 + Reminders < 2)
- [ ] Email reminder enviado
- [ ] Contador NumeroReminders incrementado
- [ ] Expirados marcados corretamente
- [ ] Teste: ajustar datas manualmente e executar

---

## 🐛 Troubleshooting Comum

### Erro: "Form not found"
**Solução:** Verificar Form ID. Usar "Enter custom value" e colar ID completo.

### Erro: "Invalid filter query"
**Solução:** Usar aspas simples no OData: `eq '@{...}'` (não duplas)

### Erro: "Column not found"
**Solução:** Verificar nome exato do campo no SharePoint (case-sensitive)

### Emails não enviados
**Solução:** Verificar permissões do Office 365 Outlook connector

### Link pré-preenchido não funciona
**Solução:** Verificar Question IDs no Forms (podem ter mudado)

---

## 📊 Próximos Passos Após Implementação

1. **Testar cada fluxo individualmente**
2. **Teste end-to-end completo:**
   - Executar Fluxo 1 para 1 contacto teste
   - Submeter resposta no Forms
   - Verificar captura pelo Fluxo 2
   - Simular reminder (ajustar data)
3. **Monitorizar primeiros envios reais**
4. **Criar dashboard de acompanhamento**
5. **Documentar erros e ajustes**

---

## 📚 Referências

- [POWER-AUTOMATE-FLOWS.md](POWER-AUTOMATE-FLOWS.md) - Especificação completa
- [FORMS-SHAREPOINT-MAPPING.md](FORMS-SHAREPOINT-MAPPING.md) - Mapeamento de campos
- [ESTADO-ATUAL.md](ESTADO-ATUAL.md) - Estado do projeto
- [settings.json](../config/settings.json) - Configurações

---

**Boa implementação! 🚀**
