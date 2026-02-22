<#
.SYNOPSIS
    Adiciona campos personalizados à lista SharePoint usando SharePoint REST API.

.DESCRIPTION
    Script para adicionar campos à lista existente usando SchemaXml.

.NOTES
    Projeto: Inquérito Satisfação Cliente
    Data: 22/02/2026
#>

# Carregar módulo helper
Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

Write-Host "`n📊 Adicionar Campos à Lista SharePoint" -ForegroundColor Cyan
Write-Host "=" * 70

# List ID da lista criada
$listId = "af4ef457-b004-4838-b917-8720346b9a8f"

# Carregar configurações
$settings = Get-ProjectSettings
$clientSecret = Get-SavedClientSecret

# Obter token
$token = Get-GraphApiToken `
    -ClientId $settings.azure.clientId `
    -ClientSecret $clientSecret `
    -TenantId $settings.azure.tenantId

# Obter Site ID
$siteUrl = $settings.sharepoint.siteUrl
$uri = [System.Uri]$siteUrl
$hostname = $uri.Host
$sitePath = $uri.AbsolutePath
$siteApiUrl = "https://graph.microsoft.com/v1.0/sites/${hostname}:${sitePath}"

$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type"  = "application/json"
}

$site = Invoke-RestMethod -Uri $siteApiUrl -Headers $headers -Method GET

Write-Host "`nSite: $($site.displayName)" -ForegroundColor Cyan
Write-Host "Lista ID: $listId" -ForegroundColor Cyan

# Definir campos usando o formato correto do Graph API
# NOTA: O campo "Title" é nativo do SharePoint e não precisa ser criado
$fields = @(
    @{
        name = "EmailContacto"
        displayName = "E-mail de contacto"
        indexed = $false
        text = @{
            allowMultipleLines = $false
            textType = "plain"
        }
    },
    @{
        name = "ConsentimentoRGPD"
        displayName = "Consentimento RGPD"
        indexed = $false
        choice = @{
            allowTextEntry = $false
            displayAs = "dropDownMenu"
            choices = @("Sim, autorizo", "Não autorizo")
        }
    },
    @{
        name = "CaracteristicasAssociadas"
        displayName = "Características associadas à ProdOut"
        indexed = $false
        text = @{
            allowMultipleLines = $true
            textType = "plain"
        }
    },
    @{
        name = "AvaliacaoServicoIntegrado"
        displayName = "Avaliação Serviço Integrado"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "AvaliacaoCertificacoes"
        displayName = "Avaliação Certificações"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "AvaliacaoExperiencia"
        displayName = "Avaliação Experiência ProdOut"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "AvaliacaoCompreensaoNecessidades"
        displayName = "Compreensão das Necessidades"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "AvaliacaoRapidezEficacia"
        displayName = "Rapidez e Eficácia"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "AvaliacaoEntrega"
        displayName = "Confiança no Processo de Entrega"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "AvaliacaoAcondicionamento"
        displayName = "Acondicionamento e Rotulagem"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "AvaliacaoImprevistos"
        displayName = "Resolução de Imprevistos"
        indexed = $false
        number = @{
            displayAs = "number"
            decimalPlaces = 0
        }
    },
    @{
        name = "SugestoesServicosProdutos"
        displayName = "Sugestões de Serviços/Produtos"
        indexed = $false
        text = @{
            allowMultipleLines = $true
            textType = "plain"
        }
    },
    @{
        name = "SugestoesDesafios"
        displayName = "Desafios a Fazer Acontecer"
        indexed = $false
        text = @{
            allowMultipleLines = $true
            textType = "plain"
        }
    },
    @{
        name = "RecomendariaProdOut"
        displayName = "Recomendaria a ProdOut"
        indexed = $false
        choice = @{
            allowTextEntry = $false
            displayAs = "dropDownMenu"
            choices = @("Sim", "Não")
        }
    }
)

$createdCount = 0
$errorCount = 0

Write-Host "`nA adicionar campos..." -ForegroundColor Yellow

foreach ($field in $fields) {
    try {
        $fieldJson = $field | ConvertTo-Json -Depth 10
        $createFieldUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/columns"
        
        $result = Invoke-RestMethod -Uri $createFieldUrl -Headers $headers -Method POST -Body $fieldJson
        Write-Host "  ✓ $($field.displayName)" -ForegroundColor Green
        $createdCount++
        
        Start-Sleep -Milliseconds 200  # Pequeno delay entre requests
    }
    catch {
        $errorMsg = $_.ErrorDetails.Message
        if ($errorMsg -like "*already exists*" -or $errorMsg -like "*itemAlreadyExists*") {
            Write-Host "  ⚠ $($field.displayName) (já existe)" -ForegroundColor Yellow
        }
        else {
            Write-Host "  ✗ $($field.displayName)" -ForegroundColor Red
            Write-Host "    Erro: $errorMsg" -ForegroundColor Gray
            $errorCount++
        }
    }
}

Write-Host "`n" + "=" * 70
Write-Host "✅ CAMPOS ADICIONADOS!" -ForegroundColor Green
Write-Host "=" * 70
Write-Host "  Campos criados: $createdCount" -ForegroundColor Green
Write-Host "  Erros: $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
Write-Host ""
