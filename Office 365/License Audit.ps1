<#
License Audit Report

1. Gather all users within definied OU's
    -IT
    -Acct
    -Exec
    -Ops
    -Xenium
    -Healthcare
    -SWG
    -SFE
    -CHW
2. Connect to Office 365
3. Identify all non-licensed users
4. 
5.
6.
7.


#>

Connect-MsolService

<#Create Audit Function
Function Audit-O365 {
    Param ( [string]$Organization )
}
#>

#This will end up as a function above
#Variables

#SFE Users
#$OUPath = 'OU=SV_Users,OU=StollerVineyards,DC=nwhq,DC=thestollergroup,DC=com'
#CHW Users
#$OUPath = 'OU=Chehalem_Users,OU=Chehalem,DC=nwhq,DC=thestollergroup,DC=com'
#SWG Users
#$OUPath = ''
#XEN Users
#$OUPath = 'OU=Xenium,OU=Tualatin_Users,OU=Tualatin,DC=nwhq,DC=thestollergroup,DC=com'
#IT Users
#$OUPath = 'OU=IT,OU=Tualatin_Users,OU=Tualatin,DC=nwhq,DC=thestollergroup,DC=com'
#$OUFilter = "*@TheStollerGroup.com"
#ACCT Users
#$OUPath = 'OU=Accounting,OU=Tualatin_Users,OU=Tualatin,DC=nwhq,DC=thestollergroup,DC=com'
#ExpressHC Users
#$OUPath = 'OU=Express Healthcare,OU=Tualatin_Users,OU=Tualatin,DC=nwhq,DC=thestollergroup,DC=com'
#OPS Users
#$OUPath = 'OU=Operations,OU=Tualatin_Users,OU=Tualatin,DC=nwhq,DC=thestollergroup,DC=com'
#EXEC Users
#$OUPath = 'OU=Executives,OU=Tualatin_Users,OU=Tualatin,DC=nwhq,DC=thestollergroup,DC=com'

#$ExportPath = 'c:\data\users_in_ou1.csv'
#Create list with UPN's for all users within specified OU(s)
$customformat = 
        @{expr={$_.UserPrincipalName};label="UserPrincipalName"},
        @{expr={$_.DisplayName};label="DisplayName"},
        @{expr={$_.isLicensed};label="isLicensed"}
Get-ADUser -Filter 'UserPrincipalName -like "*@TheStollerGroup.com"' -SearchBase "OU=IT,OU=Tualatin_Users,OU=Tualatin,DC=nwhq,DC=thestollergroup,DC=com" | ForEach-Object {Get-MsolUser -UserPrincipalName $_.UserPrincipalName | Format-List UserPrincipalName,Licenses}
Get-MSolUser -DomainName "XeniumHR.com" | Where-Object {$_.UserPrincipalName -like "*@XeniumHR.com"}