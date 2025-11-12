# Windows Development Machine Setup

Automated setup for Windows 11 development environments using PowerShell. This setup is designed for developers working with Node.js, TypeScript, .NET, C#, and web applications.

## Features

- **Simple PowerShell Scripts**: Direct PowerShell scripts with colored output
- **Two-Phase Setup**: Automatic elevation handling (admin phase + user phase)
- **Idempotent**: Safe to run multiple times without causing issues
- **Comprehensive**: Installs development tools, configures system settings, removes bloatware
- **Customizable**: Easy to modify via configuration file
- **Fast**: No framework overhead, runs directly on Windows

## What Gets Configured

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
- **Zoom**: Video conferencing
- **1Password**: Password manager
- **Notion**: Note-taking and collaboration
- **Obsidian**: Knowledge management
- **LINQPad**: .NET scratchpad

### Fonts
- JetBrains Mono
- Fira Code
- Cascadia Code
- Hack Nerd Font

### Windows System Settings
- **Explorer**: Show file extensions, hidden files, full path in title bar
- **Taskbar**: Customizable search box, task view button
- **Privacy**: Disable telemetry, advertising ID, location tracking
- **Dark Mode**: System-wide dark theme
- **Performance**: Optional animation disabling for better performance
- **Bloatware Removal**: Removes unnecessary Windows apps

### WSL (Windows Subsystem for Linux)
- Ubuntu LTS installation
- Automatic zsh and oh-my-zsh setup
- Development tools (git, build-essential)
- WSL 2 for better performance

### VS Code Extensions
- C# DevKit, C# extension
- ESLint, Prettier
- Docker, Kubernetes
- Remote - WSL, Remote - Containers
- GitLens
- GitHub Copilot
- Claude Code (Claude Dev)
- Material Icon Theme
- And more...

## Prerequisites

- Windows 11 (or Windows 10 with recent updates)
- PowerShell 5.1+ (PowerShell 7+ recommended)
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
   notepad config.ps1
   # or
   code config.ps1

   # Set your Git name and email
   # Modify package lists to add/remove software
   # Adjust system preferences to your liking
   ```

4. **Run the setup script**:
   ```powershell
   .\setup.ps1
   ```

5. **Follow the prompts**:
   - Script will auto-elevate for admin tasks
   - Phase 1 (Admin): Installs software and configures system
   - Phase 2 (User): Configures WSL, Git, VS Code extensions
   - Total time: 20-40 minutes depending on internet speed

6. **Clone your repositories** (optional):
   ```powershell
   .\clone-repos.ps1
   ```

## Directory Structure

```
win-dev-machine/
├── setup.ps1              # Main setup script
├── clone-repos.ps1        # Repository cloning script
├── config.example.ps1     # Configuration template
├── config.ps1             # Your custom configuration (gitignored)
└── README.md              # This file
```

## Configuration

All customization is done in [config.ps1](config.example.ps1). Copy the example and modify:

### Basic Configuration

```powershell
# Git settings
$GitUserName = "Your Name"
$GitUserEmail = "your.email@example.com"
$GitDefaultBranch = "main"

# Node.js version
$NodeVersion = "lts"  # or "20.15.0" for specific version

# .NET versions
$DotNetSDKs = @("8", "9")
```

### Adding/Removing Software

```powershell
# Add a new package
$CoreDevTools = @(
    "Git.Git"
    "Microsoft.VisualStudioCode"
    "MyNewTool.Package"  # Add this
)

# Comment out unwanted packages
$TextEditors = @(
    "Notepad++.Notepad++"
    # "SublimeHQ.SublimeText.4"  # Commented out
)
```

### Windows System Settings

```powershell
# Explorer settings
$ShowFileExtensions = $true
$ShowHiddenFiles = $true

# Privacy settings
$DisableTelemetry = $true
$DisableAdvertisingId = $true

# Dark mode
$UseDarkMode = $true
```

### Repository Cloning

```powershell
# Configure for clone-repos.ps1
$GitHubOrg = "YourOrgName"
$RepositoriesToClone = @(
    "repo1"
    "repo2"
    "repo3"
)
$CodeDirectory = "C:\Code"
```

## Command Line Options

```powershell
# Full setup
.\setup.ps1

# Skip bloatware removal
.\setup.ps1 -SkipBloatware

# Skip WSL installation
.\setup.ps1 -SkipWSL

# Use custom configuration file
.\setup.ps1 -Config .\my-config.ps1

# Clone repositories
.\clone-repos.ps1
```

## Updating Your Environment

To update installed packages and apply configuration changes:

```powershell
.\setup.ps1
```

The script is idempotent and will skip already-installed packages.

## Maintenance

### Keeping Software Updated

Update winget packages:
```powershell
winget upgrade --all
```

Update npm global packages:
```powershell
npm update -g
```

Update WSL:
```powershell
wsl --update
```

### Re-running After Windows Updates

After major Windows updates, re-run the setup:
```powershell
.\setup.ps1
```

This will:
- Reinstall any missing components
- Reapply system settings
- Update development tools

## Troubleshooting

### Script Won't Run - Execution Policy

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Winget Not Found

Install App Installer from Microsoft Store, or run:
```powershell
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

### Package Installation Fails

Try updating winget:
```powershell
winget source update
```

Or install manually:
```powershell
winget install --id <package-id>
```

### VS Code Extensions Fail

If VS Code isn't in PATH immediately:
1. Restart PowerShell
2. Manually install extensions: `code --install-extension <extension-id>`

