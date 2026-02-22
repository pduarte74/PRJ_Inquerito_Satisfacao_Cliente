<#
.SYNOPSIS
    Remove o campo customizado IdentificacaoNome da lista SharePoint.

.DESCRIPTION
    Após a migração dos dados para o campo nativo Title, este script remove
    o campo customizado IdentificacaoNome que não é mais necessário.

.NOTES
    Projeto: Inquérito Satisfação Cliente
    Data: 22/02/2026
    Motivo: Simplificar estrutura usando campo nativo Title
#>

Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

Write-Host "`n🗑️  Remover Campo Customizado: IdentificacaoNome" -ForegroundColor Cyan
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
    "Content-Type"  = "application/json"
}

$site = Invoke-RestMethod -Uri $siteApiUrl -Headers $headers -Method GET
$listId = $settings.sharepoint.listId

Write-Host "`nSite: $($site.displayName)" -ForegroundColor Cyan
Write-Host "Lista: $($settings.sharepoint.listName)" -ForegroundColor Cyan
Write-Host "List ID: $listId" -ForegroundColor Cyan

# Primeiro, listar as colunas para verificar
Write-Host "`n📋 A verificar colunas existentes..." -ForegroundColor Yellow

$columnsUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/columns"
$columns = Invoke-RestMethod -Uri $columnsUrl -Headers $headers -Method GET

$identificacaoColumn = $columns.value | Where-Object { $_.name -eq "IdentificacaoNome" }

if ($null -eq $identificacaoColumn) {
    Write-Host "`n⚠ Campo 'IdentificacaoNome' não encontrado na lista" -ForegroundColor Yellow
    Write-Host "  Possíveis razões:" -ForegroundColor Gray
    Write-Host "  - Já foi removido anteriormente" -ForegroundColor Gray
    Write-Host "  - Nome do campo está diferente" -ForegroundColor Gray
    
    Write-Host "`n📋 Campos existentes na lista:" -ForegroundColor Cyan
    foreach ($col in $columns.value | Where-Object { -not $_.readOnly } | Select-Object -First 10) {
        Write-Host "  - $($col.name) ($($col.displayName))" -ForegroundColor Gray
    }
    
    exit 0
}

Write-Host "  ✓ Campo 'IdentificacaoNome' encontrado (ID: $($identificacaoColumn.id))" -ForegroundColor Green

# Confirmar remoção
Write-Host "`n⚠️  ATENÇÃO: Esta ação irá remover o campo permanentemente!" -ForegroundColor Yellow
Write-Host "  Os dados do campo 'IdentificacaoNome' serão perdidos." -ForegroundColor Yellow
Write-Host "  (Mas já foram migrados para o campo 'Title')" -ForegroundColor Green

$confirm = Read-Host "`nDeseja continuar? (S/N)"

if ($confirm -notin @('S', 's', 'Sim', 'sim', 'SIM')) {
    Write-Host "`n❌ Operação cancelada pelo utilizador" -ForegroundColor Yellow
    exit 0
}

# Remover o campo
Write-Host "`n🗑️  A remover campo..." -ForegroundColor Yellow

try {
    $deleteUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/columns/$($identificacaoColumn.id)"
    
    Invoke-RestMethod `
        -Uri $deleteUrl `
        -Headers $headers `
        -Method DELETE
    
    Write-Host "`n✅ Campo 'IdentificacaoNome' removido com sucesso!" -ForegroundColor Green
    
    Write-Host "`n📊 Resultado:" -ForegroundColor Cyan
    Write-Host "  Campo removido: IdentificacaoNome" -ForegroundColor White
    Write-Host "  Campo agora usado: Title (nativo SharePoint)" -ForegroundColor Green
    Write-Host "  Total de campos personalizados: 23 (16 dados + 8 workflow)" -ForegroundColor White
    Write-Host "  Total com campos nativos: 24 (Title + 23 customizados)" -ForegroundColor White
}
catch {
    Write-Host "`n✗ ERRO ao remover campo" -ForegroundColor Red
    Write-Host "  Mensagem: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Message -match "locked") {
        Write-Host "`n💡 Dica: O campo pode estar bloqueado." -ForegroundColor Yellow
        Write-Host "  Tente remover manualmente através do SharePoint:" -ForegroundColor Gray
        Write-Host "  1. Abrir lista no SharePoint" -ForegroundColor Gray
        Write-Host "  2. Settings → List Settings" -ForegroundColor Gray
        Write-Host "  3. Columns → IdentificacaoNome → Delete" -ForegroundColor Gray
    }
    
    exit 1
}
