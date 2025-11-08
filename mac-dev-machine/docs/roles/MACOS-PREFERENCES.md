# macOS Preferences Role Documentation

## Purpose

The macOS Preferences role configures system-level settings using the `defaults` command. It customizes Dock behavior, Finder preferences, keyboard/trackpad settings, security options, and UI optimizations to create a developer-friendly environment.

## What Gets Configured

### Categories
1. **Dock**: Behavior, size, and appearance
2. **Finder**: File browser settings and visibility options
3. **Screenshots**: Location and format
4. **Trackpad**: Tap-to-click and gestures
5. **Keyboard**: Repeat rate and auto-correct
6. **UI**: Save dialogs, print dialogs, iCloud defaults
7. **Security**: Firewall, password requirements, screensaver
8. **Performance**: .DS_Store prevention, file handling

## Understanding `defaults` Command

The `defaults` command modifies macOS preference files (plist files).

**Basic syntax**:
```bash
defaults write <domain> <key> -<type> <value>
```

**Example**:
```bash
defaults write com.apple.dock autohide -bool true
```

This writes to: `~/Library/Preferences/com.apple.dock.plist`

**Common domains**:
- `com.apple.dock` - Dock preferences
- `com.apple.finder` - Finder preferences
- `NSGlobalDomain` - System-wide preferences
- `com.apple.screencapture` - Screenshot settings

## Task-by-Task Breakdown

### 1. Configure Dock Preferences

**Settings configured**:

| Setting | Default Value | Options | Effect |
|---------|--------------|---------|--------|
| `autohide` | `true` | true/false | Hide Dock automatically |
| `autohide-delay` | `0` | Float (seconds) | Delay before showing Dock |
| `tilesize` | `48` | Integer (pixels) | Size of Dock icons |
| `show-recents` | `false` | true/false | Show recent apps in Dock |
| `minimize-to-application` | `true` | true/false | Minimize windows into app icon |

**Commands executed**:
```bash
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock tilesize -int 48
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock minimize-to-application -bool true
killall Dock  # Restart Dock to apply changes
```

**Ansible Task**:
```yaml
- name: Configure Dock preferences
  community.general.osx_defaults:
    domain: com.apple.dock
    key: "{{ item.key }}"
    type: "{{ item.type }}"
    value: "{{ item.value }}"
    state: present
  loop:
    - { key: 'autohide', type: 'bool', value: true }
    # ... etc
  notify: restart dock
```

**Effect**:
- **autohide**: Dock slides down when not in use, maximizing screen space
- **autohide-delay**: Dock appears instantly when mouse moves to edge (no delay)
- **tilesize**: Moderate icon size (default is 64, we use 48)
- **show-recents**: Removes "Recent Applications" section from Dock
- **minimize-to-application**: Windows minimize into their app icon (cleaner Dock)

**Customization**: Edit in `group_vars/all.yml`:
```yaml
macos_preferences:
  dock:
    autohide: false      # Change to false to always show Dock
    tilesize: 64         # Larger icons
    autohide_delay: 0.5  # Add slight delay
```

---

### 2. Configure Finder Preferences

**Settings configured**:

| Setting | Default | Effect |
|---------|---------|--------|
| `AppleShowAllFiles` | `true` | Show hidden files (dotfiles) |
| `AppleShowAllExtensions` | `true` | Show file extensions (.txt, .jpg) |
| `ShowPathbar` | `true` | Show folder path at bottom |
| `ShowStatusBar` | `true` | Show file count and storage |
| `FXPreferredViewStyle` | `"Nlsv"` | Default view (List view) |
| `FXEnableExtensionChangeWarning` | `false` | Disable warning when changing extensions |

**Commands executed**:
```bash
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
killall Finder  # Restart Finder to apply changes
```

**View Style Options**:
- `"icnv"` - Icon view
- `"Nlsv"` - List view (default in this setup)
- `"clmv"` - Column view
- `"glyv"` - Gallery view

**Additional Finder Settings**:

**Show path in title bar**:
```bash
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
```
Effect: Window title shows `/Users/brian/Code/project` instead of just `project`

**Default location for new windows**:
```bash
defaults write com.apple.finder NewWindowTarget -string "PfHm"
```
Effect: New Finder windows open to Home folder

**Prevent .DS_Store on network volumes**:
```bash
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
```
Effect: No .DS_Store files created on network shares or USB drives

**Why important for developers**:
- See hidden config files (.gitignore, .env, etc.)
- Know file types without opening
- Navigate folder structure easily
- Avoid accidentally committing .DS_Store files

---

### 3. Configure Screenshot Settings

**Settings configured**:

| Setting | Default | Effect |
|---------|---------|--------|
| `location` | `~/Screenshots` | Where screenshots are saved |
| `type` | `"png"` | Screenshot format |
| `disable-shadow` | `false` | Include window shadows |

