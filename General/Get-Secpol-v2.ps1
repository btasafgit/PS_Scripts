$Path = "\\ormat-ilfs01\Transfer\adori\SecPol"
$cred = (Get-Credential)

#Exports secpol files from all servers
function Get-SecpoltoFiles() {
    Param(
        [Parameter(Mandatory)]
        [String] $Path,
        [Parameter(Mandatory)]
        [ValidateSet('SECURITYPOLICY', 'USER_RIGHTS')]
        [string]$policy
    )

    $srvs = Get-ADComputer -Filter { OperatingSystem -like "*server*" -and Enabled -eq $true } -Properties DNSHostName
    if ($policy -eq "SECURITYPOLICY") {
        $command = "secedit /export /cfg $Path\Security\$env:COMPUTERNAME-SECURITYPOLICY.inf /areas SECURITYPOLICY"
    }

    if ($policy -eq "USER_RIGHTS") {
        $command = "secedit /export /cfg $Path\USER_RIGHTS\$env:COMPUTERNAME-USER_RIGHTS.inf /areas USER_RIGHTS"
    }

    foreach ($i in $srvs) {
        try{
                Invoke-Command -AsJob -ComputerName $i.DNSHostName -ScriptBlock { secedit /export /cfg \\ormat-ilfs01\Transfer\adori\SecPol\USERRIGHTS\%computername%-USER_RIGHTS.inf /areas USER_RIGHTS } -Credential $cred -ErrorAction SilentlyContinue
        }
        catch {write-host $i.DNSHostName}
    }
} #End of Secpoltofiles function

#returns a user if valid by sid
function Get-UserbySID {
    Param(
        [Parameter(Mandatory)]$SID
    )
    
    if ($obj = Get-ADUser -Filter { objectSid -eq $SID }) {
        return $obj.Name
    }
    else {
        return "SID"
    }
}



#Policy parsing

#function Start-SecurityPolicyParsing()
Param(
    [Parameter(Mandatory)]
    [String] $Path
)

$files = Get-ChildItem "\\ormat-ilfs01\Transfer\adori\SecPol\Security" -File
$c = 0
foreach ($fl in $files) {

    $obj = @()
    $Array = @()
    $file = $fl.FullName

    $content = get-content $file | select -Skip 3 | select -SkipLast 3
    foreach ($l in $content) {

        $hostname = $file.Substring($file.LastIndexOf("\") + 1, (($file.LastIndexOf("\") + 1) - $file.LastIndexOf("-")) * -1)
        $policy = $l.Substring(0, $l.IndexOf('=') - 1)
        $policyValue = $l.Substring($l.IndexOf('=') + 2)

        $PolicyName = Switch ($policy) {
            "SeTrustedCredManAccessPrivilege" { "Access Credential Manager as a trusted caller" }
            "SeNetworkLogonRight" { "Access this computer from the network" }
            "SeTcbPrivilege" { "Act as part of the operating system" }
            "SeMachineAccountPrivilege" { "Add workstations to domain" }
            "SeIncreaseQuotaPrivilege" { "Adjust memory quotas for a process" }
            "SeInteractiveLogonRight" { "Allow log on locally" }
            "SeRemoteInteractiveLogonRight" { "Allow log on through Remote Desktop Services" }
            "SeBackupPrivilege" { "Back up files and directories" }
            "SeChangeNotifyPrivilege" { "Bypass traverse checking" }
            "SeSystemtimePrivilege" { "Change the system time" }
            "SeTimeZonePrivilege" { "Change the Time Zone" }
            "SeCreatePagefilePrivilege" { "Create a pagefile" }
            "SeCreateTokenPrivilege" { "Create a token object" }
            "SeCreateGlobalPrivilege" { "Create global objects" }
            "SeCreatePermanentPrivilege" { "Create permanent shared objects" }
            "SeCreateSymbolicLinkPrivilege" { "Create Symbolic Links" }
            "SeDebugPrivilege" { "Debug programs" }
            "SeDenyNetworkLogonRight" { "Deny access to this computer from the network" }
            "SeDenyBatchLogonRight" { "Deny log on as a batch job" }
            "SeDenyServiceLogonRight" { "Deny log on as a service" }
            "SeDenyInteractiveLogonRight" { "Deny log on locally" }
            "SeDenyRemoteInteractiveLogonRight" { "Deny log on through Remote Desktop Services" }
            "SeEnableDelegationPrivilege" { "Enable computer and user accounts to be trusted for delegation" }
            "SeRemoteShutdownPrivilege" { "Force shutdown from a remote system" }
            "SeAuditPrivilege" { "Generate security audits" }
            "SeImpersonatePrivilege" { "Impersonate a client after authentication" }
            "SeIncreaseWorkingSetPrivilege" { "Increase a process working set" }
            "SeIncreaseBasePriorityPrivilege" { "Increase scheduling priority" }
            "SeLoadDriverPrivilege" { "Load and unload device drivers" }
            "SeLockMemoryPrivilege" { "Lock pages in memory" }
            "SeBatchLogonRight" { "Log on as a batch job" }
            "SeServiceLogonRight" { "Log on as a service" }
            "SeSecurityPrivilege" { "Manage auditing and security log" }
            "SeRelabelPrivilege" { "Modify an object label" }
            "SeSystemEnvironmentPrivilege" { "Modify firmware environment values" }
            "SeManageVolumePrivilege" { "Perform volume maintenance tasks" }
            "SeProfileSingleProcessPrivilege" { "Profile single process" }
            "SeSystemProfilePrivilege" { "Profile system performance" }
            "SeUndockPrivilege" { "Remove computer from docking station" }
            "SeAssignPrimaryTokenPrivilege"	{ "Replace a process level token" }
            "SeRestorePrivilege" { "Restore files and directories" }
            "SeShutdownPrivilege" { "Shut down the system" }
            "SeSyncAgentPrivilege" { "Synchronize directory service data" }
            "SeTakeOwnershipPrivilege" { "Take ownership of files or other objects" }
        }


        $obj += New-Object -TypeName PSObject -Property @{
            "PolName" = $PolicyName
            $hostname = $policyValue
        }

    }
    if ($c -eq 0) {
        $obj | sort PolName | select PolName | export-csv c:\abt\SecPol-t2.csv -NoTypeInformation -Encoding UTF8 -Append
        #$Array += $obj |sort PolName |select PolName |export-csv c:\abt\SecPol-t2.csv -NoTypeInformation -Encoding UTF8 -Append
    }
    else {
        $obj | sort PolName | select $hostname | export-csv c:\abt\SecPol-t2.csv -NoTypeInformation -Encoding UTF8 -Append
        #$Array += $obj |sort PolName |select $hostname |export-csv c:\abt\SecPol-t2.csv -NoTypeInformation -Encoding UTF8 -Append
    }

    $c++
}


$Array | export-csv c:\abt\SecPol-t2.csv -NoTypeInformation -Encoding UTF8 -Append
# TESTing Zone##################################################
Get-SecpoltoFiles -Path $Path -policy USER_RIGHTS