$username = "administrator"
$password = $password = ConvertTo-SecureString "xhxntneunh,23~" -AsPlainText -Force

$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
$vm = Get-VM -Name webmrap01-revert


$fileFrom = "c:\web\site\ws3\_sites\meitav\files\tofos_gemel"
#$fileFrom = "c:\web\site\ws3\_sites\meitav\files\uplode"

$fileTo = "C:\ABT\FromWebmrap01\"

Copy-VMGuestFile -Source $fileFrom -Destination $fileTo -VM $vm -GuestToLocal -HostUser root -HostPassword W!neRoad87 -Force

#Copy-VMGuestFile -Source $fileFrom -Destination $fileTo -VM $vm -GuestToLocal -HostUser root -HostPassword W!neRoad87 -GuestCredential $cred -Force -WhatIf