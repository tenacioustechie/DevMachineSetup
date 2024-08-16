#Requires -RunAsAdministrator
# This script will create a DevDrive as a VHDX disk image and mount it to a folder and setup environment variables for npm cache and node cache

function CreateDirectory($Path, $Name) {
  New-Item -Path $Path -Name $Name -ItemType "directory" -ErrorAction SilentlyContinue
  return

  if (-not (test-path $Path ) ) {
    New-Item -Path $Path -Name $Name -ItemType "directory"
    Write-Host "$Path\$Name created"
  } else {
    Write-Host "$Path\$Name exists already"
  }
}

function CreateAndMountDevDrive($DiskName, $DiskSize, $MountBasePath, $DriveBasePath, $VariableName = $null) {
  # Setup VHDX Disk Path
  Write-Host "Checking if VHDX Disk $DiskName already exists..."
  $VhdPath = "$DriveBasePath\$DiskName-Disk.vdhx"
  if (Test-Path $VhdPath) {
    Write-Host "ERROR: $VhdPath already exists" --ForgroundColor Red
    return
  }
  # Setup Mount Path for VHDX Disk
  Write-Host "Creating Mount Folder for VHDX Disk $DiskName in $MountBasePath..."
  New-Item -Path $MountBasePath -Name $DiskName -ItemType "directory"
  $MountPath = "$MountBasePath\$DiskName"

  # Write the DiskPart script to a file
  Write-Host "Creating VHDX Disk $DiskName Size $DiskSize in $DriveBasePath..."
  $diskpartScriptPath = "$DriveBasePath\CreateVHDXdiskpartcommand.txt"
  $diskpartScriptContent = @"
CREATE VDISK FILE=`"$VhdPath`" MAXIMUM=$DiskSize TYPE=EXPANDABLE
ATTACH VDISK
convert GPT
create partition primary
format fs=ReFS quick label="$DiskName"
assign mount="$MountPath"
"@
  $diskpartScriptContent | Out-File -FilePath $diskpartScriptPath -encoding ASCII 
  
  # Execute the DiskPart script
  $diskpartOutputPath = "$BasePath\DiskPartOutput-$DiskName.txt"
  Start-Process -FilePath "diskpart.exe" -ArgumentList "/s `"$diskpartScriptPath`"" -RedirectStandardOutput $diskpartOutputPath -Wait
  $diskpartOutput = Get-Content -Path $diskpartOutputPath
  Write-Host $diskpartOutput
  Write-Host "Done creating VHDX Disk $DiskName, review above for errors"
  Write-Host ""
  
  # Removing temporary files
  Remove-Item -Path $diskpartScriptPath -Force
  
  IF ($VariableName) {
    Write-Host "Setting Variable $VariableName to $MountPath"
    Set-Variable -Name $VariableName -Value $MountPath -Scope Global
    [Environment]::SetEnvironmentVariable("$VariableName", "$MountPath", "Machine")
  }
  Write-Output "Done $DiskName"
  Write-Output ""
}

# Setup Dev Drives
Write-Output "Setting up Dev Drives"
$Drive = "C:"
if ( `get-psdrive d -ErrorAction SilentlyContinue` ) { 
  Write-Host "D Exists, using D: drive"; $Drive = "D:" 
} else { 
  Write-Host "Using C drive" 
}
Write-Host "Setting up Dev Drives on drive $Drive"

# Setup folders for Dev Drive Mount points
CreateDirectory "$Drive\" "DevDrives"

CreateAndMountDevDrive "NugetCache" 52000 "$Drive\DevDrives" "$Drive\DevDrives" "NUGET_PACKAGES"
#setx /M NUGET_PACKAGES $Drive\DevDrives\NugetCache

CreateAndMountDevDrive "NpmCache" 52000 "$Drive\DevDrives" "$Drive\DevDrives" "npm_config_cache"
#setx /M npm_config_cache $Drive\packages\NpmCache

CreateAndMountDevDrive "Code"  92000 "$Drive\" "$Drive\DevDrives"

CreateAndMountDevDrive "CodeMe"  92000 "$Drive\" "$Drive\DevDrives"

Write-Output "Done"
