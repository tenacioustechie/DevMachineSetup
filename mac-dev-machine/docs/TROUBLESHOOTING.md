# Troubleshooting Guide

Common issues and solutions for the Mac Development Machine setup.

## Table of Contents

- [Bootstrap Issues](#bootstrap-issues)
- [Ansible Issues](#ansible-issues)
- [Homebrew Issues](#homebrew-issues)
- [Development Tools Issues](#development-tools-issues)
- [System Preferences Issues](#system-preferences-issues)
- [Application Issues](#application-issues)
- [Xcode Issues](#xcode-issues)
- [General Debugging](#general-debugging)

## Bootstrap Issues

### Issue: Xcode Command Line Tools Installation Stuck

**Symptom**: Installation dialog appears but never completes

**Solutions**:

1. Cancel and retry:
```bash
# Cancel installation
sudo rm -rf /Library/Developer/CommandLineTools

# Retry
xcode-select --install
```

2. Download manually from Apple:
   - Visit https://developer.apple.com/download/more/
   - Sign in with Apple ID
   - Download "Command Line Tools for Xcode"
   - Install the DMG

3. After manual install:
```bash
./bootstrap.sh
```

---

### Issue: Homebrew Installation Fails

**Symptom**:
```
Failed to connect to raw.githubusercontent.com
```

**Solutions**:

1. Check internet connection
2. Check if GitHub is accessible:
```bash
ping github.com
```

3. Try alternative installation:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

4. Check firewall/proxy settings

---

### Issue: Permission Denied Errors

**Symptom**:
```
Permission denied @ dir_s_mkdir - /opt/homebrew
```

**Solution**:
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew

# Or for Intel Macs
sudo chown -R $(whoami) /usr/local
```

---

## Ansible Issues

### Issue: Ansible Not Found After Installation

**Symptom**:
```
ansible: command not found
```

**Solutions**:

1. Source shell configuration:
```bash
source ~/.zshrc
```

2. Manually add Homebrew to PATH:
```bash
# For Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# For Intel
eval "$(/usr/local/bin/brew shellenv)"
```

3. Restart terminal

4. Verify Homebrew is in PATH:
```bash
which brew
echo $PATH
```

---

### Issue: Ansible Module Not Found

**Symptom**:
```
ERROR! couldn't resolve module/action 'community.general.osx_defaults'
```

**Solution**:
```bash
# Install required collection
ansible-galaxy collection install community.general

# Or install all requirements
ansible-galaxy install -r requirements.yml
```

---

### Issue: Playbook Fails with "Ask for sudo password"

**Symptom**:
```
Missing sudo password
```

**Solution**:

Run with `--ask-become-pass`:
```bash
ansible-playbook -i inventory.yml playbook.yml --ask-become-pass
```

Or use bootstrap script (includes this flag):
```bash
./bootstrap.sh
```

---

### Issue: Task Fails But Playbook Continues

**Symptom**: Errors shown but playbook doesn't stop

**Reason**: Task has `ignore_errors: yes` or `failed_when: false`

**To Debug**: Run with `-vv`:
```bash
ansible-playbook playbook.yml -vv
```

---

## Homebrew Issues

### Issue: Formula Not Found

**Symptom**:
```
Error: No available formula with the name "package-name"
```

**Solutions**:

1. Update Homebrew:
```bash
brew update
```

2. Search for correct name:
```bash
brew search package-name
```

3. Check if it's a cask:
```bash
brew search --cask package-name
```

4. Package may have been renamed or removed - check Homebrew website

---

### Issue: Cask Already Installed

**Symptom**:
```
Error: Cask 'app-name' is already installed
```

**Solutions**:

1. Reinstall:
```bash
brew reinstall --cask app-name
```

2. Force install:
```bash
brew install --cask --force app-name
```

3. Or just skip (playbook will continue)

---

### Issue: Conflicting Versions

**Symptom**:
```
Error: Cannot link python@3.11
```

**Solution**:
```bash
# Unlink old version
brew unlink python@3.10

# Link new version
brew link python@3.11

# Or force link
brew link --overwrite python@3.11
```

---

### Issue: Homebrew Running Slow

**Symptom**: Package installation taking very long

**Solutions**:

1. Update Homebrew:
```bash
brew update
```

2. Clean up:
```bash
brew cleanup
```

3. Check for issues:
```bash
brew doctor
```

4. Disable auto-update during installs (temporary):
```bash
export HOMEBREW_NO_AUTO_UPDATE=1
brew install package-name
```

---

## Development Tools Issues

### Issue: fnm Command Not Found

**Symptom**:
```bash
fnm: command not found
```

**Solutions**:

1. Reload shell:
```bash
source ~/.zshrc
```

2. Verify fnm installed:
```bash
brew list | grep fnm
```

3. Manually initialize:
```bash
eval "$(fnm env --use-on-cd)"
```

4. Check .zshrc has fnm line:
```bash
grep fnm ~/.zshrc
```

---

### Issue: Node Command Not Found

**Symptom**:
```bash
node: command not found
```

**Solutions**:

1. Initialize fnm:
```bash
eval "$(fnm env --use-on-cd)"
```

2. Install Node:
```bash
fnm install 20.15.0
fnm use 20.15.0
```

3. Restart terminal

4. Check fnm status:
```bash
fnm list
fnm current
```

---

### Issue: fnm Node.js Installation Fails

**Symptom**:
```
error: Can't download the requested binary: Can't extract the file
error: Requested version v20.15.0 is not currently installed
```

**Root Cause**: Network interruption, partial download, or filesystem issue during extraction

**Solutions**:

1. **The playbook automatically retries 3 times** - wait for retries to complete

2. If all retries fail, clean up and retry manually:
```bash
# Clean up partial downloads
rm -rf ~/.local/share/fnm/node-versions/.downloads
rm -rf ~/.local/share/fnm/node-versions/v20.15.0

# Try again
fnm install 20.15.0
```

3. Check available disk space:
```bash
df -h ~
# Node.js needs ~200MB for extraction
```

4. Try a different Node version:
```bash
# Edit group_vars/all.yml
node_version: "20.18.0"  # Try latest 20.x
```

5. Check internet connection:
```bash
curl -I https://nodejs.org/dist/v20.15.0/node-v20.15.0-darwin-arm64.tar.gz
```

6. Manual download and install:
```bash
# Download manually
curl -O https://nodejs.org/dist/v20.15.0/node-v20.15.0-darwin-arm64.tar.gz

# fnm will use local file
fnm install 20.15.0
```

**Prevention**: The setup now includes:
- Automatic cleanup of partial downloads
- 3 retry attempts with 5-second delays
- Better idempotency checks

---

### Issue: .NET SDK Not Found

**Symptom**:
```bash
dotnet: command not found
```

**Solutions**:

1. Check if installed:
```bash
ls /usr/local/share/dotnet
```

2. Add to PATH:
```bash
export PATH="/usr/local/share/dotnet:$PATH"
```

3. Add to .zshrc permanently:
```bash
echo 'export PATH="/usr/local/share/dotnet:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

4. Reinstall if missing:
```bash
brew install --cask dotnet-sdk8.0
```

---

### Issue: pip Install Permission Denied

**Symptom**:
```
error: externally-managed-environment
```

**Solution**: Use virtual environments (recommended):
```bash
python3 -m venv venv
source venv/bin/activate
pip install package-name
```

Or use `--user` flag:
```bash
pip3 install --user package-name
```

---

## System Preferences Issues

### Issue: Preferences Not Taking Effect

**Symptom**: Changes don't appear after running playbook

**Solutions**:

1. Restart affected applications:
```bash
killall Dock
killall Finder
killall SystemUIServer
```

2. Log out and log back in

3. Restart Mac (for some settings)

4. Check if preference was set:
```bash
defaults read com.apple.dock autohide
```

---

### Issue: Dock/Finder Keep Restarting

**Symptom**: Applications restart repeatedly

**Reason**: Multiple preferences being set in sequence (normal during playbook)

**Solution**: Wait for playbook to complete - this is expected behavior

---

### Issue: Preferences Revert After Restart

**Symptom**: Settings reset to defaults after reboot

**Solutions**:

1. Check for management software (corporate MDM, etc.)
2. Check for sync software overwriting preferences
3. Re-run playbook after restart
4. Some preferences require SIP disabled (not recommended)

---

## Application Issues

### Issue: VS Code 'code' Command Not Found

**Symptom**:
```bash
code: command not found
```

**Solution**:

1. Open VS Code
2. Press `Cmd+Shift+P`
3. Type: "Shell Command: Install 'code' command in PATH"
4. Select and run
5. Restart terminal

---

### Issue: VS Code Extensions Fail to Install

**Symptom**:
```
Error: EACCES: permission denied
```

**Solutions**:

1. Check VS Code is installed:
```bash
ls /Applications/Visual\ Studio\ Code.app
```

2. Open VS Code first:
```bash
open -a "Visual Studio Code"
```

3. Manually install extension:
```bash
code --install-extension extension-id
```

4. Check extensions directory permissions:
```bash
ls -la ~/. vscode/extensions
```

---

### Issue: Rectangle Not Working

**Symptom**: Window management shortcuts don't work

**Solutions**:

1. Check if Rectangle is running:
```bash
ps aux | grep Rectangle
```

2. Open Rectangle manually:
```bash
open -a Rectangle
```

3. Grant Accessibility permissions:
   - System Settings > Privacy & Security > Accessibility
   - Enable Rectangle

4. Restart Rectangle

---

### Issue: Docker Command Not Found

**Symptom**:
```bash
docker: command not found
```

**Solutions**:

1. Start Docker Desktop:
```bash
open -a Docker
```

2. Wait for Docker to start (whale icon in menu bar)

3. Check Docker is in PATH:
```bash
echo $PATH | grep docker
```

4. Add to PATH if needed:
```bash
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
```

---

## Xcode Issues

### Issue: Xcode Download Fails

**Symptom**: Download starts but fails or times out

**Solutions**:

1. Check internet connection
2. Check App Store system status
3. Try manual download:
   - Open App Store app
   - Search for Xcode
   - Click "Get" or "Install"

4. For older versions:
   - Visit https://developer.apple.com/download/
   - Download Xcode manually
   - Drag to Applications

---

### Issue: Xcode License Not Accepted

**Symptom**:
```
Agreeing to the Xcode/iOS license requires admin privileges
```

**Solution**:
```bash
sudo xcodebuild -license accept
```

---

### Issue: Simulator Won't Boot

**Symptom**:
```
Unable to boot device in current state: Booted
```

**Solutions**:

1. Shutdown all simulators:
```bash
xcrun simctl shutdown all
```

2. Erase and reset:
```bash
xcrun simctl erase all
```

3. Kill Simulator app:
```bash
killall Simulator
```

4. Restart:
```bash
open -a Simulator
```

---

### Issue: CocoaPods Install Fails

**Symptom**:
```
ERROR: While executing gem ... (Gem::FilePermissionError)
```

**Solution**: Use sudo:
```bash
sudo gem install cocoapods
```

---

## General Debugging

### Enable Verbose Output

```bash
# Level 1: Verbose
ansible-playbook playbook.yml -v

# Level 2: More verbose
ansible-playbook playbook.yml -vv

# Level 3: Debug
ansible-playbook playbook.yml -vvv

# Level 4: Connection debug
ansible-playbook playbook.yml -vvvv
```

### Check Playbook Syntax

```bash
ansible-playbook playbook.yml --syntax-check
```

### Dry Run (Check What Would Change)

```bash
ansible-playbook playbook.yml --check
```

### Run Specific Tasks

```bash
# Run only one role
ansible-playbook playbook.yml --tags "homebrew"

# Skip specific role
ansible-playbook playbook.yml --skip-tags "xcode"

# Run multiple tags
ansible-playbook playbook.yml --tags "homebrew,dotfiles"
```

### Check Variable Values

```bash
# View all variables
ansible localhost -m debug -a "var=hostvars[inventory_hostname]"

# View specific variable
ansible-playbook playbook.yml -e "debug_mode=true" -v
```

### Verify File Permissions

```bash
# Check Ansible files
ls -la ~/code/DevMachineSetup/mac-dev-machine

# Check home directory
ls -la ~/

# Check specific files
ls -la ~/.zshrc
ls -la ~/.ssh
ls -la ~/.gitconfig
```

### Check Running Processes

```bash
# Check if Ansible is running
ps aux | grep ansible

# Check background processes
ps aux | grep fnm
ps aux | grep node
```

### View Logs

```bash
# System log
log show --predicate 'processImagePath contains "ansible"' --last 1h

# Homebrew logs
cat /opt/homebrew/var/log/brew.log

# Check error messages
dmesg | tail
```

## Getting Help

### Check Documentation

1. [Overview](OVERVIEW.md) - Architecture and flow
2. [Role Documentation](roles/) - What each role does
3. [Customization Guide](CUSTOMIZATION.md) - How to modify

### Check Ansible Documentation

```bash
# Module documentation
ansible-doc homebrew
ansible-doc community.general.osx_defaults
ansible-doc git_config

# List all modules
ansible-doc -l
```

### Verify System Requirements

```bash
# Check macOS version
sw_vers

# Check architecture
uname -m

# Check available disk space
df -h

# Check available memory
vm_stat
```

### Create Support Information

When asking for help, provide:

1. **macOS version**:
```bash
sw_vers
```

2. **Error message**:
```bash
ansible-playbook playbook.yml -vv 2>&1 | tee ansible-error.log
```

3. **Homebrew status**:
```bash
brew doctor
```

4. **File versions**:
```bash
ls -la group_vars/all.yml
head -20 group_vars/all.yml
```

## Clean Start

If all else fails, clean start:

### Remove Ansible

```bash
brew uninstall ansible
rm -rf ~/.ansible
```

### Remove Homebrew (extreme)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
```

### Reset Shell Configuration

```bash
# Backup
cp ~/.zshrc ~/.zshrc.backup

# Remove Ansible sections
# Edit ~/.zshrc manually to remove blocks between:
# # BEGIN ANSIBLE MANAGED BLOCK
# # END ANSIBLE MANAGED BLOCK
```

### Then Start Fresh

```bash
cd ~/code/DevMachineSetup/mac-dev-machine
./bootstrap.sh
```

## Prevention Tips

1. **Backup first**: Time Machine backup before running
2. **Test in steps**: Run one role at a time with tags
3. **Read output**: Don't ignore warnings
4. **Keep it simple**: Start with defaults, customize gradually
5. **Version control**: Commit working configurations
6. **Document changes**: Note what you customized and why

## Still Having Issues?

1. Check [GitHub Issues](https://github.com/anthropics/claude-code/issues) (if public repo)
2. Review Ansible documentation: https://docs.ansible.com/
3. Check Homebrew documentation: https://docs.brew.sh/
4. Review macOS defaults reference: https://macos-defaults.com/

## Next Steps

- [Overview](OVERVIEW.md) - Understand the architecture
- [Customization Guide](CUSTOMIZATION.md) - Customize the setup
- [Role Documentation](roles/) - Detailed role information
