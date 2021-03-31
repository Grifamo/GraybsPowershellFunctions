$7ZipInstalled = get-WmiObject -Class Win32_Product -namespace "root\cimv2" | Where-object{$_.Vendor -eq "Igor Pavlov"}

if($7ZipInstalled -ne $null -and $7ZipInstalled.Version -lt "18.05.00.0")
{
    (Start-Process -FilePath "msiexec.exe" -ArgumentList "/X {23170F69-40C1-2702-1805-000001000000} /QN" -Wait -Passthru).ExitCode
}