# Dotfiles Role Documentation

## Purpose

The Dotfiles role configures your shell environment, Git settings, and SSH configuration. It creates a consistent, developer-friendly command-line experience with custom aliases, sensible defaults, and proper permissions.

## What Gets Configured

### Shell Configuration (Zsh)
- Custom aliases using modern tools
- fnm integration for Node.js
- Homebrew environment setup
- Custom PATH configuration
- Editor preferences

### Git Configuration
- User identity (name and email)
- Default branch name
- Editor settings
- Useful aliases and behaviors
- Credential helper (macOS Keychain)

### Directory Structure
- Common development directories
- Screenshots directory
- Proper permissions

### SSH Configuration
- Proper directory permissions (700)
- SSH config file with defaults
- Keychain integration

## Task-by-Task Breakdown

### 1. Ensure .zshrc Exists

**What it does**: Creates `~/.zshrc` if it doesn't exist

**Command**:
```bash
touch ~/.zshrc
```

**Ansible Task**:
```yaml
- name: Ensure .zshrc exists
  file:
    path: "{{ user_home }}/.zshrc"
    state: touch
    mode: '0644'
```

**Why**: Ensures we have a file to add configuration to

**Idempotent**: Yes - touch doesn't modify existing files

---

### 2. Configure Zsh with Custom Settings

**What it does**: Adds a managed block to `~/.zshrc` with custom configuration

**The configuration block added**:

```bash
# === Mac Development Machine Setup ===

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# fnm (Fast Node Manager)
eval "$(fnm env --use-on-cd)"

# Aliases
alias ll='eza -la --git --icons'
alias ls='eza'
alias cat='bat'
alias tree='eza --tree'

# fzf (fuzzy finder)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Custom PATH
export PATH="$HOME/.local/bin:$PATH"

# Editor
export EDITOR="code --wait"
export VISUAL="code --wait"

# Development
export NODE_OPTIONS="--max-old-space-size=4096"

# === End Mac Development Machine Setup ===
```

**Let's break down each section**:

#### Homebrew Setup
```bash
eval "$(/opt/homebrew/bin/brew shellenv)"
```
- Adds Homebrew to PATH
- Sets up environment variables for Homebrew
- Required for `brew` command to work

#### fnm Integration
```bash
eval "$(fnm env --use-on-cd)"
```
- Initializes fnm (Fast Node Manager)
- Enables automatic Node version switching
- Adds Node binaries to PATH

#### Aliases

**ll (long list)**:
```bash
alias ll='eza -la --git --icons'
```
- `-l`: Long format (detailed)
- `-a`: Show hidden files
- `--git`: Show Git status
- `--icons`: Display file type icons

Example output:
```
drwxr-xr-x  📁 .git
-rw-r--r--  📄 package.json  (modified)
-rw-r--r--  📄 README.md
```

**ls (list)**:
```bash
alias ls='eza'
```
- Replaces traditional `ls` with modern `eza`
- Colorized output
- Better formatting

**cat (concatenate)**:
```bash
alias cat='bat'
```
- Replaces `cat` with `bat`
- Syntax highlighting
- Line numbers
- Git integration

Example:
```bash
cat file.js  # Shows JavaScript with syntax highlighting
```

**tree (directory tree)**:
```bash
alias tree='eza --tree'
```
- Shows directory structure as tree
- Colorized and formatted

Example output:
```
.
├── src/
│   ├── components/
│   └── utils/
└── package.json
```

#### fzf Integration
```bash
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
```
- Loads fuzzy finder if installed
- Enables Ctrl+R for command history search
- Enables Ctrl+T for file search

#### Custom PATH
```bash
export PATH="$HOME/.local/bin:$PATH"
```
- Adds `~/.local/bin` to PATH
- Common location for user scripts
- Checked before system binaries

