<#
.SYNOPSIS
    Adiciona os campos "Função" e "Entidade" à lista SharePoint.

.NOTES
    Projeto: Inquérito Satisfação Cliente
    Data: 22/02/2026
#>

Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

Write-Host "`n📊 Adicionar Campos: Função e Entidade" -ForegroundColor Cyan
Write-Host "=" * 70

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

Write-Host "Site: $($site.displayName)" -ForegroundColor Cyan
Write-Host "Lista ID: $listId" -ForegroundColor Cyan

# Novos campos
$newFields = @(
    @{
        name = "Funcao"
        displayName = "Função"
        enforceUniqueValues = $false
        hidden = $false
        indexed = $false
        text = @{
            allowMultipleLines = $false
            textType = "plain"
        }
    },
    @{
        name = "Entidade"
        displayName = "Entidade"
        enforceUniqueValues = $false
        hidden = $false
        indexed = $false
        text = @{
            allowMultipleLines = $false
            textType = "plain"
        }
    }
)

Write-Host "`nA adicionar campos..." -ForegroundColor Yellow

foreach ($field in $newFields) {
    try {
        $fieldJson = $field | ConvertTo-Json -Depth 10
        $createFieldUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/columns"
        
        $result = Invoke-RestMethod -Uri $createFieldUrl -Headers $headers -Method POST -Body $fieldJson
        Write-Host "  ✓ $($field.displayName)" -ForegroundColor Green
        Start-Sleep -Milliseconds 300
    }
    catch {
        $errorMsg = $_.ErrorDetails.Message
        if ($errorMsg -like "*already exists*" -or $errorMsg -like "*itemAlreadyExists*") {
            Write-Host "  ⚠ $($field.displayName) (já existe)" -ForegroundColor Yellow
        }
        else {
            Write-Host "  ✗ $($field.displayName): $errorMsg" -ForegroundColor Red
        }
    }
}

Write-Host "`n✅ Campos adicionados!" -ForegroundColor Green
Write-Host "=" * 70
Write-Host ""
