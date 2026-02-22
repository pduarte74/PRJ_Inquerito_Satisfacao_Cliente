<#
.SYNOPSIS
    Importar definições merged de volta para os flows da solução

.DESCRIPTION
    Atualiza os flows existentes na solução com as definições completas merged.
    Usa PowerShell com Microsoft.PowerApps module.
    
.NOTES
    Requer autenticação prévia: Add-PowerAppsAccount
#>

$ErrorActionPreference = "Stop"

Write-Host "`n📥 Importar Flows Merged para Solução" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$env = "Default-019607f2-cbbd-425e-a7b1-bc8d0d97a3e4"
$mergedDir = "$PSScriptRoot\flow-definitions-production"

# Mapeamento: ficheiro merged → nome do flow na solução
$flowMappings = @{
    "IQSC_RecolhaRespostas_merged" = "IQSC_Inquerito_Satisfação_Clientes_RecolhaRespostas"
    "IQSC_EnvioFormularioInicial_merged" = "IQSC_Inquerito_Satisfação_Clientes_EnvioFormularioInicial"
    "IQSC_Reminders_merged" = "IQSC_Inquerito_Satisfação_Clientes_Reminders"
}

# Verificar autenticação
Write-Host "`n🔐 Verificar autenticação..." -ForegroundColor Yellow
try {
    $testConnection = Get-Flow -EnvironmentName $env -Top 1
    Write-Host "  ✓ Autenticado!" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Não autenticado. A autenticar..." -ForegroundColor Yellow
    Add-PowerAppsAccount
}

# Obter todos os flows
Write-Host "`n📋 Obter flows da solução..." -ForegroundColor Yellow
$allFlows = Get-Flow -EnvironmentName $env
$ourFlows = $allFlows | Where-Object { $_.Properties.displayName -like 'IQSC*' }
Write-Host "  ✓ Encontrados $($ourFlows.Count) flows IQSC" -ForegroundColor Green

Write-Host "`n💾 Importar definições merged..." -ForegroundColor Cyan

$imported = 0
$errors = 0

foreach ($mergedName in $flowMappings.Keys) {
    $flowDisplayName = $flowMappings[$mergedName]
    $mergedFile = Join-Path $mergedDir "$mergedName.json"
    
    Write-Host "`n  📄 [$flowDisplayName]" -ForegroundColor Yellow
    
    if (-not (Test-Path $mergedFile)) {
        Write-Host "    ✗ Ficheiro merged não encontrado!" -ForegroundColor Red
        $errors++
        continue
    }
    
    # Encontrar o flow
    $flow = $ourFlows | Where-Object { $_.Properties.displayName -eq $flowDisplayName }
    
    if (-not $flow) {
        Write-Host "    ✗ Flow não encontrado na solução!" -ForegroundColor Red
        $errors++
        continue
    }
    
    $flowId = $flow.FlowName
    Write-Host "    ✓ Flow ID: $flowId" -ForegroundColor Gray
    
    try {
        # Ler merged JSON
        Write-Host "    ⏳ Carregar definição merged..." -ForegroundColor Gray
        $merged = Get-Content $mergedFile -Raw | ConvertFrom-Json
        
        # Preparar payload para update
        # NOTA: A API do Power Automate espera a estrutura completa
        $updatePayload = @{
            properties = @{
                displayName = $flowDisplayName
                definition = $merged.properties.definition
                connectionReferences = $merged.properties.connectionReferences
            }
        } | ConvertTo-Json -Depth 100
        
        # Construir URI da API
        $apiVersion = "2016-11-01"
        $baseUri = "https://api.flow.microsoft.com"
        $flowUri = "$baseUri/providers/Microsoft.ProcessSimple/environments/$env/flows/${flowId}?api-version=$apiVersion"
        
        Write-Host "    ⏳ A atualizar flow via API..." -ForegroundColor Gray
        
        # Obter token de autenticação
        $token = (Get-PowerAppManagementApp).properties.token
        
        if (-not $token) {
            Write-Host "    ✗ Não foi possível obter token de autenticação!" -ForegroundColor Red
            $errors++
            continue
        }
        
        # Fazer PATCH request
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        
        $response = Invoke-RestMethod -Uri $flowUri -Method Patch -Headers $headers -Body $updatePayload
        
        Write-Host "    ✅ Flow atualizado com sucesso!" -ForegroundColor Green
        $imported++
    }
    catch {
        Write-Host "    ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
        $errors++
    }
}

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan

if ($errors -eq 0) {
    Write-Host "✅ Importação completa: $imported de 3 flows atualizados!" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Importação concluída com $errors erro(s)" -ForegroundColor Yellow
    Write-Host "   ✓ $imported flow(s) atualizado(s)" -ForegroundColor Green
}

Write-Host "`n📋 Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Aceder a https://make.powerautomate.com" -ForegroundColor White
Write-Host "   2. Abrir cada flow e verificar as conexões" -ForegroundColor White
Write-Host "   3. Configurar conexões SharePoint e Office 365 se necessário" -ForegroundColor White
Write-Host "   4. Testar cada flow" -ForegroundColor White
Write-Host ""
