$Outlook = New-Object -ComObject Outlook.Application
$Namespace = $Outlook.getNamespace("MAPI")

$all_psts = $Namespace.Stores | Where-Object {($_.ExchangeStoreType -eq '3') -and ($_.FilePath -like '*.pst') -and ($_.IsDataFileStore -eq $true)}

ForEach ($pst in $all_psts){
    $Outlook.Session.RemoveStore($pst.GetRootFolder())
}