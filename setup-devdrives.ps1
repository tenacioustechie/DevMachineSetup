
# Setup Dev Drives
Write-Output "Setting up Dev Drives"
New-Item -Path "C:\" -Name "DevDrives" -ItemType "directory"

New-Item -Path "C:\DevDrives" -Name "Nuget" -ItemType "directory"

# Requires HyperV Tools
# New-VHD -Path c:\DevDrives\NugetCache.vhdx -SizeBytes 50GB -Dynamic | 
# Mount-VHD -Passthru | 
Initialize-Disk -PartitionStyle GPT -FriendlyName NugetCacheDisk -Passthru | 
New-Partition -NoDriveLetter -GptType -UseMaximumSize | 
Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache -Force


diskpart /s ./diskpart1.txt


Mount-DiskImage -ImagePath "C:\DevDrives\NugetCache.vhdx" -NoDriveLetter -PassThru | Initialize-Disk -PartitionStyle GPT -FriendlyName NugetCacheDisk -Passthru | New-Partition -UseMaximumSize | Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache -Force
Mount-DiskImage -ImagePath "C:\DevDrives\NugetCache.vhdx" -NoDriveLetter -PassThru | Initialize-Disk -PartitionStyle GPT -FriendlyName NugetCacheDisk -Passthru | New-Partition -UseMaximumSize | Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache -Force

-DiskPath "C:\DevDrives\NugetCache.vhdx" -Path C:\DevDrives\Nuget

# New-VirtualDisk doesn't let you specify file path
# New-VirtualDisk -ProvisioningType Thin -Size 50GB 
Mount-DiskImage -ImagePath "C:\DevDrives\NugetCache.vhdx" -NoDriveLetter -PassThru | 
  Initialize-Disk -PartitionStyle GPT -FriendlyName NugetCacheDisk -Passthru | 
  New-Partition -UseMaximumSize | 
  Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache -Force

Mount-DiskImage -ImagePath "C:\DevDrives\NugetCache.vhdx"
New-Partition -NoDriveLetter -Path C:\DevDrives\Nuget -UseMaximumSize
Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache

Format-Volume -DriveLetter F -DevDrive

Format-Volume -DriveLetter F -DevDrive

Format-Volume -DriveLetter F -DevDrive

diskpart /s ./diskpart2.txt