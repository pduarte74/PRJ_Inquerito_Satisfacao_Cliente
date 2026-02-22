# Power Automate - Arquitetura dos Fluxos

## Visão Geral

Sistema de 3 fluxos para gestão completa do ciclo de vida dos inquéritos de satisfação:

```
[Contactos SharePoint]
         ↓
   [FLUXO 1: Envio]
    • Gera links pré-preenchidos
    • Envia emails personalizados
    • Estado: "Email Enviado"
         ↓
   [Microsoft Forms]
    • Cliente preenche formulário
         ↓
   [FLUXO 2: Resposta]
    • Captura dados do Forms
    • Atualiza SharePoint
    • Estado: "Respondido"
    • Envia agradecimento
         ↓
   [FLUXO 3: Reminders]
    • Execução agendada
    • Verifica prazos
    • Envia lembretes
    • Atualiza contadores
```

---

## FLUXO 1: Envio de Inquéritos

### **Nome:** `Inquerito-Satisfacao-Envio-Inicial`

### **Tipo:** Manual / Agendado
- **Trigger:** Manual (com opção de agendar execução)
- **Opções:** Executar para todos os contactos com `EstadoInquerito = "Pendente"` ou para seleção manual

### **Objetivo:**
Gerar links pré-preenchidos do Microsoft Forms e enviar emails personalizados aos contactos.

### **Lógica do Fluxo:**

#### 1. **Obter Contactos**
```
Action: Get items (SharePoint)
Lista: Inquerito Satisfação Cliente
Filtro: EstadoInquerito eq 'Pendente'
```

#### 2. **Para cada contacto (Apply to each)**

##### 2.1 Gerar Link Pré-preenchido
```
Action: Compose
Nome: LinkFormulario

Expressão:
https://forms.office.com/Pages/ResponsePage.aspx?id=8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu&

r4a23b53b26c94fceb200c0bb59ca92d9=@{items('Apply_to_each')?['Title']}&

r7b2bd52ed2764c57803595d6c3ca2bb7=@{items('Apply_to_each')?['EmailContacto']}&

rd1db5d1cfeb04e50a01a18b4e4dc2bca=@{items('Apply_to_each')?['Funcao']}&

r093e6f2fc8744c43990e68b5eda96adc=@{items('Apply_to_each')?['Entidade']}
```

**Notas:**
- Os 4 primeiros campos são pré-preenchidos (Identificação, Email, Função, Entidade)
- O restante do formulário fica em branco para o cliente preencher
- URL encoding será aplicado automaticamente pelo Power Automate

##### 2.2 Calcular Prazo de Resposta
```
Action: Compose
Nome: PrazoResposta

Expressão:
addDays(utcNow(), 15)
```
*15 dias corridos a partir da data de envio*

##### 2.3 Enviar Email
```
Action: Send an email (V2)
Para: @{items('Apply_to_each')?['EmailContacto']}
Assunto: Inquérito de Satisfação - ProdOut

Corpo (HTML):
<html>
<body>
<p>Caro(a) <strong>@{items('Apply_to_each')?['Title']}</strong>,</p>

<p>No âmbito do nosso Sistema de Gestão da Qualidade e compromisso com a melhoria contínua, 
solicitamos a sua colaboração no preenchimento de um breve inquérito de satisfação sobre 
os serviços prestados pela ProdOut.</p>

<p>A sua opinião é fundamental para aprimorarmos os nossos processos e garantirmos que continuamos 
a corresponder às suas expectativas.</p>

<p style="margin: 25px 0;">
<a href="@{outputs('LinkFormulario')}" 
   style="background-color: #0078d4; color: white; padding: 12px 24px; 
          text-decoration: none; border-radius: 4px; display: inline-block;">
   Preencher Inquérito
</a>
</p>

<p><strong>Prazo de resposta:</strong> até @{formatDateTime(outputs('PrazoResposta'), 'dd/MM/yyyy')}</p>

<p>O inquérito demora aproximadamente 5 minutos a preencher e as suas respostas são tratadas 
com total confidencialidade de acordo com o RGPD.</p>

<p>Agradecemos antecipadamente a sua colaboração.</p>

<p>Com os melhores cumprimentos,<br>
<strong>Equipa ProdOut</strong></p>
</body>
</html>
```

