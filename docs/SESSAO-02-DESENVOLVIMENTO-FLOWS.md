# 🚀 SESSÃO #2 - Desenvolvimento dos Fluxos Power Automate

**Data:** [A preencher]  
**Objetivo:** Implementar os 3 fluxos automatizados no Power Automate  
**Dependências:** Sessão #1 completa ✅

---

## 📊 Estado Atual do Projeto

### ✅ Sessão #1 - Setup Inicial (CONCLUÍDA)

**Completado a 22/02/2026:**
- ✅ Repositório Git criado e publicado no GitHub
- ✅ SharePoint List configurada (24 campos: 1 nativo + 23 customizados)
- ✅ 78 contactos importados com sucesso
- ✅ Microsoft Forms mapeado (15 questões + Question IDs)
- ✅ Campo nativo Title implementado (migração bem-sucedida)
- ✅ Arquitetura de 3 fluxos documentada
- ✅ Guia de implementação completo criado

**Repositório GitHub:**
https://github.com/pduarte74/PRJ_Inquerito_Satisfacao_Cliente

---

## 🎯 Objetivos da Sessão #2

### Implementar 3 Fluxos Power Automate

```
1️⃣ FLUXO 2: Captura de Respostas (COMEÇAR AQUI)
   → Mais crítico - captura automática das respostas do Forms
   → Valida mapeamento dos 15 campos
   
2️⃣ FLUXO 1: Envio de Inquéritos
   → Gera links pré-preenchidos
   → Envia emails personalizados
   
3️⃣ FLUXO 3: Gestão de Reminders
   → Agendado diariamente
   → Envia lembretes automáticos
```

---

## 📚 Documentação Disponível

### Guias de Implementação
- **[GUIA-IMPLEMENTACAO-FLOWS.md](GUIA-IMPLEMENTACAO-FLOWS.md)** ⭐ USAR ESTE
  - Passo a passo completo para cada fluxo
  - Copy/paste de expressões prontas
  - Troubleshooting comum

### Especificações Técnicas
- **[POWER-AUTOMATE-FLOWS.md](POWER-AUTOMATE-FLOWS.md)**
  - Arquitetura completa dos 3 fluxos
  - Lógica detalhada de cada ação
  - Diagramas de estado

- **[FORMS-SHAREPOINT-MAPPING.md](FORMS-SHAREPOINT-MAPPING.md)**
  - Mapeamento completo dos 15 campos
  - Question IDs do Microsoft Forms
  - Expressões Dynamic Content

### Estado do Projeto
- **[ESTADO-ATUAL.md](ESTADO-ATUAL.md)** - Progresso atual (90%)
- **[RESUMO-SESSAO-01.md](RESUMO-SESSAO-01.md)** - O que foi feito no setup

---

## 🔑 Informações Essenciais

### Microsoft Forms
```
Form ID: 8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu

URL: https://forms.office.com/Pages/ResponsePage.aspx?id=8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu
```

### SharePoint
```
Site: https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade
Lista: Recolha de Repostas Inquerito de Satisfação de Clientes
List ID: af4ef457-b004-4838-b917-8720346b9a8f
```

### Power Platform
```
Environment: Default-019607f2-cbbd-425e-a7b1-bc8d0d97a3e4
Portal: https://make.powerautomate.com
```

### Azure AD
```
Tenant ID: 019607f2-cbbd-425e-a7b1-bc8d0d97a3e4
Client ID: 483c7be8-cc1b-48c0-a2b0-3f734b9bd521
(Credenciais copiadas do projeto Auditoria Documental)
```

---

## 🔧 Estrutura SharePoint (24 campos)

### Campos de Identificação (4)
- **Title** (nativo) - Nome do contacto
- EmailContacto - Email
- Funcao - Função
- Entidade - Instituição

### Campos de Resposta Forms (13)
- ConsentimentoRGPD (Choice)
- CaracteristicasAssociadas (Text Multi)
- AvaliacaoServicoIntegrado (Number 1-10)
- AvaliacaoCertificacoes (Number 1-10)
- AvaliacaoExperiencia (Number 1-10)
- AvaliacaoCompreensaoNecessidades (Number 1-10)
- AvaliacaoRapidezEficacia (Number 1-10)
- AvaliacaoEntrega (Number 1-10)
- AvaliacaoAcondicionamento (Number 1-10)
- AvaliacaoImprevistos (Number 1-10)
- SugestoesServicosProdutos (Text Multi)
- SugestoesDesafios (Text Multi)
- RecomendariaProdOut (Choice)

### Campos de Workflow (8)
- EstadoInquerito (Choice: Pendente/Email Enviado/Respondido/Expirado/Cancelado)
- DataEnvioInicial (DateTime)
- DataResposta (DateTime)
- PrazoResposta (Date)
- DataUltimoReminder (DateTime)
- NumeroReminders (Number)
- LinkFormularioPrefill (Text)
- ResponseId (Text)

---

## 📝 Plano de Implementação

