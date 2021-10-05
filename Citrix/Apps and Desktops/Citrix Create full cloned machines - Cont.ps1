Add-PSSnapIn citrix*

#create an GoldenImage with a single snapshot named "Base"

# GET
Get-BrokerCatalog |select Name
Get-AcctIdentityPool |select IdentityPoolName
Get-ProvScheme |select ProvisioningSchemeName,IdentityPoolName,MasterImageVM


#1
$IddPoolName = "IDP Contractors Full Clone"
$IddPoolDoamin = "DOMAIN.COM"
$IddPoolNamingSchemeType = "Numeric"
$IddPoolNamingScheme = "CTXCON0##"
$IddPoolOU = ""
New-AcctIdentityPool -Domain $IddPoolDoamin -IdentityPoolName $IddPoolName -NamingSchemeType $IddPoolNamingSchemeType -NamingScheme $IddPoolNamingScheme -OU $IddPoolOU

#2
$ProvSchemName = "ProvScheme Contractors Full Clone"
$ProvSchemCPU = 4
$ProvSchemMem = 16384
$ProvSchemHostingUnit = "CTX_Net_vlan50"
$ProvSchemGI = "CTXCONBASE"
$ProvSchemMasterImage = "XDHyp:\HostingUnits\$ProvSchemHostingUnit\$ProvSchemGI.vm\Base.snapshot"
New-ProvScheme -IdentityPoolName $IddPoolName -ProvisioningSchemeName $ProvSchemName -Scope @() -VMCpuCount $ProvSchemCPU -VMMemoryMB $ProvSchemMem `
-HostingUnitName $ProvSchemHostingUnit -UseFullDiskCloneProvisioning -MasterImageVM $ProvSchemMasterImage -InitialBatchSizeHint 1 -Verbose
Sleep 3
Publish-ProvMasterVmImage -ProvisioningSchemeName $ProvSchemName -MasterImageVM $ProvSchemMasterImage -Verbose

#4
$BrokCataName = "Broker Contractors Full Clone"
$BrokCataDesc = "New vm catalog with Full cloned vms - Contractors"
New-BrokerCatalog -Name $BrokCataName -AllocationType Random -Description $BrokCataDesc -ProvisioningType MCS -SessionSupport MultiSession -PersistUserChanges Discard
Get-BrokerCatalog $BrokCataName |Set-BrokerCatalog -MinimumFunctionalLevel L7_20 -ProvisioningSchemeId ((Get-ProvScheme -ProvisioningSchemeName $ProvSchemName).ProvisioningSchemeUid).Guid