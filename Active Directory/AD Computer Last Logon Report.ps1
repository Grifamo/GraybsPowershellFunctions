$hash_lastLogonTimestamp = @{Name="LastLogonTimeStamp";Expression={([datetime]::FromFileTime($_.LastLogonTimeStamp))}}

$Computers = @(Get-ADComputer -Properties Name,operatingSystem,lastLogontimeStamp -Filter {(OperatingSystem -like "*Windows*")})

foreach($Computer in $Computers)
{
    $Computer.OperatingSystem = $Computer.OperatingSystem -replace '®' -replace '™' -replace '专业版','Professional (Ch)' -replace 'Professionnel','Professional (Fr)'
}

[string]$body=$Computers | Select Name, OperatingSystem, $hash_lastLogonTimestamp, Enabled | Sort lastLogonTimestamp | convertto-html
$cred=Get-Credential
send-mailmessage -from Derik@Graybs.com -To Derik.Graybeal@TheStollerGroup.com -SmtpServer smtp.office365.com -Port 587 -UseSsl -Body $body -Subject "Chehalem Computer LastLogon Report" -BodyAsHtml -Credential $cred

#$Computers | Select Name, OperatingSystem, $hash_lastLogonTimestamp | Sort Name