$vCenter = "md-vc"
$VMs = Get-VM -Server $vCenter

$a = get-vm SBREMAPPGI-CHROME

$snap = $a |Get-Snapshot

for($i=0; $i -le $snap.Length-1 ;$i++)
{
    hasParentSnap -Snapshot $snap[$i]

}

Function  hasParentSnap($Snapshot)
{
    #param $Snapshot

    if($Snapshot.parent)
    {
        return $true
    }
    else
    {
        return $false
    }
}

Function  Get-LastSnap($VM)
{
    $snap = Get-Snapshot $VM
    foreach($snap in $snap)
    {
    if($snap.hasParentSnap -eq $false)
        {
            return "The Lastest Snapshot is from "
        }
    }
}



#New-Object -TypeName PSCustomObject -Property @{
#                            "VM" = $vms[$i].Name
#                            "DataStore" = $ds
#                            } |select 'VM','DataStore'
#            }
