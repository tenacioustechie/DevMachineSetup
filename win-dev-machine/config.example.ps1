# Windows Development Machine Configuration Template
#
# Copy this file to config.ps1 and customize for your environment
# cp config.example.ps1 config.ps1
#
# The config.ps1 file is gitignored so your personal settings stay private

################################################################################
# Git Configuration
################################################################################

$GitUserName = ""        # Your full name (leave empty to prompt during setup)
$GitUserEmail = ""       # Your email (leave empty to prompt during setup)
$GitDefaultBranch = "main"

################################################################################
# Node.js Configuration
################################################################################

$NodeVersion = "lts"     # "lts" for latest LTS, or specify version like "20.15.0"

# Global npm packages to install
$NpmGlobalPackages = @(
    "@angular/cli"
    "typescript"
    "ts-node"
    "yarn"
    "pnpm"
    "npm-check-updates"
)

################################################################################
# .NET Configuration
################################################################################

# .NET SDK versions to install (multiple versions supported)
$DotNetSDKs = @(
    "8"    # .NET 8 LTS
    "9"    # .NET 9 (latest)
)

################################################################################
# Python Configuration
################################################################################

$PythonVersion = "3.11"  # Or "3.10", "3.12", etc.

################################################################################
# Development Tools
################################################################################

# Core development tools (always installed)
$CoreDevTools = @(
    "Git.Git"
    "GitHub.cli"
    "GitHub.GitHubDesktop"
    "Microsoft.VisualStudioCode"
    "Microsoft.VisualStudio.2022.Professional"
    "Docker.DockerDesktop"
    "Microsoft.PowerToys"
    "Microsoft.WindowsTerminal"
)

# Database tools
$DatabaseTools = @(
    "Oracle.MySQL"
    "Oracle.MySQLWorkbench"
    "Oracle.MySQLShell"
    # "Microsoft.AzureDataStudio"    # Uncomment if needed
    # "dbeaver.dbeaver"              # Uncomment if needed
)

# API testing tools
$APITestingTools = @(
    "Postman.Postman"
    "Bruno.Bruno"
    # Other alternatives: Insomnia, Hoppscotch (web-based), Thunder Client (VS Code extension)
)

# Cloud & DevOps tools
$CloudDevOpsTools = @(
    "Amazon.AWSCLI"
    "Amazon.AWSVPNClient"
    # "Microsoft.AzureCLI"           # Uncomment if needed
    # "Hashicorp.Terraform"          # Uncomment if needed
)

# Kubernetes tools
$KubernetesTools = @(
    "Kubernetes.kubectl"
    "Helm.Helm"
    "Lens.Lens"                      # Kubernetes IDE
)

# Code comparison/merge tools
$MergeTools = @(
    "KDiff3.KDiff3"
    "WinMerge.WinMerge"
)

# Text editors
$TextEditors = @(
    "Notepad++.Notepad++"
    # "SublimeHQ.SublimeText.4"     # Uncomment if needed
)

# File managers
$FileManagers = @(
    # "ghisler.totalcommander"      # Uncomment if needed (paid)
    # "DoubleCommander.DoubleCommander"  # Uncomment if needed (free)
)

# Image editors
$ImageEditors = @(
    # "dotPDN.PaintDotNet"          # Uncomment if needed
    # "GIMP.GIMP"                   # Uncomment if needed
)

# System utilities
$SystemUtilities = @(
    "Microsoft.Sysinternals"
)

# Browsers
$Browsers = @(
    "Google.Chrome"
    "Mozilla.Firefox"
    "Microsoft.Edge"                 # Good for testing
)

# Communication & Productivity
$ProductivityTools = @(
    "Zoom.Zoom"
    "AgileBits.1Password"
    "Notion.Notion"
    "Obsidian.Obsidian"
)

# Other tools
$OtherTools = @(
    "LINQPad.LINQPad.8"
)

################################################################################
# Fonts
################################################################################

$Fonts = @(
    "JetBrains.Mono"
    "Fira.Code"
    "Cascadia.Code"
    "Nerd.Fonts.Hack"
)

################################################################################
# VS Code Extensions
################################################################################

