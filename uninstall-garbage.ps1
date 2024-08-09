# Script inspired by this gist doing the same thing https://gist.github.com/Codebytes/29bf18015f6e93fca9421df73c6e512c

# TODO: This script must be run as admin, check we are running as admin


# TODO: Add more apps to remove next time I have a base
# Remove Apps
Write-Output "Removing Apps"

$apps = "*3DPrint*", "Microsoft.MixedReality.Portal", "MSIX\Clipchamp.Clipchamp*", "MSIX\Microsoft.BingNews*", "Microsoft.Teams.Free", "MSIX\MicrosoftCorporationII.MicrosoftFamily*", "MSIX\Microsoft.ZuneVideo*" , "MSIX\Microsoft.Xbox.TCUI*" , "MSIX\Microsoft.XboxGameOverlay*" , "MSIX\Microsoft.XboxGamingOverlay*" , "MSIX\Microsoft.XboxIdentityProvider*" , "MSIX\Microsoft.XboxSpeechToTextOverlay*" , "MSIX\Microsoft.WindowsMaps*" , "MSIX\Microsoft.OutlookForWindows*" , "MSIX\Microsoft.MicrosoftOfficeHub*" , "MSIX\Microsoft.MicrosoftStickyNotes*" , "MSIX\Microsoft.GamingApp*"
Foreach ($app in $apps)
{
  Write-host "Uninstalling:" $app
  Get-AppxPackage -allusers $app | Remove-AppxPackage
}

