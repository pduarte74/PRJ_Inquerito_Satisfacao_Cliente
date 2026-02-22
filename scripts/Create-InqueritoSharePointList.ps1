<#
.SYNOPSIS
    Cria a lista SharePoint "Recolha de Repostas Inquerito de Satisfação de Clientes" com todos os campos.

.DESCRIPTION
    Script para criar a lista SharePoint e adicionar todos os campos personalizados necessários para o inquérito.

.NOTES
    Projeto: Inquérito Satisfação Cliente
    Data: 22/02/2026
#>

# Carregar módulo helper
Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

Write-Host "`n📊 Criar Lista SharePoint - Inquérito Satisfação Cliente" -ForegroundColor Cyan
Write-Host "=" * 70

# Carregar configurações
Write-Host "`n1️⃣ Carregar configurações..." -ForegroundColor Yellow
$settings = Get-ProjectSettings

if (-not $settings) {
    Write-Host "  ✗ Não foi possível carregar configurações" -ForegroundColor Red
    exit 1
}

Write-Host "  ✓ Configurações carregadas" -ForegroundColor Green
Write-Host "    Tenant: $($settings.azure.tenantId)" -ForegroundColor Gray
Write-Host "    Site: $($settings.sharepoint.siteUrl)" -ForegroundColor Gray

# Carregar Client Secret
Write-Host "`n2️⃣ Carregar Client Secret..." -ForegroundColor Yellow
$clientSecret = Get-SavedClientSecret

