
foreach($DC in $DCs){
write-host $DC.DNSHostName
Invoke-Command -ComputerName $DC.DNShostname -ScriptBlock {Get-SmbServerConfiguration | Select EnableSMB2Protocol,PSComputerName}
}


Invoke-Command -ComputerName ORMAT-OMS4.ormat.com -ScriptBlock {Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters}

$command = Get-Item HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters | ForEach-Object {Get-ItemProperty $_.pspath}
Invoke-Command -ComputerName ORMAT-OMS4.ormat.com -ScriptBlock {sc.exe qc LanmanServer}



get-mailbox "Conf-Yavne-ERP-Steamboat *" | Get-CalendarProcessing |fl AllBookInPolicy,AllRequestInPolicy,BookInPolicy
get-mailbox "Conf-Yavne-Steamboat (18)" | Set-CalendarProcessing -AllBookInPolicy:$false -AllRequestInPolicy:$false -BookInPolicy:$group.PrimarySmtpAddress -AutomateProcessing AutoAccept

Get-Mailbox "Conf-Yavne-Steamboat (18)"
get-DistributionGroup "Room-Allow-Book-IL ERP Steamboat"
$group = get-DistributionGroup "Room-Allow-Book-IL ERP Steamboat"
$members = @()
$members += "adori@ormat.com"
$members = $members | Get-Mailbox
Add-DistributionGroupMember -Identity $group.Alias -Members $members -BypassSecurityGroupManagerCheck:$true
Set-CalendarProcessing -Identity "Conf-Yavne-Steamboat (18)" -AutomateProcessing AutoAccept -BookInPolicy "adori@ormat.com" -AllBookInPolicy $false
