<#
.SYNOPSIS
    Windows Development Machine Setup - User Phase

.DESCRIPTION
    Performs user-level tasks that do not require elevation:
      - WSL first-run configuration
      - Git configuration
      - GitHub CLI authentication
      - VS Code extensions
      - Global npm packages

    This script is normally launched by setup.ps1 but can be run independently.

.PARAMETER SkipWSL
    Skip WSL configuration

.PARAMETER Config
    Path to configuration file (default: .\config.ps1)

.EXAMPLE
    .\setup-user.ps1
    Run user setup with default config

.EXAMPLE
    .\setup-user.ps1 -SkipWSL
    Skip WSL configuration
#>

param(
    [switch]$SkipWSL,
    [string]$Config = ".\config.ps1"
)

# Load shared functions and config
. "$PSScriptRoot\functions.ps1"
Load-Config -ConfigPath $Config

Write-Section "User-Level Setup"

################################################################################
# WSL First-Run Configuration
################################################################################

if (-not $SkipWSL) {
    Write-Section "WSL First-Run Configuration"

    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        Write-Info "Launching $WSLDistro for first-run setup..."
        Write-Warn "Please set up your Linux username and password when prompted"

        wsl -d $WSLDistro

        # Install development tools in WSL
        if ($InstallDevToolsInWSL) {
            Write-Info "Installing development tools in WSL..."
            wsl -d $WSLDistro -e bash -c "sudo apt update && sudo apt upgrade -y"
            wsl -d $WSLDistro -e bash -c "sudo apt install -y build-essential git curl wget"
            Write-Ok "Development tools installed in WSL"
        }

        # Install zsh and oh-my-zsh
        if ($InstallZshInWSL) {
            Write-Info "Installing zsh and oh-my-zsh in WSL..."
            wsl -d $WSLDistro -e bash -c "sudo apt install -y zsh"
            wsl -d $WSLDistro -e bash -c 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'
            wsl -d $WSLDistro -e bash -c 'sudo chsh -s /usr/bin/zsh $(whoami)'
            Write-Ok "zsh and oh-my-zsh installed in WSL"
        }

        Write-Ok "WSL configuration complete"
    }
    else {
        Write-Warn "WSL command not found. WSL may not have been installed yet."
        Write-Info "Run setup-admin.ps1 first, or install WSL manually: wsl --install"
    }
}

################################################################################
# Git Configuration
################################################################################

Write-Section "Git Configuration"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Warn "Git not found in PATH. Refreshing..."
    Update-PathFromRegistry
}

if (Get-Command git -ErrorAction SilentlyContinue) {
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
        Write-Info "Setting Git user: $GitUserName $GitUserEmail"
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

    # Create global .gitignore (using array join to avoid here-string CRLF issues)
    Write-Info "Creating global .gitignore..."

    $gitignoreLines = @(
        "# OS Files"
        ".DS_Store"
        "Thumbs.db"
        "desktop.ini"
        ""
        "# IDE"
        ".vscode/"
        ".idea/"
        "*.swp"
        "*.swo"
        "*~"
        ""
        "# Build artifacts"
        "bin/"
        "obj/"
        "node_modules/"
        "dist/"
        "build/"
        ""
        "# Environment files"
        ".env.local"
        ".env.*.local"
    )

    $gitignorePath = Join-Path $env:USERPROFILE ".gitignore_global"
    $gitignoreLines -join "`r`n" | Out-File -FilePath $gitignorePath -Encoding UTF8
    git config --global core.excludesfile $gitignorePath

    Write-Ok "Git configuration complete"
}
else {
    Write-Err "Git not found. Please install Git first (run setup-admin.ps1)."
}

################################################################################
# GitHub CLI Authentication
################################################################################

Write-Section "GitHub CLI Authentication"

if (Get-Command gh -ErrorAction SilentlyContinue) {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Already authenticated with GitHub CLI"
    }
    else {
        Write-Info "Please authenticate with GitHub CLI..."
        gh auth login
    }
}
else {
    Write-Warn "GitHub CLI (gh) not found. Skipping authentication."
    Write-Info "Install it later and run: gh auth login"
}

################################################################################
# VS Code Extensions
################################################################################

Write-Section "Installing VS Code Extensions"

# Wait for VS Code to be available (may have just been installed)
$maxAttempts = 10
$attempt = 1
while (-not (Get-Command code -ErrorAction SilentlyContinue) -and $attempt -le $maxAttempts) {
    Write-Info "Waiting for VS Code to be available (attempt $attempt/$maxAttempts)..."
    Start-Sleep -Seconds 3
    Update-PathFromRegistry
    $attempt++
}

if (Get-Command code -ErrorAction SilentlyContinue) {
    if ($null -ne $VSCodeExtensions -and $VSCodeExtensions.Count -gt 0) {
        foreach ($extension in $VSCodeExtensions) {
            Install-VSCodeExtension -ExtensionId $extension
        }
        Write-Ok "VS Code extensions installation complete"
    }
    else {
        Write-Info "No VS Code extensions configured"
    }
}
else {
    Write-Warn "VS Code not found in PATH. Please install extensions manually later."
}

################################################################################
# Global npm Packages
################################################################################

Write-Section "Installing Global npm Packages"

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Update-PathFromRegistry
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    if ($null -ne $NpmGlobalPackages -and $NpmGlobalPackages.Count -gt 0) {
        foreach ($package in $NpmGlobalPackages) {
            $installed = npm list -g $package 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Info "$package already installed"
            }
            else {
                Write-Info "Installing $package..."
                npm install -g $package
                if ($LASTEXITCODE -eq 0) {
                    Write-Ok "$package installed"
                }
                else {
                    Write-Warn "Failed to install $package"
                }
            }
        }
        Write-Ok "npm packages installation complete"
    }
    else {
        Write-Info "No global npm packages configured"
    }
}
else {
    Write-Warn "npm not found in PATH. Please install npm packages manually later."
}

################################################################################
# Setup Complete
################################################################################

Write-Section "Setup Complete!"
Write-Ok "Your Windows development environment is ready!"
Write-Host ""
Write-Info "Next steps:"
Write-Host "  1. Restart your terminal or log out/in to refresh PATH"
Write-Host "  2. Verify installations:"
Write-Host "       node --version"
Write-Host "       npm --version"
Write-Host "       dotnet --version"
Write-Host "       git --version"
Write-Host ""
Write-Info "To clone repositories, run: .\clone-repos.ps1"
Write-Info "Log file: $script:LogFile"
Write-Host ""
