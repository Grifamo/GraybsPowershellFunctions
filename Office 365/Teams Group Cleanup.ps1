#This script is intended to be run as a scheduled task
#Get-InstalledModule -Name "AzureAD*"
#Install-Module AzureADPreview
#https://support.office.com/en-us/article/manage-who-can-create-office-365-groups-4c46c8cb-17d0-44b5-9776-005fced8e618

#Teams Message Variables
$uri = 'https://outlook.office.com/webhook/352bb0b5-8cc4-4851-9544-bfc7ae16b48e@7409b1d2-6bd4-4c51-8e4d-e68ae7284050/IncomingWebhook/df0a5587528d4d4c951c127edd0fb6e1/039ab960-97dc-428e-a25f-9e2b7f877270'



$AuthorizedOwners = @('Mike.Goff@TheStollerGroup.com','Brandon.Laws@XeniumHR.com')
$AuthorizedGroups = @('e27239e9-8f1b-4355-b759-9b31e9dfea29')
<#
$customformat = 
        @{expr={$O365GroupName};label="DisplayName"},
        @{expr={$_.UserPrincipalName};label="GroupOwner"}

Get-AzureADGroup | ForEach-Object {
    $O365GroupName = $_.DisplayName
    Get-AzureADGroupOwner -ObjectId $_.ObjectID | Select $customformat
}#>

#Report Anauthorized Group Owners
Get-AzureADGroup | ForEach-Object {
    $O365Group = Get-AzureADGroup -ObjectId $_.ObjectID
    $O365GroupOwner = Get-AzureADGroupOwner -ObjectID $O365Group.ObjectID
    If ($O365GroupOwner.UserPrincipalName -notin $AuthorizedOwners -AND $O365GroupOwner.UserPrincipalName -ne $null -AND $O365Group.ObjectID -notin $AuthorizedGroups) {
        #Add in operator to handle group with multiple owners
        #If (
        
        $body = ConvertTo-Json -Depth 4 @{
            title    = "Rogue Teams Group Found"
            text   = "An Office 365 Group was created by an unauthorized owner"
            sections = @(
                @{
                    activityTitle    = $O365Group.DisplayName
                    activitySubtitle = 'Teams Group'
                    activityText     = "Please Notify and Remove"
                    activityImage    = 'https://i.imgur.com/ThR4QSe.png'
                },
                @{
                    title = '<h2 style=color:blue;>Office 365 Group Details'
                    facts = @(
                        @{
                            name  = 'Created By'
                            value = $O365GroupOwner.DisplayName
                        },
                        @{
                            name  = 'Email'
                            value = $O365GroupOwner.UserPrincipalName
                        },
                        @{
                            name  = 'AzureAD Object ID'
                            value = $O365Group.ObjectID
                        } 
                        @{
                            name = 'Administrator Tasks'
                            value = 'Notify creator and soft delete, or add AzureAD Object ID shown here to $AuthorizedGroups array in script'
                        }   
                    )
                }
            )
        }
        #$O365Group.DisplayName
        #$O365GroupOwner.UserPrincipalName
        Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType 'application/json'
    }
}

<#Troubleshooting handling groups with more than one owner
$TroubleGroup = Get-AzureADGroupOwner -ObjectId "e27239e9-8f1b-4355-b759-9b31e9dfea29"
$TroubleGroup | measure
$NonTroubleGroup = Get-AzureADGroupOwner -ObjectId "8e5e93fd-0540-4993-8af2-212d5fd63746"
$NonTroubleGroup | measure

Compare-Object -ReferenceObject $TroubleGroup.UserPrincipalName -DifferenceObject $AuthorizedOwners -IncludeEqual
#>