$VSCodeExtensions = @(
    # C# / .NET
    "ms-dotnettools.csdevkit"
    "ms-dotnettools.csharp"

    # JavaScript / TypeScript
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    # "angular.ng-template"                    # Uncomment if using Angular

    # Python
    # "ms-python.python"                       # Uncomment if using Python

    # Docker & Kubernetes
    "ms-azuretools.vscode-docker"
    "ms-kubernetes-tools.vscode-kubernetes-tools"

    # Remote Development
    "ms-vscode-remote.remote-wsl"
    "ms-vscode-remote.remote-containers"

    # Git
    "eamodio.gitlens"

    # AI Assistants
    "github.copilot"
    "saoudrizwan.claude-dev"                  # Claude Code

    # Themes & Icons
    "pkief.material-icon-theme"

    # Utilities
    "editorconfig.editorconfig"
    "bradlc.vscode-tailwindcss"
    "hashicorp.terraform"
)

################################################################################
# WSL Configuration
################################################################################

$WSLDistro = "Ubuntu"    # Ubuntu LTS
$WSLDefaultVersion = 2   # WSL 2 is faster and more compatible

# Install zsh and oh-my-zsh in WSL?
$InstallZshInWSL = $true

# Install development tools in WSL?
$InstallDevToolsInWSL = $true  # git, build-essential, etc.

################################################################################
# Windows System Settings
################################################################################

# Explorer Settings
$ShowFileExtensions = $true
$ShowHiddenFiles = $true
$ShowFullPathInTitleBar = $true
$OpenFileExplorerTo = "ThisPC"  # "ThisPC" or "QuickAccess"

# Taskbar Settings
$TaskbarAutoHide = $false
$TaskbarSearchBoxMode = 1        # 0=Hidden, 1=Icon, 2=Box
$TaskbarShowTaskView = $false    # Task View button

# Performance Settings
$DisableAnimations = $false      # Set to $true for better performance
$VisualEffectsForPerformance = $false  # Set to $true for best performance

# Privacy Settings
$DisableTelemetry = $true
$DisableAdvertisingId = $true
$DisableLocationTracking = $true

# Power Settings
$PowerPlanHighPerformance = $true  # Use High Performance power plan
$NeverSleep = $false               # Never sleep when plugged in

# Dark Mode
$UseDarkMode = $true

################################################################################
# Bloatware Removal
################################################################################

# Windows apps to remove (add or remove as needed)
$AppsToRemove = @(
    "*3DPrint*"
    "Microsoft.MixedReality.Portal"
    "MSIX\Clipchamp.Clipchamp*"
    "MSIX\Microsoft.BingNews*"
    "Microsoft.Teams.Free"
    "MSIX\MicrosoftCorporationII.MicrosoftFamily*"
    "MSIX\Microsoft.ZuneVideo*"
    "MSIX\Microsoft.Xbox.TCUI*"
    "MSIX\Microsoft.XboxGameOverlay*"
    "MSIX\Microsoft.XboxGamingOverlay*"
    "MSIX\Microsoft.XboxIdentityProvider*"
    "MSIX\Microsoft.XboxSpeechToTextOverlay*"
    "MSIX\Microsoft.WindowsMaps*"
    "MSIX\Microsoft.OutlookForWindows*"
    "MSIX\Microsoft.MicrosoftOfficeHub*"
    "MSIX\Microsoft.MicrosoftStickyNotes*"
    "MSIX\Microsoft.GamingApp*"
)

################################################################################
# Repository Configuration (for clone-repos.ps1)
################################################################################

# GitHub organization or username
$GitHubOrg = "YourOrgName"

# Repositories to clone
$RepositoriesToClone = @(
    # "repo1"
    # "repo2"
    # "repo3"
)

# Base directory for repositories
$CodeDirectory = "C:\Code"

################################################################################
# Notes & Tips
################################################################################

# Winget Package Search:
# - Search: winget search <name>
# - Get exact ID: winget show <package-id>
# - Find fonts: winget search "font"
#
# VS Code Extension Search:
# - Search: code --list-extensions
# - Get ID from: https://marketplace.visualstudio.com/
#
# Alternative API Testing Tools:
# - Insomnia.Insomnia - REST/GraphQL client
# - Hoppscotch (web-based, formerly Postwoman)
# - Thunder Client - VS Code extension (already lightweight)
# - REST Client - VS Code extension (HTTP files)
#
# To use this config:
# 1. Copy this file: cp config.example.ps1 config.ps1
# 2. Edit config.ps1 with your preferences
# 3. Run: .\setup.ps1
