$vc = "Ormat-VC.ormat.com"
$templateName = 'Windows Server 2019 Standard'
$GuestCustomizationPolicy = "Servers Join Domain - IL"
$VMnic = "NET_Prod_10_App"
$VMSM = "255.255.255.0"
$VMDG = "10.15.10.254"
$VMDNS = @("10.10.1.201","10.10.1.202")
$resourcePool = "Ormat Citrix"
$folderLocation = "Production Environment"
$folderName = "New"


$vmName = @(
"ORMCTXDDC01",
"ORMCTXDDC02",
"ORMCTXSF01",
"ORMCTXSF02",
"ORMCTXAPPS01",
"ORMCTXCON01"
)

$VMIP = @(
"10.15.10.22",
"10.15.10.23",
"10.15.10.24",
"10.15.10.25",
"10.15.10.26",
"10.15.10.27"
)


for($i=0; $i -le $vmName.Length-1 ;$i++){
$vm = $vmName[$i]
$ip = $VMIP[$i]

$OSSpecs = Get-OSCustomizationSpec -Name $GuestCustomizationPolicy -Server $vc
$VMTemplate = Get-Template -Name $templateName -Server $vc
$vmFolder = Get-Folder -Name $folderName -Location $folderLocation -Server $vc
$res = Get-ResourcePool -Server $vc -Name $resourcePool

Get-OSCustomizationSpec $GuestCustomizationPolicy -Server $vc | `
Get-OSCustomizationNicMapping -Server $vc | Set-OSCustomizationNicMapping -Server $vc -IpMode UseStaticIP -IpAddress $ip -SubnetMask $VMSM -DefaultGateway $VMDG -Dns $VMDNS[0],$VMDNS[1]


function Get-NextFreeDatastore(){
    $vc = "Ormat-VC.ormat.com"
    $dss = Get-Datastore -Name "HDS-DS*" -Server $vc
    $tmp = @()
    foreach($ds in $dss){
        $tmp += New-Object -TypeName PSCustomObject -Property @{
        "DSName" = $ds.Name
        "DSID" = $ds.Id
        "PrecentFree" = ($ds.FreeSpaceGB/$ds.CapacityGB).ToString("P")
            }
    }

    return $tmp |sort PrecentFree |select -last 1
}

#Clone VM from template
New-VM -Name $vm -Template $VMTemplate -ResourcePool $res -OSCustomizationSpec $OSSpecs -Location $vmFolder -Datastore (Get-NextFreeDatastore).DSName -Server $vc
$task = (Get-Task |where {$_.State -eq "Running" -and $_.Name -eq "CloneVM_Task"})
Start-Sleep 2
$task
while(-not(Get-Task -Id $task.Id).State -eq "Success"){

Start-Sleep 10

Get-VM $vm -Server $vc | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $VMnic -Confirm:$false -Server $vc
Start-Sleep 10

Start-VM $vm
}

sleep 100

}

foreach($i in $vmName){
Get-VM $i -Server $vc | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $VMnic -Confirm:$false -Server $vc
}


foreach($i in $vmName){
Start-VM $i
}
# Clear vars
Clear-Variable OSSpecs -Force
Clear-Variable VMTemplate -Force
Clear-Variable vmFolder -Force
Clear-Variable VMnic -Force
Clear-Variable VMIP -Force
Clear-Variable VMSM -Force
Clear-Variable VMDG -Force
Clear-Variable VMDNS -Force
Clear-Variable resourcePool -Force
Clear-Variable res -Force
Clear-Variable vmName -Force
