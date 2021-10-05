$vc = "Ormat-VC.ormat.com"
$GuestCustomizationPolicy = "Servers Join Domain - IL"
$VMnic = "NET_Prod_10_App"
$VMIP = "10.15.10.22"
$VMSM = "255.255.255.0"
$VMDG = "10.15.10.254"
$VMDNS = @("10.10.1.201","10.10.1.202")
$resourcePool = "Ormat Citrix"

$vmName = @("ORMCTXDDC02",
"ORMCTXSF02",
"ORMCTXAPPS01",
"ORMCTXAPPS02",
"ORMCTXAPPS03",
"ORMCTXCON01",
"ORMCTXCON02"
)
$vm = $vmName[0]

$OSSpecs = Get-OSCustomizationSpec -Name $GuestCustomizationPolicy -Server $vc
$VMTemplate = Get-Template -Name 'Windows Server 2019 Standard' -Server $vc
$vmFolder = Get-Folder -Id Folder-group-v129567 -Server $vc
$res = Get-ResourcePool -Server $vc -Name $resourcePool



Get-OSCustomizationSpec $GuestCustomizationPolicy -Server $vc | `
Get-OSCustomizationNicMapping -Server $vc | Set-OSCustomizationNicMapping -Server $vc -IpMode UseStaticIP -IpAddress $VMIP -SubnetMask $VMSM -DefaultGateway $VMDG -Dns $VMDNS[0],$VMDNS[1]


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
New-VM -Name $vm -Template $VMTemplate -ResourcePool $res -OSCustomizationSpec $OSSpecs -Location $vmFolder -Datastore (Get-FreeestDatastore).DSName -Server $vc
$task = (Get-Task |where {$_.State -eq "Running" -and $_.Name -eq "CloneVM_Task"})
Start-Sleep 2

while(-not(Get-Task -Id $task.Id).State -eq "Success"){

Start-Sleep 5
Get-VM $vm -Server $vc | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $VMnic -Confirm:$false -Server $vc
Start-Sleep 2

Start-VM $vm
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
