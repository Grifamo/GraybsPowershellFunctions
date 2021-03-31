<#  
  .NOTES
  ===========================================================================
   Created on:     06/29/2018
   Created by:     Derik Graybeal
   Organization:   The Stoller Group
   Version:        1.2 07/02/2018
  ===========================================================================
  .DESCRIPTION
    This script uses Microsoft Teams to notify when a OSD task sequence has completed successfully. 
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Pass', 'Fail')]
    [string]$PassFail = 'Pass'
)
$uri = 'https://outlook.office.com/webhook/352bb0b5-8cc4-4851-9544-bfc7ae16b48e@7409b1d2-6bd4-4c51-8e4d-e68ae7284050/IncomingWebhook/df0a5587528d4d4c951c127edd0fb6e1/039ab960-97dc-428e-a25f-9e2b7f877270'
# Date and Time
$DateTime = Get-Date -Format g #Time
# Time
$Time = get-date -format HH:mm
# Computer Make
$Make = (Get-WmiObject -Class Win32_BIOS).Manufacturer
# Computer Model
$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model
# Computer Name
$Name = (Get-WmiObject -Class Win32_ComputerSystem).Name
# Computer Serial Number
[string]$SerialNumber = (Get-WmiObject win32_bios).SerialNumber
# IP Address of the Computer
$IPAddress = (Get-WmiObject win32_Networkadapterconfiguration | Where-Object{ $_.ipaddress -notlike $null }).IPaddress | Select-Object -First 1
# Uses TS Env doesnt give much on x64 arch
$TSenv = New-Object -COMObject Microsoft.SMS.TSEnvironment -ErrorAction SilentlyContinue
$TSName = $TSenv.Value("_SMSTSPackageName")
#$TSUSer = TS Primary User
#$TSlogPath = $TSenv.Value("_SMSTSLogPath")
# Use the Start and End TaskSequence Varaibles to Determine the Duration
$Timespan = New-TimeSpan -Start ($TSenv.Value('StartTime')) -End ($TSenv.Value('EndTime'))
$Hours = $Timespan.Hours
$Minutes = $Timespan.Minutes
$Seconds = $Timespan.Seconds
$Duration = "$(if ($Hours -ne $null){"$Hours Hours"}) $(if ($Minutes -ne $null){"$Minutes Minutes"}) $(if ($Seconds -ne $null){"$Seconds Seconds"})"
# these values would be retrieved from or set by an application
if ($PassFail -eq 'Pass') {
    $color = 'good'
    $status = 'Successful'
    $icon = ':heavy_check_mark:'
    $thumb = 'https://i.imgur.com/BftO0Na.png'
}
if ($PassFail -eq 'Fail') {
    $color = 'danger'
    $status = 'Failed'
    $icon = ':x:'
    $thumb = 'https://i.imgur.com/ThR4QSe.png'
}

$body = ConvertTo-Json -Depth 4 @{
  title    = "$Name Completed"
  text   = " "
  sections = @(
    @{
      activityTitle    = $TSName
      activitySubtitle = 'Windows 10 1803'
      activityText     = "Deployment $status"
      activityImage    = $thumb # this value would be a path to a nice image you would like to display in notifications
    },
    @{
      title = '<h2 style=color:blue;>Deployment Details'
      facts = @(
        @{
          name  = 'Name'
          value = $Name
        },
        <#@{
          name  = 'Primary User'
          value = $TSUser
        },#>
        @{
          name  = 'Finished'
          value = "$DateTime"
        },
        @{
          name  = 'Duration'
          value = "$Timespan"
        },
        @{
          name  = 'IP Addresss'
          value = $IPAddress
        },
        @{
          name  = 'Make'
          value = $Make
        },
        @{
          name  = 'Model'
          value = $Model
        },
        @{
          name  = 'Serial'
          value = $SerialNumber
        }
      )
    }
  )
}
Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'