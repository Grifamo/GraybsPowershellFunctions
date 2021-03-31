#Get-UDDashboard | Stop-UDDashboard
#Get-UDTheme

<#$Theme = New-UDTheme -Name "Basic" -Definition @{
  UDDashboard = @{
      BackgroundColor = "#FF333333"
      FontColor = "#FFFFFFF"
  }
} -Parent "Azure"#>

$Dashboard = New-UDDashboard -Title "TSG Helpdesk Assistant" -BackgroundColor "#333333" -FontColor "#FFFFFFF" -Content {
    New-UDRow -Columns {
        New-UDColumn -SmallSize 4 -Content {
            New-UDCard -BackgroundColor "#808080" -Title "User Administration" -BackgroundColor "#808080"
        }
        New-UDColumn -SmallSize 4 -Content {
            New-UDCard -Title "Asset Management" -Text "For all changes to IT assets" -BackgroundColor "#808080"
        }
    }

}

Start-UDDashboard -Port 10000 -Dashboard $Dashboard #-AutoReload
#Start-Process http://localhost:10000