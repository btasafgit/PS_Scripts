
# Function to translates SID to account name ---------------------
function Get-AccountName {
    param(
      [String] $principal
    )
    If ( $principal[0] -eq "*" ) 
    {
      $SIDName = $principal.Substring(1)
      $sid = New-Object System.Security.Principal.SecurityIdentifier($SIDName)
      $sid.Translate([Security.Principal.NTAccount])
    }
    Else
    {
      Return $principal
    }
  }
# -----------------------------------------------------------------


<#
# Parameters
$Servers = get-adcomputer -Filter * -Properties * -SearchBase "OU=Ormat_Servers,DC=ORMAT,DC=com" 
$Cred = Get-Credential
$tmpPath = "\\ormat.com\ormat\Transfer\adori\SecPol\Security"
$ErrorActionPreference = "SilentlyContinue"


# Looping server
Foreach( $Server in $Servers )
{
  $ttt = $Server.DNSHostName
  # Query server for Security Policy
  Invoke-Command -ComputerName $ttt -Credential $cred -ScriptBlock {secedit.exe /export /areas SECURITYPOLICY /cfg C:\sec-$env:computername.txt}
  Move-item -Confirm:$false "\\$ttt\c$\sec-*" "\\ormat-ilfs01\Transfer\adori\SecPol\Security\"
}

Foreach( $Server in $Servers )
{
  $ttt = $Server.DNSHostName
  # Query server to check User rights
  Invoke-Command -ComputerName $ttt -Credential $cred -ScriptBlock {secedit.exe /export /areas USER_RIGHTS /cfg C:\UR-$env:computername.txt}
  Move-item -Confirm:$false "\\$ttt\c$\UR-*" "\\ormat.com\ormat\Transfer\adori\SecPol\USERRIGHTS\"
}


#>




#file Processing
$files = Get-childItem "\\ormat.com\ormat\Transfer\adori\SecPol\USERRIGHTS"

$obj = @()
foreach($file in $files) {
$content = get-content $file.FullName |Select-Object -Skip 3 | Select-Object -SkipLast 3
$srvName = ($file.Name).substring(3,$file.Name.indexof(".")-3) #server Name from Filename


foreach($line in $content){
  
  $ln = $line.split("=") #Splits line to Setting and Value array
  $PolicyName = $ln[0].trim()
  $PolValue = (($ln[1].trim()).split(',') -replace ‘[*]’) -join ","
  
  $head = Switch ($PolicyName){
    "SeTrustedCredManAccessPrivilege" {"Access Credential Manager as a trusted caller"} 
    "SeNetworkLogonRight" {"Access this computer from the network"} #
    "SeTcbPrivilege" {"Act as part of the operating system"} #
    "SeMachineAccountPrivilege" {"Add workstations to domain"} #
    "SeIncreaseQuotaPrivilege" {"Adjust memory quotas for a process"} #
    "SeInteractiveLogonRight" {"Allow log on locally"} #
    "SeRemoteInteractiveLogonRight" {"Allow log on through Remote Desktop Services"} #
    "SeBackupPrivilege" {"Back up files and directories"} #
    "SeChangeNotifyPrivilege" {"Bypass traverse checking"} #
    "SeSystemtimePrivilege" {"Change the system time"} #
    "SeTimeZonePrivilege" {"Change the Time Zone"} #
    "SeCreatePagefilePrivilege" {"Create a pagefile"} #
    "SeCreateTokenPrivilege" {"Create a token object"} #
    "SeCreateGlobalPrivilege" {"Create global objects"} #
    "SeCreatePermanentPrivilege" {"Create permanent shared objects"}
    "SeCreateSymbolicLinkPrivilege"{"Create Symbolic Links"} #
    "SeDebugPrivilege" {"Debug programs"} #
    "SeDenyNetworkLogonRight" {"Deny access to this computer from the network"} #
    "SeDenyBatchLogonRight" {"Deny log on as a batch job"} #
    "SeDenyServiceLogonRight" {"Deny log on as a service"} 
    "SeDenyInteractiveLogonRight" {"Deny log on locally"} #
    "SeDenyRemoteInteractiveLogonRight" {"Deny log on through Remote Desktop Services"} #
    "SeEnableDelegationPrivilege" {"Enable computer and user accounts to be trusted for delegation"}
    "SeRemoteShutdownPrivilege" {"Force shutdown from a remote system"} #
    "SeAuditPrivilege" {"Generate security audits"} #
    "SeImpersonatePrivilege" {"Impersonate a client after authentication"} #
    "SeIncreaseWorkingSetPrivilege" {"Increase a process working set"} #
    "SeIncreaseBasePriorityPrivilege" {"Increase scheduling priority"} #
    "SeLoadDriverPrivilege" {"Load and unload device drivers"} #
    "SeLockMemoryPrivilege" {"Lock pages in memory"} #
    "SeBatchLogonRight" {"Log on as a batch job"} #
    "SeServiceLogonRight" {"Log on as a service"} #
    "SeSecurityPrivilege" {"Manage auditing and security log"} #
    "SeRelabelPrivilege" {"Modify an object label"}
    "SeSystemEnvironmentPrivilege" {"Modify firmware environment values"} #
    "SeManageVolumePrivilege" {"Perform volume maintenance tasks"} #
    "SeProfileSingleProcessPrivilege" {"Profile single process"} #
    "SeSystemProfilePrivilege" {"Profile system performance"} #
    "SeUndockPrivilege" {"Remove computer from docking station"} #
    "SeAssignPrimaryTokenPrivilege"	{"Replace a process level token"} #
    "SeRestorePrivilege" {"Restore files and directories"} #
    "SeShutdownPrivilege" {"Shut down the system"} #
    "SeSyncAgentPrivilege" {"Synchronize directory service data"}
    "SeTakeOwnershipPrivilege" {"Take ownership of files or other objects"} #

    }


    #each server name and values creates another column
    
      $obj += New-Object -TypeName PSCustomObject -Property @{
            "Setting"= $head
            "Server Name" = $srvName
            "PolValue" = $PolValue
            } #end of New Object
          #>

    }#end of Foreach Line in file
  } #end of foreach file

