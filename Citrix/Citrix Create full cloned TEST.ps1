# https://support.citrix.com/article/CTX224040
Add-PSSnapIn citrix*

# Create an GoldenImage with a single snapshot named "Base"
# Base / Gold image must be in Ormat-Prod > Citrix Apps (Resource Group)

# GET
Get-BrokerCatalog |select Name
Get-AcctIdentityPool |select IdentityPoolName
Get-ProvScheme |select ProvisioningSchemeName,IdentityPoolName,MasterImageVM


#1
$IddPoolName = "Ormat IDP Business Apps Full Clone - Test"
$IddPoolDoamin = "ORMAT.COM"
$IddPoolNamingSchemeType = "Numeric"
$IddPoolNamingScheme = "ORMCTXAPPT0#"
$IddPoolOU = "OU=Xenapp 2019,OU=Citrix,OU=Ormat_Servers,DC=ORMAT,DC=com"
New-AcctIdentityPool -Domain $IddPoolDoamin -IdentityPoolName $IddPoolName -NamingSchemeType $IddPoolNamingSchemeType -NamingScheme $IddPoolNamingScheme -OU $IddPoolOU

#2
$ProvSchemName = "Ormat ProvScheme Business Apps Full Clone - Test"
$ProvSchemCPU = 4
$ProvSchemMem = 16384
$ProvSchemHostingUnit = "CTX_Net_vlan50"
$ProvSchemGI = "ORMCTXAPPBASE-T"
$ProvSchemMasterImage = "XDHyp:\HostingUnits\$ProvSchemHostingUnit\$ProvSchemGI.vm\Base.snapshot"
New-ProvScheme -IdentityPoolName $IddPoolName -ProvisioningSchemeName $ProvSchemName -Scope @() -VMCpuCount $ProvSchemCPU -VMMemoryMB $ProvSchemMem `
-HostingUnitName $ProvSchemHostingUnit -UseFullDiskCloneProvisioning -MasterImageVM $ProvSchemMasterImage -InitialBatchSizeHint 1 -Verbose
Sleep 3

#3
Publish-ProvMasterVmImage -ProvisioningSchemeName $ProvSchemName -MasterImageVM $ProvSchemMasterImage -Verbose

#4
$BrokCataName = "Ormat Broker Business Apps Full Clone - Test"
$BrokCataDesc = "New vm catalog with Full cloned vms"
New-BrokerCatalog -Name $BrokCataName -AllocationType Random -Description $BrokCataDesc -ProvisioningType MCS -SessionSupport MultiSession -PersistUserChanges Discard
Get-BrokerCatalog $BrokCataName |Set-BrokerCatalog -MinimumFunctionalLevel L7_20 -ProvisioningSchemeId ((Get-ProvScheme -ProvisioningSchemeName $ProvSchemName).ProvisioningSchemeUid).Guid


