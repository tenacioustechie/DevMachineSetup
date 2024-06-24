

function CreateAndMountDevDrive($DiskName, $DiskSize, $BasePath, $VariableName = $null) {
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
  # Set the variable if it was provided
  IF ($VariableName) {
    Set-Variable -Name $VariableName -Value $MountPath -Scope Global
    [Environment]::SetEnvironmentVariable("$VariableName", "$MountPath", "Machine")
  }
  Write-Output "Done"
}

# Setup Dev Drives
Write-Output "Setting up Dev Drives"

# Setup folders for Dev Drive Mount points
New-Item -Path "C:\" -Name "DevDrives" -ItemType "directory"

CreateAndMountDevDrive "NugetCache" 52000 "C:\DevDrives" "npm_config_cache"

#CreateAndMountDevDrive "NodeCache"  52000 "C:\DevDrives" "NUGET_PACKAGES"

#$DriveForCode = IF (Test-Path "D:\") {"D:"} ELSE {"C:"} 
#CreateAndMountDevDrive "codetb"  208000 "$DriveForCode"

Write-Output "Done"
