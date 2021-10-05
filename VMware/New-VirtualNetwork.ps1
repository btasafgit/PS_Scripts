
$netVlanID = 72
$netName = "NET_Prod_72_SF"
$netVswitch = "vSwitch0"
$vCenter = "ormat-vc.ormat.com"


Get-VMHost -Server $vCenter | Get-VirtualSwitch -Server $vCenter -Standard -Name $netVswitch | `
New-VirtualPortGroup -VLanId $netVlanID -Name $netName -Server $vCenter