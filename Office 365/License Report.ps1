<#
.SYNOPSIS
    Name: Licenses_Report.ps1
    Get licenses report from Office 365.
  
.DESCRIPTION
    The script checks everyday the licenses that are available on Office 365.
    It will provide you with a report of Active, Consumed, LockedOut, Suspended,
    Warning and Available Licenses. It also checks if any user is assigned with
    duplicate licenses that may affect each other (Exchange Plan 1, Exchange
    Plan 2, Enterprise E3). The script checks also if there is any user that has
    no license and provide the UserPrincipalName of the user/s. It will send an
    email report including this information only if there is any user with
    duplicate or no license.
  

.RELATED LINKS
    Home

.NOTES
    Version:      1.1

    Update:       25-04-2018              - Added new Licenses statuses
                                          - Updated Report
                                          - Code Optimisation
    
    Release Date: 24-05-2017
   
    Author:       Stephanos Constantinou

.EXAMPLE
    Licenses_Report.ps1
#>

$Credentials = Get-AutomationPSCredential -Name 'Admin User'
$EmailCredentials = Get-AutomationPSCredential -Name 'Email User'	
$To = 'Derik.Graybeal@TheStollerGroup.com'

$From = 'Derik.Graybeal@TheStollerGroup.com'

Get-PSSession | Remove-PSSession
	
Import-Module MSOnline
	
Connect-MsolService -Credential $Credentials
	
$SessionParams = @{
    ConfigurationName = "Microsoft.Exchange"
    ConnectionUri = "https://outlook.office365.com/powershell-liveid/"
    Credential = $Credentials
    Authentication = "Basic"
    AllowRedirection = $true}


$Session = New-PSSession @SessionParams
	
Import-PSSession -Session $Session -DisableNameChecking:$true -AllowClobber:$true | Out-Null

$AllUsers = Get-MsolUser -All

$AllUserMailboxes = (Get-Mailbox -ResultSize Unlimited |
    where {$_.RecipientTypeDetails -eq "UserMailbox"}).UserPrincipalName

$AllNoLicenseUsers = ($AllUsers |
    where {$_.isLicensed -eq $false}).UserPrincipalName

$NoLicenseMailboxes = $AllUserMailboxes |
    where {$AllNoLicenseUsers -contains $_}

$AllLicenses = Get-MsolAccountSku |
    select AccountSkuId,ActiveUnits,ConsumedUnits,LockedOutUnits,SuspendedUnits,WarningUnits

$P1 = "company:EXCHANGESTANDARD" #Exchange Online (Plan 1)
$P2 = "company:EXCHANGEENTERPRISE" #Exchange Online (Plan 2)
$E3 = "company:ENTERPRISEPACK" #Office365 Enterprise E3
$VisioP2 = "company:VISIOCLIENT" #Visio Online Plan 2
$BIFree = "company:POWER_BI_STANDARD" #Power BI (free)
$BIPro = "company:POWER_BI_PRO" #Power BI Pro
$BIPremium = "company:PBI_PREMIUM_EM1_ADDON"
$ATP = "company:ATP_ENTERPRISE" #Office 365 Advance Tread Protection
$CRMInstance = "company:CRMINSTANCE"
$ProjectEssentials = "company:PROJECTESSENTIALS" #Project Online Essentials
$ProjectProfessional = "company:PROJECTPROFESSIONAL" #Project Online Professional
$ProjectPremium = "company:PROJECTPREMIUM" #Project Online Premium
$Dyn365EnterpriseP1 = "company:DYN365_ENTERPRISE_PLAN1" #Dynamics 365 Customer Engagement Plan Enterprise Edition
$Dyn365EnterpriseTeam = "company:DYN365_ENTERPRISE_TEAM_MEMBERS" #Dynamics 365 for Team Members Enterprise Edition
$EMS = "company:EMS" #Enterprise Mobility + Security E3
$AADPremium = "company:AAD_PREMIUM" #Azure Active Directory Premium P1
$PowerApps = "company:POWERAPPS_VIRAL" #Microsoft PowerApp Plan 2 Trial
$Stream = "company:STREAM" #Microsoft Stream Trial
$Flow = "company:FLOW_FREE" #Microsoft Flow Free

