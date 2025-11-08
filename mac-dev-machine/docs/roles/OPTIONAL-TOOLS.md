# Optional Tools Role Documentation

## Purpose

The Optional Tools role installs Xcode and iOS development tools. This role is **conditional** - it only runs if you answer "yes" when prompted during bootstrap, or if you set `install_xcode: true` in configuration.

## What Gets Installed

### Xcode
- Complete Xcode IDE from Mac App Store
- Xcode Command Line Tools (additional components)
- iOS SDKs and compilers
- Interface Builder
- Instruments (profiling tools)
- Asset catalogs and other resources

### iOS Development Tools
- **CocoaPods**: Dependency manager for iOS projects
- **fastlane**: Automation tool for deployments
- **iOS Simulators**: Virtual devices for testing

## Prerequisites

### Required
- **Mac App Store account**: Must be signed in
- **Apple ID**: Required for App Store downloads
- **Disk space**: ~15-20 GB free space
- **Time**: 30-60 minutes for Xcode download

### Checking Prerequisites

**Verify App Store login**:
```bash
mas account
```

**Expected output**: Your Apple ID email

**If not signed in**: Open App Store app and sign in manually

## Task-by-Task Breakdown

### 1. Check if Xcode Already Installed

**Command**:
```bash
ls /Applications/Xcode.app
```

**Purpose**: Skip installation if Xcode already present

---

### 2. Install mas (Mac App Store CLI)

**What it does**: Installs command-line tool for App Store

**Command**:
```bash
brew install mas
```

**Why needed**: Allows scripted installation of App Store apps

---

### 3. Verify App Store Login

**Command**:
```bash
mas account
```

**Checks**:
- Signed into Mac App Store
- Can download apps

**If not signed in**:
- Script displays message
- Must sign in manually to App Store app
- Re-run script after signing in

---

### 4. Install Xcode from Mac App Store

**Command**:
```bash
mas install 497799835
```

**App ID**: 497799835 is Xcode's unique App Store identifier

**What happens**:
1. Downloads Xcode from App Store (~12-15 GB)
2. Installs to `/Applications/Xcode.app`
3. May take 30-60 minutes depending on connection speed

**Ansible Task**:
```yaml
- name: Install Xcode via mas
  command: mas install 497799835
  when:
    - not xcode_check.stat.exists
    - mas_account.rc == 0
  register: xcode_install
  changed_when: "'Installed' in xcode_install.stdout"
  async: 3600  # 1 hour timeout
  poll: 30     # Check every 30 seconds
```

**Timeout**: 1 hour (3600 seconds)

**Progress**: Checked every 30 seconds

---

### 5. Accept Xcode License

**Command**:
```bash
sudo xcodebuild -license accept
```

**Purpose**: Accept Xcode and iOS SDK license agreement

**Why needed**: Required before using Xcode command-line tools

**Permissions**: Requires sudo (admin password)

---

### 6. Install Additional Xcode Components

**Command**:
```bash
xcode-select --install
```

**What it installs**:
- Additional command-line tools
- Git (Xcode version)
- clang compiler
- make and other build tools

**Note**: May report already installed if Command Line Tools were installed during bootstrap

---

### 7. Set Active Developer Directory

**Command**:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

**Purpose**: Sets Xcode as the active developer toolset

**Why needed**: Ensures command-line tools use Xcode's versions

**Verify**:
```bash
xcode-select -p
# Output: /Applications/Xcode.app/Contents/Developer
```

---

### 8. Run Xcode First Launch

**Command**:
```bash
sudo xcodebuild -runFirstLaunch
```

**What it does**:
- Installs additional required components
- Sets up Xcode environment
- Prepares simulators
- May take 5-10 minutes

**Timeout**: 10 minutes (600 seconds)

---

### 9. Install CocoaPods

**Command**:
```bash
sudo gem install cocoapods
```

**What is CocoaPods**: Dependency manager for iOS/macOS projects (like npm for iOS)

**Usage**:
```bash
# In iOS project directory
pod init                    # Create Podfile
# Edit Podfile to add dependencies
pod install                 # Install dependencies
```

**Example Podfile**:
```ruby
platform :ios, '15.0'

target 'MyApp' do
  use_frameworks!

  pod 'Alamofire', '~> 5.6'      # Networking
  pod 'SDWebImage', '~> 5.15'    # Image loading
end
```

---

### 10. Setup CocoaPods

**Command**:
```bash
pod setup
```

**What it does**:
- Downloads CocoaPods specifications repository
- Sets up local pod cache
- May take 5-10 minutes

---

### 11. Install fastlane

**Command**:
```bash
brew install fastlane
```

