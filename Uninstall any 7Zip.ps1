Set-Location -Path HKLM:\

#Check the Program Files (x86) for 7-Zip, not necessary on x86 PCs
$Uninstalls = Get-ChildItem -path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ -Recurse

foreach($Uninstall in $Uninstalls){
    Set-Location -Path HKLM:\
    $Property = Get-ItemProperty $Uninstall

    if($Property.DisplayName -like "7-Zip*"){

        $7zip = $Property
        $ProductCode = $Property.PSChildName
        $UninstallString = $7zip.UninstallString

        If($UninstallString -eq $Null){} 
        
        elseif($UninstallString -like "msiexec.exe*") 
        {
            Msiexec.exe /uninstall $ProductCode /passive
        } 
            
        elseif ($UninstallString -like "*uninstall.exe*") 
        {
            $UninstallFolder = $UninstallString -replace 'uninstall.exe', ''
            $UninstallFolder = $UninstallFolder -replace '"',''
            Set-Location -Path $UninstallFolder
            .\uninstall.exe /S
        }

    }
    $Property = $Null
}
    
#Check regular Program Files for 7-Zip
Set-Location -Path HKLM:\

$Uninstalls = Get-ChildItem -path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ -Recurse

foreach($Uninstall in $Uninstalls){
    Set-Location -Path HKLM:\
    $Property = Get-ItemProperty $Uninstall
    #$Property.DisplayName

    if($Property.DisplayName -like "7-Zip*"){

    $7zip = $Property
    $ProductCode = $Property.PSChildName
    $UninstallString = $7zip.UninstallString

        If($UninstallString -eq $Null){} 

        elseif ($UninstallString -like "msiexec.exe*") 
        {
            Msiexec.exe /uninstall $ProductCode /passive
        }
         
        elseif ($UninstallString -like "*uninstall.exe*") 
        {
            $UninstallFolder = $UninstallString -replace 'uninstall.exe', ''
            $UninstallFolder = $UninstallFolder -replace '"',''
            Set-Location -Path $UninstallFolder
           .\uninstall.exe /S
        }
    }
    $Property = $Null
}