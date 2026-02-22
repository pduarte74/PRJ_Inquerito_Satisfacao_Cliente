# Export IQSC Flows
# Script temporário para exportar os 3 flows do projeto Inquérito Satisfação

$ErrorActionPreference = "Stop"

$flowNames = @(
    'IQSC_Inquerito_Satisfação_Clientes_EnvioFormularioInicial',
    'IQSC_Inquerito_Satisfação_Clientes_RecolhaRespostas',
    'IQSC_Inquerito_Satisfação_Clientes_Reminders'
)

$env = "Default-019607f2-cbbd-425e-a7b1-bc8d0d97a3e4"
$outputDir = "$PSScriptRoot\flow-definitions-production"

Write-Host "`n📦 Exportar 3 Flows IQSC" -ForegroundColor Cyan
Write-Host ("=" * 60) -ForegroundColor Cyan

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
Write-Host "`n📋 Obter lista de flows..." -ForegroundColor Yellow
$allFlows = Get-Flow -EnvironmentName $env
Write-Host "  ✓ Total: $($allFlows.Count) flows" -ForegroundColor Green

# Encontrar nossos flows
$ourFlows = $allFlows | Where-Object { $_.Properties.displayName -like 'IQSC*' }
Write-Host "  ✓ Flows IQSC: $($ourFlows.Count)" -ForegroundColor Green

if ($ourFlows.Count -eq 0) {
    Write-Host "`n  ✗ Nenhum flow IQSC encontrado!" -ForegroundColor Red
    exit 1
}

Write-Host "`n💾 Exportar flows..." -ForegroundColor Cyan

$exported = 0
foreach ($flowName in $flowNames) {
    Write-Host "`n  ⏳ $flowName" -ForegroundColor Yellow
    
    $flow = $ourFlows | Where-Object { $_.Properties.displayName -eq $flowName }
    
    if ($flow) {
        try {
            # Obter definição completa
            $flowDetail = Get-Flow -EnvironmentName $env -FlowName $flow.FlowName
            
            # Preparar objeto
            $exportObject = [ordered]@{
                displayName = $flowDetail.Properties.displayName
                description = $flowDetail.Properties.description
                state = $flowDetail.Properties.state
                flowId = $flow.FlowName
                environmentId = $flowDetail.Properties.environment.name
                createdTime = $flowDetail.Properties.createdTime
                lastModifiedTime = $flowDetail.Properties.lastModifiedTime
                definition = $flowDetail.Properties.definition
                connectionReferences = $flowDetail.Properties.connectionReferences
            }
            
            # Salvar
            $outputFile = Join-Path $outputDir "$flowName.json"
            $exportObject | ConvertTo-Json -Depth 100 | Set-Content $outputFile -Encoding UTF8
            
            $fileSize = [math]::Round((Get-Item $outputFile).Length / 1KB, 2)
            Write-Host "    ✓ Exportado: $fileSize KB" -ForegroundColor Green
            
            $exported++
        }
        catch {
            Write-Host "    ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "    ✗ Flow não encontrado!" -ForegroundColor Red
    }
}

Write-Host "`n" + ("=" * 60) -ForegroundColor Cyan
Write-Host "✅ Exportação completa: $exported de 3 flows" -ForegroundColor Green
Write-Host "📁 $outputDir" -ForegroundColor Gray
Write-Host ""
