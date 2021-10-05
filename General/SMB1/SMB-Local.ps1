<# Set SMB1 to disable
To Run as a task schedulaer on computers#>
#Doc
(get-date).DateTime >> c:\support\SMB.log
$env:COMPUTERNAME >> c:\support\SMB.log
(Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" DependOnService).DependOnService >> c:\support\SMB.log
(Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1).SMB1 >> c:\support\SMB.log
(Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\mrxsmb10" Start).Start >> c:\support\SMB.log
#Disable SMB1 - Local script

#Disable SMB1
$a = @("Bowser", "MRxSmb20", "NSI")
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" -Name DependOnService -Value $a
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name SMB1 -Value 0
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\services\mrxsmb10" -Name Start -Value 4



$a = @("Bowser", "MRxSmb20", "NSI")
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation" -Name DependOnService -Value $a
