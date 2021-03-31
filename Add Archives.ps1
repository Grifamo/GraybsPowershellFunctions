$Outlook = New-Object -ComObject Outlook.Application
$Namespace = $Outlook.getNamespace("MAPI")

$all_psts = import-csv C:\Users\LaceyH.NWHQ\AppData\Local\Microsoft\Outlook\Archives.csv

ForEach ($pst in $all_psts){
    Add-Content -path C:\Users\LaceyH.NWHQ\AppData\Local\Microsoft\Outlook\Archives.csv -value "$($pst.filepath)"
    $Outlook.Session.RemoveStore($pst.GetRootFolder())
}