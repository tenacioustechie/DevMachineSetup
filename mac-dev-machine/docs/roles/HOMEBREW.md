# Homebrew Role Documentation

## Purpose

The Homebrew role establishes the foundation for package management on macOS. It manages installation of command-line tools (formulae), GUI applications (casks), and Mac App Store applications.

## What Gets Installed

### Package Categories

1. **CLI Tools (Formulae)**: Command-line utilities and libraries
2. **GUI Applications (Casks)**: Desktop applications
3. **Mac App Store Apps**: Apps from the App Store (via mas-cli)

## Default Package List

### CLI Tools (`homebrew_packages`)

| Package | Purpose | Commands Added |
|---------|---------|----------------|
| `git` | Version control | `git` |
| `git-lfs` | Large file storage for Git | `git-lfs` |
| `wget` | File downloader | `wget` |
| `curl` | HTTP client | `curl` |
| `jq` | JSON processor | `jq` |
| `tree` | Directory visualization | `tree` |
| `htop` | Process monitor | `htop` |
| `fnm` | Fast Node Manager | `fnm` |
| `python@3.11` | Python interpreter | `python3`, `pip3` |
| `postgresql@15` | Database | `psql`, `postgres` |
| `awscli` | AWS command-line | `aws` |
| `terraform` | Infrastructure as code | `terraform` |
| `docker` | Container runtime CLI | `docker` |
| `docker-compose` | Multi-container orchestration | `docker-compose` |
| `ripgrep` | Fast text search | `rg` |
| `fzf` | Fuzzy finder | `fzf` |
| `bat` | Cat with syntax highlighting | `bat` |
| `eza` | Modern ls replacement | `eza` |
| `tldr` | Simplified man pages | `tldr` |
| `unzip` | Archive extraction | `unzip` |
| `p7zip` | 7-Zip compression | `7z` |

### GUI Applications (`homebrew_casks`)

| Cask | Purpose | Application |
|------|---------|-------------|
| `visual-studio-code` | Code editor | Visual Studio Code.app |
| `datagrip` | Database IDE | DataGrip.app |
| `iterm2` | Terminal emulator | iTerm.app |
| `google-chrome` | Web browser | Google Chrome.app |
| `firefox` | Web browser | Firefox.app |
| `slack` | Team communication | Slack.app |
| `zoom` | Video conferencing | zoom.us.app |
| `rectangle` | Window management | Rectangle.app |
| `raycast` | Launcher/productivity | Raycast.app |
| `maccy` | Clipboard manager | Maccy.app |
| `spotify` | Music streaming | Spotify.app |
| `vlc` | Media player | VLC.app |
| `notion` | Note-taking | Notion.app |
| `obsidian` | Knowledge base | Obsidian.app |
| `docker` | Container platform | Docker.app |
| `postman` | API testing | Postman.app |
| `font-jetbrains-mono` | Developer font | System fonts |
| `font-fira-code` | Developer font | System fonts |
| `font-hack-nerd-font` | Patched font | System fonts |

## Homebrew Taps (Repositories)

**As of 2024, no additional taps are required!**

```yaml
homebrew_taps: []
```

### Deprecated Taps (No Longer Needed)

All of the following taps have been deprecated and their contents migrated to the main Homebrew repository:

| Tap | Deprecated | Now Available In |
|-----|------------|------------------|
| `homebrew/cask` | 2021 | Built into Homebrew core |
| `homebrew/cask-fonts` | May 2024 | `homebrew/cask` |
| `homebrew/cask-versions` | May 2024 | `homebrew/cask` (use `@version` suffix) |

**What this means:**
- ✅ Fonts install directly: `brew install --cask font-jetbrains-mono`
- ✅ GUI apps install directly: `brew install --cask visual-studio-code`
- ✅ Versioned apps use suffix: `brew install --cask firefox@developer-edition`
- ❌ No tapping required anymore!

## Tasks Performed

### 1. Update Homebrew

**What it does**: Updates Homebrew's package index

**Command**:
```bash
brew update
```

