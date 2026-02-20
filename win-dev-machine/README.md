# Windows Development Machine Setup

Automated setup for Windows 11 development environments using PowerShell. Designed for developers working with Node.js, TypeScript, .NET, C#, and web applications.

## Features

- **Modular Scripts**: Separate scripts for admin and user tasks, with shared helper functions
- **Two-Phase Setup**: Admin phase (elevated) installs software, user phase configures tools
- **Standalone Phases**: Run each phase independently for partial setups or retries
- **Idempotent**: Safe to run multiple times - skips already-installed packages
- **Customizable**: All software and settings controlled via a single configuration file
- **Logged**: All output written to `%TEMP%\dev-setup.log` for debugging

## Prerequisites

- Windows 10 or 11
- PowerShell 5.1+
- Administrator access
- Internet connection

## Quick Start

1. **Clone this repository**:
   ```powershell
   git clone <repository-url>
   cd DevMachineSetup\win-dev-machine
   ```

2. **Create your configuration file**:
   ```powershell
   Copy-Item config.example.ps1 config.ps1
   ```

3. **Customize your setup** (optional but recommended):
   ```powershell
   code config.ps1
   ```
   Set your Git name and email, modify package lists, adjust system preferences.

4. **Run the setup**:
   ```powershell
   .\setup.ps1
   ```

5. **Follow the prompts**:
   - Approve the UAC elevation prompt
   - Phase 1 (Admin): Installs software, configures system settings, removes bloatware
   - Phase 2 (User): Configures Git, VS Code extensions, npm packages, WSL

6. **Clone your repositories** (optional):
   ```powershell
   .\clone-repos.ps1
   ```

## Directory Structure

```
win-dev-machine/
├── setup.ps1              # Entry point - orchestrates both phases
├── setup-admin.ps1        # Phase 1: Admin tasks (elevated)
├── setup-user.ps1         # Phase 2: User tasks (non-elevated)
├── functions.ps1          # Shared helper functions
├── clone-repos.ps1        # Repository cloning script
├── config.example.ps1     # Configuration template
├── config.ps1             # Your custom configuration (gitignored)
└── README.md              # This file
```

### Script Responsibilities

| Script | Elevation | Purpose |
|--------|-----------|---------|
| `setup.ps1` | No | Entry point. Runs pre-flight checks, launches admin phase elevated, then runs user phase. |
| `setup-admin.ps1` | Yes (Admin) | Removes bloatware, configures Windows settings, installs all software via winget, installs WSL. |
| `setup-user.ps1` | No | Configures Git, GitHub CLI auth, VS Code extensions, npm packages, WSL first-run setup. |
| `functions.ps1` | N/A | Shared helpers: colored output, logging, winget/VS Code installers, registry helpers. |
| `clone-repos.ps1` | No | Clones configured GitHub repositories. |

## What Gets Installed

### Development Tools
- **Node.js**: via fnm (Fast Node Manager) - latest LTS by default
- **.NET SDK**: .NET 8 LTS and .NET 9 (configurable versions)
- **Python**: Python 3.11 with pip
- **Version Control**: Git, Git Credential Manager, GitHub CLI, GitHub Desktop
- **IDEs**: Visual Studio Code, Visual Studio 2022 Professional
- **Package Managers**: npm, yarn, pnpm

### Applications
- **Docker**: Docker Desktop
- **Databases**: MySQL, MySQL Workbench, MySQL Shell
- **API Testing**: Postman, Bruno
- **Cloud Tools**: AWS CLI, AWS VPN Client
- **Kubernetes**: kubectl, Helm, Lens
- **Code Comparison**: KDiff3, WinMerge
- **Text Editors**: Notepad++
- **Browsers**: Chrome, Firefox, Edge

### System Utilities
- **PowerToys**: Window management, clipboard history, quick launcher
- **Windows Terminal**: Modern terminal with tabs
- **Sysinternals Suite**: System administration utilities

### Communication & Productivity
- Zoom, 1Password, Notion, Obsidian, LINQPad

### Fonts
- JetBrains Mono, Fira Code, Cascadia Code, Hack Nerd Font

### Windows System Settings
- **Explorer**: Show file extensions, hidden files, full path in title bar
- **Taskbar**: Customizable search box, task view button
- **Privacy**: Disable telemetry, advertising ID, location tracking
- **Dark Mode**: System-wide dark theme
- **Bloatware Removal**: Removes unnecessary Windows apps

### WSL (Windows Subsystem for Linux)
- Ubuntu LTS with WSL 2
- Optional zsh and oh-my-zsh setup
- Development tools (git, build-essential, curl, wget)

