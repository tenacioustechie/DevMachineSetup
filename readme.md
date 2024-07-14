# Overview

This script sets up my windows development machine using winget. It was initially used in Windows 11.

# To do

- script dev drive creation for node_modules global cache + set global environment variable for it
- script dev drive creation for nuget package cache + set global environment variable for it
- script dev drive creation for c:\code directory mount point

# Quick Start

Run this on a new machine in powershell, if you use an admin prompt, it wont prompt you for each application install.

```bash
set-executionPolicy -Scope CurrentUser RemoteSigned
.\setup.ps1
```

TODO: add dev drive steps here

# Full Documentation

## Requirements

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

You need to have the HyperV powershell module installed to use powershell modules to create VHDX files for dev drives. And windows 11 doesn't allow you to install just the powershell modules of HyperV. Thus now this script uses diskpart to do this part of the script.

```ps1
# Install only the PowerShell module
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell

# Install the Hyper-V management tool pack (Hyper-V Manager and the Hyper-V PowerShell module)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Tools-All

# Install the entire Hyper-V stack (hypervisor, services, and tools)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
```
