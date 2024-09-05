# NOTE: this command lists IIS features that could be installed
# Get-WindowsOptionalFeature -Online | Where-Object FeatureName -like 'IIS-*' | Format-Table -AutoSize
Write-Host "Installing IIS"
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ASPNET45 -ALL
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementScriptingTools
Write-Host "Done"