$registryPath1 = "HKCU:\Software\Microsoft\Office\Outlook\Addins\ShoreTel.STVMAddIn"
$registryPath2 = "HKCU:\Software\Microsoft\Office\Outlook\Addins\ShoreTel.CHMAddin"
$registryPath3 = "HKCU:\Software\Microsoft\Office\Outlook\Addins\ShoreTel.UCBAddin"
$Name = "LoadBehavior"
$value = "0"

IF(!(Test-Path $registryPath1))
    {
      New-ItemProperty -Path $registryPath1 -Name $name -Value $value
    }

IF(!(Test-Path $registryPath2))
    {
      New-ItemProperty -Path $registryPath2 -Name $name -Value $value
    }

IF(!(Test-Path $registryPath3))
    {
      New-ItemProperty -Path $registryPath3 -Name $name -Value $value
    }
