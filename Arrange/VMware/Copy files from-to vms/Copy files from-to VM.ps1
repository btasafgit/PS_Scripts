
Connect-VIServer md-vc
$hostUser = "root"
$hostPass = ConvertTo-SecureString "W!neRoad87" -AsPlainText -Force
$hostCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $hostUser, $hostPass


$guestUser = "administrator"
$guestPass = ConvertTo-SecureString 'xhxntneunh,23~' -AsPlainText -Force
$guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass


$vm = Get-VM WEBDCA01  -Server md-vc

$fileFrom = "C:\Users\btasaf\Desktop\msvcr71.dll"
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
