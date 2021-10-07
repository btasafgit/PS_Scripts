#----User Input Menu
$vcName = Read-Host "Enter vCenter Name"
$localAdminPass = Read-Host "Enter Local Administrator Password" -AsSecureString
$srvAmount = Read-Host "How Many Server would you like to deploy?"
Write-host "IP Settings"
Write-host "** The IP Addresses must be consistent and followed"
$ipPool = read-host "Specify the first IP address to be used"
#---Domain info
$username = "btasaf"
$password = ConvertTo-SecureString "1qa@WS3ed" -AsPlainText -Force
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
#---Clear Variables

Get-Variable |where {$_.Name -like "srvRDSHName*"} |Remove-Variable -ErrorAction SilentlyContinue
#Get-Variable |where {$_.Name -like "srvRDSHName*"}
Get-Variable -Name NewVMName |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name vcName |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name clusterName |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name datastoreName |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name ipAddress |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name ipSM |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name ipDG |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name DNS |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name vc |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name resourcePool |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name datastore |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name tmpl |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name domainName |Remove-Variable -ErrorAction SilentlyContinue
Get-Variable -Name localAdminPass |Remove-Variable -ErrorAction SilentlyContinue
Remove-OSCustomizationSpec "RDS-TEMP" -Confirm:$false
sleep 2
#---User Input
$NewVMNamePrefix = "MDRDSH00"
#$vcName = "md-vc" # V
$clusterName = "MDUCSTESTDEV"
$datastoreName = "dev_vmfs_ds003"
$tmplName = "MDRDSH-TMPL"
#$ipAddress = "10.1.212.14" #V
$ipSM = "255.255.255.0"
$ipDG = "10.1.212.254"
$DNS = "10.1.151.30","172.25.70.19"
$domainName = “DS-INVEST.LOCAL”
#$localAdminPass = "xhxntneunh,23~" # V
$folder = "New RDS Servers"
#---General Variables

$vc = Get-VC $vcName
$resourcePool = Get-Cluster -Server $vc -Name $clusterName
$datastore = Get-Datastore -Server $vc -Name $datastoreName
$tmpl = Get-Template -Server $vc -Name $tmplName
$vmLocation = Get-Folder $folder
#---Creating Customization Specification

$osCustSpec = New-OSCustomizationSpec -Type Persistent -OSType Windows -Server $vc -FullName "Administrator" -OrgName “Meitav Dash Investments” -Name RDS-TEMP -Domain $domainName -DomainCredentials $cred -AdminPassword $localAdminPass `
-AutoLogonCount 1 -TimeZone 135 -ChangeSid -DeleteAccounts -LicenseMaxConnections 5 -LicenseMode PerServer
$osCustSpec | Get-OSCustomizationNicMapping |Set-OSCustomizationNicMapping -Server $vc -IpMode UseStaticIp -IpAddress $ipAddress -SubnetMask $ipSM -DefaultGateway $ipDG -Dns $DNS


#---
$NewVMName.clear()
$ipAddress.clear()
$NewVMName = New-Object System.Collections.ArrayList
$ipAddress = New-Object System.Collections.ArrayList
for($i=1; $i -le $srvAmount ;$i++)
{
    $NewVMName.Add($NewVMNamePrefix+$i)
    [int32]$tmp = [int32]$ipPool.Substring($ipPool.Length-1)+$i-1
    #[int32]$tmp = $ipPool.Substring($ipPool.Length-2)+[int32]$i
    $ipAddress.Add($ipPool.Substring(0,$ipPool.Length-1)+$tmp)
}

#---

Write-Host "Will create " $NewVMName.Count "VMs with the following settings"

for($i=0; $i -lt $srvAmount ;$i++)
{
    Write-Host "VM Name: " $NewVMName[$i] "with ip address: " $ipAddress[$i]
}

#---Creating VM


New-VM -Name $NewVMName -Template $tmpl -ResourcePool $resourcePool -Datastore $datastore -OSCustomizationSpec $osCustSpec -Location $vmLocation
Start-VM -VM $NewVMName
Wait-Tools 30




