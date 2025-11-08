# Customization Guide

This guide shows you how to customize the Mac development machine setup for your specific needs.

## Table of Contents

- [Quick Customization](#quick-customization)
- [Adding/Removing Software](#addingremoving-software)
- [Customizing System Preferences](#customizing-system-preferences)
- [Modifying Roles](#modifying-roles)
- [Creating Custom Roles](#creating-custom-roles)
- [Per-Machine Configuration](#per-machine-configuration)

## Quick Customization

**Main configuration file**: [`group_vars/all.yml`](../group_vars/all.yml)

This is where you customize 90% of the setup. Edit this file before running `bootstrap.sh`.

## Adding/Removing Software

### Adding Homebrew Packages (CLI Tools)

Edit `group_vars/all.yml`:

```yaml
homebrew_packages:
  - git
  - wget
  - neovim      # Add this
  - htop
```

Find packages: https://formulae.brew.sh/

### Adding GUI Applications (Casks)

```yaml
homebrew_casks:
  - visual-studio-code
  - google-chrome
  - figma       # Add this
  - discord     # Add this
```

Find casks: https://formulae.brew.sh/cask/

### Adding VS Code Extensions

```yaml
vscode_extensions:
  - "ms-vscode.csharp"
  - "dbaeumer.vscode-eslint"
  - "rust-lang.rust-analyzer"  # Add this
```

Find extensions: https://marketplace.visualstudio.com/

### Adding npm Global Packages

```yaml
nodejs_global_packages:
  - "@angular/cli"
  - "typescript"
  - "vite"      # Add this
  - "nx"        # Add this
```

### Removing Software

Simply delete the line from the appropriate list in `group_vars/all.yml`.

**Note**: Removing from the list doesn't uninstall. To uninstall:

```bash
brew uninstall package-name
brew uninstall --cask app-name
code --uninstall-extension extension-id
npm uninstall -g package-name
```

## Customizing System Preferences

All in `group_vars/all.yml`:

### Dock Customization

```yaml
macos_preferences:
  dock:
    autohide: false           # Always show Dock
    autohide_delay: 0.5       # Delay before showing (seconds)
    tilesize: 64              # Icon size (pixels)
    show_recents: true        # Show recent apps
    minimize_to_application: false  # Minimize to Dock section
```

### Finder Customization

```yaml
macos_preferences:
  finder:
    show_hidden_files: false  # Hide dotfiles
    show_all_extensions: true # Show file extensions
    show_path_bar: true       # Show path at bottom
    show_status_bar: true     # Show file count
    default_view: "icnv"      # Icon view (icnv, Nlsv, clmv, glyv)
    disable_warning_on_change_extension: true
```

### Screenshot Customization

```yaml
macos_preferences:
  screenshots:
    location: "~/Desktop"     # Change location
    format: "jpg"             # Change format (png, jpg, pdf, tiff)
    disable_shadow: true      # Remove window shadows
```

### Keyboard & Trackpad

```yaml
macos_preferences:
  trackpad:
    enable_tap_to_click: true
    enable_three_finger_drag: false  # Add this manually

  keyboard:
    key_repeat_rate: 1        # Fastest (requires logout)
    initial_key_repeat: 10    # Shortest delay
    disable_auto_correct: true  # Disable auto-correct
```

## Changing Development Tool Versions

### Node.js Version

```yaml
node_version: "18.18.0"  # Change to any version
```

Find versions: https://nodejs.org/en/download/releases/

### .NET SDK Version

```yaml
dotnet_sdk_version: "7.0"  # Change to 7.0 or 6.0
```

Check available: `brew search dotnet-sdk`

### Python Version

Python version is determined by Homebrew formula. To use a different version:

```yaml
homebrew_packages:
  - python@3.10  # Instead of python@3.11
```

## Customizing Git Configuration

```yaml
git_user_name: "Your Name"
git_user_email: "your.email@example.com"
git_default_branch: "main"  # or "master"
```

## Modifying Roles

Each role has a `tasks/main.yml` file you can edit.

### Example: Adding a Shell Alias

Edit `roles/dotfiles/tasks/main.yml`:

Find the blockinfile task and add to the block:

```yaml
- name: Configure Zsh with custom settings
  blockinfile:
    path: "{{ user_home }}/.zshrc"
    block: |
      # ... existing content ...

      # Custom aliases
      alias projects='cd ~/Code'
      alias update-brew='brew update && brew upgrade'
      alias clean-docker='docker system prune -af'
```

### Example: Adding a macOS Preference

Edit `roles/macos-preferences/tasks/main.yml`:

```yaml
- name: Show battery percentage in menu bar
  community.general.osx_defaults:
    domain: com.apple.menuextra.battery
    key: ShowPercent
    type: string
    value: "YES"
    state: present
```

## Creating Custom Roles

To add a completely new role:

### 1. Create Role Structure

```bash
mkdir -p roles/custom-role/{tasks,defaults,handlers}
```

### 2. Create Tasks

`roles/custom-role/tasks/main.yml`:

```yaml
---
# Custom Role Tasks

- name: Install custom software
  homebrew:
    name: my-custom-tool
    state: present

- name: Configure custom tool
  copy:
    content: |
      # Custom configuration
      setting = value
    dest: "{{ user_home }}/.custom-tool-config"
```

### 3. Create Defaults

`roles/custom-role/defaults/main.yml`:

```yaml
---
# Default variables

custom_setting: "default_value"
```

### 4. Add to Playbook

Edit `playbook.yml`:

```yaml
roles:
  - role: homebrew
  - role: development-tools
  - role: dotfiles
  - role: macos-preferences
  - role: applications
  - role: custom-role      # Add this
  - role: optional-tools
```

### 5. Run

```bash
ansible-playbook -i inventory.yml playbook.yml --tags "custom-role"
```

## Per-Machine Configuration

To maintain different configurations for different Macs:

### Method 1: Host Variables

Edit `inventory.yml`:

```yaml
all:
  hosts:
    work-macbook:
      ansible_host: localhost
      install_xcode: false
      node_version: "20.15.0"

    personal-macbook:
      ansible_host: localhost
      install_xcode: true
      node_version: "18.18.0"
```

Run for specific host:

```bash
ansible-playbook playbook.yml --limit work-macbook
```

### Method 2: Group Variables

Create machine groups in `inventory.yml`:

```yaml
work_macs:
  hosts:
    work-macbook:
      ansible_host: localhost

personal_macs:
  hosts:
    personal-macbook:
      ansible_host: localhost
```

Create group-specific vars:

`group_vars/work_macs.yml`:
```yaml
install_xcode: false
homebrew_casks:
  - visual-studio-code
  - slack
  - zoom
```

`group_vars/personal_macs.yml`:
```yaml
install_xcode: true
homebrew_casks:
  - visual-studio-code
  - spotify
  - discord
```

### Method 3: Environment Variables

```bash
# Install Xcode on this run
ansible-playbook playbook.yml --extra-vars "install_xcode=true"

# Use different Node version
ansible-playbook playbook.yml --extra-vars "node_version=18.18.0"
```

## Common Customization Patterns

### Developer Workstation

Focus on development tools, minimal extras:

```yaml
homebrew_casks:
  - visual-studio-code
  - iterm2
  - docker

homebrew_packages:
  - git
  - node
  - python
```

### Full-Stack Development

Web, mobile, and cloud:

```yaml
homebrew_packages:
  - git
  - node
  - python
  - awscli
  - terraform
  - kubernetes-cli

homebrew_casks:
  - visual-studio-code
  - docker
  - postman
  - datagrip

install_xcode: true  # For mobile development
```

### Data Science/ML

Python-focused:

```yaml
homebrew_packages:
  - python@3.11
  - jupyter
  - postgresql

homebrew_casks:
  - visual-studio-code
  - r
  - tableau

# Add to development-tools role
python_packages:
  - pandas
  - numpy
  - scikit-learn
  - tensorflow
```

### Minimalist Setup

Just the essentials:

```yaml
homebrew_packages:
  - git
  - node

homebrew_casks:
  - visual-studio-code
  - google-chrome

# Remove optional tools
install_xcode: false

# Minimal VS Code extensions
vscode_extensions:
  - "ms-vscode.csharp"
  - "dbaeumer.vscode-eslint"
```

## Testing Customizations

### Dry Run (Check Mode)

See what would change without making changes:

```bash
ansible-playbook playbook.yml --check
```

### Run Specific Roles

Test just one role:

```bash
ansible-playbook playbook.yml --tags "homebrew"
```

### Verbose Output

See detailed information:

```bash
ansible-playbook playbook.yml -v   # Verbose
ansible-playbook playbook.yml -vv  # More verbose
ansible-playbook playbook.yml -vvv # Debug level
```

## Backing Up Customizations

### Backup Configuration

```bash
# Backup your customized config
cp group_vars/all.yml ~/Dropbox/mac-setup-config-backup.yml

# Or commit to Git
cd /path/to/DevMachineSetup
git add group_vars/all.yml
git commit -m "My custom Mac setup configuration"
git push
```

### Export Current Settings

```bash
# Export Homebrew packages
brew bundle dump --file=~/Brewfile

# Export VS Code extensions
code --list-extensions > ~/vscode-extensions.txt

# Export VS Code settings
cp ~/Library/Application\ Support/Code/User/settings.json ~/vscode-settings-backup.json
```

## Undoing Changes

### Reset Preferences

```bash
# Reset specific domain
defaults delete com.apple.dock
killall Dock

# Reset Finder
defaults delete com.apple.finder
killall Finder
```

### Uninstall Software

```bash
# Uninstall Homebrew package
brew uninstall package-name

# Uninstall cask
brew uninstall --cask app-name

# Remove all Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

### Reset Shell Configuration

```bash
# Backup current
cp ~/.zshrc ~/.zshrc.backup

# Remove Ansible-managed block
# Edit ~/.zshrc and delete content between markers:
# # BEGIN ANSIBLE MANAGED BLOCK - MAC DEV SETUP
# # END ANSIBLE MANAGED BLOCK - MAC DEV SETUP

# Or start fresh
mv ~/.zshrc ~/.zshrc.old
touch ~/.zshrc
```

## Tips & Best Practices

1. **Start with defaults**: Run once with default config, then customize
2. **Small changes**: Make incremental changes and test
3. **Version control**: Commit your `group_vars/all.yml` to Git
4. **Document**: Add comments explaining why you changed things
5. **Test in VM**: Use a macOS VM to test major changes (if available)
6. **Backup first**: Take a Time Machine backup before running
7. **Tags**: Use tags to run only the parts you changed

## Next Steps

- Review [Role Documentation](roles/) for what each role does
- Check [Troubleshooting Guide](TROUBLESHOOTING.md) for common issues
- See [Overview](OVERVIEW.md) for understanding the architecture
