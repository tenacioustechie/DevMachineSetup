# Mac Development Machine Setup - Documentation

Comprehensive documentation for understanding, using, and customizing the Mac development machine automation setup.

## Quick Links

### Getting Started
- **[Main README](../readme.md)** - Setup instructions and quick start
- **[Overview](OVERVIEW.md)** - Architecture, execution flow, and how everything works

### Understanding What Gets Installed
- **[Homebrew Role](roles/HOMEBREW.md)** - Package management (40+ packages)
- **[Development Tools Role](roles/DEVELOPMENT-TOOLS.md)** - Node.js, .NET, Python setup
- **[Dotfiles Role](roles/DOTFILES.md)** - Shell, Git, and SSH configuration
- **[macOS Preferences Role](roles/MACOS-PREFERENCES.md)** - System settings (50+ preferences)
- **[Applications Role](roles/APPLICATIONS.md)** - VS Code, iTerm2, Rectangle, Docker
- **[Optional Tools Role](roles/OPTIONAL-TOOLS.md)** - Xcode and iOS development

### Guides
- **[Customization Guide](CUSTOMIZATION.md)** - How to modify the setup for your needs
- **[Troubleshooting Guide](TROUBLESHOOTING.md)** - Common issues and solutions

## Documentation Structure

```
docs/
├── README.md                    # This file - documentation index
├── OVERVIEW.md                  # Architecture and execution flow
├── CUSTOMIZATION.md             # How to customize
├── TROUBLESHOOTING.md           # Common issues and solutions
└── roles/                       # Detailed role documentation
    ├── HOMEBREW.md              # Package management
    ├── DEVELOPMENT-TOOLS.md     # Dev environments
    ├── DOTFILES.md              # Shell and Git
    ├── MACOS-PREFERENCES.md     # System preferences
    ├── APPLICATIONS.md          # App configuration
    └── OPTIONAL-TOOLS.md        # Xcode and iOS
```

## How to Use This Documentation

### If You're New Here

1. Start with the [Main README](../readme.md) for setup instructions
2. Read the [Overview](OVERVIEW.md) to understand the architecture
3. Review role documentation to see what gets installed
4. Check [Customization Guide](CUSTOMIZATION.md) to personalize your setup

### If You Want to Customize

1. Read [Customization Guide](CUSTOMIZATION.md)
2. Review relevant role documentation for what you want to change
3. Edit `group_vars/all.yml` with your changes
4. Run `./bootstrap.sh` to apply changes

### If Something's Not Working

1. Check [Troubleshooting Guide](TROUBLESHOOTING.md) for your specific issue
2. Review relevant role documentation
3. Run with verbose output: `ansible-playbook playbook.yml -vv`
4. Check logs and error messages

### If You Want to Understand a Specific Part

Each role documentation explains:
- **Purpose**: What the role does
- **What Gets Installed**: Complete list of software/settings
- **Task Breakdown**: Step-by-step explanation of every command
- **Configuration**: How to customize that role
- **File Locations**: Where things are installed
- **Common Issues**: Role-specific problems and solutions
- **Useful Commands**: Reference commands for that role

## Role Documentation Summary

### [Homebrew Role](roles/HOMEBREW.md)
**Purpose**: Package management foundation

**Key Concepts**:
- Formulae (CLI tools) vs Casks (GUI apps)
- Taps (third-party repositories)
- mas (Mac App Store CLI)

**What You'll Learn**:
- How Homebrew installs packages
- How to add/remove software
- Where packages are installed
- How to troubleshoot Homebrew issues

**Read this if**: You want to add/remove applications or understand package management

---

### [Development Tools Role](roles/DEVELOPMENT-TOOLS.md)
**Purpose**: Programming language runtimes

**Key Concepts**:
- fnm (Fast Node Manager) for Node.js versions
- .NET SDK installation and management
- Python and pip configuration
- Docker Desktop setup

**What You'll Learn**:
- How fnm works vs nvm
- Managing multiple Node.js versions
- .NET SDK installation and usage
- Python virtual environments

**Read this if**: You want to change Node/Python/.NET versions or understand version management

---

### [Dotfiles Role](roles/DOTFILES.md)
**Purpose**: Shell and Git configuration

**Key Concepts**:
- Zsh configuration and aliases
- Git user and behavior settings
- SSH configuration and permissions
- Custom PATH and environment variables

**What You'll Learn**:
- What each alias does (ll, cat, tree)
- Git configuration options
- SSH key management
- fzf fuzzy finder usage

**Read this if**: You want to customize shell aliases, Git settings, or understand SSH setup

---

### [macOS Preferences Role](roles/MACOS-PREFERENCES.md)
**Purpose**: System-level settings

**Key Concepts**:
- `defaults` command for preferences
- Preference domains (com.apple.dock, NSGlobalDomain)
- Handlers for restarting apps
- Security and performance optimizations

**What You'll Learn**:
- How macOS preferences work
- What each preference does
- How to find and set preferences
- Why some changes require logout

**Read this if**: You want to customize Dock, Finder, keyboard, trackpad, or system behavior

---

### [Applications Role](roles/APPLICATIONS.md)
**Purpose**: Application-specific configuration

**Key Concepts**:
- VS Code extensions and settings
- iTerm2 preferences location
- Rectangle window management
- Application launch at login

**What You'll Learn**:
- VS Code extension management
- Application configuration locations
- Rectangle keyboard shortcuts
- Docker Desktop setup

**Read this if**: You want to configure VS Code, iTerm2, or other installed applications

---

### [Optional Tools Role](roles/OPTIONAL-TOOLS.md)
**Purpose**: iOS development setup

