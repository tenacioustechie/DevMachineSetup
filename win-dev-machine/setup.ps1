<#
.SYNOPSIS
    Windows Development Machine Setup - Entry Point

.DESCRIPTION
    Orchestrates the two-phase setup for a Windows development environment:
      1. Launches setup-admin.ps1 with elevation for system configuration
         and software installation.
      2. Runs setup-user.ps1 in the current session for user-level tasks
         like Git configuration and VS Code extensions.

    Each phase script can also be run independently.

.PARAMETER SkipBloatware
    Skip removal of Windows bloatware apps

.PARAMETER SkipWSL
    Skip WSL installation and configuration

.PARAMETER Config
    Path to custom configuration file (default: .\config.ps1)

.EXAMPLE
    .\setup.ps1
    Run full setup (will prompt for elevation)

.EXAMPLE
    .\setup.ps1 -SkipBloatware -SkipWSL
    Skip bloatware removal and WSL installation

.NOTES
    Requires: Windows 10/11, PowerShell 5.1+, Internet connection
#>

param(
    [switch]$SkipBloatware,
    [switch]$SkipWSL,
    [string]$Config = ".\config.ps1"
)

# Load shared functions
. "$PSScriptRoot\functions.ps1"

################################################################################
# Banner
################################################################################

Write-Section "Windows Development Machine Setup"
Write-Info "Log file: $script:LogFile"

################################################################################
# Pre-flight Checks
################################################################################

$osCaption = (Get-CimInstance Win32_OperatingSystem).Caption
Write-Info "OS: $osCaption"
Write-Info "PowerShell: $($PSVersionTable.PSVersion)"
Write-Info "Architecture: $env:PROCESSOR_ARCHITECTURE"

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Err "winget is not available. Please install App Installer from the Microsoft Store."
    exit 1
}
Write-Ok "Pre-flight checks passed"

################################################################################
# Resolve config to absolute path so it works from the elevated process
################################################################################

$ConfigAbsolute = (Resolve-Path $Config -ErrorAction SilentlyContinue).Path
if (-not $ConfigAbsolute) {
    Write-Err "Configuration file not found: $Config"
    Write-Info "Please copy config.example.ps1 to config.ps1 and customize it"
    exit 1
}

################################################################################
# Phase 1: Admin Tasks (elevated)
################################################################################

Write-Section "Phase 1: Administrator Tasks"
Write-Info "Launching setup-admin.ps1 with elevation..."
Write-Info "You may see a UAC prompt - please approve it."

$adminScript = Join-Path $PSScriptRoot "setup-admin.ps1"
$adminArgs = "-NoProfile -ExecutionPolicy Bypass -File `"$adminScript`" -Config `"$ConfigAbsolute`""
if ($SkipBloatware) { $adminArgs += " -SkipBloatware" }
if ($SkipWSL) { $adminArgs += " -SkipWSL" }

$adminProcess = Start-Process powershell.exe -Verb RunAs -ArgumentList $adminArgs -PassThru -Wait

if ($adminProcess.ExitCode -ne 0) {
    Write-Warn "Admin phase exited with code $($adminProcess.ExitCode)"
    Write-Info "Check the admin window for errors, or re-run setup-admin.ps1 directly"
}
else {
    Write-Ok "Admin phase completed successfully"
}

################################################################################
# Refresh PATH (picks up anything installed in Phase 1)
################################################################################

Update-PathFromRegistry

################################################################################
# Phase 2: User Tasks (current session)
################################################################################

Write-Section "Phase 2: User-Level Tasks"
Write-Info "Running setup-user.ps1..."

$userScript = Join-Path $PSScriptRoot "setup-user.ps1"
$userArgs = @{
    Config = $ConfigAbsolute
}
if ($SkipWSL) { $userArgs.SkipWSL = $true }

& $userScript @userArgs
