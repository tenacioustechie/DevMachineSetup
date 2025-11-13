# Applications Role Documentation

## Purpose

The Applications role configures application-specific settings for development tools. It installs VS Code extensions, configures editor settings, and sets up other applications like iTerm2, Rectangle, and Docker Desktop.

## What Gets Configured

### VS Code
- Extensions installation
- Editor settings (fonts, formatting, etc.)
- Language-specific settings

### iTerm2
- Preferences location
- Custom configuration directory

### Rectangle
- Launch at login
- Window management tool

### Docker Desktop
- Status verification
- Configuration check

## VS Code Configuration

### Extensions Installed

The default extension list (from `group_vars/all.yml`):

| Extension | Purpose |
|-----------|---------|
| `ms-vscode.csharp` | C# language support |
| `ms-dotnettools.csdevkit` | .NET development kit |
| `dbaeumer.vscode-eslint` | ESLint for JavaScript/TypeScript |
| `esbenp.prettier-vscode` | Code formatter |
| `angular.ng-template` | Angular template support |
| `ms-python.python` | Python language support |
| `ms-azuretools.vscode-docker` | Docker integration |
| `eamodio.gitlens` | Enhanced Git features |
| `pkief.material-icon-theme` | File icon theme |
| `github.copilot` | AI code completion |
| `editorconfig.editorconfig` | EditorConfig support |
| `bradlc.vscode-tailwindcss` | Tailwind CSS IntelliSense |
| `hashicorp.terraform` | Terraform language support |

### Installation Command

For each extension:
```bash
code --install-extension extension-id
```

**Example**:
```bash
code --install-extension ms-vscode.csharp
```

**Ansible Task**:
```yaml
- name: Install VS Code extensions
  command: "code --install-extension {{ item }}"
  loop: "{{ vscode_extensions }}"
  register: vscode_install
  changed_when: "'is already installed' not in vscode_install.stdout"
```

**Idempotent**: Yes - VS Code reports "already installed" if extension exists

### VS Code Settings

**Location**: `~/Library/Application Support/Code/User/settings.json`

**Settings configured**:

```json
{
  // Font Configuration
  "editor.fontFamily": "JetBrains Mono, Fira Code, Menlo, Monaco, 'Courier New', monospace",
  "editor.fontSize": 14,
  "editor.fontLigatures": true,  // Enable programming ligatures (-> becomes →)

  // Editor Behavior
  "editor.formatOnSave": true,  // Auto-format on save
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"  // Auto-fix ESLint errors
  },
  "files.autoSave": "onFocusChange",  // Save when switching files

  // Appearance
  "workbench.iconTheme": "material-icon-theme",

  // Terminal
  "terminal.integrated.fontFamily": "Hack Nerd Font Mono, JetBrains Mono",
  "terminal.integrated.fontSize": 13,

  // Git
  "git.autofetch": true,  // Automatically fetch from remote
  "git.confirmSync": false,  // Don't confirm push/pull

  // Explorer
  "explorer.confirmDelete": false,  // Don't confirm file deletion
  "explorer.confirmDragAndDrop": false,  // Don't confirm drag and drop

  // Language-specific Formatters
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[csharp]": {
    "editor.defaultFormatter": "ms-dotnettools.csharp"
  }
}
```

**Key Features**:

**Font Ligatures**: Programming symbols render as single characters
- `!=` becomes `≠`
- `=>` becomes `⇒`
- `>=` becomes `≥`

**Format on Save**: Code automatically formats to style guide

**Auto-fix ESLint**: Automatically fixes linting errors when saving

**Auto Save**: No need to manually save files

**Git Auto-fetch**: Keeps local repository aware of remote changes

### Adding VS Code Extensions

Edit `group_vars/all.yml`:

```yaml
vscode_extensions:
  - "ms-vscode.csharp"
  - "dbaeumer.vscode-eslint"
  - "rust-lang.rust-analyzer"  # Add this
  - "svelte.svelte-vscode"     # Add this
```

**Find extension IDs**:
1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Click extension
4. Click gear icon > "Copy Extension ID"

Or search: https://marketplace.visualstudio.com/

### Manual Extension Management

```bash
# Install extension
code --install-extension extension-id

# List installed extensions
code --list-extensions

# Uninstall extension
code --uninstall-extension extension-id

# Export extension list
code --list-extensions > extensions.txt

# Install from list
cat extensions.txt | xargs -L 1 code --install-extension
```

## iTerm2 Configuration

**What it does**: Sets up preferences storage location

### Commands Executed

```bash
# Set preferences location
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "~/.config/iterm2"

# Enable loading from custom folder
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

# Create config directory
mkdir -p ~/.config/iterm2
```

### Benefits

- Version control iTerm2 settings
- Sync settings across machines
- Backup configuration

### Customizing iTerm2

After setup, configure iTerm2 manually:
1. Open iTerm2
2. Preferences > General > Preferences
3. Verify "Load preferences from custom folder" is checked
4. Configure colors, fonts, profiles
5. Settings auto-save to `~/.config/iterm2/`

**To backup**:
```bash
# Backup
cp -r ~/.config/iterm2 ~/Dropbox/backups/

# Restore
cp -r ~/Dropbox/backups/iterm2 ~/.config/
```

## Rectangle Configuration

**What it does**: Configures Rectangle window manager to launch at login

**Command**:
```bash
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Rectangle.app", hidden:false}'
```

**Effect**: Rectangle starts automatically when you log in

### Using Rectangle

**Keyboard Shortcuts** (default):