**What is fastlane**: Automation tool for iOS deployments

**Common uses**:
- Automated beta deployments to TestFlight
- App Store submission automation
- Screenshot generation
- Code signing management

**Usage**:
```bash
# In iOS project directory
fastlane init              # Setup fastlane

# Common lanes
fastlane beta              # Deploy to TestFlight
fastlane release           # Deploy to App Store
fastlane screenshots       # Generate screenshots
```

---

### 12. List Available Simulators

**Command**:
```bash
xcrun simctl list devices available
```

**Output example**:
```
== Devices ==
-- iOS 17.0 --
    iPhone 15 (UUID)
    iPhone 15 Plus (UUID)
    iPhone 15 Pro (UUID)
    iPhone 15 Pro Max (UUID)
    iPad Pro 12.9-inch (UUID)
```

---

### 13. Create iOS Simulator Devices

**What it does**: Creates specific simulator devices for testing

**Default devices** (from `group_vars/all.yml`):
- iPhone 15
- iPhone 15 Pro
- iPad Pro 12.9-inch

**Command**:
```bash
xcrun simctl create "iPhone 15" "iPhone 15"
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro"
xcrun simctl create "iPad Pro 12.9-inch" "iPad Pro 12.9-inch"
```

**Customization**: Edit in `group_vars/all.yml`:
```yaml
ios_simulator_devices:
  - "iPhone 15"
  - "iPhone 15 Pro Max"
  - "iPhone SE (3rd generation)"
  - "iPad mini (6th generation)"
```

---

## Using Xcode After Installation

### Opening Xcode

**Command line**:
```bash
open /Applications/Xcode.app
```

**Or**: Click Xcode in Applications folder

**First launch**: May install additional components (5-10 minutes)

### Verifying Installation

```bash
# Check Xcode version
xcodebuild -version

# Check installed SDKs
xcodebuild -showsdks

# List simulators
xcrun simctl list devices

# Check Xcode path
xcode-select -p
```

**Expected output**:
```
Xcode 15.0
Build version 15A240d

iOS SDKs:
    iOS 17.0                      -sdk iphoneos17.0

iOS Simulator SDKs:
    Simulator - iOS 17.0          -sdk iphonesimulator17.0
```

### Using Simulators

**Launch specific simulator**:
```bash
xcrun simctl boot "iPhone 15"
open -a Simulator
```

**List running simulators**:
```bash
xcrun simctl list devices | grep Booted
```

**Install app in simulator**:
```bash
xcrun simctl install "iPhone 15" /path/to/MyApp.app
```

**Launch app in simulator**:
```bash
xcrun simctl launch "iPhone 15" com.example.MyApp
```

**Shutdown simulator**:
```bash
xcrun simctl shutdown "iPhone 15"
```

**Erase simulator** (reset to factory):
```bash
xcrun simctl erase "iPhone 15"
```

### Building iOS Projects

**Command line build**:
```bash
# Build for simulator
xcodebuild -scheme MyApp -sdk iphonesimulator

# Build for device
xcodebuild -scheme MyApp -sdk iphoneos

# Run tests
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 15'

# Archive for distribution
xcodebuild archive -scheme MyApp -archivePath ~/Desktop/MyApp.xcarchive
```

**Using Xcode IDE**:
1. Open project: `open MyProject.xcodeproj`
2. Select simulator from device dropdown
3. Click Run (Cmd+R) to build and run

### CocoaPods Workflow

**Setup new project**:
```bash
cd MyiOSProject
pod init
code Podfile  # Edit to add dependencies
pod install   # Install dependencies
```

**After pod install**: Open `.xcworkspace` file, not `.xcodeproj`:
```bash
open MyProject.xcworkspace
```

**Update dependencies**:
```bash
pod update
```

### fastlane Workflow

**Initialize**:
```bash
cd MyiOSProject
fastlane init
```

**Create lane** (edit `fastlane/Fastfile`):
```ruby
lane :beta do
  increment_build_number
  build_app(scheme: "MyApp")
  upload_to_testflight
end
```

**Run lane**:
```bash
fastlane beta
```

## Configuration

### Enabling/Disabling Xcode Installation

**Method 1**: Answer prompt during bootstrap

**Method 2**: Edit `group_vars/all.yml`:
```yaml
install_xcode: true  # or false
```

**Method 3**: Command-line override:
```bash
ansible-playbook playbook.yml --extra-vars "install_xcode=true"
```

### Customizing Simulator Devices

Edit `group_vars/all.yml`:

