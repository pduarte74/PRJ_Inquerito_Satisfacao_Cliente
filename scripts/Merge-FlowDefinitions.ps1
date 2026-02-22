<#
.SYNOPSIS
    Mesclar definições completas com base exportada da solução

.DESCRIPTION
    Combina os flows exportados da solução (que têm connectionReferences e metadata)
    com as definições completas criadas (que têm todas as actions implementadas).
#>

$ErrorActionPreference = "Stop"

Write-Host "`n🔄 Mesclar Definições dos Flows" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$baseDir = "$PSScriptRoot\flow-definitions-production"
$completeDir = "$PSScriptRoot\flow-definitions"

# Mapeamento dos flows
$flowMappings = @{
    "IQSC_RecolhaRespostas" = "Inquerito-Satisfacao-Captura-Respostas"
    "IQSC_EnvioFormularioInicial" = "Inquerito-Satisfacao-Envio-Inicial"
    "IQSC_Reminders" = "Inquerito-Satisfacao-Gestao-Reminders"
}

foreach ($baseName in $flowMappings.Keys) {
    $completeName = $flowMappings[$baseName]
    
    $baseFile = Join-Path $baseDir "$baseName.json"
    $completeFile = Join-Path $completeDir "$completeName.json"
    $outputFile = Join-Path $baseDir "${baseName}_merged.json"
    
    Write-Host "`n📄 [$baseName]" -ForegroundColor Yellow
    
    if (-not (Test-Path $baseFile)) {
        Write-Host "  ✗ Base não encontrada: $baseFile" -ForegroundColor Red
        continue
    }
    
    if (-not (Test-Path $completeFile)) {
        Write-Host "  ✗ Definição completa não encontrada: $completeFile" -ForegroundColor Red
        continue
    }
    
    # Ler JSONs
    Write-Host "  ⏳ Lendo JSONs..." -ForegroundColor Gray
    $base = Get-Content $baseFile -Raw | ConvertFrom-Json
    $complete = Get-Content $completeFile -Raw | ConvertFrom-Json
    
    # Adicionar connection references necessárias
    Write-Host "  ⏳ Adicionando connection references..." -ForegroundColor Gray
    
    # SharePoint (se não existir)
    if (-not $base.properties.connectionReferences.shared_sharepointonline) {
        $base.properties.connectionReferences | Add-Member -NotePropertyName "shared_sharepointonline" -NotePropertyValue ([PSCustomObject]@{
            runtimeSource = "embedded"
            connection = [PSCustomObject]@{
                connectionReferenceLogicalName = "prod_sharedsharepointonline_xxxxx"
            }
            api = [PSCustomObject]@{
                name = "shared_sharepointonline"
            }
        })
    }
    
    # Office 365 (se não existir)
    if (-not $base.properties.connectionReferences.shared_office365) {
        $base.properties.connectionReferences | Add-Member -NotePropertyName "shared_office365" -NotePropertyValue ([PSCustomObject]@{
            runtimeSource = "embedded"
            connection = [PSCustomObject]@{
                connectionReferenceLogicalName = "prod_sharedoffice365_xxxxx"
            }
            api = [PSCustomObject]@{
                name = "shared_office365"
            }
        })
    }
    
    # Substituir a definição (triggers + actions) pela versão completa
    Write-Host "  ⏳ Mesclando definição completa..." -ForegroundColor Gray
    
    # Manter o schema e parameters da base
    $base.properties.definition.triggers = $complete.triggers
    $base.properties.definition.actions = $complete.actions
    
    # Adicionar authentication nos inputs onde necessário
    Write-Host "  ⏳ Ajustando authentication..." -ForegroundColor Gray
    
    # Função recursiva para adicionar authentication
    function Add-Authentication($obj) {
        if ($obj -is [PSCustomObject]) {
            foreach ($prop in $obj.PSObject.Properties) {
                if ($prop.Name -eq "inputs" -and $prop.Value.host) {
                    # Adicionar authentication parameter
                    if (-not $prop.Value.authentication) {
                        $prop.Value | Add-Member -NotePropertyName "authentication" -NotePropertyValue "@parameters('`$authentication')" -Force
                    }
                }
                
                Add-Authentication $prop.Value
            }
        }
        elseif ($obj -is [Array]) {
            foreach ($item in $obj) {
                Add-Authentication $item
            }
        }
    }
    
    Add-Authentication $base.properties.definition.triggers
    Add-Authentication $base.properties.definition.actions
    
    # Salvar merged
    Write-Host "  ⏳ Salvando merged..." -ForegroundColor Gray
    $base |ConvertTo-Json -Depth 100 | Set-Content $outputFile -Encoding UTF8
    
    $fileSize = [math]::Round((Get-Item $outputFile).Length / 1KB, 2)
    Write-Host "  ✅ Merged salvo: $fileSize KB" -ForegroundColor Green
    Write-Host "     📁 $outputFile" -ForegroundColor DarkGray
}

Write-Host "`n"+ ("=" * 70) -ForegroundColor Cyan
Write-Host "✅ Mesclagem completa!" -ForegroundColor Green
Write-Host "`n📋 Próximo passo:" -ForegroundColor Cyan
Write-Host "   Importar os ficheiros *_merged.json de volta para a solução" -ForegroundColor White
Write-Host ""
