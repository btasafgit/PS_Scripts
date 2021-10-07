## Check Healt of vms
# currently checking for VM vs VMDK Names
$vserver = "md-vc.ds-invest.local"
Connect-VIServer $vserver
$vm = get-vm -Server $vserver
#$vm[0].Name
for($i=0; $i -le $vm.length-1 ;$i++)
{
    $vmName = $vm[$i].Name
    $vmHostName = $vm[$i].ExtensionData.Guest.HostName


    if (($vmHostName -eq $null) -or ($vmHostName.IndexOf(".")) -eq -1)
        {
            $vmHostName = ""
            $nbName = ""
            $domName = ""
        }

    elseif(($vmHostName.IndexOf(".")) -ne -1)
        {
            write-host $i " " $vmName
            $nbName = $vmHostName.Substring(0,$vmHostName.IndexOf("."))
            $domName = $vmHostName.Substring($vmHostName.IndexOf(".")+1)
        }
    else
        {
            write-host $vmName " not OK"
        }

    if(($vmHostName -ne $null) -and $vmName -ne $nbName)
        {
            $health = "Not Healthy"
        }
        else
        {
            $health = "Healthy"
        }
    New-Object -TypeName PSCustomObject -Property @{
        "VM Name" = $vmName
        "Host Name" = $vmHostName
        "NB Name" = $nbName
        "Domain Name" = $domName
        "Health" = $health
    }|select 'VM Name','Host Name','NB Name','Domain Name','Health' | export-csv C:\abt\VMNameDiff.csv -Append
}