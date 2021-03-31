function Get-Definition {
    Param(
        [parameter(Mandatory=$true,Position=0)]
        [string]$word,

        [parameter(Mandatory=$false,ValueFromPipeline=$true,Position=1)]
        [bool]$etymologybool = $false
    )

    $head = @{
        #https://developer.oxforddictionaries.com/admin/applications
        #User: Derik   Password: sweetROLLS1337!
        'Accept'='Application/json'
        'app_id'='543122e6'
        'app_key'='1c0f327ddec198042ed292e8caefee51'
    }

    $base = 'https://od-api.oxforddictionaries.com/api/v1'
    $method = '/entries/'
    $language = 'en/'

    $uri = $base + $method + $language + $word

    $results = Invoke-RestMethod -uri $uri -Headers $head
    $definition = $results.results.lexicalentries.entries.senses
    $etymology = $results.results.lexicalEntries.entries.etymologies

    if ($etymologybool -eq $true) {
        return $etymology
    } else {
        return $definition
    }
}