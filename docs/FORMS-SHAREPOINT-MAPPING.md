# Mapeamento Forms → SharePoint

**Projeto:** Inquérito Satisfação Cliente  
**Data de criação:** 22/02/2026  
**Última atualização:** 22/02/2026

---

## 📋 Nota Importante

> **Como os Question IDs foram obtidos:**  
> Os Question IDs do Microsoft Forms foram extraídos através da análise do código HTML do formulário com a ajuda do **Copilot integrado no Microsoft Edge**. Esta abordagem permite identificar rapidamente os identificadores únicos de cada pergunta sem necessidade de APIs ou ferramentas externas.

---

## 🔗 Informações do Formulário

- **Form ID:** `8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu`
- **URL Edição:** https://forms.office.com/Pages/DesignPageV2.aspx?origin=NeoPortalPage&subpage=design&id=8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu
- **URL Respostas:** https://forms.office.com/pages/responsepage.aspx?id=8geWAb3LXkKnsbyNDZej5D2DIYsnsUZNh2DUOrRLJdtURFFMQzBBVFNXTU9OVEZGWlExT1dYMDE5NiQlQCN0PWcu

---

## 📊 Lista SharePoint

- **Nome:** Recolha de Repostas Inquerito de Satisfação de Clientes
- **Site:** https://prodoutlda.sharepoint.com/sites/SistemadeGesto-Qualidade
- **List ID:** `af4ef457-b004-4838-b917-8720346b9a8f`

---

## 🗂️ Mapeamento Completo de Campos

### Campos de Identificação

| Pergunta Forms | Question ID | Campo SharePoint | Tipo |
|----------------|-------------|------------------|------|
| Identificação (nome) | `r4a23b53b26c94fceb200c0bb59ca92d9` | `Title` | Text (campo nativo) |
| E-mail de contacto | `r8b587c7f31b742e49de890182dea1cd3` | `EmailContacto` | Text |
| *(Novo)* Função | - | `Funcao` | Text |
| *(Novo)* Entidade | - | `Entidade` | Text |

### Consentimento

| Pergunta Forms | Question ID | Campo SharePoint | Tipo |
|----------------|-------------|------------------|------|
| Autoriza a recolha dos seus dados pessoais... (RGPD) | `r24b7ca0112ff46bead81029713fb5bfd` | `ConsentimentoRGPD` | Choice |

### Características ProdOut

| Pergunta Forms | Question ID | Campo SharePoint | Tipo |
|----------------|-------------|------------------|------|
| Quais são as principais características que associa à ProdOut? | `r49023c5e94b84b9fb6862866040e63ff` | `CaracteristicasAssociadas` | Text (Multi-line) |

### Avaliações (Escala 1-5)

| Pergunta Forms | Question ID | Campo SharePoint | Tipo |
|----------------|-------------|------------------|------|
| Globalmente, como avalia o serviço integrado da ProdOut? | `rab082016ed6f461d9655985e3f347a69` | `AvaliacaoServicoIntegrado` | Number |
| Em que medida as certificações da ProdOut reforçam a sua confiança? | `r494fba066e7948b3b4a0c62ccc9a41ae` | `AvaliacaoCertificacoes` | Number |
| Como avalia a sua experiência com a ProdOut? | `r3b643678d69a46a58114833fa2271186` | `AvaliacaoExperiencia` | Number |
| Em que medida a nossa equipa compreende as suas necessidades? | `r20ef8fbddee94c88a3cc757505108590` | `AvaliacaoCompreensaoNecessidades` | Number |
| Como avalia a rapidez e eficácia com que respondemos? | `r0b77678891fe41deac327c2b2d1f8d39` | `AvaliacaoRapidezEficacia` | Number |
| Sente confiança no nosso processo de entrega dos produtos? | `r161d9c17a18349e58e20a393063d4e9a` | `AvaliacaoEntrega` | Number |
| O nosso acondicionamento e rotulagem transmite segurança? | `r02e92986e4fc45a6adba1a7e8766b61a` | `AvaliacaoAcondicionamento` | Number |
| Como avalia a nossa capacidade de resolução de imprevistos? | `r8b5bea33cf64459e8217765670854bf7` | `AvaliacaoImprevistos` | Number |

### Sugestões e Feedback