```yaml
ios_simulator_devices:
  - "iPhone 15"
  - "iPhone 15 Pro"
  - "iPhone 15 Pro Max"
  - "iPhone SE (3rd generation)"
  - "iPad Pro 12.9-inch (6th generation)"
  - "iPad mini (6th generation)"
```

**Find available device types**:
```bash
xcrun simctl list devicetypes
```

## File Locations

### Xcode
```
/Applications/Xcode.app                    # Main application
~/Library/Developer/Xcode/                 # User data
  ├── DerivedData/                         # Build outputs
  ├── Archives/                            # App archives
  └── UserData/                            # User settings
```

### Simulators
```
~/Library/Developer/CoreSimulator/Devices/ # Simulator data
```

### CocoaPods
```
~/.cocoapods/                              # CocoaPods cache
<project>/Pods/                            # Project dependencies
<project>/Podfile                          # Dependency list
<project>/Podfile.lock                     # Locked versions
```

### fastlane
```
<project>/fastlane/
  ├── Fastfile                             # Automation lanes
  ├── Appfile                              # App configuration
  └── Matchfile                            # Code signing config
```

## Common Issues

### Issue: Xcode download fails

**Cause**: Network interruption or App Store issues

**Solution**:
1. Check internet connection
2. Check App Store status: https://www.apple.com/support/systemstatus/
3. Try manual install from App Store app
4. Re-run playbook after manual install

---

### Issue: Not signed into App Store

**Symptom**:
```
Error: Not signed into App Store
```

**Solution**:
1. Open App Store app
2. Click "Sign In" (bottom left)
3. Sign in with Apple ID
4. Re-run playbook

---

### Issue: Xcode license not accepted

**Symptom**:
```
Agreeing to the Xcode/iOS license requires admin privileges, please run "sudo xcodebuild -license" and then retry this command.
```

**Solution**:
```bash
sudo xcodebuild -license accept
```

---

### Issue: Command Line Tools not found

**Symptom**:
```
xcode-select: error: tool 'xcodebuild' requires Xcode
```

**Solution**:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

---

### Issue: CocoaPods installation fails

**Symptom**:
```
ERROR:  While executing gem ... (Gem::FilePermissionError)
```

**Solution**: Use sudo:
```bash
sudo gem install cocoapods
```

---

### Issue: Simulator won't boot

**Symptom**:
```
Unable to boot device in current state: Booted
```

**Solution**:
```bash
# Shutdown all simulators
xcrun simctl shutdown all

# Erase and reset
xcrun simctl erase all

# Restart Simulator app
killall Simulator
open -a Simulator
```

## Performance Notes

### Installation Time
- **Xcode download**: 30-60 minutes (12-15 GB)
- **Xcode first launch**: 5-10 minutes
- **CocoaPods setup**: 5-10 minutes
- **Total**: 45-90 minutes

### Disk Space
- **Xcode**: 12-15 GB
- **Simulators**: 5-10 GB (increases with device count)
- **CocoaPods cache**: 1-2 GB (grows over time)
- **DerivedData**: Varies by projects (can grow large)

**Cleaning up**:
```bash
# Remove Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Remove old simulators
xcrun simctl delete unavailable

# Clean CocoaPods cache
pod cache clean --all
```

## Useful Commands

```bash
# Xcode
xcodebuild -version              # Version info
xcodebuild -showsdks             # Available SDKs
xcode-select -p                  # Active Xcode path
xcode-select --install           # Install CLI tools

# Simulators
xcrun simctl list                # List all simulators
xcrun simctl boot "iPhone 15"    # Boot simulator
xcrun simctl shutdown all        # Shutdown all
xcrun simctl erase "iPhone 15"   # Reset simulator
xcrun simctl delete "iPhone 15"  # Delete simulator

# CocoaPods
pod --version                    # Version
pod init                         # Create Podfile
pod install                      # Install dependencies
pod update                       # Update dependencies
pod search <name>                # Search for pod
pod cache clean --all            # Clean cache

# fastlane
fastlane --version               # Version
fastlane init                    # Initialize
fastlane lanes                   # List available lanes
fastlane <lane_name>             # Run lane
```

## Tags

Run only optional tools tasks:
```bash
ansible-playbook playbook.yml --tags "optional"
```

Run with Xcode installation:
```bash
ansible-playbook playbook.yml --extra-vars "install_xcode=true" --tags "optional"
```

Available tags:
- `optional`: All optional tools
- `xcode`: Xcode installation and setup
- `ios`: iOS development tools
- `simulators`: Simulator configuration

## Next Steps

After optional tools are installed, your Mac development environment is complete!

See:
- [Customization Guide](../CUSTOMIZATION.md) - Customize the setup
- [Troubleshooting Guide](../TROUBLESHOOTING.md) - Common issues
