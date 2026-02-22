<#
.SYNOPSIS
    Importa contactos do ficheiro Excel para a lista SharePoint.

.DESCRIPTION
    Lê o ficheiro "Proposta Contactos Formulario Avaliação Valor e Parceria.xlsx"
    e cria itens na lista SharePoint com os dados.

.NOTES
    Projeto: Inquérito Satisfação Cliente
    Data: 22/02/2026
    Mapeamento:
    - NOME → Title (campo nativo SharePoint)
    - EMAIL → EmailContacto
    - FUNÇÃO → Funcao
    - INSTITUIÇÃO → Entidade
#>

Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force
Import-Module ImportExcel

Write-Host "`n📥 Importar Contactos do Excel para SharePoint" -ForegroundColor Cyan
Write-Host "=" * 70

# Carregar configurações
$settings = Get-ProjectSettings
$clientSecret = Get-SavedClientSecret
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
    "Content-Type"  = "application/json; charset=utf-8"
}

$site = Invoke-RestMethod -Uri $siteApiUrl -Headers $headers -Method GET
$listId = $settings.sharepoint.listId

Write-Host "Site: $($site.displayName)" -ForegroundColor Cyan
Write-Host "Lista: $($settings.sharepoint.listName)" -ForegroundColor Cyan
Write-Host "List ID: $listId" -ForegroundColor Cyan

# Ler dados do Excel
$excelFile = "$PSScriptRoot\..\docs\Proposta Contactos Formulario Avaliação Valor e Parceria.xlsx"

if (-not (Test-Path $excelFile)) {
    Write-Host "`n✗ Ficheiro Excel não encontrado: $excelFile" -ForegroundColor Red
    exit 1
}

Write-Host "`n📖 A ler ficheiro Excel..." -ForegroundColor Yellow
$contactos = Import-Excel $excelFile

Write-Host "  ✓ $($contactos.Count) contactos encontrados" -ForegroundColor Green

# Limpar emails (remover nome se presente)
function Clean-Email {
    param([string]$email)
    
    if ([string]::IsNullOrWhiteSpace($email)) {
        return ""
    }
    
    # Se tem < e >, extrair só o email
    if ($email -match '<(.+?)>') {
        return $matches[1].Trim()
    }
    
    return $email.Trim()
}

# Importar para SharePoint
Write-Host "`n📤 A importar para SharePoint..." -ForegroundColor Yellow

$createItemUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/items"
$importados = 0
$erros = 0
$ignorados = 0

foreach ($contacto in $contactos) {
    $nome = $contacto.NOME
    $email = Clean-Email $contacto.EMAIL
    $funcao = $contacto.FUNÇÃO
    $entidade = $contacto.INSTITUIÇÃO
    
    # Validar campos obrigatórios
    if ([string]::IsNullOrWhiteSpace($nome)) {
        Write-Host "  ⚠ Linha ignorada (sem nome)" -ForegroundColor Yellow
        $ignorados++
        continue
    }
    
    try {
        # Preparar item - campos vazios ficam NULL
        # Title é o campo nativo do SharePoint para o nome
        $itemFields = @{
            Title = $nome
        }
        
        # Adicionar campos opcionais apenas se tiverem valor
        if (-not [string]::IsNullOrWhiteSpace($email)) {
            $itemFields.EmailContacto = $email
        }
        if (-not [string]::IsNullOrWhiteSpace($funcao)) {
            $itemFields.Funcao = $funcao
        }
        if (-not [string]::IsNullOrWhiteSpace($entidade)) {
            $itemFields.Entidade = $entidade
        }
        
        $itemBody = @{
            fields = $itemFields
        } | ConvertTo-Json -Depth 10
        
        $result = Invoke-RestMethod `
            -Uri $createItemUrl `
            -Headers $headers `
            -Method POST `
            -Body $itemBody
        
        Write-Host "  ✓ $nome" -ForegroundColor Green
        $importados++
        
        # Pequeno delay para não sobrecarregar a API
        Start-Sleep -Milliseconds 200
    }
    catch {
        Write-Host "  ✗ $nome : $($_.Exception.Message)" -ForegroundColor Red
        $erros++
    }
}

# Resumo
Write-Host "`n" + "=" * 70
Write-Host "✅ IMPORTAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "=" * 70

Write-Host "`n📊 Resumo:" -ForegroundColor Cyan
Write-Host "  Total de contactos: $($contactos.Count)" -ForegroundColor White
Write-Host "  Importados com sucesso: $importados" -ForegroundColor Green
Write-Host "  Ignorados (vazios): $ignorados" -ForegroundColor Yellow
Write-Host "  Erros: $erros" -ForegroundColor $(if ($erros -gt 0) { "Red" } else { "Green" })

Write-Host "`n🔗 Ver lista:" -ForegroundColor Yellow
Write-Host "  $($settings.sharepoint.siteUrl)/Lists/$($settings.sharepoint.listName -replace ' ','%20')" -ForegroundColor Cyan

Write-Host ""
