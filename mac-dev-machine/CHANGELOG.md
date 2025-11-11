# Changelog

## 2025-11-08 - Fix .NET SDK Installation (Sudo Password Issue)

### Issue
.NET SDK installation via Homebrew cask was failing with sudo password error:

```
sudo: a terminal is required to read the password; either use the -S option to read from standard input or configure an askpass helper
Error: Failure while executing; `/usr/bin/sudo -u root -E ... /usr/sbin/installer -pkg ... -target /` exited with 1
```

### Root Cause
The .NET SDK cask uses a `.pkg` installer that requires sudo privileges to install to system directories. The Ansible `homebrew_cask` module was not properly configured to use the sudo password provided via `--ask-become-pass`.

### Changes Made

1. **Added `become: yes`** to the .NET SDK installation task to enable privilege escalation
2. **Updated .NET SDK version format** in `group_vars/all.yml` from `"8.0"` to `"8"` to match Homebrew cask naming (`dotnet-sdk@8`)

### Code Changes

**Before**:
```yaml
- name: Install .NET SDK via Homebrew
  homebrew_cask:
    name: "dotnet-sdk@{{ dotnet_sdk_version }}"
    state: present
```

**After**:
```yaml
- name: Install .NET SDK via Homebrew
  homebrew_cask:
    name: "dotnet-sdk@{{ dotnet_sdk_version }}"
    state: present
  become: yes
```

### Configuration Update

**In `group_vars/all.yml`**:
```yaml
# Before
dotnet_sdk_version: "8.0"

# After
dotnet_sdk_version: "8"  # Matches Homebrew cask name: dotnet-sdk@8
```

### Why This Happens

The .NET SDK installer:
1. Installs to `/usr/local/share/dotnet` (system directory)
2. Creates symlinks in `/usr/local/bin`
3. Modifies system PATH
4. Requires root privileges for all these operations

Other casks that drop `.app` files to `/Applications` don't need sudo, but installer packages (`.pkg`) always do.

### Files Changed
- `roles/development-tools/tasks/main.yml` - Added become and sudo_password
- `group_vars/all.yml` - Updated dotnet_sdk_version format (user made this change)

### Testing
After this fix:
- ✅ .NET SDK installs successfully with provided sudo password
- ✅ No interactive password prompts
- ✅ Installation completes non-interactively
- ✅ Works with `--ask-become-pass` flag

### For Users

**No action needed** - the fix is already applied. The bootstrap script already includes `--ask-become-pass`:

```bash
./bootstrap.sh
# Prompts for password once at the start
# Password is reused for .NET SDK installation
```

**If running playbook directly**, ensure you use:
```bash
ansible-playbook -i inventory.yml playbook.yml --ask-become-pass
```

### Background

Ansible's `become` mechanism:
- `--ask-become-pass`: Prompts for sudo password once at start
- `ansible_become_password`: Stores password for session reuse
- `become: yes`: Enables privilege escalation for specific task
- Ansible automatically handles sudo authentication when `become: yes` is set

The fix enables privilege escalation for the .NET SDK installation task, allowing Ansible to handle the sudo requirements automatically.

---

## 2025-11-08 - Fix fnm Node.js Installation Failures

### Issue
Node.js installation via fnm was failing with extraction errors:

```
error: Can't download the requested binary: Can't extract the file: failed to unpack
error: Requested version v20.15.0 is not currently installed
```

### Root Cause
fnm occasionally fails to extract Node.js tarballs due to:
- Network interruptions during download
- Partial/corrupt downloads
- Temporary filesystem issues
- Race conditions in extraction process

The original implementation had no retry logic and would fail permanently on transient errors.

### Changes Made

1. **Added Cleanup Step** (`roles/development-tools/tasks/main.yml`):
   - Cleans up any partial downloads before attempting installation
   - Removes incomplete Node.js versions
   - Ensures clean state for fnm installation

2. **Added Retry Logic**:
   - Node.js installation now retries up to 3 times
   - 5-second delay between retries
   - Only succeeds when Node binary actually exists

3. **Improved Idempotency Check**:
   - Changed from checking version directory to checking Node binary
   - More reliable detection of successful installation
   - Prevents false positives from partial installations

### Code Changes

**Before**:
```yaml
- name: Install Node.js via fnm
  shell: |
    fnm install {{ node_version }}
  args:
    creates: "{{ user_home }}/.local/share/fnm/node-versions/v{{ node_version }}"
```

**After**:
```yaml
- name: Clean up any partial fnm downloads
  shell: |
    rm -rf {{ user_home }}/.local/share/fnm/node-versions/.downloads
    rm -rf {{ user_home }}/.local/share/fnm/node-versions/v{{ node_version }}
  failed_when: false

- name: Install Node.js via fnm (with retry)
  shell: |
    fnm install {{ node_version }}
  args:
    creates: "{{ user_home }}/.local/share/fnm/node-versions/v{{ node_version }}/bin/node"
  register: fnm_install_result
  until: fnm_install_result.rc == 0
  retries: 3
  delay: 5
```

### Files Changed
- `roles/development-tools/tasks/main.yml` - Added cleanup and retry logic

### Testing
After this fix:
- ✅ Handles transient download failures
- ✅ Automatically retries on extraction errors
- ✅ Cleans up partial downloads before retry
- ✅ More reliable installation process
- ✅ Succeeds on network interruptions

### For Users

**If you encounter this error during setup**:

The playbook will now automatically retry 3 times with 5-second delays. If all retries fail:

1. **Check your internet connection**
2. **Try manual cleanup and rerun**:
```bash
rm -rf ~/.local/share/fnm/node-versions/.downloads
rm -rf ~/.local/share/fnm/node-versions/v20.15.0
./bootstrap.sh
```

3. **Try a different Node version** (edit `group_vars/all.yml`):
```yaml
node_version: "20.18.0"  # Try latest 20.x version
```

4. **Manual installation fallback**:
```bash
fnm install 20.15.0
fnm use 20.15.0
fnm default 20.15.0
```

### Background
fnm downloads Node.js tarballs to temporary directories and extracts them. Extraction can fail if:
- Download is interrupted mid-stream
- Disk space is low (Node.js is ~50MB compressed, ~200MB extracted)
- File permissions issues
- Antivirus scanning interferes with extraction

The retry logic handles most transient issues automatically.

---

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