#### Editor Configuration
```bash
export EDITOR="code --wait"
export VISUAL="code --wait"
```
- Sets VS Code as default editor
- `--wait`: Wait for file to be closed before returning
- Used by Git, cron, and other tools

#### Development Settings
```bash
export NODE_OPTIONS="--max-old-space-size=4096"
```
- Increases Node.js memory limit to 4GB
- Prevents out-of-memory errors in large projects
- Useful for builds and bundlers (Webpack, Vite, etc.)

**Ansible Task**:
```yaml
- name: Configure Zsh with custom settings
  blockinfile:
    path: "{{ user_home }}/.zshrc"
    block: |
      # ... (configuration above)
    marker: "# {mark} ANSIBLE MANAGED BLOCK - MAC DEV SETUP"
    create: yes
```

**Idempotent**: Yes - blockinfile only updates if block changed

**Note**: The markers allow Ansible to update just its section without affecting other customizations

---

### 3. Install fzf Key Bindings

**What it does**: Installs fzf shell integration

**Command**:
```bash
/opt/homebrew/opt/fzf/install --key-bindings --completion --no-update-rc
```

**What gets installed**:
- Ctrl+R: Search command history
- Ctrl+T: Search files
- Alt+C: Search directories

**Files created**:
- `~/.fzf.zsh`: fzf initialization script

**Ansible Task**:
```yaml
- name: Install fzf key bindings
  command: "{{ homebrew_prefix }}/opt/fzf/install --key-bindings --completion --no-update-rc"
  args:
    creates: "{{ user_home }}/.fzf.zsh"
```

**Idempotent**: Yes - `creates` ensures it only runs once

**Usage examples**:

```bash
# Search command history
# Press Ctrl+R, then type search term
git commit  # Shows all "git commit" commands from history

# Search files
# Press Ctrl+T, then type file name
code README  # Shows matching files

# Change directory
# Press Alt+C, then type directory name
cd src/  # Shows matching directories
```

---

### 4. Configure Git User Name

**What it does**: Sets your name in Git commits

**Command**:
```bash
git config --global user.name "Your Name"
```

**Ansible Task**:
```yaml
- name: Configure Git user name
  git_config:
    name: user.name
    value: "{{ git_user_name }}"
    scope: global
  when: git_user_name is defined and git_user_name != ""
```

**Configuration**: Set in `group_vars/all.yml`:
```yaml
git_user_name: "Brian Smith"
```

**File modified**: `~/.gitconfig`

**Idempotent**: Yes - only updates if value different

---

### 5. Configure Git User Email

**What it does**: Sets your email in Git commits

**Command**:
```bash
git config --global user.email "your.email@example.com"
```

**Configuration**: Set in `group_vars/all.yml`:
```yaml
git_user_email: "brian@example.com"
```

**File modified**: `~/.gitconfig`

**Why important**: GitHub/GitLab use email to link commits to your account

---

### 6. Configure Git Default Branch

**What it does**: Sets default branch name for new repos

**Command**:
```bash
git config --global init.defaultBranch main
```

**Default**: `main` (modern standard, replacing `master`)

**Effect**: When you run `git init`, default branch is `main`

---

### 7. Configure Additional Git Settings

**What it does**: Sets various Git behaviors

**Settings configured**:

| Setting | Value | Purpose |
|---------|-------|---------|
| `core.editor` | `code --wait` | Use VS Code for commit messages |
| `pull.rebase` | `false` | Use merge strategy for pulls |
| `fetch.prune` | `true` | Remove deleted remote branches |
| `core.autocrlf` | `input` | Handle line endings (Unix-style) |
| `color.ui` | `auto` | Enable colored output |
| `credential.helper` | `osxkeychain` | Store passwords in Keychain |

**Commands executed**:
```bash
git config --global core.editor "code --wait"
git config --global pull.rebase false
git config --global fetch.prune true
git config --global core.autocrlf input
git config --global color.ui auto
git config --global credential.helper osxkeychain
```

