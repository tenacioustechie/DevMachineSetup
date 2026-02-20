<#
.SYNOPSIS
    Shared helper functions for Windows development machine setup scripts.

.DESCRIPTION
    Provides logging, colored output, winget installation helpers, registry
    helpers, and other utilities used by setup-admin.ps1 and setup-user.ps1.

    Dot-source this file at the top of each script:
        . "$PSScriptRoot\functions.ps1"
#>

$script:LogFile = Join-Path $env:TEMP "dev-setup.log"

################################################################################
# Logging
################################################################################

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $Message" | Out-File -FilePath $script:LogFile -Append -Encoding UTF8
}

################################################################################
# Colored Output
################################################################################

function Write-ColorOutput {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Info', 'Success', 'Warning', 'Error', 'Section')]
        [string]$Type = 'Info'
    )

    $timestamp = Get-Date -Format "HH:mm:ss"

    switch ($Type) {
        'Info' {
            Write-Host "[$timestamp] " -ForegroundColor DarkGray -NoNewline
            Write-Host "[INFO] " -ForegroundColor Cyan -NoNewline
            Write-Host $Message
        }
        'Success' {
            Write-Host "[$timestamp] " -ForegroundColor DarkGray -NoNewline
            Write-Host "[OK] " -ForegroundColor Green -NoNewline
            Write-Host $Message
        }
        'Warning' {
            Write-Host "[$timestamp] " -ForegroundColor DarkGray -NoNewline
            Write-Host "[WARN] " -ForegroundColor Yellow -NoNewline
            Write-Host $Message
        }
        'Error' {
            Write-Host "[$timestamp] " -ForegroundColor DarkGray -NoNewline
            Write-Host "[ERROR] " -ForegroundColor Red -NoNewline
            Write-Host $Message
        }
        'Section' {
            Write-Host ""
            Write-Host "==========================================" -ForegroundColor Green
            Write-Host " $Message" -ForegroundColor Green
            Write-Host "==========================================" -ForegroundColor Green
            Write-Host ""
        }
    }

    Write-Log "[$Type] $Message"
}

function Write-Info    { param([string]$Message) Write-ColorOutput -Message $Message -Type Info }
function Write-Ok      { param([string]$Message) Write-ColorOutput -Message $Message -Type Success }
function Write-Warn    { param([string]$Message) Write-ColorOutput -Message $Message -Type Warning }
function Write-Err     { param([string]$Message) Write-ColorOutput -Message $Message -Type Error }
function Write-Section { param([string]$Message) Write-ColorOutput -Message $Message -Type Section }

################################################################################
# Utility Functions
################################################################################

function Test-IsAdmin {
    $principal = New-Object Security.Principal.WindowsPrincipal(
        [Security.Principal.WindowsIdentity]::GetCurrent()
    )
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Update-PathFromRegistry {
    $userPath    = [System.Environment]::GetEnvironmentVariable("Path", "User")
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    $env:Path = "$machinePath;$userPath"
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord"
    )

    try {
        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        return $true
    }
    catch {
        Write-Warn "Failed to set registry value: $Path\$Name - $_"
        return $false
    }
}

################################################################################
# Configuration Loading
################################################################################

function Load-Config {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ConfigPath
    )

    if (-not (Test-Path $ConfigPath)) {
        Write-Err "Configuration file not found: $ConfigPath"
        Write-Info "Please copy config.example.ps1 to config.ps1 and customize it"
        Write-Info "Example: Copy-Item config.example.ps1 config.ps1"
        exit 1
    }

    Write-Info "Loading configuration from: $ConfigPath"
    . $ConfigPath
}

################################################################################
# Winget Helpers
################################################################################

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,

        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    $displayName = if ($Name) { $Name } else { $PackageId }

    $installed = winget list --id $PackageId --exact 2>$null
    if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
        Write-Info "$displayName already installed"
        return $true
    }

    Write-Info "Installing $displayName..."
    winget install --id $PackageId --exact --source winget --silent --accept-source-agreements --accept-package-agreements

    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$displayName installed successfully"
        return $true
    }
    else {
        Write-Warn "Failed to install $displayName"
        return $false
    }
}

function Install-WingetPackages {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Packages,

        [Parameter(Mandatory = $false)]
        [string]$Category = "packages"
    )

    if ($null -eq $Packages -or $Packages.Count -eq 0) {
        Write-Info "No $Category configured, skipping"
        return
    }

    Write-Info "Installing $($Packages.Count) $Category..."

    foreach ($package in $Packages) {
        Install-WingetPackage -PackageId $package
    }

    Write-Ok "$Category installation complete"
}

################################################################################
# VS Code Helpers
################################################################################

function Install-VSCodeExtension {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExtensionId
    )

    $installed = code --list-extensions 2>$null
    if ($installed -contains $ExtensionId) {
        Write-Info "$ExtensionId already installed"
        return $true
    }

    Write-Info "Installing VS Code extension: $ExtensionId..."
    code --install-extension $ExtensionId --force 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$ExtensionId installed"
        return $true
    }
    else {
        Write-Warn "Failed to install $ExtensionId"
        return $false
    }
}
