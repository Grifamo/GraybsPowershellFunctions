# Declare Variables
[string]$UserName = $env:USERNAME
[string]$ComputerName = $env:COMPUTERNAME
$myDrives = @()
$DestDir = $env:LOCALAPPDATA
$FileName = ($UserName, $ComputerName, 'MappedDrives.csv') -join '_'
$FullFileName = Join-Path -Path $DestDir -ChildPath $FileName
 
# Set Scheduled Task action
$TaskAction = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-WindowStyle Hidden -Command "& {Get-WmiObject -Class Win32_MappedLogicalDisk -ComputerName LocalHost | Export-Csv -path "$env:LOCALAPPDATA\RawDriveInfo.csv" -Force}"'
 
# Test if Scheduled Task already exists, delete it if so
if (Get-ScheduledTask -TaskName "Powershell - Enumerate Drives - $UserName" -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName "Powershell - Enumerate Drives - $UserName" -Confirm:$false
}
 
# Create Scheduled Task
Register-ScheduledTask -Action $TaskAction -TaskName "Powershell - Enumerate Drives - $UserName" -Description "Gets users' mapped drives"
 
# Run Scheduled Task immediately
Start-ScheduledTask -TaskName "Powershell - Enumerate Drives - $UserName"
 
# Clean unneeded Scheduled Task
Unregister-ScheduledTask -TaskName "Powershell - Enumerate Drives - $UserName" -Confirm:$false
 
# Import output from Scheduled Task into new variable
$WMIDriveList = Import-Csv "$DestDir\RawDriveInfo.csv"
 
# Clean unneeded output from Scheduled Task
Remove-Item -Path "$DestDir\RawDriveInfo.csv" -Force
 
# Create custom PSObjects from output
$DriveList = foreach ($Drive in $WMIDriveList)
{
[PSCustomObject]@{
    ComputerName = $ComputerName
    UserName = $UserName
    DriveLetter = $Drive.Name
    UNCPath = $Drive.ProviderName
    LastChecked = Get-Date
    }
}
 
# Export custom PSObjects to CSV to Destination
$DriveList | Export-Csv -Path $FullFileName -NoTypeInformation