##### 2.4 Atualizar Item SharePoint
```
Action: Update item (SharePoint)
Site: https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade
Lista: Inquerito Satisfação Cliente
ID: @{items('Apply_to_each')?['ID']}

Campos:
- EstadoInquerito: "Email Enviado"
- DataEnvioInicial: @{utcNow()}
- PrazoResposta: @{outputs('PrazoResposta')}
- LinkFormularioPrefill: @{outputs('LinkFormulario')}
- NumeroReminders: 0
```

##### 2.5 Delay (opcional)
```
Action: Delay
Intervalo: 2 segundos
```
*Evita sobrecarga do servidor de email*

---

## FLUXO 2: Captura de Respostas

### **Nome:** `Inquerito-Satisfacao-Captura-Respostas`

### **Tipo:** Automatizado
- **Trigger:** When a new response is submitted (Microsoft Forms)
- **Form ID:** 8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu

### **Objetivo:**
Capturar respostas do Forms, atualizar o item correspondente no SharePoint e enviar email de agradecimento.

### **Lógica do Fluxo:**

#### 1. **Get response details**
```
Action: Get response details (Forms)
Form ID: 8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu
Response ID: @{triggerBody()?['resourceData']?['responseId']}
```

#### 2. **Encontrar Item no SharePoint**
```
Action: Get items (SharePoint)
Lista: Inquerito Satisfação Cliente
Filtro: EmailContacto eq '@{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}'
Top Count: 1
```

**Lógica de Match:**
- Usa o campo Email (r7b2bd52ed2764c57803595d6c3ca2bb7) para correlacionar resposta com contacto
- Assume que o email é único na lista

#### 3. **Condition: Item Encontrado?**

##### 3.1 Se SIM → Atualizar SharePoint
```
Action: Update item (SharePoint)
Site: https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade
Lista: Inquerito Satisfação Cliente
ID: @{first(outputs('Get_items')?['body/value'])?['ID']}

Mapeamento Completo (ver FORMS-SHAREPOINT-MAPPING.md):

Campo SharePoint                      | Question ID                         | Dynamic Content
--------------------------------------|-------------------------------------|-------------------
ConsentimentoRGPD                     | r8fe48e19d79549bf8cf1e1a1e2223d1c | ✓
CaracteristicasAssociadas             | rc38c74906d884d51b8a93e3bbdd74aa9 | ✓
AvaliacaoServicoIntegrado             | ra86f09da48214fc19234c1ad8c2f3c49 | ✓
AvaliacaoCertificacoes                | re9e5802d0c844f069ee8bc4aaa5fb3c1 | ✓
AvaliacaoExperiencia                  | r22e3f0fe5baa4e13beabcf6bfbdde8a1 | ✓
AvaliacaoCompreensaoNecessidades      | r18086fb5de1f4b8586a3ba862cd0f9df | ✓
AvaliacaoRapidezEficacia              | r7b84c2aaac4143478cd929b5ca65e38e | ✓
AvaliacaoEntrega                      | r68afb7c83b6d43d293b9bb4bff20f063 | ✓
AvaliacaoAcondicionamento             | r9f37e98a33c44e638a0f1b9a62a20ff3 | ✓
AvaliacaoImprevistos                  | r56fb5ac8d5fa48059f69f27a91f6e50b | ✓
SugestoesServicosProdutos             | rf6a1ca933f214fcb874a92e02f61c9b5 | ✓
SugestoesDesafios                     | rf5943b498a1241019699e87a12346f46 | ✓
RecomendariaProdOut                   | rc39ade3652324f5696be166a8df5c2a3 | ✓

Campos de Controlo:
- EstadoInquerito: "Respondido"
- DataResposta: @{utcNow()}
- ResponseId: @{outputs('Get_response_details')?['body/responseId']}
```

##### 3.2 Enviar Email de Agradecimento
```
Action: Send an email (V2)
Para: @{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}
Assunto: Obrigado pela sua participação - ProdOut

Corpo (HTML):
<html>
<body>
<p>Caro(a) <strong>@{outputs('Get_response_details')?['body/r4a23b53b26c94fceb200c0bb59ca92d9']}</strong>,</p>

<!-- NOTA: Este valor vem do Forms. O campo Title no SharePoint será preenchido na criação inicial do contacto -->

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

##### 3.3 Se NÃO → Log de Erro
```
Action: Send an email (V2) [para equipa interna]
Para: qualidade@prodout.pt
Assunto: ERRO - Resposta Forms sem match no SharePoint