**Key Concepts**:
- Xcode installation from App Store
- CocoaPods dependency management
- fastlane automation
- iOS Simulator management

**What You'll Learn**:
- How Xcode installation works
- CocoaPods usage
- Simulator management
- iOS development workflow

**Read this if**: You need iOS development tools or want to understand mobile development setup

---

## Understanding Ansible Concepts

### Idempotency
Running the playbook multiple times is safe - it only makes changes when needed.

**Example**: If Git is already installed, the install task reports "ok" not "changed"

### Tasks
Individual actions (install package, set preference, create file)

### Roles
Groups of related tasks (all Homebrew tasks, all dotfiles tasks, etc.)

### Variables
Configuration values in `group_vars/all.yml` that control behavior

### Handlers
Actions triggered by changes (restart Dock when preferences change)

### Tags
Labels for selective execution (`--tags "homebrew"` runs only Homebrew tasks)

### Modules
Built-in Ansible commands (`homebrew`, `git_config`, `osx_defaults`, etc.)

## Common Workflows

### Initial Setup
1. Clone repository
2. Edit `group_vars/all.yml` (set Git name/email, customize packages)
3. Run `./bootstrap.sh`
4. Wait 20-30 minutes
5. Restart terminal

### Adding Software
1. Edit `group_vars/all.yml`
2. Add to `homebrew_packages` or `homebrew_casks`
3. Run: `ansible-playbook playbook.yml --tags "packages"`

### Changing Preferences
1. Edit `macos_preferences` in `group_vars/all.yml`
2. Run: `ansible-playbook playbook.yml --tags "preferences"`

### Updating Software
```bash
brew update && brew upgrade
npm update -g
```

### Full Re-run
```bash
./bootstrap.sh
# Or
ansible-playbook -i inventory.yml playbook.yml --ask-become-pass
```

## File Reference

### Configuration Files

| File | Purpose | Edit This |
|------|---------|-----------|
| `group_vars/all.yml` | Main configuration | ✅ Yes - customize here |
| `inventory.yml` | Host definitions | Only for multi-machine |
| `playbook.yml` | Role orchestration | Rarely |
| `requirements.yml` | Galaxy dependencies | Rarely |

### Generated Files

| File | Purpose | Auto-Generated |
|------|---------|----------------|
| `~/.zshrc` | Shell config | Ansible-managed section |
| `~/.gitconfig` | Git config | Yes |
| `~/.ssh/config` | SSH config | Ansible-managed section |
| `~/Library/Preferences/*.plist` | System preferences | Yes |

### Role Files

| File | Purpose | Modify For |
|------|---------|------------|
| `roles/*/tasks/main.yml` | Task definitions | Advanced customization |
| `roles/*/defaults/main.yml` | Default variables | Advanced customization |
| `roles/*/handlers/main.yml` | Event handlers | Advanced customization |

## Command Reference

### Run Full Setup
```bash
./bootstrap.sh
```

### Run Specific Roles
```bash
ansible-playbook playbook.yml --tags "homebrew"           # Just packages
ansible-playbook playbook.yml --tags "dotfiles"           # Just shell/Git
ansible-playbook playbook.yml --tags "preferences"        # Just system settings
ansible-playbook playbook.yml --tags "development"        # Just dev tools
```

### Run in Check Mode (Dry Run)
```bash
ansible-playbook playbook.yml --check
```

### Run with Verbose Output
```bash
ansible-playbook playbook.yml -v    # Verbose
ansible-playbook playbook.yml -vv   # More verbose
ansible-playbook playbook.yml -vvv  # Debug
```

### Skip Roles
```bash
ansible-playbook playbook.yml --skip-tags "xcode"
```

## Additional Resources

### Ansible
- [Official Documentation](https://docs.ansible.com/)
- [Module Index](https://docs.ansible.com/ansible/latest/collections/index_module.html)
- [Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

### Homebrew
- [Official Site](https://brew.sh/)
- [Documentation](https://docs.brew.sh/)
- [Package Search](https://formulae.brew.sh/)

### macOS Defaults
- [macOS Defaults Reference](https://macos-defaults.com/)
- [defaults-write.com](https://www.defaults-write.com/)

### Development Tools
- [fnm Documentation](https://github.com/Schniz/fnm)
- [.NET Documentation](https://learn.microsoft.com/en-us/dotnet/)
- [Node.js Releases](https://nodejs.org/en/download/releases/)

## Contributing to Documentation

If you find errors or want to improve documentation:

1. Documentation is in Markdown format
2. Follow existing structure and style
3. Include code examples
4. Explain "why" not just "what"
5. Test commands before documenting them

## Getting Help

### Documentation Not Clear?
- Check multiple role docs - information may be in different sections
- Look at actual task files in `roles/*/tasks/main.yml`
- Run with `-vv` to see exactly what's happening

### Something Not Working?
1. Check [Troubleshooting Guide](TROUBLESHOOTING.md) first
2. Run with verbose output: `-vv`
3. Check relevant role documentation
4. Verify configuration in `group_vars/all.yml`

### Want to Extend?
1. Read [Customization Guide](CUSTOMIZATION.md)
2. Review existing role structure
3. Follow Ansible best practices
4. Test changes with `--check` first

---

## Documentation Version

This documentation corresponds to the Mac Development Machine Setup created on 2025-11-03.

**Last Updated**: 2025-11-03

**Covers**:
- Ansible-based automation
- macOS recent versions (Ventura, Sonoma, Sequoia)
- Homebrew package management
- Node.js 20.15.0 (configurable)
- .NET SDK 8.0 (configurable)
- Python 3.11 (configurable)
- Xcode 15+ (optional)

---

**Ready to get started?** Head back to the [Main README](../readme.md) and run `./bootstrap.sh`!
