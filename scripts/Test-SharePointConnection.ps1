<#
.SYNOPSIS
    Testa a conexão com SharePoint Lists via Graph API.

.DESCRIPTION
    Valida autenticação e acesso à lista SharePoint configurada.

.NOTES
    Template versão: 1.0
    Requer: ConfigHelper.psm1, config/settings.json

.EXAMPLE
    .\Test-SharePointConnection.ps1
#>

# Carregar módulo helper
Import-Module "$PSScriptRoot\ConfigHelper.psm1" -Force

Write-Host "`n🔗 Testar Conexão SharePoint" -ForegroundColor Cyan
Write-Host "=" * 50

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
Write-Host "    Lista: $($settings.sharepoint.listName)" -ForegroundColor Gray

# Carregar Client Secret
Write-Host "`n2️⃣ Carregar Client Secret..." -ForegroundColor Yellow
$clientSecret = Get-SavedClientSecret

if ([string]::IsNullOrWhiteSpace($clientSecret)) {
    Write-Host "  ✗ Client Secret não disponível" -ForegroundColor Red
    exit 1
}

# Obter token
Write-Host "`n3️⃣ Obter token de acesso..." -ForegroundColor Yellow
try {
    $token = Get-GraphApiToken `
        -ClientId $settings.azure.clientId `
        -ClientSecret $clientSecret `
        -TenantId $settings.azure.tenantId
}
catch {
    Write-Host "  ✗ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Obter site ID
Write-Host "`n4️⃣ Obter site SharePoint..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
    "Content-Type" = "application/json"
}

try {
    $siteUrl = $settings.sharepoint.siteUrl
    $siteHost = $siteUrl.Replace("https://", "").Replace("http://", "")
    $sitePath = "/" + ($siteHost -split "/", 2)[1]
    $siteHost = ($siteHost -split "/")[0]
    
    $siteUri = "https://graph.microsoft.com/v1.0/sites/$($siteHost):$($sitePath)"
    $site = Invoke-RestMethod -Uri $siteUri -Headers $headers -Method GET
    
    Write-Host "  ✓ Site encontrado: $($site.displayName)" -ForegroundColor Green
    Write-Host "    Site ID: $($site.id)" -ForegroundColor Gray
}
catch {
    Write-Host "  ✗ Erro ao obter site: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Obter lista
Write-Host "`n5️⃣ Obter lista SharePoint..." -ForegroundColor Yellow
try {
    $listName = $settings.sharepoint.listName
    $listUri = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists?`$filter=displayName eq '$listName'"
    $listResponse = Invoke-RestMethod -Uri $listUri -Headers $headers -Method GET
    
    if ($listResponse.value.Count -eq 0) {
        Write-Host "  ⚠ Lista '$listName' não encontrada" -ForegroundColor Yellow
        Write-Host "  → Verifique o nome em config/settings.json" -ForegroundColor Yellow
        exit 1
    }
    
    $list = $listResponse.value[0]
    Write-Host "  ✓ Lista encontrada: $($list.displayName)" -ForegroundColor Green
    Write-Host "    List ID: $($list.id)" -ForegroundColor Gray
    
    # Verificar se listId em settings.json está correto
    if ($settings.sharepoint.listId -and $settings.sharepoint.listId -ne $list.id) {
        Write-Host "    ⚠ listId em settings.json difere do obtido" -ForegroundColor Yellow
        Write-Host "      Settings: $($settings.sharepoint.listId)" -ForegroundColor Gray
        Write-Host "      Obtido:   $($list.id)" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  ✗ Erro ao obter lista: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Obter itens da lista
Write-Host "`n6️⃣ Obter itens da lista..." -ForegroundColor Yellow
try {
    $itemsUri = "https://graph.microsoft.com/v1.0/sites/$($site.id)/lists/$($list.id)/items?`$top=5&`$expand=fields"
    $itemsResponse = Invoke-RestMethod -Uri $itemsUri -Headers $headers -Method GET
    
    Write-Host "  ✓ $($itemsResponse.value.Count) itens obtidos (top 5)" -ForegroundColor Green
    
    if ($itemsResponse.value.Count -gt 0) {
        Write-Host "`n  Exemplo de item:" -ForegroundColor Gray
        $firstItem = $itemsResponse.value[0].fields
        $firstItem.PSObject.Properties | Select-Object -First 3 | ForEach-Object {
            Write-Host "    $($_.Name): $($_.Value)" -ForegroundColor Gray
        }
    }
}
catch {
    Write-Host "  ✗ Erro ao obter itens: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  (Possível falta de permissões)" -ForegroundColor Yellow
}

# Resumo final
Write-Host "`n" + ("=" * 50)
Write-Host "✅ Conexão SharePoint VALIDADA!" -ForegroundColor Green
Write-Host "`n📋 Informações para settings.json:" -ForegroundColor Cyan
Write-Host "  ""listId"": ""$($list.id)""" -ForegroundColor Gray
Write-Host "  ""siteId"": ""$($site.id)""" -ForegroundColor Gray
Write-Host ""
