<#
.SYNOPSIS
    Guarda o Client Secret de forma segura usando Windows DPAPI.

.DESCRIPTION
    Solicita o Client Secret e guarda-o encriptado em config/client-secret.encrypted.
    O ficheiro só pode ser desencriptado pelo mesmo utilizador na mesma máquina.

.NOTES
    Template versão: 1.0
    ⚠️ NUNCA commit o ficheiro .encrypted no Git!

.EXAMPLE
    .\Save-ClientSecret.ps1
#>

param(
    [string]$OutputFile = "$PSScriptRoot\..\config\client-secret.encrypted"
)

Write-Host "`n🔐 Guardar Client Secret de Forma Segura" -ForegroundColor Cyan
Write-Host "=" * 50

# Garantir que pasta config existe
$configDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $configDir)) {
    New-Item -ItemType Directory -Path $configDir -Force | Out-Null
    Write-Host "  ✓ Pasta config criada" -ForegroundColor Green
}

# Solicitar secret
Write-Host "`nIntroduza o Client Secret (não será mostrado):" -ForegroundColor Yellow
$secureSecret = Read-Host -AsSecureString

# Validar que não está vazio
$plainText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSecret)
)

if ([string]::IsNullOrWhiteSpace($plainText)) {
    Write-Host "  ✗ Client Secret não pode estar vazio!" -ForegroundColor Red
    exit 1
}

# Guardar encriptado
try {
    $secureSecret | ConvertFrom-SecureString | Set-Content $OutputFile
    Write-Host "  ✓ Client Secret guardado com sucesso!" -ForegroundColor Green
    Write-Host "  Local: $OutputFile" -ForegroundColor Gray
    
    # Verificar .gitignore
    $gitignorePath = "$PSScriptRoot\..\.gitignore"
    if (Test-Path $gitignorePath) {
        $gitignoreContent = Get-Content $gitignorePath -Raw
        if ($gitignoreContent -notmatch 'client-secret\.encrypted') {
            Write-Host "`n  ⚠️  AVISO: Adicione ao .gitignore:" -ForegroundColor Yellow
            Write-Host "  config/client-secret.encrypted" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "`n  ⚠️  .gitignore não encontrado! Crie um com:" -ForegroundColor Yellow
        Write-Host "  config/client-secret.encrypted" -ForegroundColor Yellow
        Write-Host "  config/settings.json" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "  ✗ Erro ao guardar: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Setup completo!" -ForegroundColor Green
Write-Host "   Pode agora usar: Get-SavedClientSecret" -ForegroundColor Gray
Write-Host ""
