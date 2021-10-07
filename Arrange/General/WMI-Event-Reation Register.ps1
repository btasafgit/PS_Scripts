$srv = "10.254.254.40"
$admUser = ".\administrator"
$admPass = ConvertTo-SecureString '$y$temP@ssw0rd2017!' -AsPlainText -Force
$admCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $admUser, $admPass
 # Define event Query
$query = "SELECT * from __InstanceCreationEvent WITHIN 1 WHERE TargetInstance ISA 'WIN32_NTLogEvent'
        AND  (TargetInstance.SourceName='System' or TargetInstance.LogFile='System')
        AND  (TargetInstance.EventIdentifier = 4006 OR TargetInstance.EventIdentifier = 4000
        )"



for($i = 0; $i -le 1000 ;$i++)
{
# Register for event - also specify an action that
# displays the log event when the event fires.
Register-WmiEvent -ComputerName 10.254.254.40 -Credential $admCred -Query $query -Action {
                #Write-Host "Log Event START============================================================================================"
                $global:myevent = $event
                #Write-Host "EVENT MESSAGE"
                #Write-Host $event.SourceEventArgs.NewEvent.TargetInstance.Message}
                #Write-Host "Log Event END============================================================================================"
# So wait
#write-host "Waiting for events " $i
}
}