$DuplicateLicenseUsers = ($AllUsers |
    where {($_.isLicensed -eq "TRUE") -and
          ((($_.Licenses.AccountSKUID -eq $E3) -and
          ($_.Licenses.AccountSKUID -eq $P2)) -or
          (($_.Licenses.AccountSKUID -eq $E3) -and
          ($_.Licenses.AccountSKUID -eq $P1)) -or
          (($_.Licenses.AccountSKUID -eq $P2) -and
          ($_.Licenses.AccountSKUID -eq $P1)))}).UserPrincipalName

$TotalP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P1}).ActiveUnits
$UsedP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P1}).ConsumedUnits
$LockedP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P1}).LockedOutUnits
$SuspendedP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P1}).SuspendedUnits
$WarningP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P1}).WarningUnits
$AvailableP1 = $TotalP1 - $UsedP1
               - $LockedP1 - $SuspendedP1
               - $WarningP1
	
$TotalP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P2}).ActiveUnits
$UsedP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P2}).ConsumedUnits
$LockedP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P2}).LockedOutUnits
$SuspendedP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P2}).SuspendedUnits
$WarningP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $P2}).WarningUnits
$AvailableP2 = $TotalP2 - $UsedP2 - $LockedP2
               - $SuspendedP2 - $WarningP2

$TotalE3 = ($AllLicenses |
    where {$_.AccountSkuId -eq $E3}).ActiveUnits
$UsedE3 = ($AllLicenses |
    where {$_.AccountSkuId -eq $E3}).ConsumedUnits
$LockedE3 = ($AllLicenses |
    where {$_.AccountSkuId -eq $E3}).LockedOutUnits
$SuspendedE3 = ($AllLicenses |
    where {$_.AccountSkuId -eq $E3}).SuspendedUnits
$WarningE3 = ($AllLicenses |
    where {$_.AccountSkuId -eq $E3}).WarningUnits
$AvailableE3 = $TotalE3 - $UsedE3 - $LockedE3
               - $SuspendedE3 - $WarningE3

$TotalVisioP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $VisioP2}).ActiveUnits
$UsedVisioP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $VisioP2}).ConsumedUnits
$LockedVisioP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $VisioP2}).LockedOutUnits
$SuspendedVisioP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $VisioP2}).SuspendedUnits
$WarningVisioP2 = ($AllLicenses |
    where {$_.AccountSkuId -eq $VisioP2}).WarningUnits
$AvailableVisioP2 = $TotalVisioP2 - $UsedVisioP2
                    - $LockedVisioP2 - $SuspendedVisioP2
                    - $WarningVisioP2

$TotalBIFree = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIFree}).ActiveUnits
$UsedBIFree = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIFree}).ConsumedUnits
$LockedBIFree = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIFree}).LockedOutUnits
$SuspendedBIFree = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIFree}).SuspendedUnits
$WarningBIFree = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIFree}).WarningUnits
$AvailableBIFree = $TotalBIFree - $UsedBIFree
                   - $LockedBIFree - $SuspendedBIFree
                   - $WarningBIFree

$TotalBIPro = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPro}).ActiveUnits
$UsedBIPro = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPro}).ConsumedUnits
$LockedBIPro = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPro}).LockedOutUnits
$SuspendedBIPro = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPro}).SuspendedUnits
$WarningBIPro = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPro}).WarningUnits
$AvailableBIPro = $TotalBIPro - $UsedBIPro - $LockedBIPro
                  - $SuspendedBIPro - $WarningBIPro

$TotalBIPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPremium}).ActiveUnits
$UsedBIPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPremium}).ConsumedUnits
$LockedBIPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPremium}).LockedOutUnits
$SuspendedBIPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPremium}).SuspendedUnits
$WarningBIPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $BIPremium}).WarningUnits
$AvailableBIPremium = $TotalBIPremium - $UsedBIPremium
                      - $LockedBIPremium - $SuspendedBIPremium
                      - $WarningBIPremium

