<#
.SYNOPSIS
    Migra dados do campo customizado IdentificacaoNome para o campo nativo Title.

.DESCRIPTION
    Este script copia os valores de IdentificacaoNome para o campo Title (nativo do SharePoint)
    para todos os itens existentes na lista. Após esta migração, o campo IdentificacaoNome
    pode ser removido da lista.

.NOTES
    Projeto: Inquérito Satisfação Cliente
    Data: 22/02/2026
    Motivo: Usar campo nativo Title ao invés de campo customizado
#>

Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

Write-Host "`n🔄 Migração: IdentificacaoNome → Title" -ForegroundColor Cyan
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

# Obter todos os itens da lista
Write-Host "`n📋 A obter itens da lista..." -ForegroundColor Yellow

$getItemsUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/items?expand=fields"
$items = Invoke-RestMethod -Uri $getItemsUrl -Headers $headers -Method GET

Write-Host "  ✓ $($items.value.Count) itens encontrados" -ForegroundColor Green

if ($items.value.Count -eq 0) {
    Write-Host "`n⚠ Nenhum item para migrar" -ForegroundColor Yellow
    exit 0
}

# Migrar cada item
Write-Host "`n🔄 A migrar dados..." -ForegroundColor Yellow

$migrados = 0
$erros = 0
$semNome = 0

foreach ($item in $items.value) {
    $itemId = $item.id
    $nomeAtual = $item.fields.IdentificacaoNome
    $titleAtual = $item.fields.Title
    
    # Se IdentificacaoNome está vazio, ignorar
    if ([string]::IsNullOrWhiteSpace($nomeAtual)) {
        Write-Host "  ⚠ Item $itemId - sem nome em IdentificacaoNome" -ForegroundColor Yellow
        $semNome++
        continue
    }
    
    # Se Title já tem valor e é igual, não precisa atualizar
    if ($titleAtual -eq $nomeAtual) {
        Write-Host "  → Item $itemId - já migrado ($nomeAtual)" -ForegroundColor Gray
        $migrados++
        continue
    }
    
    try {
        # Atualizar Title
        $updateUrl = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$listId/items/$itemId"
        
        $updateBody = @{
            fields = @{
                Title = $nomeAtual
            }
        } | ConvertTo-Json -Depth 10
        
        $result = Invoke-RestMethod `
            -Uri $updateUrl `
            -Headers $headers `
            -Method PATCH `
            -Body $updateBody
        
        Write-Host "  ✓ Item $itemId - $nomeAtual" -ForegroundColor Green
        $migrados++
        
        Start-Sleep -Milliseconds 200
    }
    catch {
        Write-Host "  ✗ Item $itemId - ERRO: $($_.Exception.Message)" -ForegroundColor Red
        $erros++
    }
}

# Resumo
Write-Host "`n" + "=" * 70
Write-Host "✅ MIGRAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "=" * 70

Write-Host "`n📊 Resumo:" -ForegroundColor Cyan
Write-Host "  Total de itens: $($items.value.Count)" -ForegroundColor White
Write-Host "  Migrados com sucesso: $migrados" -ForegroundColor Green
Write-Host "  Sem nome (ignorados): $semNome" -ForegroundColor Yellow
Write-Host "  Erros: $erros" -ForegroundColor $(if ($erros -gt 0) { "Red" } else { "Green" })

if ($migrados -gt 0) {
    Write-Host "`n✅ Próximo passo: Remover o campo 'IdentificacaoNome' da lista" -ForegroundColor Cyan
    Write-Host "   (pode ser feito manualmente no SharePoint ou via script)" -ForegroundColor Gray
}
