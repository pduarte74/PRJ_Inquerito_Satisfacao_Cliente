<#
.SYNOPSIS
    Adiciona campos de controlo de estado e workflow à lista SharePoint.

.DESCRIPTION
    Adiciona campos para controlar o ciclo de vida do inquérito:
    - Estado (Pendente/Enviado/Respondido/Expirado)
    - Datas de envio e resposta
    - Controlo de reminders
    - Prazo de resposta

.NOTES
    Projeto: Inquérito Satisfação Cliente
    Data: 22/02/2026
#>

Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

Write-Host "`n📊 Adicionar Campos de Controlo de Workflow" -ForegroundColor Cyan
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

# Campos de controlo de workflow
$workflowFields = @(
    @{
        name = "EstadoInquerito"
        displayName = "Estado do Inquérito"
        indexed = $false
        choice = @{
            allowTextEntry = $false
            displayAs = "dropDownMenu"
            choices = @(
                "Pendente",
                "Email Enviado",
                "Respondido",
                "Expirado",
                "Cancelado"
            )
        }
    },
    @{
        name = "DataEnvioInicial"
        displayName = "Data Envio Inicial"
        indexed = $false
        dateTime = @{
            displayAs = "default"
            format = "dateTime"
        }
    },
    @{
        name = "DataResposta"
        displayName = "Data da Resposta"
        indexed = $false
        dateTime = @{
            displayAs = "default"
            format = "dateTime"
        }
    },
    @{
        name = "PrazoResposta"
        displayName = "Prazo de Resposta"
        indexed = $false
        dateTime = @{
            displayAs = "default"
            format = "dateOnly"
        }
    },
    @{
        name = "DataUltimoReminder"
        displayName = "Data Último Reminder"
        indexed = $false
        dateTime = @{
            displayAs = "default"
            format = "dateTime"
        }
    },
    @{
        name = "NumeroReminders"
        displayName = "Número de Reminders"
        indexed = $false
        number = @{
            decimalPlaces = "none"
            displayAs = "number"
        }
    },
    @{
        name = "LinkFormularioPrefill"
        displayName = "Link Formulário (Pré-preenchido)"
        indexed = $false
        text = @{
            allowMultipleLines = $false
            textType = "plain"
        }
    },
    @{
        name = "ResponseId"
        displayName = "Response ID (Forms)"
        indexed = $false
        text = @{
            allowMultipleLines = $false
            textType = "plain"
        }
    }
)

Write-Host "`nA adicionar campos de workflow..." -ForegroundColor Yellow

$createdCount = 0
$skippedCount = 0

foreach ($field in $workflowFields) {
    try {
        $fieldJson = $field | ConvertTo-Json -Depth 10
        $createFieldUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/columns"
        
        $result = Invoke-RestMethod -Uri $createFieldUrl -Headers $headers -Method POST -Body $fieldJson
        Write-Host "  ✓ $($field.displayName)" -ForegroundColor Green
        $createdCount++
        Start-Sleep -Milliseconds 300
    }
    catch {
        $errorMsg = $_.ErrorDetails.Message
        if ($errorMsg -like "*already exists*" -or $errorMsg -like "*itemAlreadyExists*") {
            Write-Host "  ⚠ $($field.displayName) (já existe)" -ForegroundColor Yellow
            $skippedCount++
        }
        else {
            Write-Host "  ✗ $($field.displayName): $errorMsg" -ForegroundColor Red
        }
    }
}

Write-Host "`n" + "=" * 70
Write-Host "✅ Campos de Workflow Adicionados!" -ForegroundColor Green
Write-Host "=" * 70
Write-Host "  Campos criados: $createdCount" -ForegroundColor Green
Write-Host "  Campos já existentes: $skippedCount" -ForegroundColor Yellow

Write-Host "`n📋 Total de campos na lista: 25" -ForegroundColor Cyan
Write-Host ""
