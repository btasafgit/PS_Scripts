$a = Get-WinEvent -Computer $TargetName -FilterHashtable @{ Logname = ‘Security’; ID = 4624 } -MaxEvents 5 | Select @{ N = ‘User’; E = { $_.Properties[1].Value } }, TimeCreated

$event = Get-WinEvent -FilterHashtable @{ Logname = ‘Security’; ID = 4624 } -MaxEvents 1
[xml]$xmlEvent = $event.ToXml()