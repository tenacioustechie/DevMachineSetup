
# Setup Dev Drives
Write-Output "Setting up Dev Drives"
# Setup folders for Dev Drive Mount points
New-Item -Path "C:\" -Name "DevDrives" -ItemType "directory"

# Requires HyperV Tools
#diskpart /s ./diskpart1.txt

# Mount NugetCache Disk
$DiskName = "Test"
$DiskSize = 52000
$BasePath = "C:\DevDrives"

# FUNCTION to create and mount dev drive
# Setup Variables
$MountPath = "$BasePath\$DiskName"
$VhdPath = "$BasePath\$DiskName.vdhx"
# Create the mount point folder
New-Item -Path $BasePath -Name $DiskName -ItemType "directory"
# Create the Vhdx disk image
"CREATE VDISK FILE=`"$VhdPath`" MAXIMUM=$DiskSize TYPE=EXPANDABLE" | diskpart
# Mount the Vhdx disk image
Mount-DiskImage -ImagePath $VhdPath -NoDriveLetter
# Get the disk number of the mounted VHD
$Disk = Get-Disk | Where-Object { $_.Location -eq $VhdPath }
# Initialize the disk
Initialize-Disk -Number $Disk.Number -PartitionStyle GPT
# Create a new partition and format it
$Partition = New-Partition -DiskNumber $Disk.Number -UseMaximumSize -NoDriveLetter
# Format the partition as a dev drive
Format-Volume -Partition $Partition -DevDrive -NewFileSystemLabel $DiskName -Confirm:$false
# Mount the partion to a path
$Partition | Add-PartitionAccessPath -AccessPath $MountPath
Write-Output "Done"










# New-VHD -Path c:\DevDrives\NugetCache.vhdx -SizeBytes 50GB -Dynamic | 
# Mount-VHD -Passthru | 
Initialize-Disk -PartitionStyle GPT -FriendlyName NugetCacheDisk -Passthru | 
New-Partition -NoDriveLetter -GptType -UseMaximumSize | 
Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache -Force


Mount-DiskImage -ImagePath "C:\DevDrives\NugetCache.vhdx" -NoDriveLetter -PassThru | 
Initialize-Disk -PartitionStyle GPT -FriendlyName NugetCacheDisk -Passthru | 
New-Partition -UseMaximumSize | 
Format-Volume -DevDrive -Confirm:$false -FileSystemLabel NugetCache -Force

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