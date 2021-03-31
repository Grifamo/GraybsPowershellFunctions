#--------------------------------------------------------------------------------- 
#The sample scripts are not supported under any Microsoft standard support 
#program or service. The sample scripts are provided AS IS without warranty  
#of any kind. Microsoft further disclaims all implied warranties including,  
#without limitation, any implied warranties of merchantability or of fitness for 
#a particular purpose. The entire risk arising out of the use or performance of  
#the sample scripts and documentation remains with you. In no event shall 
#Microsoft, its authors, or anyone else involved in the creation, production, or 
#delivery of the scripts be liable for any damages whatsoever (including, 
#without limitation, damages for loss of business profits, business interruption, 
#loss of business information, or other pecuniary loss) arising out of the use 
#of or inability to use the sample scripts or documentation, even if Microsoft 
#has been advised of the possibility of such damages 
#--------------------------------------------------------------------------------- 

Function GetAllADUsersLastLogonTime
{
    Param
    (
        [String]$OutCsvFilePath = "C:\AllADUsersLastLogonTimeList.csv",
        [Int]$PageSize = 100
    )
    $Filter = "(&(objectCategory=User))"
            
    $Domain = New-Object System.DirectoryServices.DirectoryEntry 
    $Searcher = New-Object System.DirectoryServices.DirectorySearcher
    $Searcher.SearchRoot = "LDAP://$($Domain.DistinguishedName)"
    $Searcher.PageSize = 1000
    $Searcher.SearchScope = "Subtree"
    $Searcher.Filter = $Filter
    $Searcher.PropertiesToLoad.Add("Name") | Out-Null
    $Searcher.PropertiesToLoad.Add("LastLogonTimeStamp") | Out-Null

    $Results = $Searcher.FindAll()
    
     "SamAccountName,LastLogonTimeStamp" | out-file $OutCsvFilePath -encoding ascii -append 
     Foreach($Result in $Results)
     {
            $Name = $Result.Properties.Item("Name")
            $LastLogonTimeStamp = $Result.Properties.Item("LastLogonTimeStamp")          
            If ($LastLogonTimeStamp.Count -eq 0)
            {
                $LastLogonTimeStamp = "Never Logon"
            }
            Else
            {
                $Time = [DateTime]$LastLogonTimeStamp.Item(0)
                $LastLogonTimeStamp = $Time.AddYears(1600).ToString("yyyy/MM/dd")
            }
            
            $Name.trim().replace(","," ") + "," + $LastLogonTimeStamp.trim() | out-file $OutCsvFilePath -encoding ascii -append                                               
     }
   
}