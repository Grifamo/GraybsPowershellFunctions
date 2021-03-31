$Application = 'Outlook'
$Label = "$Application-Microsoft-Scan"
$GS = 'MAJORVERSION 16 INSTALLTYPE MSI' # Office 2016 MSI

$LocalOffCATFiles = (Get-Content env:LOCALAPPDATA) + "\Microsoft\offcat"
$NetworkLocationForReportFile = '\\TSGFS1\ISHome\Shared\Office Troubleshooting'
$OffCATScanFileName = "OffCAT_Results`.$Application`-$env:USERDOMAIN`-$env:computername`-$env:username`.$DateTime.offx"
$OffCATOutputFile = "$OffCATReportPath\$OffCATScanFileName"

cd $LocalOffCATFiles
.\OffCATcmd.exe -l $Label -dat $OffCATOutputFile -cfg $Application -PIIAck -AE -gs $GS
Start-Process OffCATcmd.exe -dat $OffCATOutputFile -l $Label -cfg $Application -PIIAck -AE -gs $GS
            $proc = Get-Process OffCATcmd
            Wait-Process -InputObject $proc