if ([string]::IsNullOrWhiteSpace($clientSecret)) {
    Write-Host "  ✗ Client Secret não disponível" -ForegroundColor Red
    Write-Host "  Execute primeiro: .\scripts\Save-ClientSecret.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "  ✓ Client Secret carregado" -ForegroundColor Green

# Obter token
Write-Host "`n3️⃣ Obter token de acesso..." -ForegroundColor Yellow
try {
    $token = Get-GraphApiToken `
        -ClientId $settings.azure.clientId `
        -ClientSecret $clientSecret `
        -TenantId $settings.azure.tenantId
    
    Write-Host "  ✓ Token obtido com sucesso" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Headers para todas as requests
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

# Obter Site ID
Write-Host "`n4️⃣ Obter Site SharePoint..." -ForegroundColor Yellow
try {
    # Extrair hostname e path do site URL
    $siteUrl = $settings.sharepoint.siteUrl
    $uri = [System.Uri]$siteUrl
    $hostname = $uri.Host
    $sitePath = $uri.AbsolutePath
    
    # Construir URL da API
    $siteApiUrl = "https://graph.microsoft.com/v1.0/sites/${hostname}:${sitePath}"
    
    $site = Invoke-RestMethod -Uri $siteApiUrl -Headers $headers -Method GET
    Write-Host "  ✓ Site encontrado: $($site.displayName)" -ForegroundColor Green
    Write-Host "    Site ID: $($site.id)" -ForegroundColor Gray
}
catch {
    Write-Host "  ✗ Erro ao obter site: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Criar lista
Write-Host "`n5️⃣ Criar lista SharePoint..." -ForegroundColor Yellow

$listPayload = @{
    displayName = $settings.sharepoint.listName
    columns     = @()
    list        = @{
        template = "genericList"
    }
} | ConvertTo-Json -Depth 10

try {
    $createListUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists"
    $list = Invoke-RestMethod -Uri $createListUrl -Headers $headers -Method POST -Body $listPayload
    
    Write-Host "  ✓ Lista criada com sucesso!" -ForegroundColor Green
    Write-Host "    Lista ID: $($list.id)" -ForegroundColor Gray
    Write-Host "    Nome: $($list.displayName)" -ForegroundColor Gray
}
catch {
    $errorDetails = $_.ErrorDetails.Message | ConvertFrom-Json
    if ($errorDetails.error.code -eq "itemAlreadyExists") {
        Write-Host "  ⚠ Lista já existe. A obter lista existente..." -ForegroundColor Yellow
        
        # Obter lista existente
        $getListsUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists?`$filter=displayName eq '$($settings.sharepoint.listName)'"
        $existingLists = Invoke-RestMethod -Uri $getListsUrl -Headers $headers -Method GET
        
        if ($existingLists.value.Count -gt 0) {
            $list = $existingLists.value[0]
            Write-Host "  ✓ Lista existente encontrada" -ForegroundColor Green
            Write-Host "    Lista ID: $($list.id)" -ForegroundColor Gray
        }
        else {
            Write-Host "  ✗ Erro: Lista não encontrada" -ForegroundColor Red
            exit 1
        }
    }
    else {
        Write-Host "  ✗ Erro ao criar lista: $($errorDetails.error.message)" -ForegroundColor Red
        exit 1
    }
}

# Definição de campos personalizados
Write-Host "`n6️⃣ Adicionar campos personalizados..." -ForegroundColor Yellow

$customFields = @(
    @{
        displayName = "Identificação (nome)"
        name        = "IdentificacaoNome"
        type        = "text"
    },
    @{
        displayName = "E-mail de contacto"
        name        = "EmailContacto"
        type        = "text"
    },
    @{
        displayName = "Consentimento RGPD"
        name        = "ConsentimentoRGPD"
        type        = "choice"
        choice      = @{
            allowTextEntry = $false
            choices        = @("Sim, autorizo", "Não autorizo")
        }
    },
    @{
        displayName = "Características associadas à ProdOut"
        name        = "CaracteristicasAssociadas"
        type        = "text"
        text        = @{
            allowMultipleLines = $true
        }
    },
    @{
        displayName = "Avaliação Serviço Integrado"
        name        = "AvaliacaoServicoIntegrado"
        type        = "number"
    },
    @{
        displayName = "Avaliação Certificações"
        name        = "AvaliacaoCertificacoes"
        type        = "number"
    },
    @{
        displayName = "Avaliação Experiência ProdOut"
        name        = "AvaliacaoExperiencia"
        type        = "number"
    },
    @{
        displayName = "Compreensão das Necessidades"
        name        = "AvaliacaoCompreensaoNecessidades"
        type        = "number"
    },
    @{
        displayName = "Rapidez e Eficácia"
        name        = "AvaliacaoRapidezEficacia"
        type        = "number"
    },
    @{
        displayName = "Confiança no Processo de Entrega"
        name        = "AvaliacaoEntrega"
        type        = "number"
    },
    @{
        displayName = "Acondicionamento e Rotulagem"
        name        = "AvaliacaoAcondicionamento"
        type        = "number"
    },
    @{
        displayName = "Resolução de Imprevistos"
        name        = "AvaliacaoImprevistos"
        type        = "number"
    },
    @{
        displayName = "Sugestões de Serviços/Produtos"
        name        = "SugestoesServicosProdutos"
        type        = "text"
        text        = @{
            allowMultipleLines = $true
        }
    },
    @{
        displayName = "Desafios a Fazer Acontecer"
        name        = "SugestoesDesafios"
        type        = "text"
        text        = @{
            allowMultipleLines = $true
        }
    },
    @{
        displayName = "Recomendaria a ProdOut"
        name        = "RecomendariaProdOut"
        type        = "choice"
        choice      = @{
            allowTextEntry = $false
            choices        = @("Sim", "Não")
        }
    }
)

$createdFields = 0
$skippedFields = 0

foreach ($field in $customFields) {
    try {
        $fieldPayload = $field | ConvertTo-Json -Depth 10
        $createFieldUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$($list.id)/columns"
        
        $newField = Invoke-RestMethod -Uri $createFieldUrl -Headers $headers -Method POST -Body $fieldPayload
        Write-Host "  ✓ Campo criado: $($field.displayName)" -ForegroundColor Green
        $createdFields++
    }
    catch {
        $errorDetails = $_.ErrorDetails.Message
        if ($errorDetails -like "*already exists*" -or $errorDetails -like "*itemAlreadyExists*") {
            Write-Host "  ⚠ Campo já existe: $($field.displayName)" -ForegroundColor Yellow
            $skippedFields++
        }
        else {
            Write-Host "  ✗ Erro ao criar campo '$($field.displayName)': $errorDetails" -ForegroundColor Red
        }
    }
}

# Resumo
Write-Host "`n" + "=" * 70
Write-Host "✅ PROCESSO CONCLUÍDO!" -ForegroundColor Green
Write-Host "=" * 70

Write-Host "`n📊 Resumo:" -ForegroundColor Cyan
Write-Host "  Lista: $($list.displayName)" -ForegroundColor White
Write-Host "  Lista ID: $($list.id)" -ForegroundColor White
Write-Host "  Campos criados: $createdFields" -ForegroundColor Green
Write-Host "  Campos já existentes: $skippedFields" -ForegroundColor Yellow
Write-Host "  Site: $($settings.sharepoint.siteUrl)" -ForegroundColor White

Write-Host "`n📝 Próximo passo:" -ForegroundColor Yellow
Write-Host "  Atualize o settings.json com o List ID:" -ForegroundColor Yellow
Write-Host "  `"listId`": `"$($list.id)`"" -ForegroundColor Cyan

Write-Host "`n🔗 Aceder à lista:" -ForegroundColor Yellow
Write-Host "  $($list.webUrl)" -ForegroundColor Cyan

Write-Host ""