$TotalATP = ($AllLicenses |
    where {$_.AccountSkuId -eq $ATP}).ActiveUnits
$UsedATP = ($AllLicenses |
    where {$_.AccountSkuId -eq $ATP}).ConsumedUnits
$LockedATP = ($AllLicenses |
    where {$_.AccountSkuId -eq $ATP}).LockedOutUnits
$SuspendedATP = ($AllLicenses |
    where {$_.AccountSkuId -eq $ATP}).SuspendedUnits
$WarningATP = ($AllLicenses |
    where {$_.AccountSkuId -eq $ATP}).WarningUnits
$AvailableATP = $TotalATP - $UsedATP - $LockedATP
                - $SuspendedATP - $WarningATP

$TotalCRMInstance = ($AllLicenses |
    where {$_.AccountSkuId -eq $CRMInstance}).ActiveUnits
$UsedCRMInstance = ($AllLicenses |
    where {$_.AccountSkuId -eq $CRMInstance}).ConsumedUnits
$LockedCRMInstance = ($AllLicenses |
    where {$_.AccountSkuId -eq $CRMInstance}).LockedOutUnits
$SuspendedCRMInstance = ($AllLicenses |
    where {$_.AccountSkuId -eq $CRMInstance}).SuspendedUnits
$WarningCRMInstance = ($AllLicenses |
    where {$_.AccountSkuId -eq $CRMInstance}).WarningUnits
$AvailableCRMInstance = $TotalCRMInstance - $UsedCRMInstance
                        - $LockedCRMInstance - $SuspendedCRMInstance
                        - $WarningCRMInstance

$TotalProjectEssentials = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectEssentials}).ActiveUnits
$UsedProjectEssentials = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectEssentials}).ConsumedUnits
$LockedProjectEssentials = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectEssentials}).LockedOutUnits
$SuspendProjectEssentials = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectEssentials}).SuspendedUnits
$WarningProjectEssentials = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectEssentials}).WarningUnits
$AvailableProjectEssentials = $TotalProjectEssentials
                              - $UsedProjectEssentials
                              - $LockedProjectEssentials
                              - $SuspendProjectEssentials
                              - $WarningProjectEssentials

$TotalProjectProfessional = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectProfessional}).ActiveUnits
$UsedProjectProfessional = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectProfessional}).ConsumedUnits
$LockedProjectProfessional = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectProfessional}).LockedOutUnits
$SuspendedProjectProfessional = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectProfessional}).SuspendedUnits
$WarningProjectProfessional = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectProfessional}).WarningUnits
$AvailableProjectProfessional = $TotalProjectProfessional
                                - $UsedProjectProfessional
                                - $LockedProjectProfessional
                                - $SuspendedProjectProfessional
                                - $WarningProjectProfessional

$TotalProjectPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectPremium}).ActiveUnits
$UsedProjectPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectPremium}).ConsumedUnits
$LockedProjectPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectPremium}).LockedOutUnits
$SuspendedProjectPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectPremium}).SuspendedUnits
$WarningProjectPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $ProjectPremium}).WarningUnits
$AvailableProjectPremium = $TotalProjectPremium
                           - $UsedProjectPremium
                           - $LockedProjectPremium
                           - $SuspendedProjectPremium
                           - $WarningProjectPremium

$TotalDyn365EnterpriseP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseP1}).ActiveUnits
$UsedDyn365EnterpriseP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseP1}).ConsumedUnits
$LockedDyn365EnterpriseP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseP1}).LockedOutUnits
$SuspendedDyn365EnterpriseP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseP1}).SuspendedUnits
$WarningDyn365EnterpriseP1 = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseP1}).WarningUnits
$AvailableDyn365EnterpriseP1 = $TotalDyn365EnterpriseP1
                               - $UsedDyn365EnterpriseP1
                               - $LockedDyn365EnterpriseP1
                               - $SuspendedDyn365EnterpriseP1
                               - $WarningDyn365EnterpriseP1