| Shortcut | Action |
|----------|--------|
| `Ctrl+Opt+Left` | Snap window to left half |
| `Ctrl+Opt+Right` | Snap window to right half |
| `Ctrl+Opt+Up` | Maximize window |
| `Ctrl+Opt+Down` | Restore window size |
| `Ctrl+Opt+F` | Fullscreen window |
| `Ctrl+Opt+C` | Center window |

**Quarters**:
- `Ctrl+Opt+U` - Top-left quarter
- `Ctrl+Opt+I` - Top-right quarter
- `Ctrl+Opt+J` - Bottom-left quarter
- `Ctrl+Opt+K` - Bottom-right quarter

**Thirds**:
- `Ctrl+Opt+D` - Left 1/3
- `Ctrl+Opt+F` - Center 1/3
- `Ctrl+Opt+G` - Right 1/3

### Customizing Rectangle

1. Click Rectangle icon in menu bar
2. Preferences
3. Customize keyboard shortcuts
4. Enable/disable features

**Alternative**: Magnet (paid app with similar features)

## Docker Desktop Configuration

**What it does**: Verifies Docker Desktop is installed

**Command**:
```bash
docker info
```

**Expected**: Docker server information

**If not running**: Message displays: "Start Docker Desktop from Applications folder"

### Starting Docker Desktop

**Manual start**:
1. Open `/Applications/Docker.app`
2. Accept license terms (first time)
3. Wait for whale icon to stop animating in menu bar
4. Verify: `docker ps`

### Docker Desktop Settings

**Recommended settings** (configure in Docker Desktop app):

1. **Resources**:
   - CPUs: Half of available cores
   - Memory: 4-8 GB
   - Disk: 60 GB

2. **General**:
   - Start Docker Desktop when you log in: ✓
   - Use Docker Compose V2: ✓

3. **Docker Engine** (advanced):
```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB"
    }
  }
}
```

### Useful Docker Commands

```bash
# Check Docker is running
docker info

# List running containers
docker ps

# List all containers
docker ps -a

# List images
docker images

# Remove stopped containers
docker container prune

# Remove unused images
docker image prune

# Remove all unused data
docker system prune
```

## Git Credential Helper

**What it does**: Ensures Git uses macOS Keychain for password storage

**Command**:
```bash
git config --global credential.helper osxkeychain
```

**Effect**:
- Passwords stored in macOS Keychain
- No need to enter password repeatedly
- Secure storage with encryption

**Verify**:
```bash
git config --global credential.helper
# Output: osxkeychain
```

## Configuration

### Adding VS Code Extensions

Edit `group_vars/all.yml`:

```yaml
vscode_extensions:
  - "ms-vscode.csharp"
  - "new-extension-id"  # Add here
```

### Customizing VS Code Settings

VS Code settings are hardcoded in the role. To customize:

**Option 1**: Edit `roles/applications/tasks/main.yml` and modify the settings JSON

**Option 2**: After setup, manually configure in VS Code:
- Settings are stored in `~/Library/Application Support/Code/User/settings.json`
- Use VS Code Settings UI (Cmd+,)
- Settings Sync to sync across machines

**Option 3**: Use VS Code Settings Sync feature:
1. Cmd+Shift+P > "Settings Sync: Turn On"
2. Sign in with GitHub/Microsoft
3. Settings auto-sync across machines

## File Locations

### VS Code
```
~/Library/Application Support/Code/
├── User/
│   ├── settings.json       # User settings
│   ├── keybindings.json    # Keyboard shortcuts
│   └── snippets/           # Custom snippets
└── extensions/             # Installed extensions
```

### iTerm2
```
~/.config/iterm2/
└── com.googlecode.iterm2.plist  # All iTerm2 settings
```

### Rectangle
Settings stored in:
```
~/Library/Preferences/com.knollsoft.Rectangle.plist
```

### Docker
```
~/.docker/
├── config.json       # Docker CLI config
└── daemon.json       # Docker daemon config (if configured)
```

## Common Issues

### Issue: code command not found

**Cause**: VS Code shell command not installed

**Solution**:
1. Open VS Code
2. Cmd+Shift+P
3. "Shell Command: Install 'code' command in PATH"
4. Restart terminal

---

### Issue: VS Code extension installation fails

**Cause**: Network issue or VS Code not running

**Solution**:
```bash
# Retry installation
code --install-extension extension-id

# Check if VS Code is in PATH
which code

# Try opening VS Code first
code .
```

---

### Issue: Rectangle not launching at login

**Cause**: macOS login items permission

**Solution**:
1. System Settings > General > Login Items
2. Verify Rectangle is in list
3. Toggle off and on if needed

Or manually add:
1. System Settings > General > Login Items
2. Click "+"
3. Select `/Applications/Rectangle.app`

---

### Issue: Docker command not found

**Cause**: Docker Desktop not started

**Solution**:
1. Open Docker Desktop
2. Wait for startup
3. Retry command

Or check PATH:
```bash
echo $PATH | grep docker
```

## Performance Notes

**Execution time**:
- VS Code extensions: 3-5 minutes (depends on number and size)
- Other configurations: <1 minute
- Total: ~5 minutes

**Disk space**:
- VS Code extensions: 200-500 MB
- Docker Desktop: 2-4 GB

## Tags

Run only applications tasks:
```bash
ansible-playbook playbook.yml --tags "applications"
```

Available tags:
- `applications`: All application tasks
- `vscode`: VS Code configuration only
- `iterm2`: iTerm2 configuration
- `rectangle`: Rectangle configuration
- `docker`: Docker verification
- `git`: Git credential helper

## Next Steps

After applications are configured, you can optionally install Xcode and iOS development tools.

See: [Optional Tools Role Documentation](OPTIONAL-TOOLS.md)
