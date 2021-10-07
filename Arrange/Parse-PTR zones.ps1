$zones = Get-DnsServerZone -ComputerName ormat-ildc01 |where {$_.IsReverseLookupZone -eq $true -and $_.IsAutoCreated -eq $false}
$fZones = @()

foreach($i in $zones){
    $t1 = ($i.ZoneName).Replace('.in-addr.arpa',"")
    $t2 = $t1.split(".")
    $ip = $t2[2] +"."+ $t2[1] +"."+ $t2[0] +"."+ "0"
    $fZones += $ip
}

Get-ADReplicationSubnet -filter * -Properties * | Select Name