### WSL Installation Issues

If WSL fails to install:
1. Enable virtualization in BIOS
2. Run: `wsl --install --no-distribution`
3. Restart computer
4. Run: `wsl --install -d Ubuntu`

### Node/fnm Not Found After Installation

Restart your terminal to refresh PATH, or manually add:
```powershell
$env:Path += ";$env:LOCALAPPDATA\fnm"
```

### Git Credential Manager Issues

If authentication fails:
```powershell
git config --global credential.helper manager
```

## Two-Phase Setup Explained

The setup uses a two-phase approach for security and reliability:

**Phase 1 (Administrator)**:
- Runs with elevated privileges
- Removes bloatware
- Configures Windows system settings
- Installs all software via winget
- Installs WSL (but doesn't launch it)
- Automatically launches Phase 2 when complete

**Phase 2 (User-level)**:
- Runs without elevation (normal user)
- Configures WSL (username/password setup)
- Sets up Git configuration
- Authenticates with GitHub CLI
- Installs VS Code extensions
- Installs global npm packages

This separation ensures:
- Security: Minimal actions run as admin
- Reliability: User-level configs don't need elevation
- Better experience: WSL setup is interactive

## Migration to New PC

To set up a new Windows PC with your existing configuration:

1. **On your old PC**:
   - Commit any custom changes to `config.ps1`
   - Push changes to your repository (or copy config.ps1)

2. **On your new PC**:
   - Clone the repository
   - Copy your `config.ps1`
   - Run `.\setup.ps1`
   - Run `.\clone-repos.ps1`

3. **Manually migrate**:
   - SSH keys from `~\.ssh\`
   - VS Code settings (or use Settings Sync)
   - Application-specific data

4. **Optional**: Use Windows Backup for:
   - User files and documents
   - Application settings not covered by automation

## Architecture

This setup uses a straightforward PowerShell approach:

1. **setup.ps1** loads **config.ps1**
2. Auto-elevates for Phase 1 (admin tasks)
3. Phase 1 installs software and configures system
4. Phase 1 launches Phase 2 (user tasks)
5. Phase 2 configures user-level settings
6. Each step checks if already completed (idempotent)
7. Colored output shows progress

This matches the Mac setup approach - simple, direct, and effective!

## Comparison to Old Script

**Improvements over old `runme.ps1`**:

1. **Configuration File**: Separate config.ps1 (gitignored)
2. **Colored Output**: Clear progress indicators
3. **Better Idempotency**: Checks before installing
4. **More Tools**: fnm, Kubernetes, Bruno, more fonts
5. **System Settings**: Configures Windows preferences
6. **Separate Repo Script**: clone-repos.ps1 for flexibility
7. **Better Documentation**: Comprehensive README
8. **Latest Node**: Uses fnm with LTS auto-install
9. **.NET 9**: Includes latest .NET version
10. **VS Code Extensions**: Automated installation

## Finding Package IDs

### Winget Packages

```powershell
# Search for a package
winget search "package name"

# Get exact ID
winget show "Package.ID"

# Example
winget search vscode
winget show Microsoft.VisualStudioCode
```

### VS Code Extensions

Visit [VS Code Marketplace](https://marketplace.visualstudio.com/) or:

```powershell
# List installed extensions
code --list-extensions

# Search in marketplace
# Extension ID format: publisher.extension-name
```

## Alternative Tools Mentioned

### API Testing
- **Postman**: Full-featured, popular
- **Bruno**: Lightweight, open-source, Git-friendly
- **Insomnia**: REST/GraphQL client
- **Thunder Client**: VS Code extension
- **REST Client**: VS Code extension for .http files

### File Managers
- **Total Commander**: Powerful (paid)
- **Double Commander**: Free alternative

### Image Editors
- **Paint.NET**: Simple, fast
- **GIMP**: Full-featured, free Photoshop alternative

## Resources

- [Winget Documentation](https://docs.microsoft.com/en-us/windows/package-manager/winget/)
- [fnm (Fast Node Manager)](https://github.com/Schniz/fnm)
- [PowerToys](https://docs.microsoft.com/en-us/windows/powertoys/)
- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [VS Code Documentation](https://code.visualstudio.com/docs)

## License

This setup configuration is provided as-is for personal use. Modify as needed for your environment.

---

## Quick Reference

### Common Commands

```powershell
# Full setup
.\setup.ps1

# Clone repositories
.\clone-repos.ps1

# Update all winget packages
winget upgrade --all

# Update npm packages
npm update -g

# List installed winget packages
winget list

# Check Node versions
fnm list

# Switch Node version
fnm use 18.18.0
```

### File Locations After Setup

- Node.js: Managed by fnm in `%LOCALAPPDATA%\fnm\`
- Git config: `~\.gitconfig`
- Global .gitignore: `~\.gitignore_global`
- VS Code settings: `%APPDATA%\Code\User\`
- Configuration: `.\config.ps1`
- Repositories: `C:\Code\` (or configured path)

### Next Steps After Setup

1. Open VS Code and sign into Settings Sync (if used)
2. Generate SSH key: `ssh-keygen -t ed25519 -C "your.email@example.com"`
3. Add SSH key to GitHub/GitLab
4. Run `.\clone-repos.ps1` to clone your projects
5. Start Docker Desktop if needed
6. Configure any application-specific settings
7. Review Windows settings in Settings app

---

**Need help?** Check the troubleshooting section above or open an issue.
