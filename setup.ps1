# Script inspired by this gist doing the same thing https://gist.github.com/Codebytes/29bf18015f6e93fca9421df73c6e512c

#Install WinGet
#Based on this gist: https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
    "Installing winget Dependencies"
    Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

    $releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $releases = Invoke-RestMethod -uri $releases_url
    $latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1

    "Installing winget from $($latestRelease.browser_download_url)"
    Add-AppxPackage -Path $latestRelease.browser_download_url
}
else {
    "winget already installed"
}

# FYI: NOT SURE IF NEED THIS
#Configure WinGet
#Write-Output "Configuring winget"
#winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
# $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
# $settingsJson = 
# @"
#     {
#         // For documentation on these settings, see: https://aka.ms/winget-settings
#         "experimentalFeatures": {
#           "experimentalMSStore": true,
#         }
#     }
# "@;
# $settingsJson | Out-File $settingsPath -Encoding utf8

# Setup Dev Drives
Write-Output "Setting up Dev Drives"
New-Item -Path "C:\" -Name "DevDrives" -ItemType "directory"

New-Item -Path "C:\DevDrives" -Name "Nuget" -ItemType "directory"

New-VHD -Path c:\DevDrives\NugetCache.vhdx -SizeBytes 50GB -Dynamic | 
Mount-VHD -Passthru | 
Initialize-Disk -PartitionStyle GPT -FriendlyName NugetCacheDisk -Passthru | 
New-Partition -NoDriveLetter -Path C:\DevDrives\Nuget -UseMaximumSize | 
Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache -Force

# May need some of these options
# Mount-VHD -NoDriveLetter -Path C:\DevDrives\Nuget -Passthru

#Install New apps
Write-Output "Installing Apps"
$apps = @(
#    @{name = "Microsoft.AzureCLI" }, 
#    @{name = "Microsoft.Azure.StorageExplorer" }, 
#    @{name = "Microsoft.PowerShell" }, 
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" }, 
#    @{name = "JanDeDobbeleer.OhMyPosh" },
    @{name = "Microsoft.PowerToys" }, 
    @{name = "JoachimEibl.KDiff3"},
    @{name = "Git.Git" }, 
    @{name = "GitExtensionsTeam.GitExtensions"},
#    @{name = "GitHub.cli" },
#    @{name = "GitHub.GitHubDesktop" },
    @{name = "CoreyButler.NVMforWindows" },
#    @{name = "Docker.DockerDesktop" },
#    @{name = "Microsoft.DotNet.SDK.3_1" },
#    @{name = "Microsoft.DotNet.SDK.6"  },
#    @{name = "Microsoft.DotNet.SDK.7" },
    @{name = "Microsoft.DotNet.SDK.8" },
#    @{name = "Microsoft.DotNet.HostingBundle.3_1"},
#    @{name = "Microsoft.DotNet.HostingBundle.6"},
#    @{name = "Microsoft.DotNet.HostingBundle.7"},
    @{name = "Microsoft.DotNet.HostingBundle.8"},
#    @{name = "Microsoft.DotNet.AspNetCore.3_1"},
#    @{name = "Microsoft.DotNet.AspNetCore.6"},
#    @{name = "Microsoft.DotNet.AspNetCore.7"},
    @{name = "Microsoft.DotNet.AspNetCore.8"},
#    @{name = "Canonical.Ubuntu.2204" },
    @{name = "Python.Python.3.10" },
#    @{name = "Oracle.MySQL"},
#    @{name = "Oracle.MySQLWorkbench"},
#    @{name = "Oracle.MySQLShell"},
    @{name = "JetBrains.DataGrip"},
#    @{name = "Node.js" },
    @{name = "Visual Studio Professional 2022" }
    @{name = "Amazon.AWSVPNClient"},
    @{name = "Spotify.Spotify"}
);

Foreach ($app in $apps) {
    $listApp = winget list --exact -q $app.name --accept-source-agreements 
    if (![String]::Join("", $listApp).Contains($app.name)) {
        Write-host "Installing:" $app.name
        if ($app.source -ne $null) {
            winget install --exact --silent $app.name --source $app.source --accept-package-agreements
        }
        else {
            winget install --exact --silent $app.name --accept-package-agreements
        }
    }
    else {
        Write-host "Skipping Install of " $app.name
    }
}

# Install NVM Packages
Write-Output "Installing NVM Packages"
nvm install 20.15.0
nvm use 20.15.0
npm install -g @angular/cli



# TODO: Add more apps to remove next time I have a base 
# Remove Apps
Write-Output "Removing Apps"

$apps = "*3DPrint*", "Microsoft.MixedReality.Portal"
Foreach ($app in $apps)
{
  Write-host "Uninstalling:" $app
  Get-AppxPackage -allusers $app | Remove-AppxPackage
}

#Setup WSL
wsl --install