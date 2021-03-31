$customformat = 
        @{expr={$_.UserPrincipalName};label="UserPrincipalName"},
        @{expr={$_.DisplayName};label="DisplayName"},
        @{expr={$_.isLicensed};label="isLicensed"}
Get-MSOLUser | Sort DisplayName -Descending | Select $customformat | Export-CSV "\\TSGFS1\ISHome\DLGraybeal\Scripts\CSV Exports\MSOL Users.csv" -NoTypeInformation