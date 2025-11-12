# Mac Development Machine Setup

Automated setup for macOS development environments using shell scripts. This setup is designed for developers working with Node.js, TypeScript, .NET, C#, React Native, Tauri, and web applications.

## Features

- **Simple Shell Scripts**: Direct bash scripts similar to the Windows PowerShell approach
- **Idempotent**: Safe to run multiple times without causing issues
- **Comprehensive**: Installs development tools, configures system preferences, and sets up applications
- **Customizable**: Easy to add, remove, or modify packages and settings via configuration file
- **Fast**: No framework overhead, runs directly on your system

## What Gets Configured

### Development Tools
- **Node.js**: via fnm (Fast Node Manager) with configurable version
- **.NET SDK**: .NET 8 SDK (or your preferred version)
- **Python**: Python 3.11 with pip
- **Version Control**: Git with Git LFS
- **Package Managers**: npm, yarn, pnpm
- **Global npm packages**: Angular CLI, TypeScript, and more

### Applications
- **IDEs**: Visual Studio Code with extensions, DataGrip
- **Terminal**: iTerm2
- **Browsers**: Google Chrome, Firefox
- **Communication**: Zoom
- **Utilities**: Rectangle (window management), Raycast (launcher), Maccy (clipboard)
- **DevOps**: Docker, Terraform, AWS CLI
- **Media**: Spotify, VLC
- **Productivity**: Notion, Obsidian

### System Preferences
- Dock configuration (auto-hide, size, behavior)
- Finder preferences (show hidden files, extensions, path bar)
- Screenshot settings (custom location, format)
- Trackpad and keyboard settings
- Performance optimizations

### Shell Configuration
- Zsh with custom aliases (using eza, bat, fzf)
- fnm integration for Node.js version management
- Git configuration with sensible defaults
- PATH setup for all development tools

### Optional Tools
- **Xcode** and iOS development tools (prompt during setup)

## Prerequisites

