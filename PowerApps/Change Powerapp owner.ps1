Construction Report test

Step 1: Get the Owner Guid
Nschmal@ORMAT.COM = b8c1a565-8b5c-48a6-a6d8-d509afe70993
Arevach@ORMAT.COM = 90bffaf3-e0c4-4261-aa46-b0b5c2e8a108
Apacker@ORMAT.COM = 97496811-1594-4d20-97fa-6e39e9c6f89c

Step 2: 
$AppName = "Construction Report"
Get-AdminPowerAppEnvironment |where {$_.EnvironmentType -eq "Default"} |Get-AdminPowerApp |where {$_.DisplayName -like $AppName}

$owner = "b8c1a565-8b5c-48a6-a6d8-d509afe70993"
Get-AdminPowerAppEnvironment |where {$_.EnvironmentType -eq "Default"} |Get-AdminPowerApp |where {$_.DisplayName -like $AppName} |Set-AdminPowerAppOwner -AppOwner $owner

<#Get a specific flow#>
get-AdminFlowOwnerRole -EnvironmentName Default-dc2405bc-2600-477d-8b8e-3994f5b537a3 -FlowName ba41cd65-a8d3-4f42-a692-9f8755b8bdb2

<#Set the above Flow a new owner#>
Set-AdminFlowOwnerRole -PrincipalType User -PrincipalObjectId b8c1a565-8b5c-48a6-a6d8-d509afe70993 -RoleName CanEdit -FlowName ba41cd65-a8d3-4f42-a692-9f8755b8bdb2 -EnvironmentName Default-dc2405bc-2600-477d-8b8e-3994f5b537a3

<#Get a list of all flows nested under the same PowerApp with a specific Owner#>
Get-AdminPowerAppEnvironment |where {$_.EnvironmentType -eq "Default"} |Get-AdminPowerApp |where {$_.DisplayName -like "Construction Report - Dev"} |Get-AdminFlow |where {$_.CreatedBy -match "97496811-1594-4d20-97fa-6e39e9c6f89c"}

<#Get all flows nested under the same Powerapp that mach specific owner#>
$AppName = "Construction Report"
$oldOwner = "97496811-1594-4d20-97fa-6e39e9c6f89c"
Get-AdminPowerAppEnvironment |where {$_.EnvironmentType -eq "Default"} |Get-AdminPowerApp |where {$_.DisplayName -like $AppName} |Get-AdminFlow |where {$_.CreatedBy -match $oldOwner}

<#Set all flows nested under the same Powerapp that mach specific owner and replace the owner for all flows#>
$AppName = "Construction Report"
$oldOwner = "97496811-1594-4d20-97fa-6e39e9c6f89c"
$newOwner = "b8c1a565-8b5c-48a6-a6d8-d509afe70993"
Get-AdminPowerAppEnvironment |where {$_.EnvironmentType -eq "Default"} |Get-AdminPowerApp |where {$_.DisplayName -like $AppName} |Get-AdminFlow |where {$_.CreatedBy -match $oldOwner} |Set-AdminFlowOwnerRole -PrincipalType User -PrincipalObjectId $newOwner -RoleName CanEdit -EnvironmentName Default-dc2405bc-2600-477d-8b8e-3994f5b537a3

get-AdminFlowOwnerRole -EnvironmentName Default-dc2405bc-2600-477d-8b8e-3994f5b537a3 -FlowName 37f2fc18-4c5a-4419-acf2-46530375e9cc
Set-AdminFlowOwnerRole -PrincipalType User -PrincipalObjectId b8c1a565-8b5c-48a6-a6d8-d509afe70993 -RoleName CanEdit -FlowName 390a42f1-c9c1-46b7-9750-d39bf3f73d3e -EnvironmentName Default-dc2405bc-2600-477d-8b8e-3994f5b537a3