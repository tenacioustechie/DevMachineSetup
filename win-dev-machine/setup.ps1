<#
.SYNOPSIS
    Windows Development Machine Setup Script

.DESCRIPTION
    Automated setup for Windows development environments.
    Similar to the Mac setup.sh - direct and simple with colored output.

    This script performs a two-phase setup:
    - Phase 1 (Admin): System configuration, software installation, bloatware removal
    - Phase 2 (User): WSL setup, Git configuration, VS Code extensions

.PARAMETER Elevated
    Internal flag indicating script is running with admin privileges

.PARAMETER UserPhase
    Internal flag indicating script is in user-level phase

.PARAMETER SkipBloatware
    Skip removal of Windows bloatware apps

.PARAMETER SkipWSL
    Skip WSL installation and configuration

.PARAMETER Config
    Path to custom configuration file (default: .\config.ps1)

.EXAMPLE
    .\setup.ps1
    Run full setup (will auto-elevate for admin tasks)

.EXAMPLE
    .\setup.ps1 -SkipBloatware
    Skip bloatware removal

.EXAMPLE
    .\setup.ps1 -Config .\my-config.ps1
    Use custom configuration file

.NOTES
    Requires: Windows 11 (or Windows 10), PowerShell 5.1+
    Network: Internet connection required for downloads
#>

param(
    [switch]$Elevated,
    [switch]$UserPhase,
    [switch]$SkipBloatware,
    [switch]$SkipWSL,
    [string]$Config = ".\config.ps1"
)

################################################################################
# Color Functions for Output
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
            Write-Host "[SUCCESS] " -ForegroundColor Green -NoNewline
            Write-Host $Message
        }
        'Warning' {
            Write-Host "[$timestamp] " -ForegroundColor DarkGray -NoNewline
            Write-Host "[WARNING] " -ForegroundColor Yellow -NoNewline
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
            Write-Host $Message -ForegroundColor Green
            Write-Host "==========================================" -ForegroundColor Green
            Write-Host ""
        }
    }
}

function Write-Info { param([string]$Message) Write-ColorOutput -Message $Message -Type Info }
function Write-Success { param([string]$Message) Write-ColorOutput -Message $Message -Type Success }
function Write-Warning { param([string]$Message) Write-ColorOutput -Message $Message -Type Warning }
function Write-Error { param([string]$Message) Write-ColorOutput -Message $Message -Type Error }
function Write-Section { param([string]$Message) Write-ColorOutput -Message $Message -Type Section }

################################################################################
# Helper Functions
################################################################################

function Test-IsAdmin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageId,

        [Parameter(Mandatory = $false)]
        [string]$Name
    )

    $displayName = if ($Name) { $Name } else { $PackageId }

    # Check if already installed
    $installed = winget list --id $PackageId --exact 2>$null
    if ($LASTEXITCODE -eq 0 -and $installed -match $PackageId) {
        Write-Info "✓ $displayName already installed"
        return $true
    }

    Write-Info "Installing $displayName..."
    winget install --id $PackageId --exact --source winget --silent --accept-source-agreements --accept-package-agreements

    if ($LASTEXITCODE -eq 0) {
        Write-Success "$displayName installed successfully"
        return $true
    }
    else {
        Write-Warning "Failed to install $displayName"
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

    Write-Info "Installing $($Packages.Count) $Category..."

    foreach ($package in $Packages) {
        Install-WingetPackage -PackageId $package
    }

    Write-Success "$Category installation complete"
}

function Install-VSCodeExtension {
    param(
        [Parameter(Mandatory = $true)]
        [string]$ExtensionId
    )

    # Check if already installed
    $installed = code --list-extensions 2>$null
    if ($installed -contains $ExtensionId) {
        Write-Info "✓ $ExtensionId already installed"
        return $true
    }

    Write-Info "Installing VS Code extension: $ExtensionId..."
    code --install-extension $ExtensionId --force 2>$null

    if ($LASTEXITCODE -eq 0) {
        Write-Success "$ExtensionId installed"
        return $true
    }
    else {
        Write-Warning "Failed to install $ExtensionId"
        return $false
    }
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
        Write-Warning "Failed to set registry value: $Path\$Name"
        return $false
    }
}