- macOS (tested on recent versions)
- Administrator access (you'll be prompted for your password)
- Internet connection
- Apple ID (only if installing Xcode from App Store)

## Quick Start

1. **Clone this repository**:
   ```bash
   git clone <repository-url>
   cd DevMachineSetup/mac-dev-machine
   ```

2. **Create your personal configuration file**:
   ```bash
   # Copy the example configuration
   cp config.example.sh config.sh

   # Edit with your personal settings
   nano config.sh
   # or
   code config.sh

   # Set your Git name and email
   # Modify package lists to add/remove software
   # Adjust system preferences to your liking
   ```

3. **Run the setup script**:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

4. **Follow the prompts**:
   - Enter your password when requested (for sudo access)
   - Wait for the installation to complete (15-30 minutes)

5. **Restart your terminal** to load new shell configurations:
   ```bash
   source ~/.zshrc
   ```

## Directory Structure

```
mac-dev-machine/
├── setup.sh              # Main setup script
├── config.example.sh     # Example configuration (committed to repo)
├── config.sh             # Your personal configuration (gitignored - EDIT THIS)
├── README.md             # This file
├── CHANGELOG.md          # Version history and fixes
└── docs/                 # Detailed documentation
    ├── OVERVIEW.md
    ├── CUSTOMIZATION.md
    ├── TROUBLESHOOTING.md
    └── roles/            # Documentation for each setup component
```

## Customization

All customization is done in [config.sh](config.sh).

**Important**: The `config.sh` file is gitignored and won't be committed. Create it from the example:
```bash
cp config.example.sh config.sh
```

This file contains:

### Adding or Removing Software

```bash
# Add Homebrew packages (CLI tools)
HOMEBREW_PACKAGES=(
    "git"
    "neovim"  # Add this
)

# Add Homebrew casks (GUI apps)
HOMEBREW_CASKS=(
    "visual-studio-code"
    "figma"  # Add this
)

# Add VS Code extensions
VSCODE_EXTENSIONS=(
    "ms-vscode.csharp"
    "rust-lang.rust-analyzer"  # Add this
)
```

### Modifying System Preferences

```bash
# Dock settings
MACOS_DOCK_AUTOHIDE=true      # Change to false to always show dock
MACOS_DOCK_TILESIZE=48        # Adjust dock icon size

# Finder settings
MACOS_FINDER_SHOW_HIDDEN=true # Change to false to hide dotfiles
```

### Setting Git Configuration

```bash
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="your.email@example.com"
```

### Configuring Node.js Version

```bash
NODE_VERSION="20.15.0"  # Change to your preferred version
```

For more customization options, see [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md)

## Command Line Options

```bash
# Skip Xcode installation prompt
./setup.sh --skip-xcode

# Use custom configuration file
./setup.sh --config path/to/custom-config.sh

# Combine options
./setup.sh --skip-xcode --config my-config.sh
```

## Updating Your Environment

To update installed packages and apply any configuration changes:

```bash
./setup.sh
```

The script is idempotent and will skip already-installed packages.

## Maintenance

### Keeping Software Updated

Update Homebrew packages:
```bash
brew update && brew upgrade
```

Update npm global packages:
```bash
npm update -g
```

Check for macOS updates:
```bash
softwareupdate -l
```

### Re-running Setup After macOS Upgrades

After a major macOS upgrade, re-run the setup:
```bash
./setup.sh
```

This will:
- Reinstall any missing components
- Reapply system preferences
- Update development tools

## Troubleshooting

### Xcode Command Line Tools Not Installing

If the script gets stuck on Xcode Command Line Tools:
1. Manually install: `xcode-select --install`
2. Complete the installation dialog
3. Run `./setup.sh` again

### Homebrew Installation Fails

If Homebrew fails to install:
1. Check internet connection
2. Visit https://brew.sh for manual installation
3. Run `./setup.sh` again after Homebrew is installed

### fnm Node.js Installation Fails

The script includes automatic retry logic (3 attempts). If all fail:
```bash
# Clean up partial downloads
rm -rf ~/.local/share/fnm/node-versions/.downloads
rm -rf ~/.local/share/fnm/node-versions/v20.15.0

# Try again
./setup.sh
```

### .NET SDK Installation Requires Password

.NET SDK uses a `.pkg` installer that requires administrator privileges. You'll be prompted for your password - this is normal and expected.

### VS Code Extensions Fail to Install

If VS Code extensions fail:
1. Open VS Code manually: `code`
2. Check that the `code` command is in your PATH
3. Manually install extensions: `code --install-extension <extension-id>`

### Docker Not Running

Docker Desktop must be started manually:
1. Open Docker Desktop from Applications
2. Wait for it to start
3. Verify: `docker ps`

For more troubleshooting help, see [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)

## Migration to New Mac

To set up a new Mac with your existing configuration:

1. **On your old Mac**:
   - Keep a copy of your `config.sh` file (save it elsewhere or remember your settings)
   - Note: `config.sh` is gitignored, so it won't be in the repository

2. **On your new Mac**:
   - Clone the repository
   - Create your config: `cp config.example.sh config.sh`
   - Edit `config.sh` with your personal settings (or copy from your old Mac)
   - Run `./setup.sh`
   - Manually migrate:
     - SSH keys from `~/.ssh/`
     - Application data as needed

3. **Optional**: Use macOS Migration Assistant for:
   - User files and documents
   - Photos, Music, and other media
   - Application settings not covered by this automation

## Backup Recommendations

Before running the setup, consider backing up:
- Current dotfiles (`~/.zshrc`, `~/.gitconfig`, etc.)
- VS Code settings (`~/Library/Application Support/Code/User/`)
- SSH keys (`~/.ssh/`)
- Any custom configurations

## Architecture

This setup uses a straightforward shell script approach:

1. **setup.sh** - Main orchestration script that:
   - Runs pre-flight checks
   - Installs Xcode Command Line Tools
   - Installs Homebrew
   - Installs all packages and applications
   - Configures development tools
   - Sets up shell and Git configuration
   - Applies macOS preferences
   - Configures applications

2. **config.sh** / **config.example.sh** - Configuration files:
   - `config.example.sh` - Example configuration (committed to repo)
   - `config.sh` - Your personal configuration (gitignored)
   - Contains package lists, tool versions, preferences, Git config, and VS Code extensions

This approach is:
- **Simple**: No framework overhead, just bash
- **Fast**: Direct execution without abstraction layers
- **Debuggable**: Easy to understand what's happening
- **Maintainable**: Similar to the Windows PowerShell approach

## Comparison to Ansible Approach

**Why Shell Scripts Instead of Ansible?**

This setup originally used Ansible but was converted to shell scripts because:

1. **Simpler**: No Ansible installation or learning curve required
2. **Faster**: No framework overhead
3. **More Reliable**: Avoids conflicts like Homebrew refusing to run as root
4. **Easier to Debug**: Plain bash is easier to understand and troubleshoot
5. **Consistent**: Matches the Windows PowerShell approach in this repository
6. **No Dependencies**: Just bash, which is already on your Mac

For the full history and reasoning, see [CHANGELOG.md](CHANGELOG.md)

## Resources

- [Homebrew](https://brew.sh/)
- [fnm (Fast Node Manager)](https://github.com/Schniz/fnm)
- [macOS defaults Reference](https://macos-defaults.com/)
- [dotfiles Guide](https://dotfiles.github.io/)

## License

This setup configuration is provided as-is for personal use. Modify as needed for your environment.

---

## Quick Reference

### Common Commands

```bash
# Full setup
./setup.sh

# Skip Xcode prompt
./setup.sh --skip-xcode

# Use custom config
./setup.sh --config my-config.sh

# Update Homebrew packages
brew update && brew upgrade

# Update npm packages
npm update -g

# Check Node versions
fnm list

# Switch Node version
fnm use 18.18.0
```

### File Locations After Setup

- Node.js: Managed by fnm in `~/.local/share/fnm/`
- Homebrew: `/opt/homebrew` (Apple Silicon) or `/usr/local` (Intel)
- VS Code settings: `~/Library/Application Support/Code/User/`
- Shell config: `~/.zshrc`
- Git config: `~/.gitconfig`
- Personal configuration: `./config.sh` (gitignored)
- Example configuration: `./config.example.sh` (in repo)

### Next Steps After Setup

1. Open VS Code and sign into Settings Sync (if used)
2. Generate SSH key: `ssh-keygen -t ed25519 -C "your.email@example.com"`
3. Add SSH key to GitHub/GitLab
4. Clone your projects to `~/Code/`
5. Start Docker Desktop if needed
6. Configure any application-specific settings
7. Review and adjust system preferences in System Settings

---

**Need help?** Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) or review the script output for specific errors.