### FASE 1: Fluxo 2 - Captura de Respostas (60 min)

**Importância:** Crítico - sem este fluxo, as respostas não são capturadas.

**Passos:**
1. Aceder ao Power Automate
2. Criar flow "Automated cloud flow"
3. Trigger: "When a new response is submitted" (Forms)
4. Action: "Get response details"
5. Action: "Get items" (SharePoint - filtrar por email)
6. Condition: Item encontrado?
   - YES → Update item (mapear 15 campos) + Send email (agradecimento)
   - NO → Send email (erro para equipa interna)
7. Configurar concurrency e retry policy
8. **TESTAR:** Submeter Forms e verificar SharePoint

**Documentação:** Seção "FLUXO 2" em [GUIA-IMPLEMENTACAO-FLOWS.md](GUIA-IMPLEMENTACAO-FLOWS.md)

### FASE 2: Fluxo 1 - Envio de Inquéritos (45 min)

**Dependência:** Fluxo 2 deve estar funcional para teste end-to-end.

**Passos:**
1. Criar flow "Instant cloud flow" (manual trigger)
2. Get items (SharePoint - filtro: EstadoInquerito = "Pendente")
3. Apply to each:
   - Compose: Link pré-preenchido
   - Compose: Prazo resposta (+15 dias)
   - Send email personalizado
   - Update item (EstadoInquerito = "Email Enviado")
   - Delay 2 segundos
4. **TESTAR:** Executar para 1 contacto teste

**Documentação:** Seção "FLUXO 1" em [GUIA-IMPLEMENTACAO-FLOWS.md](GUIA-IMPLEMENTACAO-FLOWS.md)

### FASE 3: Fluxo 3 - Gestão de Reminders (45 min)

**Dependência:** Fluxos 1 e 2 funcionais.

**Passos:**
1. Criar flow "Scheduled cloud flow" (diário 09:00)
2. Compose: Data limite reminder (hoje + 3 dias)
3. Get items (filtro: Email Enviado + Prazo <= limite + Reminders < 2)
4. Condition: Existem contactos?
   - YES → Apply to each:
     - Compose: Dias restantes
     - Send email reminder
     - Update item (NumeroReminders +1)
     - Delay 3 segundos
5. Get items: Expirados (Prazo < hoje)
6. Apply to each → Update (EstadoInquerito = "Expirado")
7. **TESTAR:** Ajustar datas manualmente e executar

**Documentação:** Seção "FLUXO 3" em [GUIA-IMPLEMENTACAO-FLOWS.md](GUIA-IMPLEMENTACAO-FLOWS.md)

---

## ✅ Checklist de Validação Final

### End-to-End Test
- [ ] Criar contacto teste com EstadoInquerito = "Pendente"
- [ ] Executar Fluxo 1 → Verificar email recebido
- [ ] Submeter resposta no Forms
- [ ] Verificar Fluxo 2 executou → SharePoint atualizado
- [ ] Verificar email de agradecimento recebido
- [ ] Ajustar data de prazo para teste reminders
- [ ] Executar Fluxo 3 → Verificar reminder enviado

### Documentação
- [ ] Atualizar ESTADO-ATUAL.md (progresso → 100%)
- [ ] Criar RESUMO-SESSAO-02.md
- [ ] Commit e push das alterações

---

## 🐛 Troubleshooting Rápido

### "Form not found"
→ Verificar Form ID. Usar "Enter custom value".

### "Invalid filter query"
→ Usar aspas simples: `eq '@{...}'` (não duplas)

### "Column not found"
→ Verificar nome exato no SharePoint (case-sensitive)

### Link pré-preenchido não funciona
→ Verificar Question IDs (seção no FORMS-SHAREPOINT-MAPPING.md)

---

## 📊 Próximos Passos Após Implementação

1. ✅ Testar fluxos individualmente
2. ✅ Teste end-to-end completo
3. 🔄 Executar envio para grupo piloto (5-10 contactos)
4. 📈 Monitorizar primeiros dias
5. 📊 Criar views SharePoint para acompanhamento
6. 🎨 Opcional: Dashboard Power BI

---

## 💡 Notas Importantes

### Estado dos Contactos
- **Pendente:** Contacto importado, aguarda envio
- **Email Enviado:** Link enviado, aguarda resposta
- **Respondido:** Inquérito completado ✅
- **Expirado:** Prazo ultrapassado sem resposta
- **Cancelado:** Manualmente cancelado

### Prazos
- **15 dias** após envio para responder
- **Reminders:** 3 dias antes do prazo
- **Máximo:** 2 reminders por contacto

### Segurança
- Credenciais em `config/client-secret.encrypted` (DPAPI)
- Ficheiro `config/settings.json` em .gitignore
- Forms apenas para utilizadores autenticados (opcional)

---

**🚀 Pronto para começar a Sessão #2!**

**Tempo estimado total:** 2-3 horas  
**Resultado esperado:** 3 fluxos implementados e testados  
**Estado final esperado:** Projeto 100% funcional
