$customformat = 
        @{expr={$_.UserPrincipalName};label="UserPrincipalName"},
        @{expr={$_.DisplayName};label="DisplayName"},
        @{expr={$_.Licenses.AccountSkuId};label="Licensed"}
$result = Get-MSOLUser | Where-Object {($_).isLicensed -eq "True"} | Sort DisplayName -Descending | Select $customformat
$runningout=@()
$result | foreach{
    if($_.unassigned -le 5){
        $runningout+=$_
    }
}
[string]$body=$runningout | convertto-html
#[string]$body=$result | convertto-html
$cred=Get-Credential
send-mailmessage -from Derik@Graybs.com -To Mike.Goff@TheStollerGroup.com,Derik.Graybeal@TheStollerGroup.com -SmtpServer smtp.office365.com -Port 587 -UseSsl -Body $body -Subject "Chehalem Office 365 License Report" -BodyAsHtml -Credential $cred
