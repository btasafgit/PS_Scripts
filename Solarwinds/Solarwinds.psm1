#default swinds server

#http://solarwinds.github.io/OrionSDK/2018.4/schema/Orion.Nodes.html
#https://loop1.com/swblog/using-the-rest-api-to-get-the-most-out-of-solarwinds-part-2/
$ct = "application/json"
$hostname = "ORM-SWinds.ormat.com"
$cred = (Get-Credential)
$servers = '"Ormat-MIR","Ormat-Modula"'

foreach ($s in $servers) {
    # Query Node
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    $uri = "https://$($hostname):17778/SolarWinds/InformationService/v3/Json/Query"
    #$json = "{`"query`": `"SELECT NodeID, Caption FROM Orion.Nodes WHERE Caption LIKE @Caption`",`"parameters`": {`"Caption`": `"$s`"}}"
    #$json = "{`"query`": `"SELECT NodeID, Caption FROM Orion.Nodes WHERE Caption IN @Caption`",`"parameters`": {`"Caption`": [`"Ormat-MIR`",`"Ormat-Modula`"]}}"
    $json = "{`"query`": `"SELECT NodeID, Caption FROM Orion.Nodes WHERE Caption IN @Caption`",`"parameters`": {`"Caption`": [$servers]}}"
    $b = Invoke-RestMethod -Body $json -Credential $cred -Method Post -Uri $uri -ContentType $ct -DisableKeepAlive
    $nodeID = "N:"+$b.results[0].NodeID
    $stopwatch.Stop()
    $stopwatch

    # Unmanage Node
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    $UnmanageTime = "60"
    $now = (Get-Date).ToUniversalTime()
    $join = (Join-SWNodes $b.results.NodeID)
    $jsonUnmanage = "[`"$($join)`",`"$($now.AddSeconds(-1))`",`"$($now.AddMinutes($UnmanageTime))`",`"$false`"]"
    $uriUnmanage = "https://$($hostname):17778/SolarWinds/InformationService/v3/Json/Invoke/Orion.Nodes/Unmanage"
    Invoke-RestMethod -Body $jsonUnmanage -Credential $cred -Method Post -Uri $uriUnmanage -ContentType $ct
    $stopwatch.Stop()
    $stopwatch
}

foreach ($s in $servers) {
# Remanage Node
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$jsonManage = "[`"$($nodeID)`"]"
$uriManage = "https://$($hostname):17778/SolarWinds/InformationService/v3/Json/Invoke/Orion.Nodes/Remanage"
Invoke-RestMethod -Body $jsonManage -Credential $cred -Method Post -Uri $uriManage -ContentType $ct -DisableKeepAlive
$stopwatch.Stop()
$stopwatch


# Poll node
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$jsonPoll = "[`"$($nodeID)`"]"
$uriPoll = "https://$($hostname):17778/SolarWinds/InformationService/v3/Json/Invoke/Orion.Nodes/PollNow"
Invoke-RestMethod -Body $jsonPoll -Credential $cred -Method Post -Uri $uriPoll -ContentType $ct -DisableKeepAlive
$stopwatch.Stop()
$stopwatch

}







function Join-SWNodes(){
param([Array]$Array)
$arr = $Array
$out = ""
    for($i=0; $i -le $arr.Length-1;$i++)
    {$out += "`"N:$($arr[$i])`","}
return $out.TrimEnd(",")
}









Get-MessageTrace -MessageId "JIRA.183075.1629119145000.25227.1630417260046@Atlassian.JIRA" -StartDate (get-date).AddDays(-10) -EndDate (get-date)
Get-MessageTrace -MessageId "<488250787.30236.1630417260406@Ormat-JIRA.ORMAT.com>" -StartDate (get-date).AddDays(-10) -EndDate (get-date)
Get-MessageTrace -MessageId "<1628328990.30248.1630417858482@Ormat-JIRA.ORMAT.com>" -StartDate (get-date).AddDays(-10) -EndDate (get-date)
Get-MessageTrace -MessageId "<JIRA.183075.1629119145000.25242.1630417920113@Atlassian.JIRA>" -StartDate (get-date).AddDays(-10) -EndDate (get-date)

$id = "<488250787.30236.1630417260406@Ormat-JIRA.ORMAT.com>"
Get-MessageTrace -MessageId $id -StartDate (get-date).AddDays(-10) -EndDate (get-date)