################################################################################
# Initial Check and Phase Routing
################################################################################

# If neither flag is present, re-launch elevated for Phase 1
if (-not ($Elevated -or $UserPhase)) {
    Write-Section "Windows Development Machine Setup"
    Write-Info "Starting setup process..."
    Write-Info "Launching Phase 1 (Admin) with elevation..."

    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated"
    if ($SkipBloatware) { $arguments += " -SkipBloatware" }
    if ($SkipWSL) { $arguments += " -SkipWSL" }
    if ($Config -ne ".\config.ps1") { $arguments += " -Config `"$Config`"" }

    Start-Process pwsh -Verb RunAs -ArgumentList $arguments
    exit
}

################################################################################
# Load Configuration
################################################################################

if (-not (Test-Path $Config)) {
    Write-Error "Configuration file not found: $Config"
    Write-Info "Please copy config.example.ps1 to config.ps1 and customize it"
    Write-Info "Example: Copy-Item config.example.ps1 config.ps1"
    exit 1
}

Write-Info "Loading configuration from: $Config"
. $Config

################################################################################
# Phase 1: Admin Tasks
################################################################################

if ($Elevated) {
    Write-Section "Phase 1: Administrator Tasks"

    # Verify admin rights
    if (-not (Test-IsAdmin)) {
        Write-Error "This script must be run as Administrator for Phase 1"
        exit 1
    }

    #---------------------------------------------------------------------------
    # Pre-flight Checks
    #---------------------------------------------------------------------------

    Write-Section "Pre-flight Checks"

    Write-Info "Windows Version: $(( Get-CimInstance Win32_OperatingSystem).Caption)"
    Write-Info "PowerShell Version: $($PSVersionTable.PSVersion)"
    Write-Info "Architecture: $env:PROCESSOR_ARCHITECTURE"

    # Check if winget is available
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Error "winget is not available. Please install App Installer from Microsoft Store."
        exit 1
    }

    Write-Success "Pre-flight checks complete"

    #---------------------------------------------------------------------------
    # Remove Bloatware
    #---------------------------------------------------------------------------

    if (-not $SkipBloatware) {
        Write-Section "Removing Windows Bloatware"

        foreach ($pattern in $AppsToRemove) {
            Write-Info "Removing apps matching: $pattern"

            # Remove provisioned packages
            Get-AppxProvisionedPackage -Online |
                Where-Object DisplayName -Like $pattern |
                Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Out-Null

            # Remove installed packages
            Get-AppxPackage -AllUsers -Name $pattern |
                Remove-AppxPackage -ErrorAction SilentlyContinue | Out-Null
        }

        Write-Success "Bloatware removal complete"
    }

    #---------------------------------------------------------------------------
    # Windows System Settings
    #---------------------------------------------------------------------------

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

    # Set File Explorer to open to This PC
    if ($OpenFileExplorerTo -eq "ThisPC") {
        Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
                         -Name "LaunchTo" -Value 1
    }

    # Taskbar Settings
    Write-Info "Configuring Taskbar..."

    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" `
                     -Name "SearchboxTaskbarMode" -Value $TaskbarSearchBoxMode

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
                         -Name "UserPreferencesMask" -Value ([byte[]](144,18,3,128,16,0,0,0))
    }

    Write-Success "Windows system settings configured"

    #---------------------------------------------------------------------------
    # Install Core Development Tools
    #---------------------------------------------------------------------------

    Write-Section "Installing Core Development Tools"
    Install-WingetPackages -Packages $CoreDevTools -Category "core development tools"

    # Configure Windows Terminal as default
    Write-Info "Setting Windows Terminal as default console..."
    Set-RegistryValue -Path "HKCU:\Console" -Name "DelegationConsole" -Value 1 -Type DWord

    #---------------------------------------------------------------------------
    # Install fnm (Fast Node Manager)
    #---------------------------------------------------------------------------

    Write-Section "Installing fnm (Fast Node Manager)"
    Install-WingetPackage -PackageId "Schniz.fnm" -Name "fnm"

    # Add fnm to PATH for current session
    $env:Path += ";$env:LOCALAPPDATA\fnm"

    # Install Node.js
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
        Write-Success "Node.js installed: $nodeVer"
    }

    #---------------------------------------------------------------------------
    # Install .NET SDKs
    #---------------------------------------------------------------------------

    Write-Section "Installing .NET SDKs"

    foreach ($version in $DotNetSDKs) {
        Install-WingetPackage -PackageId "Microsoft.DotNet.SDK.$version" -Name ".NET SDK $version"
        Install-WingetPackage -PackageId "Microsoft.DotNet.HostingBundle.$version" -Name ".NET Hosting Bundle $version"
        Install-WingetPackage -PackageId "Microsoft.DotNet.AspNetCore.$version" -Name ".NET AspNetCore $version"
    }

    #---------------------------------------------------------------------------
    # Install Python
    #---------------------------------------------------------------------------

    Write-Section "Installing Python"
    Install-WingetPackage -PackageId "Python.Python.$PythonVersion" -Name "Python $PythonVersion"

    #---------------------------------------------------------------------------
    # Install Database Tools
    #---------------------------------------------------------------------------

    Write-Section "Installing Database Tools"
    Install-WingetPackages -Packages $DatabaseTools -Category "database tools"

    #---------------------------------------------------------------------------
    # Install API Testing Tools
    #---------------------------------------------------------------------------

    Write-Section "Installing API Testing Tools"
    Install-WingetPackages -Packages $APITestingTools -Category "API testing tools"

    #---------------------------------------------------------------------------
    # Install Cloud & DevOps Tools
    #---------------------------------------------------------------------------

    Write-Section "Installing Cloud & DevOps Tools"
    Install-WingetPackages -Packages $CloudDevOpsTools -Category "cloud & DevOps tools"

    #---------------------------------------------------------------------------
    # Install Kubernetes Tools
    #---------------------------------------------------------------------------

    Write-Section "Installing Kubernetes Tools"
    Install-WingetPackages -Packages $KubernetesTools -Category "Kubernetes tools"

    #---------------------------------------------------------------------------
    # Install Code Comparison/Merge Tools
    #---------------------------------------------------------------------------

    Write-Section "Installing Code Comparison Tools"
    Install-WingetPackages -Packages $MergeTools -Category "merge tools"

    #---------------------------------------------------------------------------
    # Install Text Editors
    #---------------------------------------------------------------------------

    Write-Section "Installing Text Editors"
    Install-WingetPackages -Packages $TextEditors -Category "text editors"

    #---------------------------------------------------------------------------
    # Install File Managers
    #---------------------------------------------------------------------------

    if ($FileManagers.Count -gt 0) {
        Write-Section "Installing File Managers"
        Install-WingetPackages -Packages $FileManagers -Category "file managers"
    }

    #---------------------------------------------------------------------------
    # Install Image Editors
    #---------------------------------------------------------------------------

    if ($ImageEditors.Count -gt 0) {
        Write-Section "Installing Image Editors"
        Install-WingetPackages -Packages $ImageEditors -Category "image editors"
    }

    #---------------------------------------------------------------------------
    # Install System Utilities
    #---------------------------------------------------------------------------

    Write-Section "Installing System Utilities"
    Install-WingetPackages -Packages $SystemUtilities -Category "system utilities"

    #---------------------------------------------------------------------------
    # Install Browsers
    #---------------------------------------------------------------------------

    Write-Section "Installing Browsers"
    Install-WingetPackages -Packages $Browsers -Category "browsers"

    #---------------------------------------------------------------------------
    # Install Communication & Productivity Tools
    #---------------------------------------------------------------------------

    Write-Section "Installing Communication & Productivity Tools"
    Install-WingetPackages -Packages $ProductivityTools -Category "productivity tools"

    #---------------------------------------------------------------------------
    # Install Other Tools
    #---------------------------------------------------------------------------

    if ($OtherTools.Count -gt 0) {
        Write-Section "Installing Other Tools"
        Install-WingetPackages -Packages $OtherTools -Category "other tools"
    }

    #---------------------------------------------------------------------------
    # Install Fonts
    #---------------------------------------------------------------------------

    Write-Section "Installing Developer Fonts"
    Install-WingetPackages -Packages $Fonts -Category "fonts"

    #---------------------------------------------------------------------------
    # Install Git Credential Manager
    #---------------------------------------------------------------------------

    Write-Section "Installing Git Credential Manager"
    Install-WingetPackage -PackageId "Microsoft.GitCredentialManager" -Name "Git Credential Manager"

    #---------------------------------------------------------------------------
    # Install WSL
    #---------------------------------------------------------------------------

    if (-not $SkipWSL) {
        Write-Section "Installing WSL"

        Write-Info "Installing WSL with $WSLDistro..."
        wsl --install -d $WSLDistro --no-launch
        wsl --set-default-version $WSLDefaultVersion

        Write-Success "WSL installed (distro will be configured in Phase 2)"
    }

    #---------------------------------------------------------------------------
    # Install NuGet Artifacts Credential Provider
    #---------------------------------------------------------------------------

    Write-Section "Installing NuGet Artifacts Credential Provider"
    Write-Info "Downloading and installing..."
    Invoke-Expression "& { $(Invoke-RestMethod https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"
    Write-Success "NuGet Artifacts Credential Provider installed"

    #---------------------------------------------------------------------------
    # Phase 1 Complete - Launch Phase 2
    #---------------------------------------------------------------------------

    Write-Section "Phase 1 Complete"
    Write-Success "Administrator tasks completed successfully"
    Write-Info "Launching Phase 2 (User tasks) in a non-elevated window..."

    $shell = New-Object -ComObject "Shell.Application"
    $arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -UserPhase -Config `"$Config`""
    if ($SkipWSL) { $arguments += " -SkipWSL" }
    $shell.ShellExecute("pwsh.exe", $arguments, "", "open", 1)

    exit
}

