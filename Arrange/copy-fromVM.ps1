$hostUser = "root"
$hostPass = ConvertTo-SecureString "W!neRoad87" -AsPlainText -Force
$hostCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $hostUser, $hostPass

$guestUser = "administrator"
$guestPass = ConvertTo-SecureString '$y$temP@ssw0rd2017!' -AsPlainText -Force
#$guestPass = ConvertTo-SecureString 'P1kach0023~' -AsPlainText -Force
#$guestPass = ConvertTo-SecureString 'xhxntneunh,23~' -AsPlainText -Force
$guestCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $guestUser, $guestPass

$fileFrom = "C:\1.ISO"
$fileTo = "C:\Users\btasaf.DS-INVEST\Desktop\"

$vm = get-VM SBREMAPP001 -Server md-vc
Copy-VMGuestFile -Source $fileFrom -Destination $fileTo -VM $vm -GuestToLocal -GuestCredential $guestCred -Force -Verbose
