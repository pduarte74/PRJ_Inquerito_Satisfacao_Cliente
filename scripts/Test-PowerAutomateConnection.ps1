<#
.SYNOPSIS
    Testa a conexão com Power Automate.

.DESCRIPTION
    Valida autenticação delegada e lista flows disponíveis no environment.

.NOTES
    Template versão: 1.0
    Requer: Microsoft.PowerApps.PowerShell module
    
.EXAMPLE
    .\Test-PowerAutomateConnection.ps1
#>

Write-Host "`n⚡ Testar Conexão Power Automate" -ForegroundColor Cyan
Write-Host "=" * 50

# Verificar módulo instalado
Write-Host "`n1️⃣ Verificar módulo PowerShell..." -ForegroundColor Yellow
$module = Get-Module -ListAvailable -Name Microsoft.PowerApps.PowerShell

if (-not $module) {
    Write-Host "  ⚠ Módulo Microsoft.PowerApps.PowerShell não instalado" -ForegroundColor Yellow
    Write-Host "`n  Para instalar, execute:" -ForegroundColor Yellow
    Write-Host "  Install-Module -Name Microsoft.PowerApps.Administration.PowerShell -Scope CurrentUser" -ForegroundColor Cyan
    Write-Host "  Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber -Scope CurrentUser" -ForegroundColor Cyan
    exit 1
}

Write-Host "  ✓ Módulo encontrado: v$($module.Version)" -ForegroundColor Green

# Tentar autenticar
Write-Host "`n2️⃣ Autenticar (abrirá browser)..." -ForegroundColor Yellow
try {
    Add-PowerAppsAccount -ErrorAction Stop | Out-Null
    Write-Host "  ✓ Autenticação bem-sucedida!" -ForegroundColor Green
}
catch {
    Write-Host "  ✗ Erro na autenticação: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Listar environments
Write-Host "`n3️⃣ Listar environments..." -ForegroundColor Yellow
try {
    $environments = Get-PowerAppEnvironment
    
    if ($environments.Count -eq 0) {
        Write-Host "  ⚠ Nenhum environment encontrado" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "  ✓ $($environments.Count) environment(s) encontrado(s):" -ForegroundColor Green
    foreach ($env in $environments) {
        Write-Host "    - $($env.DisplayName) ($($env.EnvironmentName))" -ForegroundColor Gray
    }
}
catch {
    Write-Host "  ✗ Erro ao listar environments: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Carregar settings para obter environment correto
$settingsFile = "$PSScriptRoot\..\config\settings.json"
$targetEnvironment = $null

if (Test-Path $settingsFile) {
    try {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
        $targetEnvironment = $settings.powerPlatform.environmentName
        Write-Host "`n  Environment configurado: $targetEnvironment" -ForegroundColor Cyan
    }
    catch {
        Write-Host "  ⚠ Não foi possível ler settings.json" -ForegroundColor Yellow
    }
}

# Usar default environment se não configurado
if (-not $targetEnvironment) {
    $targetEnvironment = $environments[0].EnvironmentName
    Write-Host "`n  Usando environment default: $targetEnvironment" -ForegroundColor Cyan
}

# Listar flows
Write-Host "`n4️⃣ Listar flows no environment..." -ForegroundColor Yellow
try {
    $flows = Get-Flow -EnvironmentName $targetEnvironment
    
    if ($flows.Count -eq 0) {
        Write-Host "  ⚠ Nenhum flow encontrado no environment" -ForegroundColor Yellow
        Write-Host "  (Normal se projeto ainda não tem flows)" -ForegroundColor Gray
    }
    else {
        Write-Host "  ✓ $($flows.Count) flow(s) encontrado(s):" -ForegroundColor Green
        
        $flows | Select-Object -First 10 | ForEach-Object {
            $status = if ($_.Properties.state -eq "Started") { "🟢" } else { "🔴" }
            Write-Host "    $status $($_.Properties.displayName)" -ForegroundColor Gray
        }
        
        if ($flows.Count -gt 10) {
            Write-Host "    ... e mais $($flows.Count - 10) flows" -ForegroundColor DarkGray
        }
    }
}
catch {
    Write-Host "  ✗ Erro ao listar flows: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  (Verifique permissões no environment)" -ForegroundColor Yellow
}

# Resumo final
Write-Host "`n" + ("=" * 50)
Write-Host "✅ Conexão Power Automate VALIDADA!" -ForegroundColor Green
Write-Host "`n📋 Informações para settings.json:" -ForegroundColor Cyan
Write-Host "  ""environmentName"": ""$targetEnvironment""" -ForegroundColor Gray
Write-Host ""
