$compList = Get-ADComputer -Filter * -SearchBase "OU=Servers,DC=DS-Invest,DC=Local"
$fileLoc = 'c:\abt\SIDList.csv'
$toolLoc = "E:\Tools\Microsoft\SysinternalsSuite"
Set-Location -Path $toolLoc

for($i=0; $i -le $compList.Length-1 ;$i++)
{
    #Get copmuter
    $comp = $compList[$i].Name

    #Get Machine SID
    $compSID = .\PsGetsid.exe \\$comp
    $machineSID = $compSID |select -Skip 2
    #Get AD SID
    $ADSID = $compList[$i].SID
                            New-Object -TypeName PSCustomObject -Property @{
                            "Computername" = $comp
                            "MachineSID" = $machineSID[0]
                            "ADSID" = $ADSID
                            } |select 'Computername','MachineSID','ADSID' | export-csv $fileLoc -Append
                            

}