################################################################################
# Phase 2: User Tasks
################################################################################

if ($UserPhase) {
    Write-Section "Phase 2: User-Level Tasks"

    #---------------------------------------------------------------------------
    # WSL First-Run Configuration
    #---------------------------------------------------------------------------

    if (-not $SkipWSL) {
        Write-Section "WSL First-Run Configuration"
        Write-Info "Launching $WSLDistro for first-run setup..."
        Write-Warning "Please set up your Linux username and password"

        wsl -d $WSLDistro

        # Install development tools in WSL
        if ($InstallDevToolsInWSL) {
            Write-Info "Installing development tools in WSL..."

            wsl -d $WSLDistro -e bash -c "sudo apt update && sudo apt upgrade -y"
            wsl -d $WSLDistro -e bash -c "sudo apt install -y build-essential git curl wget"

            Write-Success "Development tools installed in WSL"
        }

        # Install zsh and oh-my-zsh
        if ($InstallZshInWSL) {
            Write-Info "Installing zsh and oh-my-zsh in WSL..."

            wsl -d $WSLDistro -e bash -c "sudo apt install -y zsh"
            wsl -d $WSLDistro -e bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
            wsl -d $WSLDistro -e bash -c "chsh -s $(which zsh)"

            Write-Success "zsh and oh-my-zsh installed in WSL"
        }

        Write-Success "WSL configuration complete"
    }

    #---------------------------------------------------------------------------
    # Git Configuration
    #---------------------------------------------------------------------------

    Write-Section "Git Configuration"

    Write-Info "Configuring Git settings..."

    git config --global pull.rebase false
    git config --global core.autocrlf false
    git config --global core.eol lf
    git config --global init.defaultBranch $GitDefaultBranch
    git config --global core.editor "code --wait"
    git config --global merge.tool kdiff3
    git config --global diff.tool kdiff3

    # User info
    if ($GitUserName -and $GitUserEmail) {
        Write-Info "Setting Git user: $GitUserName <$GitUserEmail>"
        git config --global user.name $GitUserName
        git config --global user.email $GitUserEmail
    }
    else {
        Write-Info "Enter your Git user information:"
        $name = Read-Host "  Full name"
        $email = Read-Host "  Email"
        git config --global user.name $name
        git config --global user.email $email
    }

    git config --global --add safe.directory "*"

    # Create global .gitignore
    Write-Info "Creating global .gitignore..."
    $gitignoreContent = @"
# OS Files
.DS_Store
Thumbs.db
desktop.ini

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Build artifacts
bin/
obj/
node_modules/
dist/
build/

# Environment files
.env.local
.env.*.local
"@

    $gitignorePath = "$env:USERPROFILE\.gitignore_global"
    $gitignoreContent | Out-File -FilePath $gitignorePath -Encoding UTF8
    git config --global core.excludesfile $gitignorePath

    Write-Success "Git configuration complete"

    #---------------------------------------------------------------------------
    # GitHub CLI Authentication
    #---------------------------------------------------------------------------

    Write-Section "GitHub CLI Authentication"
    Write-Info "Please authenticate with GitHub CLI..."
    gh auth login

    #---------------------------------------------------------------------------
    # VS Code Extensions
    #---------------------------------------------------------------------------

    Write-Section "Installing VS Code Extensions"

    # Wait for VS Code to be available
    $maxAttempts = 10
    $attempt = 1
    while (-not (Get-Command code -ErrorAction SilentlyContinue) -and $attempt -le $maxAttempts) {
        Write-Info "Waiting for VS Code to be available (attempt $attempt/$maxAttempts)..."
        Start-Sleep -Seconds 3
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        $attempt++
    }

    if (Get-Command code -ErrorAction SilentlyContinue) {
        foreach ($extension in $VSCodeExtensions) {
            Install-VSCodeExtension -ExtensionId $extension
        }
        Write-Success "VS Code extensions installation complete"
    }
    else {
        Write-Warning "VS Code not found. Please install extensions manually later."
    }

    #---------------------------------------------------------------------------
    # Install Global npm Packages
    #---------------------------------------------------------------------------

    Write-Section "Installing Global npm Packages"

    foreach ($package in $NpmGlobalPackages) {
        # Check if already installed
        $installed = npm list -g $package 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Info "✓ $package already installed"
        }
        else {
            Write-Info "Installing $package..."
            npm install -g $package
            if ($LASTEXITCODE -eq 0) {
                Write-Success "$package installed"
            }
            else {
                Write-Warning "Failed to install $package"
            }
        }
    }

    Write-Success "npm packages installation complete"

    #---------------------------------------------------------------------------
    # Setup Complete
    #---------------------------------------------------------------------------

    Write-Section "Setup Complete!"
    Write-Success "Your Windows development environment is ready!"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Restart your terminal or refresh PATH"
    Write-Host "  2. Verify installations:"
    Write-Host "     - node --version"
    Write-Host "     - npm --version"
    Write-Host "     - dotnet --version"
    Write-Host "     - git --version"
    Write-Host ""
    Write-Info "To clone repositories, run: .\clone-repos.ps1"
    Write-Info "To customize your setup, edit: $Config"
    Write-Host ""

    exit
}
