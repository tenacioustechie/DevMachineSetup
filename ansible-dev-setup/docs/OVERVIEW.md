# Mac Development Machine Setup - Overview

## Table of Contents

- [Architecture](#architecture)
- [Execution Flow](#execution-flow)
- [Roles Overview](#roles-overview)
- [Configuration System](#configuration-system)
- [Idempotency](#idempotency)

## Architecture

This Mac development machine setup uses **Ansible**, a declarative automation tool, to configure macOS systems consistently and repeatably.

### Why Ansible?

1. **Declarative**: You describe *what* you want, not *how* to achieve it
2. **Idempotent**: Safe to run multiple times without breaking things
3. **Cross-platform**: Same tool can be used for Linux and potentially Windows
4. **Well-documented**: Large community and extensive module library
5. **Version controlled**: Track changes to your environment over time

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                      bootstrap.sh                           │
│  • Installs prerequisites (Homebrew, Ansible)               │
│  • Prompts for options (Xcode, etc.)                        │
│  • Launches Ansible playbook                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                     playbook.yml                            │
│  • Orchestrates role execution                              │
│  • Loads variables from group_vars/all.yml                  │
│  • Executes roles in defined order                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                        Roles                                │
│  ┌──────────────────────────────────────────────┐          │
│  │ 1. homebrew       → Package Management        │          │
│  │ 2. development-tools → Node/.NET/Python       │          │
│  │ 3. dotfiles       → Shell & Git Config        │          │
│  │ 4. macos-preferences → System Settings        │          │
│  │ 5. applications   → App-specific Config       │          │
│  │ 6. optional-tools → Xcode (conditional)       │          │
│  └──────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

## Execution Flow

### 1. Bootstrap Phase (`bootstrap.sh`)

**Purpose**: Prepare the system with prerequisites

**Steps**:
1. Verify running on macOS
2. Install Xcode Command Line Tools (if missing)
3. Install Homebrew (if missing)
4. Update Homebrew
5. Install Ansible via Homebrew
6. Install Ansible Galaxy requirements
7. Prompt user for configuration options
8. Execute the Ansible playbook

**Commands Executed**:
```bash
# Check for Xcode CLI tools
xcode-select -p

# Install Xcode CLI tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Update Homebrew
brew update

# Install Ansible
brew install ansible

# Install Galaxy requirements
ansible-galaxy install -r requirements.yml

# Run playbook
ansible-playbook -i inventory.yml playbook.yml --extra-vars "install_xcode=true" --ask-become-pass
```

### 2. Playbook Execution (`playbook.yml`)

**Purpose**: Orchestrate role execution in correct order

**Steps**:
1. Load variables from `group_vars/all.yml`
2. Display setup information (hostname, OS version, etc.)
3. Verify prerequisites (Homebrew installed)
4. Execute each role in sequence
5. Display completion summary
6. Check for system updates

**Role Execution Order**:
```yaml
1. homebrew          # Install packages first
2. development-tools # Setup dev environments
3. dotfiles          # Configure shell and Git
4. macos-preferences # Set system preferences
5. applications      # Configure installed apps
6. optional-tools    # Xcode (if requested)
```

### 3. Role Execution

Each role follows this pattern:

```
roles/<role-name>/
├── tasks/main.yml      # Main task list (what to do)
├── defaults/main.yml   # Default variables
└── handlers/main.yml   # Event handlers (optional)
```

## Roles Overview

### 1. Homebrew Role

**Purpose**: Package management foundation

**What it does**:
- Updates Homebrew to latest version
- Adds custom package repositories (taps)
- Installs CLI tools (formulae)
- Installs GUI applications (casks)
- Installs Mac App Store apps (via mas)
- Cleans up old versions

**Key Modules Used**:
- `homebrew`: Install CLI packages
- `homebrew_tap`: Add repositories
- `homebrew_cask`: Install GUI apps

**Documentation**: [docs/roles/HOMEBREW.md](roles/HOMEBREW.md)

### 2. Development Tools Role

**Purpose**: Setup development environments

**What it does**:
- Configures fnm (Fast Node Manager) for Node.js
- Installs specific Node.js version
- Installs global npm packages
- Installs .NET SDK
- Configures Python and pip
- Initializes Git LFS
- Verifies Docker installation

**Key Commands**:
- `fnm install <version>`
- `npm install -g <package>`
- `dotnet --version`

**Documentation**: [docs/roles/DEVELOPMENT-TOOLS.md](roles/DEVELOPMENT-TOOLS.md)

### 3. Dotfiles Role

**Purpose**: Shell and Git configuration

**What it does**:
- Configures Zsh with custom aliases
- Sets up fnm integration
- Installs fzf key bindings
- Configures Git settings (user, editor, defaults)
- Creates common directories
- Sets up SSH with proper permissions

**Files Modified**:
- `~/.zshrc`
- `~/.gitconfig`
- `~/.ssh/config`

**Documentation**: [docs/roles/DOTFILES.md](roles/DOTFILES.md)

### 4. macOS Preferences Role

**Purpose**: System-level configuration

**What it does**:
- Configures Dock behavior
- Sets Finder preferences
- Configures screenshots
- Sets trackpad/keyboard settings
- Enables security features
- Optimizes UI behavior
- Prevents .DS_Store on network drives

**Key Module**: `community.general.osx_defaults`

**Documentation**: [docs/roles/MACOS-PREFERENCES.md](roles/MACOS-PREFERENCES.md)

### 5. Applications Role

**Purpose**: Application-specific configuration

**What it does**:
- Installs VS Code extensions
- Configures VS Code settings
- Sets up iTerm2 preferences
- Configures Rectangle for window management
- Checks Docker Desktop status

**Files Modified**:
- `~/Library/Application Support/Code/User/settings.json`
- `~/.config/iterm2/`

**Documentation**: [docs/roles/APPLICATIONS.md](roles/APPLICATIONS.md)

### 6. Optional Tools Role

**Purpose**: iOS development setup (conditional)

**What it does**:
- Installs Xcode from App Store
- Accepts Xcode license
- Installs additional Xcode components
- Installs CocoaPods
- Installs fastlane
- Creates iOS simulator devices

**Key Commands**:
- `mas install 497799835` (Xcode)
- `xcodebuild -license accept`
- `gem install cocoapods`

**Documentation**: [docs/roles/OPTIONAL-TOOLS.md](roles/OPTIONAL-TOOLS.md)

## Configuration System

### Variable Hierarchy

Ansible loads variables in this order (later values override earlier ones):

1. **Role defaults**: `roles/<role>/defaults/main.yml`
2. **Group variables**: `group_vars/all.yml` ← **Your main config file**
3. **Playbook variables**: `playbook.yml`
4. **Command-line variables**: `--extra-vars`

### Main Configuration File

**Location**: `group_vars/all.yml`

This is where you customize your setup:

```yaml
# Package lists
homebrew_packages: [...]
homebrew_casks: [...]

# Node.js version
node_version: "20.15.0"

# Git configuration
git_user_name: "Your Name"
git_user_email: "your.email@example.com"

# System preferences
macos_preferences:
  dock:
    autohide: true
    tilesize: 48
  # ... more settings
```

### Tags System

Each task is tagged for selective execution:

```bash
# Run only specific parts
ansible-playbook playbook.yml --tags "packages"
ansible-playbook playbook.yml --tags "dotfiles,git"
ansible-playbook playbook.yml --skip-tags "xcode"
```

**Common Tags**:
- `homebrew`, `packages`, `casks`
- `development`, `node`, `dotnet`, `python`
- `dotfiles`, `shell`, `git`, `ssh`
- `preferences`, `dock`, `finder`, `security`
- `applications`, `vscode`
- `xcode`, `ios`, `simulators`

## Idempotency

**Definition**: Running the playbook multiple times produces the same result without breaking things.

### How It Works

1. **Check before action**: Most tasks check if something is already configured
2. **State management**: Ansible tracks whether changes were made
3. **Safe operations**: Commands designed to be safe when repeated

### Examples

```yaml
# Homebrew package installation
- name: Install Git
  homebrew:
    name: git
    state: present  # Only installs if not present

# File creation
- name: Create .zshrc
  file:
    path: ~/.zshrc
    state: touch  # Only creates if doesn't exist

# Line in file
- name: Add to .zshrc
  lineinfile:
    path: ~/.zshrc
    line: 'export PATH="$PATH:..."'
    state: present  # Only adds if not present
```

### Benefits

- Safe to run after system updates
- Safe to run to apply new configuration changes
- Easy to recover from partial failures
- Can be run on schedule for updates

## File Locations

After running the setup, files are located at:

```
System:
├── /opt/homebrew/ (Apple Silicon)
│   └── /usr/local/ (Intel)
│       ├── bin/           # Homebrew CLI tools
│       └── Caskroom/      # GUI applications

User Home (~):
├── .zshrc                 # Shell configuration
├── .gitconfig             # Git configuration
├── .ssh/config            # SSH configuration
├── .local/share/fnm/      # Node.js versions
├── Library/
│   └── Application Support/
│       ├── Code/User/     # VS Code settings
│       └── iTerm2/        # iTerm2 settings
├── Code/                  # Projects directory
├── Screenshots/           # Custom screenshot location
└── Projects/              # Additional projects directory
```

## Understanding Ansible Output

### Task Status Indicators

- **ok**: Task ran successfully, no changes needed
- **changed**: Task made changes to the system
- **skipping**: Task skipped due to condition
- **failed**: Task encountered an error

### Example Output

```
TASK [homebrew : Install Homebrew packages] *****************************
ok: [localhost] => (item=git)
changed: [localhost] => (item=neovim)
skipping: [localhost] => (item=xcode-select)

PLAY RECAP ***************************************************************
localhost         : ok=45   changed=12   unreachable=0    failed=0
```

This shows:
- 45 tasks completed successfully
- 12 tasks made changes
- 0 tasks failed

## Next Steps

Now that you understand the architecture, explore the detailed role documentation:

1. [Homebrew Role](roles/HOMEBREW.md) - Package management
2. [Development Tools Role](roles/DEVELOPMENT-TOOLS.md) - Dev environments
3. [Dotfiles Role](roles/DOTFILES.md) - Shell and Git
4. [macOS Preferences Role](roles/MACOS-PREFERENCES.md) - System settings
5. [Applications Role](roles/APPLICATIONS.md) - App configuration
6. [Optional Tools Role](roles/OPTIONAL-TOOLS.md) - Xcode and iOS

Or jump to:
- [Customization Guide](CUSTOMIZATION.md) - How to modify the setup
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Common issues and solutions