$TotalDyn365EnterpriseTeam = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseTeam}).ActiveUnits
$UsedDyn365EnterpriseTeam = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseTeam}).ConsumedUnits
$LockedDyn365EnterpriseTeam = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseTeam}).LockedOutUnits
$SuspendedDyn365EnterpriseTeam = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseTeam}).SuspendedUnits
$WarningDyn365EnterpriseTeam = ($AllLicenses |
    where {$_.AccountSkuId -eq $Dyn365EnterpriseTeam}).WarningUnits
$AvailableDyn365EnterpriseTeam = $TotalDyn365EnterpriseTeam
                                 - $UsedDyn365EnterpriseTeam
                                 - $LockedDyn365EnterpriseTeam
                                 - $SuspendedDyn365EnterpriseTeam
                                 - $WarningDyn365EnterpriseTeam

$TotalEMS = ($AllLicenses |
    where {$_.AccountSkuId -eq $EMS}).ActiveUnits
$UsedEMS = ($AllLicenses |
    where {$_.AccountSkuId -eq $EMS}).ConsumedUnits
$LockedEMS = ($AllLicenses |
    where {$_.AccountSkuId -eq $EMS}).LockedOutUnits
$SuspendedEMS = ($AllLicenses |
    where {$_.AccountSkuId -eq $EMS}).SuspendedUnits
$WarningEMS = ($AllLicenses |
    where {$_.AccountSkuId -eq $EMS}).WarningUnits
$AvailableEMS = $TotalEMS - $UsedEMS - $LockedEMS
                - $SuspendedEMS - $WarningEMS

$TotalAADPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $AADPremium}).ActiveUnits
$UsedAADPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $AADPremium}).ConsumedUnits
$LockedAADPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $AADPremium}).LockedOutUnits
$SuspendedAADPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $AADPremium}).SuspendedUnits
$WarningAADPremium = ($AllLicenses |
    where {$_.AccountSkuId -eq $AADPremium}).WarningUnits
$AvailableAADPremium = $TotalAADPremium - $UsedAADPremium
                       - $LockedAADPremium
                       - $SuspendedAADPremium
                       - $WarningAADPremium

$TotalPowerApps = ($AllLicenses |
    where {$_.AccountSkuId -eq $PowerApps}).ActiveUnits
$UsedPowerApps = ($AllLicenses |
    where {$_.AccountSkuId -eq $PowerApps}).ConsumedUnits
$LockedPowerApps = ($AllLicenses |
    where {$_.AccountSkuId -eq $PowerApps}).LockedOutUnits
$SuspendedPowerApps = ($AllLicenses |
    where {$_.AccountSkuId -eq $PowerApps}).SuspendedUnits
$WarningPowerApps = ($AllLicenses |
    where {$_.AccountSkuId -eq $PowerApps}).WarningUnits
$AvailablePowerApps = $TotalPowerApps - $UsedPowerApps - $LockedPowerApps
                      - $SuspendedPowerApps - $WarningPowerApps

$TotalStream = ($AllLicenses |
    where {$_.AccountSkuId -eq $Stream}).ActiveUnits
$UsedStream = ($AllLicenses |
    where {$_.AccountSkuId -eq $Stream}).ConsumedUnits
$LockedStream = ($AllLicenses |
    where {$_.AccountSkuId -eq $Stream}).LockedOutUnits
$SuspendedStream = ($AllLicenses |
    where {$_.AccountSkuId -eq $Stream}).SuspendedUnits
$WarningStream = ($AllLicenses |
    where {$_.AccountSkuId -eq $Stream}).WarningUnits
$AvailableStream = $TotalStream - $UsedStream
                   - $LockedStream - $SuspendedStream
                   - $WarningStream