Corpo:
Response ID: @{outputs('Get_response_details')?['body/responseId']}
Email: @{outputs('Get_response_details')?['body/r7b2bd52ed2764c57803595d6c3ca2bb7']}
Nome: @{outputs('Get_response_details')?['body/r4a23b53b26c94fceb200c0bb59ca92d9']}

Ação necessária: Verificar lista SharePoint e adicionar manualmente.
```

---

## FLUXO 3: Gestão de Reminders

### **Nome:** `Inquerito-Satisfacao-Reminders`

### **Tipo:** Agendado
- **Trigger:** Recurrence
- **Frequência:** Daily (Diário)
- **Hora:** 09:00 AM (Portugal Time)

### **Objetivo:**
Enviar lembretes automáticos aos contactos que ainda não responderam e cujo prazo está próximo.

### **Lógica do Fluxo:**

#### 1. **Calcular Data Limite para Reminder**
```
Action: Compose
Nome: DataLimiteReminder

Expressão:
addDays(utcNow(), 3)
```
*Envia reminder se faltam 3 dias ou menos para o prazo*

#### 2. **Obter Contactos Elegíveis**
```
Action: Get items (SharePoint)
Lista: Inquerito Satisfação Cliente

Filtro OData:
(EstadoInquerito eq 'Email Enviado') and 
(PrazoResposta le '@{outputs('DataLimiteReminder')}') and
(NumeroReminders lt 2)

ORDER BY: PrazoResposta asc
```

**Critérios:**
- Estado = "Email Enviado" (ainda não responderam)
- Prazo de Resposta ≤ Hoje + 3 dias
- Menos de 2 reminders enviados (limite máximo)

#### 3. **Condition: Existem contactos?**

##### 3.1 Se SIM → Apply to each

###### 3.1.1 Calcular Dias Restantes
```
Action: Compose
Nome: DiasRestantes

Expressão:
div(
  sub(
    ticks(items('Apply_to_each')?['PrazoResposta']),
    ticks(utcNow())
  ),
  864000000000
)
```

###### 3.1.2 Enviar Email de Reminder
```
Action: Send an email (V2)
Para: @{items('Apply_to_each')?['EmailContacto']}
Assunto: Lembrete: Inquérito de Satisfação - ProdOut

Corpo (HTML):
<html>
<body>
<p>Caro(a) <strong>@{items('Apply_to_each')?['Title']}</strong>,</p>

<p>Este é um lembrete amigável sobre o Inquérito de Satisfação da ProdOut que lhe enviámos.</p>

<p><strong>⏰ Prazo:</strong> @{formatDateTime(items('Apply_to_each')?['PrazoResposta'], 'dd/MM/yyyy')} 
<em>(faltam @{outputs('DiasRestantes')} dias)</em></p>

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

###### 3.1.3 Atualizar Contadores
```
Action: Update item (SharePoint)
Site: https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade
Lista: Inquerito Satisfação Cliente
ID: @{items('Apply_to_each')?['ID']}

Campos:
- NumeroReminders: @{add(items('Apply_to_each')?['NumeroReminders'], 1)}
- DataUltimoReminder: @{utcNow()}
```

###### 3.1.4 Delay
```
Action: Delay
Intervalo: 3 segundos
```

##### 3.2 Se NÃO → Nenhuma ação necessária
*Fluxo termina sem enviar emails*

---

#### 4. **Processar Inquéritos Expirados**

##### 4.1 Obter Inquéritos Expirados
```
Action: Get items (SharePoint)
Lista: Inquerito Satisfação Cliente

Filtro:
(EstadoInquerito eq 'Email Enviado') and 
(PrazoResposta lt '@{utcNow()}')
```

##### 4.2 Apply to each → Marcar como Expirado
```
Action: Update item (SharePoint)
ID: @{items('Apply_to_each_2')?['ID']}

Campos:
- EstadoInquerito: "Expirado"
```

