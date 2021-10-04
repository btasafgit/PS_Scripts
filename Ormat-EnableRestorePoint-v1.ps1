# Variables
$drv = "C:\"
$date = get-date
$d = $date.ToShortDateString() + " " + $date.ToShortTimeString()
$log = @()
$logOut = "C:\support\SRLog.log"


# Enable System restore + prechecking and set SRP disk reservation
try {
    $isSREnabled = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\" -Name RPSessionInterval -Verbose -ErrorAction stop -ErrorVariable +log
}
catch {
    Out-File -InputObject $log[0].Message -FilePath $logOut -Append
}
<#Enabled = 1, Disabled = 0#>
try {
    if ($isSREnabled.RPSessionInterval -eq 0) {
        Enable-ComputerRestore -Drive $drv -Verbose -ErrorAction stop -ErrorVariable +log
        C:\Windows\System32\vssadmin Resize ShadowStorage /On=C: /For=C: /MaxSize=4%
    }
}
catch {
    Out-File -InputObject $log[$log.length - 1].Message -FilePath $logOut -Append
}
# create First restore point
<# Morning System Restore point#>
try {
    if ($date.Hour -lt 12) {
        Checkpoint-Computer -Description "[Morning] System Restore $d" -RestorePointType APPLICATION_INSTALL
    }
    <# Noon System Restore point#>
    if ($date.Hour -eq 12) {
        Checkpoint-Computer -Description "[Noon] Noon System Restore $d" -RestorePointType APPLICATION_INSTALL -Verbose
    }
    <# After Noon System Restore point#>
    if ($date.Hour -gt 12) {
        Checkpoint-Computer -Description "[Evening] Evening System Restore $d" -RestorePointType APPLICATION_INSTALL -Verbose
    }
}
catch {
    Out-File -InputObject $log[0].Message -FilePath $logOut -Append
}
