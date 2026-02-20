<#
.SYNOPSIS
    Windows Development Machine Setup - Administrator Phase

.DESCRIPTION
    Performs tasks that require elevation:
      - Remove Windows bloatware
      - Configure Windows system settings (explorer, taskbar, privacy, etc.)
      - Install development software via winget
      - Install WSL

    This script is normally launched by setup.ps1 but can be run independently.

.PARAMETER SkipBloatware
    Skip removal of Windows bloatware apps

.PARAMETER SkipWSL
    Skip WSL installation

.PARAMETER Config
    Path to configuration file (default: .\config.ps1)

.EXAMPLE
    .\setup-admin.ps1
    Run admin setup with default config

.NOTES
    Must be run as Administrator.
#>

param(
    [switch]$SkipBloatware,
    [switch]$SkipWSL,
    [string]$Config = ".\config.ps1"
)

# Load shared functions and config
. "$PSScriptRoot\functions.ps1"
Load-Config -ConfigPath $Config

################################################################################
# Verify Admin Rights
################################################################################

Write-Section "Administrator Setup"

if (-not (Test-IsAdmin)) {
    Write-Err "This script must be run as Administrator"
    Write-Info "Right-click PowerShell and select 'Run as administrator', or use setup.ps1"
    exit 1
}

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
# Remove Bloatware
################################################################################

if (-not $SkipBloatware) {
    Write-Section "Removing Windows Bloatware"

    if ($null -eq $AppsToRemove -or $AppsToRemove.Count -eq 0) {
        Write-Info "No bloatware patterns configured, skipping"
    }
    else {
        foreach ($pattern in $AppsToRemove) {
            Write-Info "Removing apps matching: $pattern"

            Get-AppxProvisionedPackage -Online |
                Where-Object DisplayName -Like $pattern |
                Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null

            Get-AppxPackage -AllUsers -Name $pattern -ErrorAction SilentlyContinue |
                Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
        }

        Write-Ok "Bloatware removal complete"
    }
}

################################################################################
# Windows System Settings
################################################################################

Write-Section "Configuring Windows System Settings"

# Explorer Settings
Write-Info "Configuring File Explorer..."

if ($ShowFileExtensions) {
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "HideFileExt" -Value 0
}

if ($ShowHiddenFiles) {
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "Hidden" -Value 1
}

if ($ShowFullPathInTitleBar) {
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" `
        -Name "FullPath" -Value 1
}

if ($OpenFileExplorerTo -eq "ThisPC") {
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "LaunchTo" -Value 1
}

# Taskbar Settings
Write-Info "Configuring Taskbar..."

if ($null -ne $TaskbarSearchBoxMode) {
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
        -Name "SearchboxTaskbarMode" -Value $TaskbarSearchBoxMode
}

if (-not $TaskbarShowTaskView) {
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
        -Name "ShowTaskViewButton" -Value 0
}

# Dark Mode
if ($UseDarkMode) {
    Write-Info "Enabling Dark Mode..."
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
        -Name "AppsUseLightTheme" -Value 0
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
        -Name "SystemUsesLightTheme" -Value 0
}

# Privacy Settings
Write-Info "Configuring Privacy settings..."

if ($DisableTelemetry) {
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
        -Name "AllowTelemetry" -Value 0
}

if ($DisableAdvertisingId) {
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
        -Name "Enabled" -Value 0
}

if ($DisableLocationTracking) {
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" `
        -Name "Value" -Value "Deny" -Type "String"
}

# Performance Settings
if ($DisableAnimations) {
    Write-Info "Disabling animations for better performance..."
    Set-RegistryValue -Path "HKCU:\Control Panel\Desktop\WindowMetrics" `
        -Name "MinAnimate" -Value 0
    Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" `
        -Name "UserPreferencesMask" -Value ([byte[]](144, 18, 3, 128, 16, 0, 0, 0))
}

Write-Ok "Windows system settings configured"

################################################################################
# Install Software via Winget
################################################################################

Write-Section "Installing Core Development Tools"
Install-WingetPackages -Packages $CoreDevTools -Category "core development tools"

Write-Info "Setting Windows Terminal as default console..."
Set-RegistryValue -Path "HKCU:\Console" -Name "DelegationConsole" -Value 1 -Type DWord

