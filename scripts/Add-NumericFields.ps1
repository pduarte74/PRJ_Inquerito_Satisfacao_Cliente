<#
.SYNOPSIS
    Adiciona campos numéricos à lista SharePoint.

.NOTES
    Campos numéricos para avaliações (1-5).
#>

Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

$listId = "af4ef457-b004-4838-b917-8720346b9a8f"
$settings = Get-ProjectSettings
$clientSecret = Get-SavedClientSecret
$token = Get-GraphApiToken -ClientId $settings.azure.clientId -ClientSecret $clientSecret -TenantId $settings.azure.tenantId

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

Write-Host "`n📊 Adicionar Campos Numéricos" -ForegroundColor Cyan

# Campos numéricos com formato simplificado
$numericFields = @(
    @{ name = "AvaliacaoServicoIntegrado"; displayName = "Avaliação Serviço Integrado" },
    @{ name = "AvaliacaoCertificacoes"; displayName = "Avaliação Certificações" },
    @{ name = "AvaliacaoExperiencia"; displayName = "Avaliação Experiência ProdOut" },
    @{ name = "AvaliacaoCompreensaoNecessidades"; displayName = "Compreensão das Necessidades" },
    @{ name = "AvaliacaoRapidezEficacia"; displayName = "Rapidez e Eficácia" },
    @{ name = "AvaliacaoEntrega"; displayName = "Confiança no Processo de Entrega" },
    @{ name = "AvaliacaoAcondicionamento"; displayName = "Acondicionamento e Rotulagem" },
    @{ name = "AvaliacaoImprevistos"; displayName = "Resolução de Imprevistos" }
)

foreach ($field in $numericFields) {
    try {
        $fieldDef = @{
            name = $field.name
            displayName = $field.displayName
            enforceUniqueValues = $false
            hidden = $false
            indexed = $false
            number = @{
                decimalPlaces = "none"
                displayAs = "number"
            }
        }
        
        $fieldJson = $fieldDef | ConvertTo-Json -Depth 10
        $createFieldUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/columns"
        
        $result = Invoke-RestMethod -Uri $createFieldUrl -Headers $headers -Method POST -Body $fieldJson
        Write-Host "  ✓ $($field.displayName)" -ForegroundColor Green
        Start-Sleep -Milliseconds 300
    }
    catch {
        $errorMsg = $_.ErrorDetails.Message
        Write-Host "  ✗ $($field.displayName): $errorMsg" -ForegroundColor Red
    }
}

Write-Host "`n✅ Concluído!" -ForegroundColor Green