### VS Code Extensions
- C# DevKit, ESLint, Prettier, Docker, Kubernetes
- Remote WSL, Remote Containers, GitLens
- GitHub Copilot, Claude Code, Material Icon Theme, and more

## Command Line Options

```powershell
# Full setup (admin + user phases)
.\setup.ps1

# Skip bloatware removal
.\setup.ps1 -SkipBloatware

# Skip WSL installation and configuration
.\setup.ps1 -SkipWSL

# Use a custom configuration file
.\setup.ps1 -Config .\my-config.ps1

# Combine options
.\setup.ps1 -SkipBloatware -SkipWSL

# Run phases independently
.\setup-admin.ps1                  # Must run as Administrator
.\setup-user.ps1                   # Run as normal user
.\setup-admin.ps1 -SkipBloatware   # Admin phase without bloatware removal

# Clone repositories
.\clone-repos.ps1
```

## Configuration

All customization is done in `config.ps1`. Copy the example template and modify:

```powershell
Copy-Item config.example.ps1 config.ps1
```

### Key Settings

```powershell
# Git
$GitUserName = "Your Name"
$GitUserEmail = "your.email@example.com"

# Node.js - "lts" or a specific version like "20.15.0"
$NodeVersion = "lts"

# .NET SDK versions to install
$DotNetSDKs = @("8", "9")

# Windows settings
$UseDarkMode = $true
$ShowFileExtensions = $true
$DisableTelemetry = $true
```

### Adding/Removing Software

Each software category is an array of winget package IDs. Add or comment out entries:

```powershell
$CoreDevTools = @(
    "Git.Git"
    "Microsoft.VisualStudioCode"
    "MyNewTool.Package"            # Add new packages
    # "Docker.DockerDesktop"       # Comment out to skip
)
```

Find package IDs with `winget search <name>`.

### Repository Cloning

```powershell
$GitHubOrg = "YourOrgName"
$RepositoriesToClone = @("repo1", "repo2", "repo3")
$CodeDirectory = "C:\Code"
```

## Troubleshooting

### Script Won't Run - Execution Policy

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Winget Not Found

Install App Installer from the Microsoft Store, or run:
```powershell
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

### Package Installation Fails

Update winget sources and retry:
```powershell
winget source update
winget install --id <package-id>
```

### VS Code Extensions Fail

If VS Code isn't in PATH after installation, restart your terminal or run the user phase again:
```powershell
.\setup-user.ps1
```

### WSL Installation Issues

1. Enable virtualization in BIOS
2. Run: `wsl --install --no-distribution`
3. Restart computer
4. Run: `wsl --install -d Ubuntu`

### Node/fnm Not Found After Installation

Restart your terminal to refresh PATH, or manually add:
```powershell
$env:Path += ";$env:LOCALAPPDATA\fnm"
```

### Checking the Log File

All script output is logged for debugging:
```powershell
notepad $env:TEMP\dev-setup.log
```

## Maintenance

### Keeping Software Updated

```powershell
winget upgrade --all       # Update all winget packages
npm update -g              # Update global npm packages
wsl --update               # Update WSL
```

### Re-running After Changes

The scripts are idempotent. Re-run anytime to apply config changes or reinstall missing tools:
```powershell
.\setup.ps1
```

Or run individual phases:
```powershell
.\setup-admin.ps1    # Re-run admin tasks only
.\setup-user.ps1     # Re-run user tasks only
```

## Migration to New PC

1. **From your old PC**: Copy or commit your `config.ps1`
2. **On your new PC**:
   ```powershell
   git clone <repository-url>
   cd DevMachineSetup\win-dev-machine
   # Copy your config.ps1 into this directory
   .\setup.ps1
   .\clone-repos.ps1
   ```
3. **Manually migrate**: SSH keys (`~\.ssh\`), VS Code settings (or use Settings Sync)

## Quick Reference

```powershell
.\setup.ps1                # Full setup
.\setup-admin.ps1          # Admin tasks only
.\setup-user.ps1           # User tasks only
.\clone-repos.ps1          # Clone repositories
winget upgrade --all       # Update all packages
fnm list                   # List installed Node versions
fnm use 20                 # Switch Node version
```

### File Locations After Setup

| Item | Location |
|------|----------|
| Node.js | `%LOCALAPPDATA%\fnm\` |
| Git config | `~\.gitconfig` |
| Global .gitignore | `~\.gitignore_global` |
| VS Code settings | `%APPDATA%\Code\User\` |
| Setup log | `%TEMP%\dev-setup.log` |
| Configuration | `.\config.ps1` |
| Repositories | `C:\Code\` (or configured path) |
