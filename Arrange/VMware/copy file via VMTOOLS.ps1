Connect-VIServer md-vc
$username = "administrator"
$password = $password = ConvertTo-SecureString "xhxntneunh,23~" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password


$hostUser = "root"
$hostPass = $hostPass = ConvertTo-SecureString "W!neRoad87" -AsPlainText -Force
$hostCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $hostUser, $hostPass

$vm = "VMNAME"

#Copy Source
$fileFrom = "\\na01\install\GnuPG\gpg4win-2.3.3.exe"
#Copy Destination
$fileTo = "C:\temp\"


Copy-VMGuestFile -Source $fileFrom -Destination $fileTo -VM $vm -LocalToGuest -GuestCredential $cred -Force -Verbose