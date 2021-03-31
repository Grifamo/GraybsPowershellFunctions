$DiscMaster   = New-Object -ComObject IMAPI2.MsftDiscMaster2
$DiscRecorder = New-Object -ComObject IMAPI2.MsftDiscRecorder2
$DiscRecorder.InitializeDiscRecorder($DiscMaster)
$DiscRecorder.EjectMedia()