$vc = "ormat-vc.ormat.com"
Connect-VIServer $vc
$hostUser = "root"
$hostPass = ConvertTo-SecureString "1q2w3e4R" -AsPlainText -Force
$hostCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $hostUser, $hostPass


$guestUser = "administrator"
$guestPass = ConvertTo-SecureString 'Meteor@' -AsPlainText -Force
$guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass


$vm = Get-VM Ormat-Meteor -Server $vc

$fileFrom = "C:\ABT\Digi-Driver-XP.exe"
$fileTo = "C:\"
Copy-VMGuestFile -Source $fileFrom -Destination $fileTo -VM $vm -LocalToGuest -GuestCredential $guestCred -Force

#######################################################################################################################
#Start-Sleep 10
$guestUser = "administrator"
$guestPass = ConvertTo-SecureString '$y$temP@ssw0rd2017!' -AsPlainText -Force
#$guestPass = ConvertTo-SecureString 'xhxntneunh,23~' -AsPlainText -Force
$guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass

$fileFrom = "C:\Users\administrator\desktop\"
$fileTo = "C:\ABT\"

$vm = get-VM MTV-WS -Server md-vc
Copy-VMGuestFile -Source $fileFrom -Destination $fileTo -VM $vm -GuestToLocal -GuestCredential $guestCred -Force -Verbose