**Ansible Task**:
```yaml
- name: Configure Git settings
  git_config:
    name: "{{ item.name }}"
    value: "{{ item.value }}"
    scope: global
  loop:
    - { name: 'core.editor', value: 'code --wait' }
    # ... etc
```

**Idempotent**: Yes

---

### 8. Create Common Directories

**What it does**: Creates standard development directories

**Directories created**:
- `~/Code` - Main projects directory
- `~/Screenshots` - Custom screenshot location
- `~/Projects` - Additional projects directory

**Commands**:
```bash
mkdir -p ~/Code
mkdir -p ~/Screenshots
mkdir -p ~/Projects
```

**Permissions**: 755 (rwxr-xr-x)

**Ansible Task**:
```yaml
- name: Create commonly used directories
  file:
    path: "{{ user_home }}/{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - Code
    - Screenshots
    - Projects
```

**Idempotent**: Yes - creates only if missing

---

### 9. Create SSH Directory

**What it does**: Creates `~/.ssh` with secure permissions

**Command**:
```bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
```

**Permissions**: 700 (rwx------) - only owner can access

**Why important**: SSH requires proper permissions for security

**Idempotent**: Yes

---

### 10. Create SSH Config File

**What it does**: Creates `~/.ssh/config` with default settings

**Command**:
```bash
touch ~/.ssh/config
chmod 600 ~/.ssh/config
```

**Permissions**: 600 (rw-------) - only owner can read/write

**Idempotent**: Yes

---

### 11. Add SSH Config Defaults

**What it does**: Adds SSH configuration for all hosts

**Configuration added**:
```ssh-config
# Default SSH settings
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

**What each setting does**:

- `AddKeysToAgent yes`: Automatically add keys to SSH agent
- `UseKeychain yes`: Store passphrases in macOS Keychain
- `IdentityFile ~/.ssh/id_ed25519`: Default SSH key to use

**Ansible Task**:
```yaml
- name: Add SSH config defaults
  blockinfile:
    path: "{{ user_home }}/.ssh/config"
    block: |
      # Default SSH settings
      Host *
        AddKeysToAgent yes
        UseKeychain yes
        IdentityFile ~/.ssh/id_ed25519
    marker: "# {mark} ANSIBLE MANAGED BLOCK"
    create: yes
```

**Benefits**:
- Don't need to enter SSH key passphrase repeatedly
- Keys automatically loaded when needed
- Consistent configuration across all SSH connections

**Idempotent**: Yes - blockinfile manages its section

---

### 12. Display Summary

**What it does**: Shows configuration status

**Example output**:
```
Dotfiles Configuration Complete
Shell: zsh with custom aliases and functions
Git configured: Yes
SSH directory configured with proper permissions
```

## Configuration

### Setting Git User Information

**Required**: Edit `group_vars/all.yml`:

```yaml
git_user_name: "Your Name"
git_user_email: "your.email@example.com"
git_default_branch: "main"
```

**If left empty**: Git tasks will be skipped

### Adding Custom Aliases

Edit `group_vars/all.yml` or modify the blockinfile task in the role.

**Example additions**:
```bash
# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Directory shortcuts
alias projects='cd ~/Code'
alias downloads='cd ~/Downloads'

# System shortcuts
alias update='brew update && brew upgrade'
```

### Customizing Shell Prompt

The default Zsh prompt is used. To customize, add to `.zshrc` outside the managed block:

```bash
# Custom prompt (add after Ansible block)
PROMPT='%F{blue}%~%f $ '
```

Or use a framework like Oh My Zsh (install separately).

## Files Modified

### ~/.zshrc
- **Location**: `/Users/<username>/.zshrc`
- **Permissions**: 644 (rw-r--r--)
- **Managed section**: Between Ansible markers
- **Custom sections**: Safe to add outside markers

### ~/.gitconfig
- **Location**: `/Users/<username>/.gitconfig`
- **Permissions**: 644 (rw-r--r--)
- **Format**: INI-style configuration

Example contents:
```ini
[user]
    name = Brian Smith
    email = brian@example.com
