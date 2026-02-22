# 📚 Índice de Documentação - [Nome do Projeto]

**Template versão:** 1.0  
**Última atualização:** [Data]  
**Status:** 📝 Documentação em construção

---

## 🚀 Quick Start (Leia Primeiro)

### ⚡ Setup Ultra-Rápido
1. **[../QUICKSTART.md](../QUICKSTART.md)** - ⭐⭐⭐ Setup mínimo em 30 minutos (NOVO)

### Para Setup Inicial
1. **[SETUP-INICIAL.md](SETUP-INICIAL.md)** - ⭐ Configuração completa do projeto (2-3h)
2. **[AUTH-METHODS.md](AUTH-METHODS.md)** - Métodos de autenticação validados
3. **[START-NEXT-SESSION.md](START-NEXT-SESSION.md)** - Checklist para cada sessão

### Para Desenvolvimento
1. **[criar-flows-export-edit-import.md](criar-flows-export-edit-import.md)** - Criar/editar flows
2. **[iteracoes-desenvolvimento.md](iteracoes-desenvolvimento.md)** - Planeamento de iterações
3. **[forms-sharepoint-mapping.md](forms-sharepoint-mapping.md)** - Mapear campos

### Ferramentas de Gestão ⭐ NOVO
1. **[../CHEATSHEET.md](../CHEATSHEET.md)** - ⭐ Referência rápida (comandos, patterns, one-liners)
2. **[../CHECKLIST-VALIDACAO.md](../CHECKLIST-VALIDACAO.md)** - Validação completa do template/projeto
3. **[../MIGRACAO-PROJETO-EXISTENTE.md](../MIGRACAO-PROJETO-EXISTENTE.md)** - Migrar projeto existente (4-5h)
4. **[../VERSION.md](../VERSION.md)** - Histórico de versões detalhado

### Para Troubleshooting
1. **[troubleshooting.md](troubleshooting.md)** - Problemas comuns
2. **[../scripts/README.md](../scripts/README.md)** - Lista de scripts disponíveis

---

## 📖 Documentação por Categoria

### 🔧 Setup e Configuração
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [SETUP-INICIAL.md](SETUP-INICIAL.md) | Setup completo do projeto do zero | ⭐⭐⭐ Essencial |
| [AUTH-METHODS.md](AUTH-METHODS.md) | Métodos de autenticação (App Reg, Delegada) | ⭐⭐⭐ Essencial |
| [ESTRUTURA-PROJETO.md](ESTRUTURA-PROJETO.md) | Organização de pastas e ficheiros | ⭐⭐ Alta |
| [config-settings.md](config-settings.md) | Configurações do projeto | ⭐ Referência |

### 🔄 Workflows e Processos
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [START-NEXT-SESSION.md](START-NEXT-SESSION.md) | Checklist para iniciar cada sessão | ⭐⭐⭐ Essencial |
| [iteracoes-desenvolvimento.md](iteracoes-desenvolvimento.md) | Metodologia de iterações incrementais | ⭐⭐ Alta |
| [flows-principais.md](flows-principais.md) | Descrição detalhada dos flows | ⭐⭐ Alta |
| [ESTADO-ATUAL.md](ESTADO-ATUAL.md) | Estado atual do projeto | ⭐⭐ Alta |

### 📝 Criar e Editar Flows
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [criar-flows-export-edit-import.md](criar-flows-export-edit-import.md) | Método Export-Edit-Import (Recomendado) | ⭐⭐⭐ Essencial |
| [flow-template-basico.md](flow-template-basico.md) | Template JSON de flow básico | ⭐⭐ Alta |
| [flow-actions-reference.md](flow-actions-reference.md) | Referência de ações comuns | ⭐ Útil |

### 📋 Forms e SharePoint
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [forms-sharepoint-mapping.md](forms-sharepoint-mapping.md) | Mapear campos Forms → SharePoint | ⭐⭐⭐ Essencial |
| [forms-question-ids.md](forms-question-ids.md) | IDs das questões do Forms (preencher) | ⭐⭐ Referência |
| [forms-prefill-url.md](forms-prefill-url.md) | Criar URLs com pre-fill | ⭐⭐ Alta |
| [sharepoint-list-structure.md](sharepoint-list-structure.md) | Estrutura da lista SharePoint | ⭐⭐ Referência |
| [sharepoint-helpers-guide.md](sharepoint-helpers-guide.md) | Scripts helper para SharePoint | ⭐ Útil |

### 🔐 Segurança e Autenticação
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [AUTH-METHODS.md](AUTH-METHODS.md) | Métodos validados (App Reg, Delegada) | ⭐⭐⭐ Essencial |
| [security-best-practices.md](security-best-practices.md) | Boas práticas de segurança | ⭐⭐ Alta |

### 🔍 Testes e Validação
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [testing-guide.md](testing-guide.md) | Guia de testes | ⭐⭐ Alta |
| [validacao-end-to-end.md](validacao-end-to-end.md) | Teste completo do fluxo | ⭐⭐ Alta |

### 🆘 Troubleshooting
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [troubleshooting.md](troubleshooting.md) | Problemas comuns e soluções | ⭐⭐⭐ Essencial |
| [error-handling.md](error-handling.md) | Tratamento de erros nos flows | ⭐ Útil |

### 📚 Referência Técnica
| Documento | Descrição | Prioridade |
|-----------|-----------|-----------|
| [power-automate-connectors.md](power-automate-connectors.md) | Connectors disponíveis | Referência |
| [sharepoint-rest-api.md](sharepoint-rest-api.md) | REST API SharePoint | Referência |
| [graph-api-reference.md](graph-api-reference.md) | Microsoft Graph API | Referência |

---

## 📂 Scripts Principais