**Commands executed**:
```bash
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location -string "~/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool false
```

**Screenshot keyboard shortcuts**:
- `Cmd+Shift+3`: Full screen
- `Cmd+Shift+4`: Selection
- `Cmd+Shift+4, then Space`: Window screenshot
- `Cmd+Shift+5`: Screenshot utility

**Format options**:
- `"png"` - Lossless, larger files (default)
- `"jpg"` - Compressed, smaller files
- `"pdf"` - Vector format
- `"tiff"` - High quality

**Customization**:
```yaml
macos_preferences:
  screenshots:
    location: "~/Desktop"     # Save to Desktop
    format: "jpg"             # Use JPG instead
    disable_shadow: true      # Remove shadows
```

---

### 4. Configure Trackpad Preferences

**Settings configured**:

| Setting | Default | Effect |
|---------|---------|--------|
| `Clicking` | `true` | Tap trackpad to click |
| `com.apple.mouse.tapBehavior` | `1` | Tap-to-click on login screen too |

**Commands executed**:
```bash
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
```

**Effect**:
- Don't need to press trackpad down to click
- Faster, more comfortable interaction
- Works on login screen too

**Other trackpad options** (not configured by default):

```bash
# Three-finger drag (move windows)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Trackpad speed (1-3, default 1)
defaults write NSGlobalDomain com.apple.trackpad.scaling -int 2
```

---

### 5. Configure Keyboard Preferences

**Settings configured**:

| Setting | Default | Effect |
|---------|---------|--------|
| `KeyRepeat` | `2` | How fast keys repeat |
| `InitialKeyRepeat` | `15` | Delay before repeat starts |
| `NSAutomaticSpellingCorrectionEnabled` | `true` | Auto-correct typing |

**Commands executed**:
```bash
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool true
```

**KeyRepeat values**:
- System allows: 2 (fast) to 120 (slow)
- Our default: 2 (fastest through UI)
- Hidden faster: `defaults write NSGlobalDomain KeyRepeat -int 1` (requires logout)

**InitialKeyRepeat values**:
- System allows: 15 (short) to 120 (long)
- Our default: 15 (shortest through UI)

**Why fast repeat for developers**:
- Navigate code quickly with arrow keys
- Delete text faster
- More responsive editing experience

**Disable auto-correct** (optional):
```yaml
macos_preferences:
  keyboard:
    disable_auto_correct: true  # Disable auto-correct
```

**Disable smart quotes and dashes**:
```bash
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
```
Effect: Type straight quotes (`"`) instead of curly quotes (`""`), needed for code

---

### 6. Configure UI Preferences

**Expand save panel by default**:
```bash
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
```
Effect: Save dialogs open in expanded view (shows full file browser)

**Expand print panel by default**:
```bash
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
```
Effect: Print dialogs show all options

**Save to disk (not iCloud) by default**:
```bash
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
```
Effect: Save dialog defaults to local disk, not iCloud Drive

**Why important**:
- See full folder structure when saving
- Don't accidentally save to iCloud
- More control over file locations

---

### 7. Configure Security Preferences

**Disable "Are you sure?" dialog for downloaded apps**:
```bash
defaults write com.apple.LaunchServices LSQuarantine -bool false
```
**Warning**: This reduces security. Only use if you trust all downloaded apps.

**Require password immediately after sleep**:
```bash
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
```
Effect: Lock screen immediately when sleeping or starting screensaver

**Enable firewall**:
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
```
Effect: Blocks incoming network connections

**Check firewall status**:
```bash
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
```

---

### 8. Configure Menu Bar

**Show battery percentage**:
```bash
defaults write com.apple.menuextra.battery ShowPercent -string "YES"
```
Effect: See battery percentage in menu bar (80% instead of just icon)

---

### 9. Performance Optimizations

**Avoid creating .DS_Store on network volumes**:
```bash
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
```

**Avoid creating .DS_Store on USB volumes**:
```bash
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
```

**Why important**:
- .DS_Store files clutter Git repos
- Can cause issues on non-Mac systems
- Slow down network file operations

**To prevent in Git repos**, also add to `.gitignore`:
```
.DS_Store
```

---

### 10. Handlers: Restart Dock and Finder

**What they do**: Restart apps to apply preferences

**Commands**:
```bash
killall Dock
killall Finder
```

**Ansible Handlers** (in `handlers/main.yml`):
```yaml
- name: restart dock
  command: killall Dock
  ignore_errors: yes

- name: restart finder
  command: killall Finder
  ignore_errors: yes
