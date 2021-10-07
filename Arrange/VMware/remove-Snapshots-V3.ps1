Connect-VIServer md-vc -User "ds-invest\btasaf" -Password "1qa@WS3ed"
$logPath = "c:\abt\SnapRemoval.log"
$dt = get-date -Format dd/MM/yyyy-hh:mm:ss
$vms = Get-VM SBREMAPP-TEST
$sleep = 3
#Remove Snapshot Procedure





foreach($vm in $vms)
{
    
    #Get-Variable -Name out |Remove-Variable -ErrorAction SilentlyContinue
    
    if(((hasSnapshot($vm)) -eq $true) -and ((excludeFromSnapRemove($vm)) -eq $false))
    {
        
        try{
                #$snaps = Get-Snapshot -VM $vm | Remove-Snapshot -RemoveChildren -Confirm:$false
                $vm = $vm | get-view
                #$vmEvents = Get-VIEvent -Entity $vm
                
                $taskRemoveSnap = $vm.RemoveAllSnapshots_Task(0) #--Start Snapshot removal Task
                sleep $sleep
                while((Get-Task |? {$_.ID -eq "Task-"+$taskRemoveSnap.Value}).State -eq "Running") #--Start While for Snapshot removal Task
                {
                    $out = $dt+","+$vm.Name+","+"Snap Removal Still Running"
                    out-file $logPath -InputObject $out -Append

                    if((Get-Task |? {$_.ID -eq "Task-"+$taskRemoveSnap.Value}).State -eq "Success") #--Start if Snap Remove OK
                    {
                        $out = $dt+","+$vm.Name+","+"Snap Remove Success"
                        out-file $logPath -InputObject $out -Append
                        
                        $taskConsolSnap = $vm.ConsolidateVMDisks_Task() |out-file $logPath #--Start Snapshot Consolidate
                        sleep $sleep
                        while((Get-Task |? {$_.ID -eq "Task-"+$taskConsolSnap.Value}).State -eq "Running")
                            {#--START Snapshot Consolidate
                            
                            $out = $dt+","+$vm.Name+","+"Snap Consolidate Still Running"
                            out-file $logPath -InputObject $out -Append
                            
                            if((Get-Task |? {$_.ID -eq "Task-"+$taskConsolSnap.Value}).State -eq "Success")#--if Snap Consolidate OK
                                {
                                $out = $dt+","+$vm.Name+","+"Snap Consolidate Success"
                                out-file $logPath -InputObject $out -Append
                                }
                            else{
                                $out = $dt+","+$vm.Name+","+"Snap Consolidate Failed"+","+$Error[0].Exception.Message
                                out-file $logPath -InputObject $out -Append
                                }
                            
                            sleep $sleep
                            }#--END Snapshot Consolidate
                    }
                    else
                    {
                        $out = $dt+","+$vm.Name+","+"Snap Remove Failed"+","+$Error[0].Exception.Message
                        out-file $logPath -InputObject $out -Append
                    }
                    
                    sleep $sleep
                }
                
            }
            catch
            {
                $out = $dt+","+$vm.Name+$Error[0].Exception.Message
            }
            out-file $logPath -InputObject $out -Append
    }
    else
    {
        if((hasSnapshot($vm)) -eq $false)
        {
            $out = $dt+","+$vm.Name+","+"Has No Snapshots1"
            out-file $logPath -InputObject $out -Append
        }
        elseif((excludeFromSnapRemove($vm)) -eq $true)
        {
            $out = $dt+","+$vm.Name+","+"is excluded from Snapshots"
            out-file $logPath -InputObject $out -Append 
        }
    }

}

Function hasSnapshot($vm)
{
    if((Get-Snapshot -vm $vm) -ne $null)
    {
        return $true
    }
    else
    {
        return $false
    }
}

Function excludeFromSnapRemove($vm)
{
    if(($vm.ExtensionData.CustomValue |where {$_.key -eq "1001"}).value -eq 1)
    {
        return $true
    }
    else
    {
        return $false
    }
}




#$vms = Get-VM SBREMAPP-TEST |Get-View
#$task = $vms[0].RemoveAllSnapshots_Task(0)
#$task = $vms[0].ConsolidateVMDisks_Task()
#$task = Get-Task |? {$_.ID -eq "Task-"+$task.Value}
#$task
