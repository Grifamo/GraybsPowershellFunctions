#This is how you can connect to Office 365 with PowerShell
#https://docs.microsoft.com/en-us/office365/enterprise/powershell/connect-to-all-office-365-services-in-a-single-windows-powershell-window

#Install required software
Install-Module MSOnline
    #If prompted to install the NuGet provider, type Y and press ENTER
    #If prompted to install the module from PSGallery, type Y and press ENTER

#Office 365 Exchange Powershell
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking
Remove-PSSession $Session

#Connect to Azure AD
$UserCredential = Get-Credential
Connect-MsolService -Credential $UserCredential
    #In the Windows PowerShell Credential Request dialog box, type your Office 365 work or school account user name and password, and then click OK
    #If you don't receive any errors, you connected successfully

New-MoveRequest -Identity Derik.Graybeal@thestollergroup.com -RemoteCredential (Get-Credential) -Remote -RemoteHostName 'owa.thestollergroup.com' -BatchName DerikMove -PrimaryOnly -TargetDeliveryDomain TheStollerGroup.mail.onmicrosoft.com