[init]
    defaultBranch = main
[core]
    editor = code --wait
[credential]
    helper = osxkeychain
```

### ~/.ssh/config
- **Location**: `/Users/<username>/.ssh/config`
- **Permissions**: 600 (rw-------)
- **Format**: SSH config format

Example contents:
```
# Default SSH settings
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

# Custom host configuration (add your own)
Host github.com
  User git
  IdentityFile ~/.ssh/github_key
```

## Common Workflows

### After Installation

**1. Generate SSH key**:
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

**2. Start SSH agent and add key**:
```bash
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

**3. Copy public key**:
```bash
cat ~/.ssh/id_ed25519.pub | pbcopy
```

**4. Add to GitHub/GitLab**:
- Go to Settings > SSH Keys
- Paste the public key

### Using Custom Aliases

```bash
# Instead of 'ls -la'
ll

# Instead of 'cat file.txt'
cat file.txt  # Now uses bat with syntax highlighting

# Instead of 'find . -name "*.js"'
# Just press Ctrl+T and type .js

# Instead of scrolling through history
# Press Ctrl+R and type search term
```

### Testing Git Configuration

```bash
# Check Git config
git config --list

# Test commit
cd ~/Code/test-repo
git init
echo "test" > README.md
git add README.md
git commit -m "Test commit"
# Should open VS Code for commit message
```

## Common Issues

### Issue: Aliases not working

**Cause**: Shell not reloaded

**Solution**:
```bash
source ~/.zshrc
# Or restart terminal
```

---

### Issue: Git editor not opening

**Cause**: VS Code `code` command not in PATH

**Solution**:
1. Open VS Code
2. Press Cmd+Shift+P
3. Type "Shell Command: Install 'code' command in PATH"
4. Restart terminal

---

### Issue: SSH key passphrase requested every time

**Cause**: Key not added to Keychain

**Solution**:
```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

---

### Issue: Permission denied (publickey)

**Cause**: SSH key not added to GitHub/GitLab

**Solution**:
1. Copy public key: `cat ~/.ssh/id_ed25519.pub | pbcopy`
2. Add to GitHub: Settings > SSH and GPG keys > New SSH key
3. Test: `ssh -T git@github.com`

---

### Issue: .zshrc changes not taking effect

**Cause**: Syntax error or conflicting configuration

**Solution**:
1. Check for errors: `zsh -n ~/.zshrc`
2. View errors: `source ~/.zshrc`
3. Fix syntax errors
4. Ensure no conflicting configurations

## Performance Notes

**Execution time**: 10-20 seconds

**Shell startup time**: <100ms (with fnm and fzf)

## Useful Commands

### Shell

```bash
# Reload shell configuration
source ~/.zshrc

# Check shell
echo $SHELL

# List aliases
alias

# Remove alias
unalias ll

# View command definition
type ll
```

### Git

```bash
# View all Git config
git config --list

# View specific config
git config user.name

# Set config
git config --global user.name "New Name"

# Unset config
git config --global --unset setting.name

# Edit config file
code ~/.gitconfig
```

### SSH

```bash
# Test SSH connection
ssh -T git@github.com

# List loaded keys
ssh-add -l

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Remove key from agent
ssh-add -d ~/.ssh/id_ed25519

# View public key
cat ~/.ssh/id_ed25519.pub
```

## Tags

Run only dotfiles tasks:
```bash
ansible-playbook playbook.yml --tags "dotfiles"
```

Available tags:
- `dotfiles`: All dotfiles tasks
- `shell`: Zsh configuration
- `git`: Git configuration
- `ssh`: SSH setup
- `directories`: Create directories

## Next Steps

After dotfiles are configured, the macos-preferences role will set system-level settings.

See: [macOS Preferences Role Documentation](MACOS-PREFERENCES.md)
