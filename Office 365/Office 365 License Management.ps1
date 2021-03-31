#Assign licenses to user accounts

<# Research Materials
The procedures in this script require you to connect to Office 365 PowerShell (Is in this script)

1. Manage user accounts and licenes (has links to all below topics): https://docs.microsoft.com/en-us/office365/enterprise/powershell/view-account-license-and-service-details-with-office-365-powershell
    a. View licenses and services
    b. View licensed and unlicensed users
    c. Assign licenses to user accounts
    d. View account license and service details
    e. Assign roles to user accounts
    f. Disable access to services
    g. View user accounts
2. Bulk assign licenses: https://joshheffner.com/bulk-assign-licenses-in-office-365-using-powershell/
3. Manage Office 365 licenses: https://4sysops.com/archives/manage-office-365-licenses-with-powershell/
    a. Has table with all AccountSKUID values for subscriptions

To create a new account that has services disabled:
    Example 1a: $LO = New-MsolLicenseOptions -AccountSkuId "litwareinc:ENTERPRISEPACK" -DisabledPlans "SHAREPOINTWAC", "SHAREPOINTENTERPRISE"
    Example 1b: New-MsolUser -UserPrincipalName allieb@litwareinc.com -DisplayName "Allie Bellew" -FirstName Allie -LastName Bellew -LicenseAssignment litwareinc:ENTERPRISEPACK -LicenseOptions $LO -UsageLocation US
#>

#Example 1: 
(Get-MSOLUser -UserPrincipalName Derik@GraybsTech.com).Licenses.ServiceStatus
#This gets all licensed services for this user.
(Get-MSOLUser -UserPrincipalName Derik@GraybsTech.com).Licenses.ServiceStatus[14]
#This shows the value of the requested index. In this case the service is Exchange_S_Standard

#Example 2:
Get-MsolAccountSku | Select -ExpandProperty ServiceStatus
#This shows ALL Service Plans and their Provisioning Status
Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq "O365_Business_Premium"}
#This shows active and consumed licenses of specified subcription
Get-MsolAccountSku | Where-Object {$_.SkuPartNumber -eq "O365_Business_Premium"} | ForEach-Object {$_.ServiceStatus}
#This command shows all Service Plans for each active licensed user

#Configure Custom License Service Plans for Disabled Options
$LicenseNoExchange = New-MsolLicenseOptions -AccountSkuId "GraybsTech:O365_BUSINESS_PREMIUM" -DisabledPlans "EXCHANGE_S_STANDARD"
Set-MsolUserLicense -UserPrincipalName Derik@GraybsTech.com -LicenseOptions $LicenseNoExchange





#Build a Report (Export CSV)
$customformat = @{expr={$_.AccountSkuID};label="AccountSkuId"},
         @{expr={$_.ActiveUnits};label="Total"},
         @{expr={$_.ConsumedUnits};label="Assigned"},
        @{expr={$_.activeunits-$_.consumedunits};label="Unassigned"},
        @{expr={$_.WarningUnits};label="Warning"}
Get-MsolAccountSku | sort activeunits -desc | select $customformat | Export-CSV "\\TSGFS1\ISHome\DLGraybeal\Scripts\CSV Exports\MSOL Users with Licenses.csv" -NoTypeInformation


#Build a Report (HTML Email) and send to specified email
$customformat = @{expr={$_.AccountSkuID};label="AccountSkuId"},
         @{expr={$_.ActiveUnits};label="Total"},
         @{expr={$_.ConsumedUnits};label="Assigned"},
        @{expr={$_.activeunits-$_.consumedunits};label="Unassigned"},
        @{expr={$_.WarningUnits};label="Warning"}
$result = Get-MsolAccountSku | sort activeunits -desc | select $customformat
$runningout=@()
$result | foreach{
    if($_.unassigned -le 5){
        $runningout+=$_
    }
}
[string]$body=$runningout | convertto-html
#[string]$body=$result | convertto-html
$cred=Get-Credential
send-mailmessage -from Derik@GraybsTech.com -To Derik@GraybsTech.com -SmtpServer smtp.office365.com -Port 587 -UseSsl -Body $body -Subject "Daily Office 365 License Report" -BodyAsHtml -Credential $cred


#Assign License with disabled plans to specific users (CSV import)
$LicenseNoExchange = New-MsolLicenseOptions -AccountSkuId "GraybsTech:O365_BUSINESS_PREMIUM" -DisabledPlans "EXCHANGE_S_STANDARD"
#Create CSV
$customformat = 
        @{expr={$_.UserPrincipalName};label="UserPrincipalName"},
        @{expr={$_.DisplayName};label="DisplayName"},
        @{expr={$_.isLicensed};label="isLicensed"}
Get-MSOLUser | Sort DisplayName -Descending | Select $customformat | Export-CSV "\\TSGFS1\ISHome\DLGraybeal\Scripts\CSV Exports\MSOL Users.csv" -NoTypeInformation #Can add a "Where-Object {$_.isLicensed -eq "False"}" or similar to trim users
#Modify CSV for users that you want this license customization to apply to.
#Once you've modified the CSV, save it and then run the following
$ModifyUsers = Import-CSV -Path "\\TSGFS1\ISHome\DLGraybeal\Scripts\CSV Exports\MSOL Users.csv"
$ModifyUsers | ForEach-Object {Set-MsolUserLicense -UserPrincipalName $_.UserPrincipalName -LicenseOptions $LicenseNoExchange}

Set-MsolUserLicense -UserPrincipalName Derik@GraybsTech.com -LicenseOptions $LicenseNoExchange