---

## Campos Envolvidos

### **Campos de Identificação**
- `Title` (Text - campo nativo SharePoint)
- `EmailContacto` (Text)
- `Funcao` (Text)
- `Entidade` (Text)

### **Campos de Resposta Forms** (13 campos)
- `ConsentimentoRGPD` (Choice)
- `CaracteristicasAssociadas` (Text - Multiple)
- `AvaliacaoServicoIntegrado` (Number 1-10)
- `AvaliacaoCertificacoes` (Number 1-10)
- `AvaliacaoExperiencia` (Number 1-10)
- `AvaliacaoCompreensaoNecessidades` (Number 1-10)
- `AvaliacaoRapidezEficacia` (Number 1-10)
- `AvaliacaoEntrega` (Number 1-10)
- `AvaliacaoAcondicionamento` (Number 1-10)
- `AvaliacaoImprevistos` (Number 1-10)
- `SugestoesServicosProdutos` (Text - Long)
- `SugestoesDesafios` (Text - Long)
- `RecomendariaProdOut` (Choice)

### **Campos de Controlo Workflow** (8 campos)
- `EstadoInquerito` (Choice): Pendente | Email Enviado | Respondido | Expirado | Cancelado
- `DataEnvioInicial` (DateTime)
- `DataResposta` (DateTime)
- `PrazoResposta` (Date Only)
- `DataUltimoReminder` (DateTime)
- `NumeroReminders` (Number)
- `LinkFormularioPrefill` (Text)
- `ResponseId` (Text)

**Total:** 25 campos

---

## Diagrama de Estados

```
[Pendente]
    ↓ (Fluxo 1)
[Email Enviado] ←─────┐
    ↓                  │
    ├─→ (Resposta) → [Respondido] ✓
    │                  
    └─→ (Prazo expirado) → [Expirado] ✗
    
Reminders: até 2x enquanto em "Email Enviado"
```

---

## Configurações Recomendadas

### **Fluxo 1 - Envio**
- **Concurrency Control:** Degree of parallelism = 5
- **Retry Policy:** 2 attempts com 1 minuto de intervalo
- **Run After:** Continue on failure (para emails individuais)

### **Fluxo 2 - Captura**
- **Concurrency Control:** ON (permite múltiplas respostas simultâneas)
- **Retry Policy:** Exponential 4 attempts
- **Timeout:** 5 minutos

### **Fluxo 3 - Reminders**
- **Concurrency Control:** OFF (execução sequencial)
- **Retry Policy:** Default
- **Timeout:** 1 hora (para listas grandes)

---

## Monitorização

### **Métricas a Acompanhar:**
1. Taxa de envio (emails enviados / total contactos)
2. Taxa de resposta (respondidos / emails enviados)
3. Taxa de conversão por reminder (respostas após reminder)
4. Tempo médio de resposta
5. Taxa de expiração

### **Views SharePoint Sugeridas:**
1. **Por Responder:** EstadoInquerito = "Email Enviado", ordenado por PrazoResposta
2. **Respondidos Hoje:** EstadoInquerito = "Respondido", DataResposta = hoje
3. **Expirados:** EstadoInquerito = "Expirado"
4. **Pendentes de Envio:** EstadoInquerito = "Pendente"

---

## Notas de Implementação

### **Segurança:**
- Fluxos devem correr com conta de serviço dedicada
- Forms configurado para aceitar respostas apenas de utilizadores autenticados (opcional)
- Lista SharePoint com permissões restritas (Qualidade + Admin)

### **Compliance RGPD:**
- Campo ConsentimentoRGPD obrigatório no Forms
- Respostas armazenadas apenas no tenant da organização
- Política de retenção: 2 anos após DataResposta

### **Personalizações Futuras:**
- Dashboard Power BI para análise de respostas
- Integração com Teams para notificações à equipa
- Workflow de follow-up para respostas com avaliações baixas
- Relatório automático mensal para Reunião de Revisão pela Gestão

---

**Documentação relacionada:**
- [FORMS-SHAREPOINT-MAPPING.md](FORMS-SHAREPOINT-MAPPING.md) - Mapeamento completo de campos
- [config/settings.json](../config/settings.json) - Question IDs e configurações