$TotalFlow = ($AllLicenses |
    where {$_.AccountSkuId -eq $Flow}).ActiveUnits
$UsedFlow = ($AllLicenses |
    where {$_.AccountSkuId -eq $Flow}).ConsumedUnits
$LockedFlow = ($AllLicenses |
    where {$_.AccountSkuId -eq $Flow}).LockedOutUnits
$SuspendedFlow = ($AllLicenses |
    where {$_.AccountSkuId -eq $Flow}).SuspendedUnits
$WarningFlow = ($AllLicenses |
    where {$_.AccountSkuId -eq $Flow}).WarningUnits
$AvailableFlow = $TotalFlow - $UsedFlow - $LockedFlow
                 - $SuspendedFlow - $WarningFlow

$Email = @"
<img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" data-wp-preserve="%3Cstyle%3E%0D%0A%0D%0Abody%20%7B%20font-family%3ASegoe%2C%20%22Segoe%20UI%22%2C%20%22DejaVu%20Sans%22%2C%20%22Trebuchet%20MS%22%2C%20Verdana%2C%20sans-serif%20!important%3B%20color%3A%23434242%3B%7D%0D%0ATABLE%20%7B%20font-family%3ASegoe%2C%20%22Segoe%20UI%22%2C%20%22DejaVu%20Sans%22%2C%20%22Trebuchet%20MS%22%2C%20Verdana%2C%20sans-serif%20!important%3B%20border-width%3A%201px%3Bborder-style%3A%20solid%3Bborder-color%3A%20black%3Bborder-collapse%3A%20collapse%3B%7D%0D%0ATR%20%7Bborder-width%3A%201px%3Bpadding%3A%2010px%3Bborder-style%3A%20solid%3Bborder-color%3A%20white%3B%20%7D%0D%0ATD%20%7Bfont-family%3ASegoe%2C%20%22Segoe%20UI%22%2C%20%22DejaVu%20Sans%22%2C%20%22Trebuchet%20MS%22%2C%20Verdana%2C%20sans-serif%20!important%3B%20border-width%3A%201px%3Bpadding%3A%2010px%3Bborder-style%3A%20solid%3Bborder-color%3A%20white%3B%20background-color%3A%23C3DDDB%3B%7D%0D%0A.colorm%20%7Bbackground-color%3A%2358A09E%3B%20color%3Awhite%3B%7D%0D%0A.colort%7Bbackground-color%3A%2358A09E%3B%20padding%3A20px%3B%20color%3Awhite%3B%20font-weight%3Abold%3B%7D%0D%0A.colorn%7Bbackground-color%3Atransparent%3B%7D%0D%0A%3C%2Fstyle%3E" data-mce-resize="false" data-mce-placeholder="1" class="mce-object" width="20" height="20" alt="<style>" title="<style>" />
<body>

<h3>Licensing report</h3>


<h4>Licenses Issues:</h4>
<table>
    <tr>
    	<td class="colorm">Mailboxes with duplicate license:</td>
        <td >$DuplicateLicenseUsers</td>
    </tr>
    <tr>
	    <td class="colorm">Mailboxes with no license:</td>
	    <td>$NoLicenseMailboxes</td>
    </tr>
</table>

