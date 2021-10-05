<#
        .SYNOPSIS
        A basic script for auto reboot and testing of servers after updates

        .DESCRIPTION
        Add a detailed description

        .PARAMETER ServerName
        Specifies the file name.

        .PARAMETER Extension
        Specifies the extension. "Txt" is the default.

        .INPUTS
        None. You cannot pipe objects to Add-Extension.

        .OUTPUTS
        System.String. Add-Extension returns a string with the extension or file name.

        .EXAMPLE
        PS> extension -name "File"
        File.txt

        .EXAMPLE
        PS> extension -name "File" -extension "doc"
        File.doc

        .EXAMPLE
        PS> extension "File" "doc"
        File.doc

        .LINK
        Online version: http://www.fabrikam.com/extension.html

        .LINK
        Set-Item
    #>


# Modules



$Servers = @("Ormat-MBAM")
$KB
$cred = (Get-Credential)
$ct = "application/json"
$hostname = "ORM-SWinds.ormat.com"

# Loops through servers
foreach($i in $Servers){



# Gather info

    # Info from VM
    # Info from AD

# Unmanage from Solarwinds
foreach ($s in $servers) {
    # Query Node
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    $uri = "https://$($hostname):17778/SolarWinds/InformationService/v3/Json/Query"
    $json = "{`"query`": `"SELECT NodeID, Caption FROM Orion.Nodes WHERE Caption LIKE @Caption`",`"parameters`": {`"Caption`": `"$s%`"}}"
    $b = Invoke-RestMethod -Body $json -Credential $cred -Method Post -Uri $uri -ContentType $ct
    $nodeID = "N:"+$b.results[0].NodeID
    $stopwatch.Stop()
    $stopwatch

    # Unmanage Node
    $stopwatch =  [system.diagnostics.stopwatch]::StartNew()
    $UnmanageTime = "60"
    $now = (Get-Date).ToUniversalTime()
    $jsonUnmanage = "[`"$($nodeID)`",`"$($now.AddSeconds(-1))`",`"$($now.AddMinutes($UnmanageTime))`",`"$false`"]"
    $uriUnmanage = "https://$($hostname):17778/SolarWinds/InformationService/v3/Json/Invoke/Orion.Nodes/Unmanage"
    Invoke-RestMethod -Body $jsonUnmanage -Credential $cred -Method Post -Uri $uriUnmanage -ContentType $ct
    $stopwatch.Stop()
    $stopwatch
}
# Reboot

# Check if the server is up by checking ping + Netlogon

# Check if the KB is installed (via code of CyberObserver or SCCM)

# Test specific services if needed

# Remanage from Solarwinds + Poll
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
    

}









