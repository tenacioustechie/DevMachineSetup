<#
.SYNOPSIS
  Two-phase Dev-box bootstrap:  
   • Phase 1 (Admin): remove Appx bloat, winget installs, WSL install, credential provider  
   • Phase 2 (User): WSL first-run, Git config & auth, clone repos  

.NOTES
  • Must be run on Windows 11 Pro with PowerShell 7+ (or PS 5.1).  
  • You only invoke it once—no manual re-launch needed.  
#>

param(
  [switch]$Elevated,
  [switch]$UserPhase
)

# --------------------------
# If neither flag is present, re-launch elevated for Phase 1
# --------------------------
if (-not ($Elevated -or $UserPhase)) {
    Write-Host "▶ Launching Phase 1 (Admin) with elevation..."
    Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated"
    exit
}

# --------------------------
# Phase 1: Admin tasks
# --------------------------
if ($Elevated) {

    # 1) Remove unwanted Appx
    $patterns = @(
      "*3DPrint*","Microsoft.MixedReality.Portal","MSIX\Clipchamp.Clipchamp*",
      "MSIX\Microsoft.BingNews*","Microsoft.Teams.Free","MSIX\MicrosoftCorporationII.MicrosoftFamily*",
      "MSIX\Microsoft.ZuneVideo*","MSIX\Microsoft.Xbox.TCUI*","MSIX\Microsoft.XboxGameOverlay*",
      "MSIX\Microsoft.XboxGamingOverlay*","MSIX\Microsoft.XboxIdentityProvider*",
      "MSIX\Microsoft.XboxSpeechToTextOverlay*","MSIX\Microsoft.WindowsMaps*",
      "MSIX\Microsoft.OutlookForWindows*","MSIX\Microsoft.MicrosoftOfficeHub*",
      "MSIX\Microsoft.MicrosoftStickyNotes*","MSIX\Microsoft.GamingApp*"
    )
    foreach ($p in $patterns) {
      Get-AppxProvisionedPackage -Online |
        Where-Object DisplayName -Like $p |
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
      Get-AppxPackage -AllUsers -Name $p |
        Remove-AppxPackage         -ErrorAction SilentlyContinue
    }

    # 2) Windows Terminal
    winget install --id Microsoft.WindowsTerminal -e --source winget
    New-ItemProperty -Path "HKCU:\Console" -Name "DelegationConsole" -PropertyType DWord -Value 1 -Force

    # 3) WSL install (distro install only—no interactive first-run)
    wsl --install -d Ubuntu
    wsl --set-default-version 2

    # 4) NVM & Node
    winget install --id CoreyButler.NVMforWindows -e --source winget
    $env:Path += ";$env:ProgramFiles\nodejs\nvm"
    nvm install 20.0.0
    nvm use     20.0.0

    # 5) Bulk winget
    $ids = @(
      "JanDeDobbeleer.OhMyPosh","Microsoft.PowerToys","Docker.DockerDesktop",
      "Microsoft.DotNet.SDK.3.1","Microsoft.DotNet.HostingBundle.3.1","Microsoft.DotNet.AspNetCore.3.1",
      "Microsoft.DotNet.SDK.8","Microsoft.DotNet.HostingBundle.8","Microsoft.DotNet.AspNetCore.8",
      "Microsoft.VisualStudioCode","Microsoft.VisualStudio.2022.Professional","JoachimEibl.KDiff3",
      "SublimeHQ.SublimeText.4","Git.Git","GitExtensionsTeam.GitExtensions",
      "GitHub.cli","GitHub.GitHubDesktop","Python.Python.3.10",
      "Oracle.MySQL","Oracle.MySQLWorkbench","Oracle.MySQLShell",
      "Amazon.AWSVPNClient","Amazon.AWSCLI","Postman.Postman",
      "Google.Chrome","Mozilla.Firefox","AgileBits.1Password",
      "Notion.Notion","LINQPad.LINQPad.8"
    )
    foreach ($i in $ids) {
      winget install --id $i -e --source winget
    }

    # 6) NuGet Artifacts CredProvider
    iex "& { $(irm https://aka.ms/install-artifacts-credprovider.ps1) } -AddNetfx"

    # --------------------------
    # Now spawn Phase 2 under the user context
    # --------------------------
    Write-Host "`n✅ Phase 1 complete. Launching Phase 2 (User) in a non-elevated window..."
    $shell = New-Object -ComObject "Shell.Application"
    $args  = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -UserPhase"
    $shell.ShellExecute("pwsh.exe", $args, "", "open", 1)

    exit
}

# --------------------------
# Phase 2: User-level tasks
# --------------------------
if ($UserPhase) {

    # 3b) WSL first-run (allows you to set your Linux username/password)
    Write-Host "▶ Launching Ubuntu for first-run configuration..."
    wsl -d Ubuntu

    # 7) Git config
    git config --global pull.rebase true
    git config --global core.autocrlf input
    git config --global core.eol lf
    git config --global init.defaultBranch main
    git config --global core.editor "code --wait"
    git config --global merge.tool kdiff3
    git config --global diff.tool  kdiff3

    Write-Host "`n⚙️  Enter your Git user info:"
    $Name  = Read-Host  "  Full name"
    $Email = Read-Host  "  Work email"
    git config --global user.name  "$Name"
    git config --global user.email "$Email"
    git config --global --add safe.directory "*"

    # 8) GitHub CLI auth & repos
    gh auth login

    $repos = @(
      "TB.Compose","Trybooking-Db","TB.UI","Trybooking-CommonApi","TryBooking-Checkout",
      "TryBooking-Donation","Trybooking-Login","Trybooking-AdminApi","TryBooking-Legacy",
      "TryBooking-ReportingApi","TB.BookingAppApi","TB.Events","TB.Bookings",
      "Trybooking-AppResources","Trybooking-Messaging","TB.Communications"
    )
    $codeDir = "C:\Code"
    if (-not (Test-Path $codeDir)) { New-Item -ItemType Directory -Path $codeDir | Out-Null }
    Set-Location $codeDir

    foreach ($r in $repos) {
      git clone "https://github.com/TryBookingDev/$r.git"
    }

    Write-Host "`n🎉 All done! Enjoy your new dev environment."
    exit
}