<h4>Totals of licenses we have:</h4>
<table>
	<tr>
    	<td class="colorn"></td>
    	<td class="colort">We have:</td>
        <td class="colort">Used:</td>
        <td class="colort">LockedOut:</td>
        <td class="colort">Suspended:</td>
        <td class="colort">Warning:</td>
        <td class="colort">Available:</td>
    </tr>
	<tr>
        <td class="colorm">Exchange Online (Plan1):</td>
        <td style="text-align:center">$TotalP1</td>
        <td style="text-align:center">$UsedP1</td>
        <td style="text-align:center">$LockedP1</td>
        <td style="text-align:center">$SuspendedP1</td>
        <td style="text-align:center">$WarningP1</td>
        <td style="text-align:center">$AvailableP1</td>
	</tr>
	<tr>
		<td class="colorm">Exchange Online (Plan2):</td>
        <td style="text-align:center">$TotalP2</td>
        <td style="text-align:center">$UsedP2</td>
        <td style="text-align:center">$LockedP2</td>
        <td style="text-align:center">$SuspendedP2</td>
        <td style="text-align:center">$WarningP2</td>
        <td style="text-align:center">$AvailableP2</td>
	</tr>
    <tr>
    	<td class="colorm">Office365 Enterprise E3:</td>
        <td style="text-align:center">$TotalE3</td>
        <td style="text-align:center">$UsedE3</td>
        <td style="text-align:center">$LockedE3</td>
        <td style="text-align:center">$SuspendedE3</td>
        <td style="text-align:center">$WarningE3</td>
        <td style="text-align:center">$AvailableE3</td>
    </tr>
    <tr>
    	<td class="colorm">Visio Online Plan 2:</td>
        <td style="text-align:center">$TotalVisioP2</td>
        <td style="text-align:center">$UsedVisioP2</td>
        <td style="text-align:center">$LockedVisioP2</td>
        <td style="text-align:center">$SuspendedVisioP2</td>
        <td style="text-align:center">$WarningVisioP2</td>
        <td style="text-align:center">$AvailableVisioP2</td>
    </tr>
    <tr>
    	<td class="colorm">Power BI (free):</td>
        <td style="text-align:center">$TotalBIFree</td>
        <td style="text-align:center">$UsedBIFree</td>
        <td style="text-align:center">$LockedBIFree</td>
        <td style="text-align:center">$SuspendedBIFree</td>
        <td style="text-align:center">$WarningBIFree</td>
        <td style="text-align:center">$AvailableBIFree</td>
    </tr>
    <tr>
    	<td class="colorm">Power BI Pro:</td>
        <td style="text-align:center">$TotalBIPro</td>
        <td style="text-align:center">$UsedBIPro</td>
        <td style="text-align:center">$LockedBIPro</td>
        <td style="text-align:center">$SuspendedBIPro</td>
        <td style="text-align:center">$WarningBIPro</td>
        <td style="text-align:center">$AvailableBIPro</td>
    </tr>
    <tr>
    	<td class="colorm">Power BI Premium EM1:</td>
        <td style="text-align:center">$TotalBIPremium</td>
        <td style="text-align:center">$UsedBIPremium</td>
        <td style="text-align:center">$LockedBIPremium</td>
        <td style="text-align:center">$SuspendedBIPremium</td>
        <td style="text-align:center">$WarningBIPremium</td>
        <td style="text-align:center">$AvailableBIPremium</td>
    </tr>
    <tr>
    	<td class="colorm">Office 365 Advance Tread Protection:</td>
        <td style="text-align:center">$TotalATP</td>
        <td style="text-align:center">$UsedATP</td>
        <td style="text-align:center">$LockedATP</td>
        <td style="text-align:center">$SuspendedATP</td>
        <td style="text-align:center">$WarningATP</td>
        <td style="text-align:center">$AvailableATP</td>
    </tr>
    <tr>
    	<td class="colorm">Microsoft Dynamics CRM Online Instance:</td>
        <td style="text-align:center">$TotalCRMInstance</td>
        <td style="text-align:center">$UsedCRMInstance</td>
        <td style="text-align:center">$LockedCRMInstance</td>
        <td style="text-align:center">$SuspendedCRMInstance</td>
        <td style="text-align:center">$WarningCRMInstance</td>
        <td style="text-align:center">$AvailableCRMInstance</td>
    </tr>
    <tr>
    	<td class="colorm">Project Online Essentials:</td>
        <td style="text-align:center">$TotalProjectEssentials</td>
        <td style="text-align:center">$UsedProjectEssentials</td>
        <td style="text-align:center">$LockedProjectEssentials</td>
        <td style="text-align:center">$SuspendedProjectEssentials</td>
        <td style="text-align:center">$WarningProjectEssentials</td>
        <td style="text-align:center">$AvailableProjectEssentials</td>
    </tr>
    <tr>
    	<td class="colorm">Project Online Professional:</td>
        <td style="text-align:center">$TotalProjectProfessional</td>
        <td style="text-align:center">$UsedProjectProfessional</td>
        <td style="text-align:center">$LockedProjectProfessional</td>
        <td style="text-align:center">$SuspendedProjectProfessional</td>
        <td style="text-align:center">$WarningProjectProfessional</td>
        <td style="text-align:center">$AvailableProjectProfessional</td>
    </tr>
    <tr>
    	<td class="colorm">Project Online Premium:</td>
        <td style="text-align:center">$TotalProjectPremium</td>
        <td style="text-align:center">$UsedProjectPremium</td>
        <td style="text-align:center">$LockedProjectPremium</td>
        <td style="text-align:center">$SuspendedProjectPremium</td>
        <td style="text-align:center">$WarningProjectPremium</td>
        <td style="text-align:center">$AvailableProjectPremium</td>
    </tr>
    <tr>
    	<td class="colorm">Dynamics 365 Customer Engagement Plan Enterprise Edition:</td>
        <td style="text-align:center">$TotalDyn365EnterpriseP1</td>
        <td style="text-align:center">$UsedDyn365EnterpriseP1</td>
        <td style="text-align:center">$LockedDyn365EnterpriseP1</td>
        <td style="text-align:center">$SuspendedDyn365EnterpriseP1</td>
        <td style="text-align:center">$WarningDyn365EnterpriseP1</td>
        <td style="text-align:center">$AvailableDyn365EnterpriseP1</td>
    </tr>
    <tr>
    	<td class="colorm">Dynamics 365 for Team Members Enterprise Edition:</td>
        <td style="text-align:center">$TotalDyn365EnterpriseTeam</td>
        <td style="text-align:center">$UsedDyn365EnterpriseTeam</td>
        <td style="text-align:center">$LockedDyn365EnterpriseTeam</td>
        <td style="text-align:center">$SuspendedDyn365EnterpriseTeam</td>
        <td style="text-align:center">$WarningDyn365EnterpriseTeam</td>
        <td style="text-align:center">$AvailableDyn365EnterpriseTeam</td>
    </tr>
    <tr>
    	<td class="colorm">Enterprise Mobility + Security E3:</td>
        <td style="text-align:center">$TotalEMS</td>
        <td style="text-align:center">$UsedEMS</td>
        <td style="text-align:center">$LockedEMS</td>
        <td style="text-align:center">$SuspendedEMS</td>
        <td style="text-align:center">$WarningEMS</td>
        <td style="text-align:center">$AvailableEMS</td>
    </tr>
    <tr>
    	<td class="colorm">Azure Active Directory Premium P1:</td>
        <td style="text-align:center">$TotalAADPremium</td>
        <td style="text-align:center">$UsedAADPremium</td>
        <td style="text-align:center">$LockedAADPremium</td>
        <td style="text-align:center">$SuspendedAADPremium</td>
        <td style="text-align:center">$WarningAADPremium</td>
        <td style="text-align:center">$AvailableAADPremium</td>
    </tr>
    <tr>
    	<td class="colorm">Microsoft PowerApp Plan 2 Trial:</td>
        <td style="text-align:center">$TotalPowerApps</td>
        <td style="text-align:center">$UsedPowerApps</td>
        <td style="text-align:center">$LockedPowerApps</td>
        <td style="text-align:center">$SuspendedPowerApps</td>
        <td style="text-align:center">$WarningPowerApps</td>
        <td style="text-align:center">$AvailablePowerApps</td>
    </tr>
    <tr>
    	<td class="colorm">Microsoft Stream Trial:</td>
        <td style="text-align:center">$TotalStream</td>
        <td style="text-align:center">$UsedStream</td>
        <td style="text-align:center">$LockedStream</td>
        <td style="text-align:center">$SuspendedStream</td>
        <td style="text-align:center">$WarningStream</td>
        <td style="text-align:center">$AvailableStream</td>
    </tr>
    <tr>
    	<td class="colorm">Microsoft Flow Free:</td>
        <td style="text-align:center">$TotalFlow</td>
        <td style="text-align:center">$UsedFlow</td>
        <td style="text-align:center">$LockedFlow</td>
        <td style="text-align:center">$SuspendedFlow</td>
        <td style="text-align:center">$WarningFlow</td>
        <td style="text-align:center">$AvailableFlow</td>
    </tr>
    
