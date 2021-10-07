while((Get-WmiObject -Class win32_process | Where-Object name -Match explorer).getowner().user -ne $a)
{
Write-Host (Get-WmiObject -Class win32_process | Where-Object name -Match explorer).getowner().user
}




$TargetName = “LLION-P1”
$RC = Get-WinEvent -Computer $TargetName -FilterHashtable @{ Logname = ‘Security’; ID = 4672 } -MaxEvents 250 | Select @{ N = ‘User’; E = { $_.Properties[1].Value } }, TimeCreated
$RC |Where-Object {$_.User -ne "SYSTEM" -and $_.User -notlike "*$"}


enter-pssession $TargetName
& 'C:\users\adori\OneDrive - Ormat\desktop\PsExec.exe' \\LLION-P1 cmd

