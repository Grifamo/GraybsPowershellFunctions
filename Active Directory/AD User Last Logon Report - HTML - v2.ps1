$hash_lastLogonTimestamp = @{Name="LastLogonTimeStamp";Expression={([datetime]::FromFileTime($_.LastLogonTimeStamp))}}
$ADUsers = @(Get-ADUser -Filter * -SearchBase "OU=SBSUsers,OU=Users,OU=MyBusiness,DC=cwinternal,DC=local"  -Properties * | ForEach {})
$ADUsers2 = @(Get-ADUser -Filter * -SearchBase "CN=Users,DC=cwinternal,DC=local"  -Properties *)

[string]$body=$ADUsers | Select CN, SAMAccountName, $hash_lastLogonTimestamp, Enabled, DistinguishedName | Sort LastLogonTimeStamp | convertto-html
[string]$body2=$ADUsers2 | Select CN, SAMAccountName, $hash_lastLogonTimestamp, Enabled, DistinguishedName | Sort LastLogonTimeStamp | convertto-html
$cred=Get-Credential
send-mailmessage -from Derik@Graybs.com -To Derik.Graybeal@TheStollerGroup.com -SmtpServer smtp.office365.com -Port 587 -UseSsl -Body $body -Subject "Chehalem User Report; SBSUsers" -BodyAsHtml -Credential $cred
send-mailmessage -from Derik@Graybs.com -To Derik.Graybeal@TheStollerGroup.com -SmtpServer smtp.office365.com -Port 587 -UseSsl -Body $body2 -Subject "Chehalem User Report; Default User Container" -BodyAsHtml -Credential $cred

