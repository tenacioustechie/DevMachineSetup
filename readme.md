# Development Machine Setup

Automated setup scripts for Windows and macOS development environments.

## What's Included

- **Windows Setup** (root directory) - PowerShell scripts using winget for Windows 11
- **macOS Setup** ([`mac-dev-machine/`](mac-dev-machine/)) - Shell scripts for automated Mac development environment
- **Ansible Setup** ([`ansible-dev-setup/`](ansible-dev-setup/)) - Archived Ansible-based Mac setup (reference only)

## Quick Start

### Windows Setup

This script sets up Windows development machines using winget. Initially used in Windows 11.

### macOS Setup

Automated macOS development environment setup using shell scripts.

```bash
cd mac-dev-machine
cp config.example.sh config.sh
# Edit config.sh with your personal settings
./setup.sh
```

See [`mac-dev-machine/readme.md`](mac-dev-machine/readme.md) for full documentation.

---

## Windows Setup - Detailed Instructions

### To Do

- script dev drive creation for node_modules global cache + set global environment variable for it
- script dev drive creation for nuget package cache + set global environment variable for it
- script dev drive creation for c:\code directory mount point

### Machine Setup

Run these scripts on a new machine in powershell. Note: use a user powershell prompt, unless the script explicitly requires it (the scripts detect if they need admin and will imediatly error if not run with elevated admin permissions).

Make sure scripts are executable with this command

```bash
set-executionPolicy -Scope CurrentUser RemoteSigned
```

## Remove Unnecessary software

```bash
.\uninstall-rubbish.ps1
```

## Install Software

You can customise what is installed by commenting in and out the packages in the package list of this script. Review the list before you execute so that you are familiar with what is being installed. https://learn.microsoft.com/en-us/windows/dev-drive/

```bash
.\install-packages.ps1
```

## Setup Dev Drives

NOTE: manual setup recomended at this point in time, scripted version doesn't work full.

Dev drives are a new Microsoft Windows feature that can improve build times and performance when coding. This is mostly focused at your code directory, npm cache directory, and nuget package cache directory as they contain thousands of files.

Use the 'About this PC' in control panel to work out what edition of Windows 11 you are running.

- If you are running 'Windows 11 Pro' then you need to manually setup DevDrives listed below
- If you are running 'Windows 11 Pro for Workstations' or 'Windows 11 Enterprise' you should be able to use the script below to setup dev drives.

```bash
cd dev-drive-setup
.\setup-devdrives.ps1
```

If you are manually setting up dev drives using 'Disks & Volumes' Settings app, then you should create these directorys on D: drive or C: drive. (I use a separate D: drive if possible or on desktop so that the OS is left alone. I'm unsure if it actually helps performance or not).

- Nuget Cache directory -> mounted in D:\DevDrives\NugetCache
- Npm Cache directory -> mounted in D:\DevDrives\NpmCache
- Code directory -> mounted in D:\Code

Each directory needs a dev drive setup and mounted. Then you can run these statements to ensure Nuget and Npm cache directories are used by those tools.

```bash
# make sure paths are correct for what you have setup
# Run these in an 'admin' terminal powershell window
setx /M NUGET_PACKAGES D:\DevDrives\NugetCache
setx /M npm_config_cache D:\packages\NpmCache
```

# Requirements and References

- You need to be using Windows 10 (1807 or higher) or windows 11.
- You need 'App Installer' installed (usually included in base windows install I think, or available on microsoft store)
- Winget https://learn.microsoft.com/en-us/windows/package-manager/
- Enable running of scripts for your current user
  `set-executionPolicy -Scope CurrentUser RemoteSigned`

Winget CLI should be available on the system.

## Winget Commands

Winget has several useful commands

```ps1
winget search [app-name]

winget install [app-id]

winget info
```

## Winget Install

Several useful options when installing from a script.

```ps1
winget install --silent [app-name]

```

- --silent installs hiding any gui or popup confirmations, useful when scripting several installations at once.

## Other Setup steps

Setup Win Dev Drive and mount in c:\code directory for code to go into before cloning code
https://learn.microsoft.com/en-us/windows/dev-drive/

# A Note on HyperV

You need to have the HyperV powershell module installed to use powershell modules to create VHDX files for dev drives in powershell. And windows 11 doesn't allow you to install just the powershell modules of HyperV. Thus the scripts in this repository explicitly use diskpart to do this setup as the powershell tools for hyperV are often not installed or required or aloud by many organisations.

```ps1
# Install only the PowerShell module
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell

# Install the Hyper-V management tool pack (Hyper-V Manager and the Hyper-V PowerShell module)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All

# Install the entire Hyper-V stack (hypervisor, services, and tools)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```