| Pergunta Forms | Question ID | Campo SharePoint | Tipo |
|----------------|-------------|------------------|------|
| Que outros serviços/produtos poderemos desenvolver? | `r9335116c94fe45c6ab74186ea814ce32` | `SugestoesServicosProdutos` | Text (Multi-line) |
| Que outros desafios a ProdOut poderá ajudar a fazer acontecer? | `rfa2eb4d4a1be4a9bb2c1d3668012f8ee` | `SugestoesDesafios` | Text (Multi-line) |

### Recomendação

| Pergunta Forms | Question ID | Campo SharePoint | Tipo |
|----------------|-------------|------------------|------|
| Recomendaria a ProdOut a outras empresas? | `rf5943b498a1241019699e87a12346f46` | `RecomendariaProdOut` | Choice |

---

## 📝 Código para Power Automate

### Dynamic Content Mapping

Quando criar o flow no Power Automate, use estas expressões para mapear os campos:

```javascript
// Campos de Texto
IdentificacaoNome: body('Get_response_details')?['r4a23b53b26c94fceb200c0bb59ca92d9']
EmailContacto: body('Get_response_details')?['r8b587c7f31b742e49de890182dea1cd3']
CaracteristicasAssociadas: body('Get_response_details')?['r49023c5e94b84b9fb6862866040e63ff']
SugestoesServicosProdutos: body('Get_response_details')?['r9335116c94fe45c6ab74186ea814ce32']
SugestoesDesafios: body('Get_response_details')?['rfa2eb4d4a1be4a9bb2c1d3668012f8ee']

// Campos de Escolha
ConsentimentoRGPD: body('Get_response_details')?['r24b7ca0112ff46bead81029713fb5bfd']
RecomendariaProdOut: body('Get_response_details')?['rf5943b498a1241019699e87a12346f46']

// Campos Numéricos (Avaliações)
AvaliacaoServicoIntegrado: body('Get_response_details')?['rab082016ed6f461d9655985e3f347a69']
AvaliacaoCertificacoes: body('Get_response_details')?['r494fba066e7948b3b4a0c62ccc9a41ae']
AvaliacaoExperiencia: body('Get_response_details')?['r3b643678d69a46a58114833fa2271186']
AvaliacaoCompreensaoNecessidades: body('Get_response_details')?['r20ef8fbddee94c88a3cc757505108590']
AvaliacaoRapidezEficacia: body('Get_response_details')?['r0b77678891fe41deac327c2b2d1f8d39']
AvaliacaoEntrega: body('Get_response_details')?['r161d9c17a18349e58e20a393063d4e9a']
AvaliacaoAcondicionamento: body('Get_response_details')?['r02e92986e4fc45a6adba1a7e8766b61a']
AvaliacaoImprevistos: body('Get_response_details')?['r8b5bea33cf64459e8217765670854bf7']
```

---

## 📦 Dados Importados

### Contactos (22/02/2026)

- **Fonte:** `docs/Proposta Contactos Formulario Avaliação Valor e Parceria.xlsx`
- **Total importado:** 78 contactos
- **Campos mapeados:**
  - NOME → IdentificacaoNome
  - EMAIL → EmailContacto
  - FUNÇÃO → Funcao
  - INSTITUIÇÃO → Entidade

**Script usado:** `scripts/Import-ContactosFromExcel.ps1`

---

## ✅ Validação

### Checklist de Validação

- [x] Todos os Question IDs validados
- [x] 17 campos criados no SharePoint
- [x] Tipos de dados corretos
- [x] Mapeamento documentado
- [x] Dados de teste importados (78 contactos)
- [ ] Flow criado e testado
- [ ] Submissão de teste validada

---

## 🔧 Scripts Relacionados

1. **Create-InqueritoSharePointList.ps1** - Cria a lista inicial
2. **Add-SharePointListFields.ps1** - Adiciona campos de texto e choice
3. **Add-NumericFields.ps1** - Adiciona campos numéricos
4. **Add-FuncaoEntidadeFields.ps1** - Adiciona campos Função e Entidade
5. **Import-ContactosFromExcel.ps1** - Importa contactos do Excel

---

## 📚 Referências

- [Microsoft Forms Documentation](https://support.microsoft.com/forms)
- [SharePoint REST API](https://docs.microsoft.com/sharepoint/dev/sp-add-ins/get-to-know-the-sharepoint-rest-service)
- [Power Automate Connectors](https://docs.microsoft.com/connectors/)

---

**Última atualização:** 22/02/2026  
**Autor:** pduarte  
**Versão:** 1.0