**Why**: Ensures you get the latest package versions

**Idempotent**: Yes - safe to run multiple times

---

### 2. Tap Repositories

**Status**: ⚠️ This step is now skipped (as of 2024)

**What it does**: Would add custom package repositories if any were defined

**Current configuration**: `homebrew_taps: []` (empty list)

**Why empty**: As of May 2024, all common taps have been deprecated:
- `homebrew/cask` - merged into core (2021)
- `homebrew/cask-fonts` - merged into `homebrew/cask` (May 2024)
- `homebrew/cask-versions` - merged into `homebrew/cask` (May 2024)

**If you need custom taps**: Add third-party taps to the list in `group_vars/all.yml`:
```yaml
homebrew_taps:
  - vendor/custom-tap
```

**Error Handling**: The task has resilient error handling that ignores "already tapped" and "no longer necessary" errors

---

### 3. Install Homebrew Packages

**What it does**: Installs CLI tools and libraries

**Command**:
```bash
brew install git
brew install wget
# ... for each package in the list
```

**Ansible Module**: `homebrew`

**Ansible Task**:
```yaml
- name: Install Homebrew packages
  homebrew:
    name: "{{ item }}"
    state: present
  loop: "{{ homebrew_packages }}"
```

**How it works**:
1. Checks if package is already installed
2. If not installed, downloads and installs
3. If installed, verifies it's the correct version
4. Reports "changed" only if installation occurred

**Idempotent**: Yes - skips already-installed packages

---

### 4. Install Homebrew Casks

**What it does**: Installs GUI applications

**Command**:
```bash
brew install --cask visual-studio-code
brew install --cask google-chrome
# ... for each cask in the list
```

**Ansible Module**: `homebrew_cask`

**Ansible Task**:
```yaml
- name: Install Homebrew casks
  homebrew_cask:
    name: "{{ item }}"
    state: present
  loop: "{{ homebrew_casks }}"
  ignore_errors: yes
```

**Note**: `ignore_errors: yes` because some casks may require manual interaction

**How it works**:
1. Checks if application is already installed in `/Applications`
2. If not, downloads and installs
3. Some casks may prompt for permissions

**Idempotent**: Yes - skips already-installed applications

---

### 5. Install Mac App Store Apps (Optional)

**What it does**: Installs apps from the Mac App Store

**Prerequisite**:
- User must be signed into the Mac App Store
- `mas` (Mac App Store CLI) must be installed

**Command**:
```bash
brew install mas
mas install 497799835  # Xcode
```

**Ansible Task**:
```yaml
- name: Install mas (Mac App Store CLI)
  homebrew:
    name: mas
    state: present
  when: mas_packages is defined

- name: Install Mac App Store applications
  command: "mas install {{ item.id }}"
  loop: "{{ mas_packages }}"
  when: mas_packages is defined
```

**How to add MAS apps**:

1. Find the app ID:
```bash
mas search "Xcode"
# Output: 497799835  Xcode (15.0.1)
```

2. Add to `group_vars/all.yml`:
```yaml
mas_packages:
  - { id: 497799835, name: "Xcode" }
  - { id: 1295203466, name: "Microsoft Remote Desktop" }
```

**Idempotent**: Mostly - mas checks if app is installed

---

### 6. Cleanup Old Versions

**What it does**: Removes old versions of packages to save disk space

**Command**:
```bash
brew cleanup
```

**When**: Runs at the end of the role

**Disk space saved**: Typically 500MB - 2GB

**Idempotent**: Yes - safe to run anytime

---

### 7. Run Diagnostics

**What it does**: Checks for common Homebrew issues

**Command**:
```bash
brew doctor
```

**Output**:
- Green check: All good
- Yellow warning: Minor issues (usually ignorable)
- Red error: Requires attention

**Common warnings** (usually safe to ignore):
- "You have unlinked kegs"
- "You have uncommitted modifications"

**Idempotent**: Yes - informational only

## Configuration

### Adding Packages

Edit `group_vars/all.yml`:

