
# Primary group to Split
$grp = Get-ADGroupMember -Identity VPN-Ormat-Users-Access

# Group objects from each domain
$ILgrp = Get-ADGroup -Identity FW-IL-VPN-UserAccess
$KEgrp = Get-ADGroup -Server 'ke-il-dc1.ke.ormat.com' -Identity FW-KE-VPN-UserAccess
$USgrp = Get-ADGroup -Server 'us-il-dc1.us.ormat.com' -Identity FW-US-VPN-UserAccess
$CAgrp = Get-ADGroup -Server 'ca-il-dc1.ca.us.ormat.com' -Identity FW-CA-VPN-UserAccess
$NVgrp = Get-ADGroup -Server 'nv-reno-dc1.nv.us.ormat.com' -Identity FW-NV-VPN-UserAccess
$MMTHgrp = Get-ADGroup -Server 'mammoth-il-dc1.mammoth.us.ormat.com' -Identity FW-MMTH-VPN-UserAccess
$HIgrp = Get-ADGroup -Server 'hi-il-dc1.hi.us.ormat.com' -Identity FW-HI-VPN-UserAccess

# Arrays for each domain users to be populated
$ILusrs = @()
$KEusrs = @()
$USusrs = @()
$CAusrs = @()
$NVusrs = @()
$MMTHusrs = @()
$HIusrs = @()

# Loop for populating the Arrays with usres from each domain (of the main group) to the relevant individual lists
foreach($i in $grp){
    
    # get a specific user - for extended properties
    $usr = get-aduser -Server $GC -Properties CanonicalName $i.distinguishedName

    # gets user's domain
    $domain = $usr.CanonicalName.substring(0,$usr.CanonicalName.IndexOf('/'))

    # Populates each domain's group with it's relevant users from the bigger group
    if($domain -eq "KE.ORMAT.COM"){
        #write-host $domain
        $KEusrs += $usr
    }
    if($domain -eq "US.ORMAT.COM"){
        #write-host $domain
        $USusrs += $usr
    }
    if($domain -eq "CA.US.ORMAT.com"){
        #write-host $domain
        $CAusrs += $usr
    }
    if($domain -eq "NV.US.ORMAT.com"){
        #write-host $domain
        $NVusrs += $usr
    }
    if($domain -eq "HI.US.ORMAT.com"){
        #write-host $domain
        $HIusrs += $usr
    }
    if($domain -eq "MAMMOTH.US.ORMAT.com"){
        #write-host $domain
        $MMTHusrs += $usr
    }
    if($domain -eq "ORMAT.com"){
        #write-host $domain
        $ILusrs += $usr
    }
    Clear-Variable domain -Force
} 

# Adding each domain users group to it's domain dedicated group
Add-ADGroupMember -Identity $ILgrp -Members $ILusrs
Add-ADGroupMember -Identity $KEgrp -Members $KEusrs
Add-ADGroupMember -Identity $USgrp -Members $USusrs
Add-ADGroupMember -Identity $CAgrp -Members $CAusrs
Add-ADGroupMember -Identity $NVgrp -Members $NVusrs
Add-ADGroupMember -Identity $MMTHgrp -Members $MMTHusrs
Add-ADGroupMember -Identity $HIgrp -Members $HIusrs


<#For SYSTEM Use only
Clear-Variable usr -Force
Clear-Variable ILgrp -Force
Clear-Variable KEgrp -Force
Clear-Variable USgrp -Force
Clear-Variable CAgrp -Force
Clear-Variable NVgrp -Force
Clear-Variable MMTHgrp -Force
Clear-Variable HIgrp -Force
Clear-Variable ILusrs -Force
Clear-Variable KEusrs -Force
Clear-Variable USusrs -Force
Clear-Variable CAusrs -Force
Clear-Variable NVusrs -Force
Clear-Variable MMTHusrs -Force
Clear-Variable HIusrs -Force#>