$hash_lastLogonTimestamp = @{Name="LastLogonTimeStamp";Expression={([datetime]::FromFileTime($_.LastLogonTimeStamp))}}
$SearchBases = 'OU=SBSUsers,OU=Users,OU=MyBusiness,DC=cwinternal,DC=local','CN=Users,DC=cwinternal,DC=local'
$SearchBases | ForEach {$ADUsers = @(Get-ADUser -Filter * -SearchBase $_  -Properties *)}
$ADUsers = @(Get-ADUser -Filter * -SearchBase $SearchBases  -Properties * )
#$ADUsers = @($Searchbases | ForEach {Get-ADUser -Filter * -SearchBase $SearchBases  -Properties * })
ForEach($SearchBase in $SearchBases)
{
    Get-ADUser -Filter * -SearchBase $_  -Properties *
}


[string]$body=$ADUsers | Select CN, SAMAccountName, $hash_lastLogonTimestamp, Enabled, DistinguishedName | Sort lastLogonTimestamp | convertto-html
$cred=Get-Credential
send-mailmessage -from Derik@Graybs.com -To Derik.Graybeal@TheStollerGroup.com -SmtpServer smtp.office365.com -Port 587 -UseSsl -Body $body -Subject "Chehalem User Report" -BodyAsHtml -Credential $cred

