
Connect-VIServer md-vc
$hostUser = "root"
$hostPass = ConvertTo-SecureString "W!neRoad87" -AsPlainText -Force
$hostCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $hostUser, $hostPass


$guestUser = "administrator"
$guestPass = ConvertTo-SecureString '$y$temP@ssw0rd2017!' -AsPlainText -Force
$guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass


$vms = Get-VM -Server md-vc |where {$_.Guest.OSFullName -like "*Windows Server*" -and $_.PowerState -eq "PoweredOn"}
$vms
foreach($vm in $vms)
{
if((Invoke-VMScript -VM $vm -ScriptType bat -ScriptText 'dir c:\windows\' -HostCredential $hostCred -GuestCredential $guestCred).ExitCode -eq 0)
{
    #write-host $vm.Name "password changed"
}
else
{
    write-host $vm.Name
}
}
