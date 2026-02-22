<#
.SYNOPSIS
    Reimportar solução com flows atualizados

.DESCRIPTION
    1. Substitui os JSON dos flows na solução extraída com as versões merged
    2. Re-zip a solução
    3. Importa a solução atualizada
    
.NOTES
    Este é o método mais robusto e seguro para atualizar flows em soluções
#>

$ErrorActionPreference = "Stop"

Write-Host "`n📦 Reimportar Solução com Flows Atualizados" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$extractedPath = ".\solution-exports\temp_extract"
$workflowsPath = Join-Path $extractedPath "Workflows"
$mergedDir = ".\scripts\flow-definitions-production"
$outputZip = ".\solution-exports\InqueritoSatisfaoClientes_updated_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"

# Mapeamento: merged → workflow na solução
$flowMappings = @{
    "IQSC_RecolhaRespostas_merged.json" = "IQSC_Inquerito_Satisfao_Clientes_RecolhaRespostas-D1422A6F-E50F-F111-8407-0022489D6559.json"
    "IQSC_EnvioFormularioInicial_merged.json" = "IQSC_Inquerito_Satisfao_Clientes_EnvioFormularioIn-48D49126-E10F-F111-8407-0022489D6559.json"  
    "IQSC_Reminders_merged.json" = "IQSC_Inquerito_Satisfao_Clientes_Reminders-88388E67-E60F-F111-8407-0022489D6559.json"
}

Write-Host "`n1️⃣  Substituir JSON dos flows..." -ForegroundColor Cyan

foreach ($mergedName in $flowMappings.Keys) {
    $targetName = $flowMappings[$mergedName]
    
    $mergedFile = Join-Path $mergedDir $mergedName
    $targetFile = Join-Path $workflowsPath $targetName
    
    Write-Host "  ⏳ $mergedName → $targetName" -ForegroundColor Yellow
    
    if (-not (Test-Path $mergedFile)) {
        Write-Host "    ✗ Merged não encontrado!" -ForegroundColor Red
        continue
    }
    
    if (-not (Test-Path $targetFile)) {
        Write-Host "    ✗ Target não encontrado!" -ForegroundColor Red
        continue
    }
    
    # Copiar merged para sobrescrever o original
    Copy-Item -Path $mergedFile -Destination $targetFile -Force
    
    $size = [math]::Round((Get-Item $targetFile).Length / 1KB, 2)
    Write-Host "    ✅ Substituído: $size KB" -ForegroundColor Green
}

Write-Host "`n2️⃣ Re-zipar solução..." -ForegroundColor Cyan

if (Test-Path $outputZip) {
    Remove-Item $outputZip -Force
}

# Comprimir tudo de volta
Compress-Archive -Path "$extractedPath\*" -DestinationPath $outputZip -Force

$zipSize = [math]::Round((Get-Item $outputZip).Length / 1KB, 2)
Write-Host "  ✅ Solução comprimida: $zipSize KB" -ForegroundColor Green
Write-Host "     📁 $outputZip" -ForegroundColor DarkGray

Write-Host "`n3️⃣  Importar solução atualizada..." -ForegroundColor Cyan
Write-Host "  ⏳ A importar via PAC CLI..." -ForegroundColor Yellow

try {
    $result = pac solution import --path $outputZip --async false --force-overwrite 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✅ Solução importada com sucesso!" -ForegroundColor Green
    }
    else {
        Write-Host "  ⚠️  Aviso: Exit code $LASTEXITCODE" -ForegroundColor Yellow
        Write-Host $result
    }
}
catch {
    Write-Host "  ✗ Erro na importação: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n  Pode importar manualmente:" -ForegroundColor Yellow
    Write-Host "     1. Aceder a https://make.powerautomate.com" -ForegroundColor White
    Write-Host "     2. Solutions → Import solution" -ForegroundColor White
    Write-Host "     3. Browse: $outputZip" -ForegroundColor White
}

Write-Host "`n" + ("=" * 70) -ForegroundColor Cyan
Write-Host "✅ Processo completo!" -ForegroundColor Green

Write-Host "`n📋 Verificar:" -ForegroundColor Cyan
Write-Host "   1. Aceder a https://make.powerautomate.com" -ForegroundColor White
Write-Host "   2. Solutions → Inquerito Satisfação Clientes" -ForegroundColor White
Write-Host "   3. Abrir cada flow e verificar:" -ForegroundColor White
Write-Host "      • Todas as actions estão presentes" -ForegroundColor Gray
Write-Host "      • Conexões SharePoint e Office 365 configuradas" -ForegroundColor Gray
Write-Host "      • Testar cada flow" -ForegroundColor Gray
Write-Host ""
