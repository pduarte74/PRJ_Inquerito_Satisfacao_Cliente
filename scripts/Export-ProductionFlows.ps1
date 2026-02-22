<#
.SYNOPSIS
    Exporta flows de produção do Power Automate.

.DESCRIPTION
    Conecta ao Power Automate via autenticação delegada e exporta definições dos flows
    da solução especificada para flow-definitions-production/.
    
    ⚠️ ÚNICO método funcional para exportar flows!
    ❌ NÃO usar: PAC CLI solution export (falha com permissões)

.PARAMETER SolutionName
    Nome da solução (opcional). Se não especificado, usa settings.json.

.PARAMETER EnvironmentName
    Nome do environment (opcional). Se não especificado, usa settings.json.

.NOTES
    Template versão: 1.0
    Requer: Microsoft.PowerApps.PowerShell module
    
.EXAMPLE
    .\Export-ProductionFlows.ps1
    
.EXAMPLE
    .\Export-ProductionFlows.ps1 -SolutionName "minhasolucao" -EnvironmentName "Default-[TenantId]"
#>

param(
    [string]$SolutionName,
    [string]$EnvironmentName,
    [string]$OutputDir = "$PSScriptRoot\flow-definitions-production"
)

Write-Host "`n📦 Exportar Flows de Produção" -ForegroundColor Cyan
Write-Host "=" * 60

# Carregar configurações
if (-not $SolutionName -or -not $EnvironmentName) {
    $settingsFile = "$PSScriptRoot\..\config\settings.json"
    if (Test-Path $settingsFile) {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
        
        if (-not $SolutionName) {
            $SolutionName = $settings.powerPlatform.solutionName
        }
        if (-not $EnvironmentName) {
            $EnvironmentName = $settings.powerPlatform.environmentName
        }
        
        Write-Host "  ✓ Configurações carregadas de settings.json" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠ settings.json não encontrado, usar parâmetros" -ForegroundColor Yellow
    }
}

if (-not $EnvironmentName) {
    Write-Host "  ✗ EnvironmentName não especificado!" -ForegroundColor Red
    Write-Host "  Use: -EnvironmentName 'Default-[TenantId]'" -ForegroundColor Yellow
    exit 1
}

Write-Host "  Environment: $EnvironmentName" -ForegroundColor Gray
if ($SolutionName) {
    Write-Host "  Solução: $SolutionName" -ForegroundColor Gray
}

# Verificar módulo PowerShell
$module = Get-Module -ListAvailable -Name Microsoft.PowerApps.PowerShell
if (-not $module) {
    Write-Host "`n  ✗ Módulo Microsoft.PowerApps.PowerShell não instalado!" -ForegroundColor Red
    Write-Host "  Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

# Autenticar
Write-Host "`n🔐 Autenticar Power Automate (abrirá browser)..." -ForegroundColor Cyan
try {
    Add-PowerAppsAccount -ErrorAction Stop | Out-Null
    Write-Host "  ✓ Autenticado com sucesso!" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Erro na autenticação: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Listar flows
Write-Host "`n📋 Obter lista de flows..." -ForegroundColor Cyan
try {
    $allFlows = Get-Flow -EnvironmentName $EnvironmentName -ErrorAction Stop
    
    if ($allFlows.Count -eq 0) {
        Write-Host "  ⚠ Nenhum flow encontrado no environment" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "  ✓ $($allFlows.Count) flow(s) encontrado(s) no environment" -ForegroundColor Green
    
    # Filtrar por solução se especificado
    if ($SolutionName) {
        # Nota: Filtrar por SolutionId requer obter solution ID primeiro
        # Por simplicidade, exportar todos os flows
        Write-Host "  ℹ Exportando todos os flows (filtro por solução a implementar)" -ForegroundColor Cyan
    }
    
    $flowsToExport = $allFlows
}
catch {
    Write-Host "  ✗ Erro ao listar flows: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Criar diretório de output
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "`n  ✓ Diretório criado: $OutputDir" -ForegroundColor Green
}

# Exportar cada flow
Write-Host "`n💾 Exportar flows..." -ForegroundColor Cyan
$exportCount = 0
$errorCount = 0

foreach ($flow in $flowsToExport) {
    $flowName = $flow.Properties.displayName
    $flowId = $flow.FlowName
    
    try {
        Write-Host "  ⏳ $flowName..." -ForegroundColor Yellow -NoNewline
        
        # Obter definição completa
        $flowDetail = Get-Flow -EnvironmentName $EnvironmentName -FlowName $flowId
        
        # Preparar objeto para export
        $exportObject = @{
            "displayName" = $flowDetail.Properties.displayName
            "definition" = $flowDetail.Properties.definition
            "connectionReferences" = $flowDetail.Properties.connectionReferences
            "state" = $flowDetail.Properties.state
            "flowId" = $flowId
            "lastModifiedTime" = $flowDetail.Properties.lastModifiedTime
        }
        
        # Nome do ficheiro (sanitizar)
        $safeFileName = $flowName -replace '[\\/:*?"<>|]', '_'
        $outputFile = Join-Path $OutputDir "$safeFileName.json"
        
        # Guardar com Depth 100 (importante para flows complexos!)
        $exportObject | ConvertTo-Json -Depth 100 | Set-Content $outputFile -Encoding UTF8
        
        $fileSize = (Get-Item $outputFile).Length / 1KB
        Write-Host " ✓ ($([math]::Round($fileSize, 2)) KB)" -ForegroundColor Green
        
        $exportCount++
    }
    catch {
        Write-Host " ✗ Erro: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
}

# Resumo
Write-Host "`n" + ("=" * 60)
Write-Host "✅ Exportação completa!" -ForegroundColor Green
Write-Host "  ✓ $exportCount flow(s) exportado(s)" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "  ⚠ $errorCount erro(s)" -ForegroundColor Yellow
}
Write-Host "  📁 Local: $OutputDir" -ForegroundColor Gray

# Listar ficheiros criados
Write-Host "`n📄 Ficheiros criados:" -ForegroundColor Cyan
Get-ChildItem $OutputDir -Filter "*.json" | ForEach-Object {
    $size = [math]::Round($_.Length / 1KB, 2)
    Write-Host "  - $($_.Name) ($size KB)" -ForegroundColor Gray
}

Write-Host ""