</table>

</body>

"@

if (($NoLicenseMailboxes -ne $null) -or
   ($DuplicateLicenseUsers -ne $null)){
    $EmailParams = @{
        To = $To
        Subject = "Licensing Report $(Get-Date -format dd/MM/yyyy)"
        Body = $Email
        BodyAsHtml = $True
        Priority = "High"
        UseSsl = $True
        Port = "587"
        SmtpServer = "smtp.office365.com"
        Credential = $EmailCredentials
        From = $From}

	send-mailmessage @EmailParams}

if ($error -ne $null){
    foreach ($value in $error){
        $ErrorEmailTemp = @"
<tr>
    <td class="colorm">$value</td>
</tr>
"@

        $ErrorEmailResult = $ErrorEmailResult + "`r`n" + $ErrorEmailTemp}

    $ErrorEmailUp = @"
<img src="data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7" data-wp-preserve="%3Cstyle%3E%0D%0Abody%20%7Bfont-family%3ASegoe%2C%20%22Segoe%20UI%22%2C%20%22DejaVu%20Sans%22%2C%20%22Trebuchet%20MS%22%2C%20Verdana%2C%20sans-serif%20!important%3B%20color%3A%23434242%3B%7D%0D%0ATABLE%20%7Bfont-family%3ASegoe%2C%20%22Segoe%20UI%22%2C%20%22DejaVu%20Sans%22%2C%20%22Trebuchet%20MS%22%2C%20Verdana%2C%20sans-serif%20!important%3B%20border-width%3A%201px%3Bborder-style%3A%20solid%3Bborder-color%3A%20black%3Bborder-collapse%3A%20collapse%3B%7D%0D%0ATR%20%7Bborder-width%3A%201px%3Bpadding%3A%2010px%3Bborder-style%3A%20solid%3Bborder-color%3A%20white%3B%20%7D%0D%0ATD%20%7Bfont-family%3ASegoe%2C%20%22Segoe%20UI%22%2C%20%22DejaVu%20Sans%22%2C%20%22Trebuchet%20MS%22%2C%20Verdana%2C%20sans-serif%20!important%3B%20border-width%3A%201px%3Bpadding%3A%2010px%3Bborder-style%3A%20solid%3Bborder-color%3A%20white%3B%20background-color%3A%23C3DDDB%3B%7D%0D%0A.colorm%20%7Bbackground-color%3A%2358A09E%3B%20color%3Awhite%3B%7D%0D%0Ah3%20%7Bcolor%3A%23BD3337%20!important%3B%7D%0D%0A%3C%2Fstyle%3E" data-mce-resize="false" data-mce-placeholder="1" class="mce-object" width="20" height="20" alt="<style>" title="<style>" />

<body>
<h3 style="color:#BD3337 !important;"> WARNING!!!</h3>

<p>There were errors during users attributes changes check</p>

<p>Please check the errors and act accordingly</p>

<table>

"@

    $ErrorEmailDown = @"
</table>
</body>
"@

    $ErrorEmail = $ErrorEmailUp + $ErrorEmailResult + $ErrorEmailDown

    $ErrorEmailParams = @{
        To = $To
        Subject = "Licensing Report $(Get-Date -format dd/MM/yyyy) - WARNING"
        Body = $Email
        BodyAsHtml = $True
        Priority = "High"
        UseSsl = $True
        Port = "587"
        SmtpServer = "smtp.office365.com"
        Credential = $EmailCredentials
        From = $From}
		
    send-mailmessage @ErrorEmailParams}