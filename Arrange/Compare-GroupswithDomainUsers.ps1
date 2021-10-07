# Variables
$allOrmatUsers = @()
$enabledUsers = @()
$outFile = 'c:\abt\grpDiff-v2.csv'
$grpName = "Domain Users"
$otherGrpName = "FW-Global-VPN-UserAccess"
$dcs = @("ormat-isr1.ormat.com","ke-il-dc1.ke.ormat.com","us-il-dc1.us.ormat.com","ca-il-dc1.ca.us.ormat.com", `
"mammoth-il-dc1.mammoth.us.ormat.com","hi-il-dc1.hi.us.ormat.com","nv-il-dc1.nv.us.ormat.com")
# Collects users from all domain
# 
foreach($dc in $dcs){$allOrmatUsers += Get-ADGroupMember $grpName -Server "" -Recursive}

# Sort both groups
$groupA = $allOrmatUsers |Sort-Object -Property Name
$groupB = Get-ADGroupMember $otherGrpName -Recursive |Sort-Object -Property Name

#creates a compared object
$compare = Compare-Object -ReferenceObject $groupA -DifferenceObject $groupB

#removes disabled accounts
foreach($i in $compare){
    if((get-aduser -identity $i.InputObject).Enabled -eq $true)
        {$enabledUsers += $i}
}

# Export the results to a file
$enabledUsers | Export-Csv $outFile -NoTypeInformation