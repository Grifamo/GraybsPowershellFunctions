# Declare Variables
[string]$UserName = $env:USERNAME
[string]$ComputerName = $env:COMPUTERNAME
$myDrives = @()
$DestDir = $env:LOCALAPPDATA
$FileName = ($UserName, $ComputerName, 'MappedDrives.csv') -join '_'
$FullFileName = Join-Path -Path $DestDir -ChildPath $FileName

Get-WmiObject -Class Win32_logicaldisk -Filter "DriveType = '4'" | Select PSComputerName,Name,ProviderName,VolumeName | Export-Csv -Path $FullFileName -NoTypeInformation