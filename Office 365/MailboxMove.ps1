#Mailbox Migration

$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking -AllowClobber

New-MoveRequest -Identity Derik.Graybeal@thestollergroup.com -RemoteCredential (Get-Credential) -Remote -RemoteHostName 'owa.thestollergroup.com' -BatchName DerikMove2 -BadItemLimit 100 -PrimaryOnly -TargetDeliveryDomain TheStollerGroup.mail.onmicrosoft.com
Remove-MoveRequest -Identity Derik.Graybeal@thestollergroup.com -force

Get-MoveRequest -BatchName DerikMove2
Get-MoveRequestStatistics -Identity Derik.Graybeal@thestollergroup.com
get-moverequeststatistics -Identity Derik.Graybeal@thestollergroup.com | select DisplayName,SyncStage,Failure*,Message,PercentComplete,largeitemsencountered,baditemsencountered|ft -autosize
Remove-PSSession $Session