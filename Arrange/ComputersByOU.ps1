$ouServers = 'OU=Servers,DC=DS-Invest,DC=Local'
$csvFile = 'c:\abt\compInOU.csv'
$compList = Get-ADComputer -Filter * -Properties * -SearchBase $ouServers

for($i=0; $i -le $compList.Length-1 ;$i++)
{
    #$comp = $compList[$i]
    $firstCommaAt = $compList[$i].DistinguishedName.IndexOf(",")
    $OU = $compList[$i].DistinguishedName.Substring($firstCommaAt+1)
    New-Object -TypeName PSCustomObject -Property @{
                            "Computername" = $compList[$i].Name
                            "OU" = $OU
                            } |select 'Computername','OU'| export-csv $csvFile -Append
}


