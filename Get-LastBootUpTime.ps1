function Get-LastBootUpTime {
Param(
[Parameter(Position = 1)]
[string]$Computer = $env:COMPUTERNAME
)
Get-CimInstance -ComputerName $Computer -ClassName Win32_OperatingSystem | Select-Object LastBootUpTime
}