foreach ($user in (Get-ADUser -SearchBase "OU=SV_Users,OU=StollerVineyards,DC=nwhq,DC=thestollergroup,DC=com" -LdapFilter '(proxyAddresses=*)')) {
	$address = Get-ADUser $user -Properties proxyAddresses | Select -Expand proxyAddresses | Where {$_ -clike "SMTP:*"}
	$User.UserPrincipalName
    $newUPN = $address.SubString(5)
	Set-ADUser $user -UserPrincipalName $newUPN
    $User = Get-ADUser $User
    $User.UserPrincipalName
    "`n"

}