# fnm and Node.js
Write-Section "Installing fnm (Fast Node Manager)"
Install-WingetPackage -PackageId "Schniz.fnm" -Name "fnm"

$env:Path += ";$env:LOCALAPPDATA\fnm"

Write-Info "Installing Node.js ($NodeVersion)..."
if ($NodeVersion -eq "lts") {
    fnm install --lts
    fnm use lts-latest
    fnm default lts-latest
}
else {
    fnm install $NodeVersion
    fnm use $NodeVersion
    fnm default $NodeVersion
}

$nodeVer = node --version 2>$null
if ($nodeVer) {
    Write-Ok "Node.js installed: $nodeVer"
}

# .NET SDKs
if ($null -ne $DotNetSDKs -and $DotNetSDKs.Count -gt 0) {
    Write-Section "Installing .NET SDKs"
    foreach ($version in $DotNetSDKs) {
        Install-WingetPackage -PackageId "Microsoft.DotNet.SDK.$version" -Name ".NET SDK $version"
        Install-WingetPackage -PackageId "Microsoft.DotNet.HostingBundle.$version" -Name ".NET Hosting Bundle $version"
        Install-WingetPackage -PackageId "Microsoft.DotNet.AspNetCore.$version" -Name ".NET AspNetCore $version"
    }
}

# Python
if ($PythonVersion) {
    Write-Section "Installing Python"
    Install-WingetPackage -PackageId "Python.Python.$PythonVersion" -Name "Python $PythonVersion"
}

# Package categories
Write-Section "Installing Database Tools"
Install-WingetPackages -Packages $DatabaseTools -Category "database tools"

Write-Section "Installing API Testing Tools"
Install-WingetPackages -Packages $APITestingTools -Category "API testing tools"

Write-Section "Installing Cloud & DevOps Tools"
Install-WingetPackages -Packages $CloudDevOpsTools -Category "cloud & DevOps tools"

Write-Section "Installing Kubernetes Tools"
Install-WingetPackages -Packages $KubernetesTools -Category "Kubernetes tools"

Write-Section "Installing Code Comparison Tools"
Install-WingetPackages -Packages $MergeTools -Category "merge tools"

Write-Section "Installing Text Editors"
Install-WingetPackages -Packages $TextEditors -Category "text editors"

Write-Section "Installing File Managers"
Install-WingetPackages -Packages $FileManagers -Category "file managers"

Write-Section "Installing Image Editors"
Install-WingetPackages -Packages $ImageEditors -Category "image editors"

Write-Section "Installing System Utilities"
Install-WingetPackages -Packages $SystemUtilities -Category "system utilities"

Write-Section "Installing Browsers"
Install-WingetPackages -Packages $Browsers -Category "browsers"

Write-Section "Installing Communication & Productivity Tools"
Install-WingetPackages -Packages $ProductivityTools -Category "productivity tools"

Write-Section "Installing Other Tools"
Install-WingetPackages -Packages $OtherTools -Category "other tools"

Write-Section "Installing Developer Fonts"
Install-WingetPackages -Packages $Fonts -Category "fonts"

# Git Credential Manager
Write-Section "Installing Git Credential Manager"
Install-WingetPackage -PackageId "Microsoft.GitCredentialManager" -Name "Git Credential Manager"

################################################################################
# Install WSL
################################################################################

if (-not $SkipWSL) {
    Write-Section "Installing WSL"
    Write-Info "Installing WSL with $WSLDistro..."

    wsl --install -d $WSLDistro --no-launch
    wsl --set-default-version $WSLDefaultVersion

    Write-Ok "WSL installed (distro will be configured in user phase)"
}

################################################################################
# NuGet Artifacts Credential Provider
################################################################################

Write-Section "Installing NuGet Artifacts Credential Provider"
Write-Info "Downloading and installing..."
try {
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"
    Write-Ok "NuGet Artifacts Credential Provider installed"
}
catch {
    Write-Warn "Failed to install NuGet Artifacts Credential Provider: $_"
}

################################################################################
# Done
################################################################################

Write-Section "Administrator Setup Complete"
Write-Ok "All admin tasks finished successfully"
Write-Info "This window will close. User-level setup continues in the original window."

exit 0