Ver [../scripts/README.md](../scripts/README.md) para lista completa e exemplos.

### Essenciais
- `ConfigHelper.psm1` - Módulo de autenticação SharePoint/Graph API
- `SharePointListHelper.psm1` - Helpers para SharePoint
- `Export-ProductionFlows.ps1` - Exportar flows de produção
- `Import-FlowDefinitionToProduction.ps1` - Atualizar flows
- `Test-SharePointConnection.ps1` - Testar conectividade SharePoint
- `Test-PowerAutomateConnection.ps1` - Testar conectividade Power Automate
- `Save-ClientSecret.ps1` - Guardar Client Secret seguro

### Auxiliares
- Scripts específicos do projeto conforme necessário

---

## 🗂️ Estrutura de Pastas

```
📦 [Nome do Projeto]
├── README.md                        # Quick start e overview
├── config/
│   ├── client-secret.encrypted      # Credenciais (NUNCA commit!)
│   └── settings.json                # Configurações do projeto
├── docs/                            # 📚 ESTA PASTA
│   ├── INDEX.md                     # Este ficheiro
│   ├── SETUP-INICIAL.md             # Setup do projeto
│   ├── AUTH-METHODS.md              # Autenticação
│   ├── START-NEXT-SESSION.md        # Checklist sessões
│   ├── criar-flows-export-edit-import.md
│   ├── iteracoes-desenvolvimento.md
│   ├── flows-principais.md
│   ├── forms-sharepoint-mapping.md
│   ├── forms-question-ids.md
│   ├── troubleshooting.md
│   └── archive/                     # Histórico
├── scripts/
│   ├── README.md
│   ├── ConfigHelper.psm1
│   ├── SharePointListHelper.psm1
│   └── [outros scripts]
├── solution-exports/                # Backups
└── solutions/                       # Power Platform
```

---

## 🔄 Workflow Típico de Desenvolvimento

### Sessão de Trabalho Típica

1. **Início** ([START-NEXT-SESSION.md](START-NEXT-SESSION.md))
   - Verificar auth
   - Ler estado atual
   - Planear trabalho

2. **Desenvolvimento**
   - Seguir metodologia de iterações
   - Criar/editar flows
   - Testar incrementalmente

3. **Validação**
   - Testes unitários
   - Testes integração
   - Documentar resultados

4. **Documentação**
   - Atualizar docs relevantes
   - Registar decisões
   - Arquivar obsoletos

5. **Encerramento**
   - Commit Git
   - Atualizar ESTADO-ATUAL
   - Exportar backup

### Desenvolvimento de Nova Iteração

1. **Planeamento**
   - Criar doc: `ITERACAO-[N]-[NOME].md`
   - Definir objetivo claro
   - Listar ações necessárias

2. **Implementação**
   - Seguir [criar-flows-export-edit-import.md](criar-flows-export-edit-import.md)
   - Desenvolver incrementalmente
   - Testar frequentemente

3. **Deploy**
   - Import para produção
   - Verificar flow ativo
   - Monitorizar execuções

4. **Documentação**
   - Atualizar [ESTADO-ATUAL.md](ESTADO-ATUAL.md)
   - Atualizar [flows-principais.md](flows-principais.md)
   - Atualizar README.md

---

## 📊 Estado da Documentação

### Documentos Essenciais Completos
- [x] INDEX.md (este ficheiro)
- [x] SETUP-INICIAL.md
- [x] AUTH-METHODS.md
- [x] START-NEXT-SESSION.md
- [x] criar-flows-export-edit-import.md
- [ ] iteracoes-desenvolvimento.md - ⚠️ A completar
- [ ] forms-sharepoint-mapping.md - ⚠️ A completar
- [ ] flows-principais.md - ⚠️ A preencher com flows reais
- [ ] troubleshooting.md - ⚠️ A expandir conforme surgem problemas

### Documentos a Criar Conforme Necessário
- [ ] ITERACAO-1-[NOME].md - Criar quando planear iteração 1
- [ ] ITERACAO-2-[NOME].md - Criar quando planear iteração 2
- [ ] [outros específicos do projeto]

---

## 🔍 Como Encontrar Informação

### "Preciso configurar o projeto do zero"
→ [SETUP-INICIAL.md](SETUP-INICIAL.md)

### "Como me autentico?"
→ [AUTH-METHODS.md](AUTH-METHODS.md)

### "Vou começar uma sessão de trabalho"
→ [START-NEXT-SESSION.md](START-NEXT-SESSION.md)

### "Preciso criar um novo flow"
→ [criar-flows-export-edit-import.md](criar-flows-export-edit-import.md)

### "Como mapear campos do Forms?"
→ [forms-sharepoint-mapping.md](forms-sharepoint-mapping.md)

### "Tenho um erro..."
→ [troubleshooting.md](troubleshooting.md)

### "Que scripts posso usar?"
→ [../scripts/README.md](../scripts/README.md)

### "Qual é o estado atual?"
→ [ESTADO-ATUAL.md](ESTADO-ATUAL.md)

---

## 📞 Manutenção desta Documentação

### Quando Atualizar

- **Após cada iteração:** Criar/atualizar ITERACAO-[N].md
- **Após mudanças grandes:** Atualizar flows-principais.md
- **Quando surgem problemas:** Adicionar a troubleshooting.md
- **Regularmente:** Atualizar ESTADO-ATUAL.md
- **Ao arquivar:** Mover para archive/ e referenciar

### Princípios

1. **Uma fonte de verdade:** Evitar duplicação
2. **Links internos:** Usar links relativos entre docs
3. **Histórico preservado:** Arquivar, não apagar
4. **Sempre atualizar INDEX:** Este ficheiro é o mapa

---

**Última revisão:** [Data]  
**Próxima revisão:** [Data + 1 mês]
