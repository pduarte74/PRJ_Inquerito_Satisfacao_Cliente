<#
.SYNOPSIS
    Funções helper para autenticação e configuração.

.DESCRIPTION
    Módulo com funções para autenticação SharePoint, Graph API e gestão de credenciais.
    
    ✅ VALIDADO: SharePoint/Graph API via App Registration (Client Credentials)
    ❌ NÃO USAR: Power Automate requer autenticação delegada (Add-PowerAppsAccount)
    
    Ver detalhes: ../docs/AUTH-METHODS.md

.NOTES
    Template versão: 1.0
    Baseado em: Projeto Auditoria Documental FF 2026
#>

function Get-SavedClientSecret {
    <#
    .SYNOPSIS
        Carrega o ClientSecret guardado de forma segura.
    
    .DESCRIPTION
        Carrega o ClientSecret do ficheiro encriptado. Se não existir, solicita ao utilizador.
    
    .EXAMPLE
        $secret = Get-SavedClientSecret
    
    .EXAMPLE
        $secret = Get-SavedClientSecret -SecretFile "config\my-secret.encrypted"
    #>
    
    [CmdletBinding()]
    param(
        [string]$SecretFile = "$PSScriptRoot\..\config\client-secret.encrypted"
    )
    
    if (Test-Path $SecretFile) {
        try {
            $secureSecret = Get-Content $SecretFile | ConvertTo-SecureString
            $plainSecret = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureSecret)
            )
            
            Write-Host "  ✓ ClientSecret carregado do ficheiro seguro" -ForegroundColor Green
            return $plainSecret
        }
        catch {
            Write-Host "  ⚠ Erro ao carregar ClientSecret: $($_.Exception.Message)" -ForegroundColor Yellow
            Write-Host "  → Execute Save-ClientSecret.ps1 para guardar novamente" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "  ℹ ClientSecret não encontrado em: $SecretFile" -ForegroundColor Yellow
        Write-Host "  → Execute Save-ClientSecret.ps1 primeiro" -ForegroundColor Yellow
    }
    
    # Solicitar manualmente se não conseguiu carregar
    $secureInput = Read-Host -AsSecureString -Prompt "  Digite o ClientSecret"
    return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureInput)
    )
}

function Get-GraphApiToken {
    <#
    .SYNOPSIS
        Obtém um token de acesso do Microsoft Graph API.
    
    .DESCRIPTION
        Autentica com Azure AD usando Client Credentials e retorna um token de acesso.
        
        ✅ FUNCIONAL: SharePoint, Graph API
        ❌ NÃO FUNCIONA: Power Automate flows (usar Add-PowerAppsAccount)
    
    .PARAMETER ClientId
        Application (client) ID do App Registration.
    
    .PARAMETER ClientSecret
        Client Secret do App Registration.
    
    .PARAMETER TenantId
        Directory (tenant) ID do Azure AD.
    
    .PARAMETER Scope
        Scope do token. Padrão: "https://graph.microsoft.com/.default"
    
    .EXAMPLE
        $token = Get-GraphApiToken -ClientId "..." -ClientSecret "..." -TenantId "..."
    
    .EXAMPLE
        $secret = Get-SavedClientSecret
        $token = Get-GraphApiToken -ClientId "..." -ClientSecret $secret -TenantId "..."
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ClientId,
        
        [Parameter(Mandatory=$true)]
        [string]$ClientSecret,
        
        [Parameter(Mandatory=$true)]
        [string]$TenantId,
        
        [string]$Scope = "https://graph.microsoft.com/.default"
    )
    
    $tokenUrl = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
    $body = @{
        client_id     = $ClientId
        client_secret = $ClientSecret
        scope         = $Scope
        grant_type    = "client_credentials"
    }
    
    try {
        Write-Verbose "Obtendo token de: $tokenUrl"
        $response = Invoke-RestMethod -Uri $tokenUrl -Method POST -Body $body -ContentType "application/x-www-form-urlencoded"
        
        Write-Host "  ✓ Token obtido com sucesso" -ForegroundColor Green
        Write-Verbose "Token expira em: $($response.expires_in) segundos"
        
        return $response.access_token
    }
    catch {
        Write-Host "  ✗ Erro ao obter token: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Get-ProjectSettings {
    <#
    .SYNOPSIS
        Carrega as configurações do projeto do ficheiro settings.json.
    
    .DESCRIPTION
        Lê o ficheiro config/settings.json e retorna um objeto com as configurações.
    
    .EXAMPLE
        $settings = Get-ProjectSettings
        $siteUrl = $settings.sharepoint.siteUrl
    #>
    
    [CmdletBinding()]
    param(
        [string]$SettingsFile = "$PSScriptRoot\..\config\settings.json"
    )
    
    if (-not (Test-Path $SettingsFile)) {
        Write-Host "  ⚠ Ficheiro settings.json não encontrado: $SettingsFile" -ForegroundColor Yellow
        Write-Host "  → Crie o ficheiro com base em config/settings.json.template" -ForegroundColor Yellow
        return $null
    }
    
    try {
        $settings = Get-Content $SettingsFile -Raw | ConvertFrom-Json
        Write-Verbose "Configurações carregadas de: $SettingsFile"
        return $settings
    }
    catch {
        Write-Host "  ✗ Erro ao ler settings.json: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

function Test-GraphApiConnection {
    <#
    .SYNOPSIS
        Testa a conexão com Graph API.
    
    .DESCRIPTION
        Obtém um token e faz um request simples para validar autenticação.
    
    .EXAMPLE
        Test-GraphApiConnection -ClientId "..." -ClientSecret "..." -TenantId "..."
    
    .EXAMPLE
        $settings = Get-ProjectSettings
        Test-GraphApiConnection `
            -ClientId $settings.azure.clientId `
            -ClientSecret (Get-SavedClientSecret) `
            -TenantId $settings.azure.tenantId
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ClientId,
        
        [Parameter(Mandatory=$true)]
        [string]$ClientSecret,
        
        [Parameter(Mandatory=$true)]
        [string]$TenantId
    )
    
    try {
        Write-Host "`n🔐 Testando conexão Graph API..." -ForegroundColor Cyan
        
        # Obter token
        $token = Get-GraphApiToken -ClientId $ClientId -ClientSecret $ClientSecret -TenantId $TenantId
        
        # Testar request simples
        $headers = @{
            "Authorization" = "Bearer $token"
        }
        
        $response = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/organization" -Headers $headers -Method GET
        
        Write-Host "  ✓ Conexão Graph API bem-sucedida!" -ForegroundColor Green
        Write-Host "  Tenant: $($response.value[0].displayName)" -ForegroundColor Gray
        
        return $true
    }
    catch {
        Write-Host "  ✗ Erro na conexão Graph API: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Exportar funções
Export-ModuleMember -Function @(
    'Get-SavedClientSecret',
    'Get-GraphApiToken',
    'Get-ProjectSettings',
    'Test-GraphApiConnection'
)