```yaml
homebrew_packages:
  - git
  - neovim  # Add this

homebrew_casks:
  - visual-studio-code
  - figma  # Add this
```

### Removing Packages

**Option 1**: Remove from list and run playbook again (doesn't uninstall)

**Option 2**: Manually uninstall:
```bash
brew uninstall package-name
brew uninstall --cask app-name
```

### Updating Packages

**Manual update**:
```bash
brew update      # Update package list
brew upgrade     # Upgrade all packages
brew upgrade git # Upgrade specific package
```

**Via playbook**: Run the playbook again with update tag:
```bash
ansible-playbook playbook.yml --tags "homebrew,update"
```

## File Locations

### Homebrew Installation

**Apple Silicon (M1/M2/M3)**:
- Location: `/opt/homebrew`
- Binaries: `/opt/homebrew/bin`
- Cellar: `/opt/homebrew/Cellar`

**Intel**:
- Location: `/usr/local`
- Binaries: `/usr/local/bin`
- Cellar: `/usr/local/Cellar`

### Installed Applications

**Casks**: `/Applications` or `~/Applications`

**Formulae**: Linked to `/opt/homebrew/bin` (or `/usr/local/bin`)

## Common Issues

### Issue: Cask Installation Fails

**Symptom**:
```
Error: It seems there is already an App at '/Applications/App.app'
```

**Solution**:
1. Remove the existing app from Applications
2. Run the playbook again

Or manually:
```bash
brew install --cask --force app-name
```

---

### Issue: Permission Denied

**Symptom**:
```
Error: Permission denied @ dir_s_mkdir - /opt/homebrew
```

**Solution**:
```bash
sudo chown -R $(whoami) /opt/homebrew
```

---

### Issue: Formula Not Found

**Symptom**:
```
Error: No available formula with the name "package-name"
```

**Solution**:
1. Update Homebrew: `brew update`
2. Check package name: `brew search package-name`
3. Package may have been renamed or removed

---

### Issue: Conflicting Versions

**Symptom**:
```
Error: Cannot link python@3.11
```

**Solution**:
```bash
brew unlink python@3.10
brew link python@3.11
```

## Useful Commands

### Search for packages:
```bash
brew search keyword
```

### Get package info:
```bash
brew info package-name
```

### List installed packages:
```bash
brew list           # Formulae
brew list --cask    # Casks
```

### Check for updates:
```bash
brew outdated
```

### Upgrade all:
```bash
brew upgrade
```

### Uninstall:
```bash
brew uninstall package-name
brew uninstall --cask app-name
```

### Clean up:
```bash
brew cleanup
brew cleanup -s  # Also clean up download cache
```

### Check for issues:
```bash
brew doctor
```

## Performance Notes

### Installation Time

**CLI tools (formulae)**: 2-5 minutes for typical setup

**GUI apps (casks)**: 10-20 minutes (download size varies)

**Total**: Approximately 15-25 minutes

### Disk Space

**Homebrew itself**: ~500MB

**Typical packages**: 2-5GB

**With all casks**: 8-12GB

## Security Considerations

### Package Verification

Homebrew verifies checksums for all downloads:
```bash
brew info package-name
# Shows: SHA256 checksum
```

### Cask Verification

Casks are notarized by Apple when possible. Check:
```bash
spctl --assess --verbose /Applications/App.app
```

### Keeping Packages Updated

Security updates are released regularly:
```bash
brew update && brew upgrade
```

## Tags

Run only Homebrew tasks:
```bash
ansible-playbook playbook.yml --tags "homebrew"
```

Available tags:
- `homebrew`: All homebrew tasks
- `taps`: Only tap repositories
- `packages`: Only install formulae
- `casks`: Only install casks
- `mas`: Only Mac App Store apps
- `update`: Update Homebrew
- `cleanup`: Clean old versions
- `diagnostics`: Run brew doctor

## Next Steps

After Homebrew role completes, the development-tools role will use these packages to set up Node.js, .NET, and Python environments.

See: [Development Tools Role Documentation](DEVELOPMENT-TOOLS.md)