```

**When triggered**: Automatically when related preferences change

**Effect**: Apps restart (takes 1-2 seconds), preferences take effect immediately

## Configuration

### Customizing Preferences

Edit `group_vars/all.yml`:

```yaml
macos_preferences:
  dock:
    autohide: false           # Always show Dock
    tilesize: 64              # Larger icons
    autohide_delay: 0.5       # Slight delay before showing

  finder:
    show_hidden_files: false  # Hide dotfiles
    default_view: "icnv"      # Icon view instead of list

  screenshots:
    location: "~/Desktop"     # Save to Desktop
    format: "jpg"             # Use JPG

  keyboard:
    key_repeat_rate: 1        # Even faster (requires logout)
    disable_auto_correct: true  # Disable auto-correct
```

### Adding New Preferences

To add preferences not in the default configuration:

1. Find the preference key:
```bash
# List all defaults for a domain
defaults read com.apple.dock

# Find specific key
defaults read com.apple.dock persistent-apps
```

2. Add to role tasks in `roles/macos-preferences/tasks/main.yml`:
```yaml
- name: Configure new preference
  community.general.osx_defaults:
    domain: com.apple.dock
    key: show-process-indicators
    type: bool
    value: true
    state: present
  notify: restart dock
```

3. Add to `group_vars/all.yml` for configurability:
```yaml
macos_preferences:
  dock:
    show_process_indicators: true
```

## File Locations

Preference files are stored in:
```
~/Library/Preferences/
├── com.apple.dock.plist
├── com.apple.finder.plist
├── com.apple.screencapture.plist
├── com.apple.AppleMultitouchTrackpad.plist
└── .GlobalPreferences.plist (NSGlobalDomain)
```

**Format**: Binary plist files (not human-readable)

**To view**:
```bash
defaults read com.apple.dock
# or
plutil -p ~/Library/Preferences/com.apple.dock.plist
```

## Common Issues

### Issue: Changes not taking effect

**Cause**: App not restarted

**Solution**:
```bash
killall Dock
killall Finder
killall SystemUIServer  # For menu bar changes
```

Or log out and log back in.

---

### Issue: Preference reverts after restart

**Cause**: Another app or system process is overwriting it

**Solution**:
1. Check for conflicting apps (management software, sync tools)
2. Re-run the playbook after restart
3. Some preferences require SIP (System Integrity Protection) to be disabled (not recommended)

---

### Issue: Permission denied when setting preference

**Cause**: System preference requires elevated privileges

**Solution**: Some preferences need `sudo`:
```bash
sudo defaults write /Library/Preferences/com.apple.preference domain key -type value
```

---

### Issue: Dock/Finder keeps restarting

**Cause**: Multiple preferences being set rapidly

**Solution**: Normal during playbook execution. Wait for completion.

## Manual Preference Management

### View current value:
```bash
defaults read com.apple.dock autohide
```

### Set preference:
```bash
defaults write com.apple.dock autohide -bool true
killall Dock
```

### Delete preference (reset to default):
```bash
defaults delete com.apple.dock autohide
killall Dock
```

### Export preferences:
```bash
defaults export com.apple.dock ~/dock-settings.plist
```

### Import preferences:
```bash
defaults import com.apple.dock ~/dock-settings.plist
killall Dock
```

## Discovering Preferences

**Method 1: Compare before/after**
```bash
# Before changing setting in System Settings
defaults read com.apple.dock > ~/before.txt

# After changing setting
defaults read com.apple.dock > ~/after.txt

# Compare
diff ~/before.txt ~/after.txt
```

**Method 2: Monitor changes**
```bash
# Watch for changes
fswatch -0 ~/Library/Preferences | xargs -0 -n 1 echo
```

**Method 3: Search online**
- https://macos-defaults.com/ - Comprehensive database
- https://www.defaults-write.com/ - Community database

## Performance Notes

**Execution time**: 15-30 seconds

**System impact**: Minimal - just restarting Dock and Finder

**Requires restart**: Some preferences take effect immediately, others need logout/restart

## Useful Commands

```bash
# List all preferences for a domain
defaults read com.apple.dock

# Search for a key
defaults find autohide

# Reset all Dock preferences
defaults delete com.apple.dock
killall Dock

# Reset all Finder preferences
defaults delete com.apple.finder
killall Finder

# View system-wide preferences
defaults read NSGlobalDomain

# Check current keyboard repeat rate
defaults read NSGlobalDomain KeyRepeat
```

## Tags

Run only preferences tasks:
```bash
ansible-playbook playbook.yml --tags "preferences"
```

Available tags:
- `preferences`: All preference tasks
- `dock`: Dock settings only
- `finder`: Finder settings only
- `screenshots`: Screenshot settings
- `trackpad`: Trackpad settings
- `keyboard`: Keyboard settings
- `security`: Security settings
- `ui`: UI preferences

## Next Steps

After system preferences are configured, the applications role will configure app-specific settings.

See: [Applications Role Documentation](APPLICATIONS.md)
