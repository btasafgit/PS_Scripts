$vCenter = "md-vc"
$VMs = Get-VM Converter,'OnCommand Unified Manager',btasaf-vm,AmanRem01,AmanRem02 -Server $vCenter
$verbose = 0
$winVM = @()
$linVM = @()

for($i=0; $i -le $VMs.Length-1 ;$i++)
{
    if($VMs[$i].Guest.OSFullName -like "*Windows*")
        {
            $winVM+=$VMs[$i]
            #Write-host "WinVM Now Has " $winVM.Count " Items"
        }
    else
        {
            $linVM+=$VMs[$i]
            #Write-host "LinVM Now Has " $linVM.Count " Items"
        }
}

for($i=0; $i -le $winVM.Length-1 ;$i++)
{
    $snap = Get-Snapshot -VM $winVM[$i].Name
    if($snap -ne $null)
        {
            Remove-Snapshot -Snapshot $snap -Confirm:$false

        }
}

for($i=0; $i -le $linVM.Length-1 ;$i++)
{
     $count =0
     $snap = Get-Snapshot -VM $linVM[$i].Name
     
     if($snap -ne $null)
        {
             Shutdown-VMGuest -VM $linVM[$i].Name -Confirm:$false

             #Wait for VM shutdown

                Do{
                sleep 1
                write-host $count
                $count++
                if($count -eq 60)
                    {
                        break
                    }
                }
                while($linVM[$i].PowerState -ne "PoweredOff")

                if($snap -ne $null)
                    {
                        Remove-Snapshot -Snapshot $snap -Confirm:$false
                    }

        }

}

