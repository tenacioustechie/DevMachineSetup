# NOTE: do NOT run this as admin, it works better asking for admin on each install


# Setup WSL and set default version to 2
Write-Host "Installing and setting up Windows subsystem for Linux (WSL)..."
Write-Host "It will ask for a password, please enter a password for the WSL user, and remember it..."
Write-Host "Please exit the WSL distribution by running 'exit' once WSL is installed..."
Read-Host -Prompt "Press Enter to continue"
wsl --set-default-version 2
wsl --update
wsl --install -d Ubuntu

#Install New apps
Write-Output "Installing Apps"
$apps = @(
    @{name = "Ubuntu" },
    @{name = "Microsoft.PowerShell" }, 
    @{name = "Microsoft.WindowsTerminal"; source = "msstore" }, 
    @{name = "JanDeDobbeleer.OhMyPosh" },
    @{name = "Microsoft.PowerToys" }, 
    @{name = "CoreyButler.NVMforWindows" },
#    @{name = "Node.js" },
    @{name = "Docker.DockerDesktop" },
#    @{name = "Microsoft.DotNet.SDK.3_1" },
#    @{name = "Microsoft.DotNet.HostingBundle.3_1"},
#    @{name = "Microsoft.DotNet.AspNetCore.3_1"},
    @{name = "Microsoft.DotNet.SDK.6"  },
    @{name = "Microsoft.DotNet.HostingBundle.6"},
    @{name = "Microsoft.DotNet.AspNetCore.6"},
#    @{name = "Microsoft.DotNet.SDK.7" },
#    @{name = "Microsoft.DotNet.HostingBundle.7"},
#    @{name = "Microsoft.DotNet.AspNetCore.7"},
    @{name = "Microsoft.DotNet.SDK.8" },
    @{name = "Microsoft.DotNet.HostingBundle.8"},
    @{name = "Microsoft.DotNet.AspNetCore.8"},
    @{name = "Microsoft.VisualStudioCode" }, 
    @{name = "Visual Studio Professional 2022" },
    @{name = "JoachimEibl.KDiff3"},
    @{name = "Git.Git" }, 
    @{name = "GitExtensionsTeam.GitExtensions"},
    @{name = "GitHub.cli" },
    @{name = "GitHub.GitHubDesktop" },
    @{name = "Python.Python.3.10" },
    @{name = "Oracle.MySQL"},
    @{name = "Oracle.MySQLWorkbench"},
    @{name = "Oracle.MySQLShell"},
#    @{name = "JetBrains.DataGrip"},
#    @{name = "Spotify.Spotify"}
#    @{name = "Microsoft.AzureCLI" }, 
#    @{name = "Microsoft.Azure.StorageExplorer" }, 
    @{name = "Amazon.AWSVPNClient"},
    @{name = "Amazon.AWSCLI" }
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
#Write-Output "Installing NVM Packages"
#nvm install 20.15.0
#nvm use 20.15.0
#npm install -g @angular/cli

Write-Host "Done"