$obj  | export-csv c:\abt\UR-out.csv -Encoding UTF8 -NoTypeInformation -Append
Clear-Variable head -force 
Clear-Variable obj -force
Clear-Variable tmpArr -Force




# SID Parsing
foreach($s in $SID){
  $object = New-Object System.Security.Principal.SecurityIdentifier (“$s”)
try{$result = $object.Translate([System.Security.Principal.NTAccount])
$s +"="+ $result.Value
}
catch{}
}



function Get-Secpol($compName){
  #The function is running on the remote computer

  #Validate if folder structure exists and creates it if not
  Invoke-Command -computerName $compName -ScriptBlock {
    if(-not(Test-Path c:\Secpol\Security)) {New-Item -ItemType Directory -Name "Secpol\Security" -Path c:\}
    if(-not(Test-Path c:\Secpol\UserRights)) {New-Item -ItemType Directory -Name "Secpol\UserRights" -Path c:\}
    

    #Export Security Settings
    if(Test-Path C:\Secpol\Security\sec-$env:computername.txt){
      Rename-Item C:\Secpol\Security\sec-$env:computername.txt -NewName C:\Secpol\Security\sec-$env:computername.bkp
    }
    else {
      secedit.exe /export /areas SECURITYPOLICY /cfg C:\Secpol\Security\sec-$env:computername.txt
    }
    #Export USer Rights
    if(Test-Path C:\Secpol\UserRights\UR-$env:computername.txt){
      Rename-Item C:\Secpol\UserRights\UR-$env:computername.txt -NewName C:\Secpol\UserRights\UR-$env:computername.bkp
    }
    else {
      secedit.exe /export /areas USER_RIGHTS /cfg C:\Secpol\UserRights\UR-$env:computername.txt
    }
  } 
}

function Remove-SecpolURValue($compName,$propertyName,$SID){
  # compName = Computername
  #propertyname = security setting to work on
  # SID = the SID to remove
  $propertyName = $propertyName+" = "
  $newURFile = "\\$compName\C$\Secpol\UserRights\UR-$compName-New.cfg"
  $URFile = Get-Content "\\$compName\C$\Secpol\UserRights\UR-$compName.txt"
  [string]$line = $URFile -match $propertyName
  [string]$newLine = $line -replace "[*]$SID,",''
  $URFile.replace($line,$newLine) |set-content $newURFile
}

function Add-SecpolURValue($compName,$propertyName,$SID){
  # compName = Computername
  #propertyname = security setting to work on
  # SID = the SID to remove
  $propertyName = $propertyName+" = "
  $newURFile = "\\$compName\C$\Secpol\UserRights\UR-$compName-New.cfg"
  $URFile = Get-Content "\\$compName\C$\Secpol\UserRights\UR-$compName.txt"
  [string]$line = $URFile -match $propertyName
  [string]$newLine = $line+",*$SID"
  $URFile.replace($line,$newLine) |set-content $newURFile
}

function Set-NewSecpolUR($compName){
  Invoke-Command -computerName $compName -ScriptBlock {
    SecEdit.exe /configure /db c:\windows\security\local.sdb /cfg "C:\Secpol\UserRights\UR-$env:computername-New.cfg" /areas USER_RIGHTS
  }
}

function Cleanup($compName){
  Remove-Item "\\$compName\C$\Secpol\UserRights\*.txt"
  Remove-Item "\\$compName\C$\Secpol\Security\*.txt"
}
###############################################################
#          END User Rights Policy
###############################################################


###############################################################
#Main for User Rights Policy
###############################################################

$comps =  @("SAPSFCC01")
foreach($i in $comps){


  $compName = $i
  
Get-Secpol $compName
#remove Users group
Remove-SecpolURValue -compName $compName -propertyName "SeChangeNotifyPrivilege" -SID "S-1-5-32-545"
Set-NewSecpolUR -compName $compName
sleep 3
Cleanup -compName $compName
sleep 2

#Remove Everyone group
Get-Secpol $compName
Remove-SecpolURValue -compName $compName -propertyName "SeChangeNotifyPrivilege" -SID "S-1-1-0"
Set-NewSecpolUR -compName $compName
sleep 3
Cleanup -compName $compName
sleep 2

#Add Auth Users
Get-Secpol $compName
Add-SecpolURValue -compName $compName -propertyName "SeChangeNotifyPrivilege" -SID "S-1-5-11"
Set-NewSecpolUR -compName $compName
sleep 3
Cleanup -compName $compName
sleep 2
}



###############################################################
#Main for Security Policy
###############################################################



#function (){}
function Get-SecpolSec($compName,$propertyName){

  $propertyName = $propertyName+" = "
  $newURFile = "\\$compName\C$\Secpol\UserRights\UR-$compName-New.cfg"
  $URFile = Get-Content "\\$compName\C$\Secpol\UserRights\UR-$compName.txt"
  [string]$line = $URFile -match $propertyName
  [string]$newLine = $line -replace "[*]$SID,",''
  $URFile.replace($line,$newLine) |set-content $newURFile
}

