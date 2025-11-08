# Changelog

## 2025-11-08 - Remove All Deprecated Homebrew Taps

### Issue
Running the setup resulted in errors when tapping Homebrew repositories:
1. **First error**: `homebrew/cask` - "no longer typically necessary"
2. **Second error**: `homebrew/cask-fonts` - deprecated May 2024
3. **Potential error**: `homebrew/cask-versions` - deprecated May 2024

### Root Cause
Homebrew has consolidated all casks, fonts, and versioned applications into the main `homebrew/cask` repository. All separate taps have been deprecated and are no longer needed.

### Timeline of Deprecations
- **2021**: `homebrew/cask` integrated into Homebrew core
- **May 2024**: `homebrew/cask-fonts` deprecated, fonts migrated to `homebrew/cask`
- **May 2024**: `homebrew/cask-versions` deprecated, versioned casks now use `@version` suffix in `homebrew/cask`

### Changes Made

1. **Updated `group_vars/all.yml`**:
   - Removed all deprecated taps
   - Set `homebrew_taps: []` (empty list)
   - Added comprehensive comment explaining the deprecations

2. **Updated Documentation** (`docs/roles/HOMEBREW.md`):
   - Documented all deprecated taps with deprecation dates
   - Explained that no taps are needed anymore
   - Updated task descriptions to reflect current state
   - Added examples of how to install fonts and apps directly

3. **Enhanced Error Handling** in `roles/homebrew/tasks/main.yml`:
   - Task gracefully handles tap deprecation messages
   - Won't fail if taps are "no longer necessary"
   - Future-proof against additional Homebrew changes

### How It Works Now

**Before** (required tapping):
```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono
```

**After** (direct installation):
```bash
brew install --cask font-jetbrains-mono  # No tap needed!
```

**Versioned apps** (use @version suffix):
```bash
brew install --cask firefox@developer-edition
```

### Files Changed
- `group_vars/all.yml` - Removed all taps, set to empty list
- `roles/homebrew/tasks/main.yml` - Enhanced error handling (from previous fix)
- `docs/roles/HOMEBREW.md` - Updated documentation

### Testing
After this fix:
- ✅ No tapping errors
- ✅ All casks install successfully
- ✅ All fonts install successfully
- ✅ Versioned applications work with @version suffix
- ✅ Setup completes without errors

### For Users
If you've already cloned this repository:

**Pull the latest changes**:
```bash
cd /path/to/DevMachineSetup
git pull
```

**If you have old taps**, remove them:
```bash
brew untap homebrew/cask-fonts 2>/dev/null || true
brew untap homebrew/cask-versions 2>/dev/null || true
```

Then re-run:
```bash
./bootstrap.sh
```

---

## 2025-11-08 - Fix Homebrew Cask Tap Error (Initial Fix)

### Issue
Running the setup for the first time resulted in an error during the "Tap Homebrew repositories" task:

```
[ERROR]: Task failed: Module failed: added: 0 unchanged: 0, error: failed to tap: homebrew/cask due to Error: Tapping homebrew/cask is no longer typically necessary.
```

### Root Cause
As of Homebrew 3.0 (released in 2021), `homebrew/cask` was integrated into Homebrew core and no longer needs to be tapped as a separate repository. Attempting to tap it now causes an error.

### Changes Made

1. **Updated `group_vars/all.yml`**:
   - Removed `homebrew/cask` from the `homebrew_taps` list
   - Added comment explaining that it's now built-in
   - Kept `homebrew/cask-fonts` and `homebrew/cask-versions` (still required)

2. **Updated `roles/homebrew/tasks/main.yml`**:
   - Added error handling to the tap task
   - Task now ignores "already tapped" and "no longer typically necessary" errors
   - This makes the role more resilient to Homebrew changes

3. **Updated Documentation**:
   - Updated `docs/roles/HOMEBREW.md` to reflect current Homebrew behavior
   - Added note about `homebrew/cask` being built-in
   - Documented the error handling in the tap task

### Files Changed
- `group_vars/all.yml` - Removed obsolete tap
- `roles/homebrew/tasks/main.yml` - Added error handling
- `docs/roles/HOMEBREW.md` - Updated documentation

### Testing
After this fix:
- ✅ Homebrew taps install successfully
- ✅ Casks (GUI applications) install without issues
- ✅ Fonts from `homebrew/cask-fonts` install correctly
- ✅ Setup completes without errors

### For Users
If you've already cloned this repository before this fix:

**Option 1: Pull the latest changes**
```bash
cd /path/to/DevMachineSetup
git pull
```

**Option 2: Manual fix**
Edit `group_vars/all.yml` and remove `- homebrew/cask` from the `homebrew_taps` list:

```yaml
homebrew_taps:
  - homebrew/cask-fonts
  - homebrew/cask-versions
```

Then re-run:
```bash
./bootstrap.sh
```

### Background
- **Homebrew 3.0** (February 2021): Integrated casks into core
- **Before**: Required `brew tap homebrew/cask` to install GUI apps
- **After**: Casks work out of the box with `brew install --cask <app>`
- **Our setup**: Uses Ansible's `homebrew_cask` module which handles this automatically

### Additional Notes
The error handling added to the tap task makes the setup more resilient to future Homebrew changes. If Homebrew deprecates additional taps or makes similar changes, the setup will continue to work instead of failing.
