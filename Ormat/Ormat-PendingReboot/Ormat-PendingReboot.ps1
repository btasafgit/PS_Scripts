Import-Module .\Ormat-GetAllServers.psm1

#Notes
<#
This script checks through a list of computers to report via email
whether any computers are in a "Reboot Pending" state.

Last update: 07/01/2019
#>

$timer = [System.Diagnostics.Stopwatch]::StartNew()
#Email Variables
$smtpServer = "ormat-mbx.ormat.com"
$smtpFrom = "Reboot Pending Report <Reboot.Pending@Ormat.com>"
$smtpTo = "adori@ORMAT.COM"
$Subject = "Reboot Pending report"
$date = get-date

$ErrorLog = New-Item -Name ErrorLog.txt -ItemType File -Force

$srvList = Ormat-GetAllServers
$CommaList = $srvList
$srvError = @()


<# Server list Table#>
#Table Style
$style = "<style>BODY{font-family: Calibri; font-size: 10pt;}"
$style = $style + "TABLE{border: 0px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 0px solid black; background: #f7f7f7; padding: 5px; }"
$style = $style + "TD{border: 0px solid black; padding: 5px; }"
$style = $style + "</style>"
$THstyle = "font-size:16pt;font-weight:bold;"
$TDstyle = "font-weight:bold;text-align:center;"

#Clean Start 
$Checks = ("WUboot,WUVal,PakBoot,PakVal,PakWowBoot,PakWowVal,RenFileBoot,PCnameBoot,CBSboot,CBSVal,Content")
$Clear = $Checks.split(",")


#Table header row
$Content =""
$Content += "<p>$date</p>"
$Content += "<table id=""t1"">"
$Content += "<tr bgcolor=#ADD8E6>"
$Content += "<td width=100 style=$THstyle>Server</td>"
$Content += "<td width=75 style=$TDstyle>Reboot Required?</td>"
$Content += "<td width=75 style=$TDstyle>Windows Updates</td>"
$Content += "<td width=75 style=$TDstyle>Package Installer</td>"
$Content += "<td width=75 style=$TDstyle>Package Installer 64</td>"
$Content += "<td width=75 style=$TDstyle>File Rename</td>"
$Content += "<td width=75 style=$TDstyle>Hostname Change</td>"
$Content += "<td width=80 style=$TDstyle>Component Based Services</td>"
$Content += "<td width=80 style=$TDstyle>LastLogon</td>"
foreach ($PC in $CommaList){ <#Start of Foreach#>
    $serverName = $PC.DNSHostName
    $lastLogon = [datetime]::FromFileTime($PC.lastLogon)
    <# Testing Access to computer via winrm#>
if(Test-WSMan -ComputerName $PC.DNSHostName -ErrorVariable +srvError)

{
$serverName = $PC.DNSHostName
$Content += "<tr>"
#Windows Updates
$WUVal = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction SilentlyContinue -ErrorVariable +srvError}) #| foreach { $_.RebootRequired }
if ($WUVal -ne $null) {$WUBoot = "Yes"}
else {$WUBoot = "No"}
#Package Installer
$PakVal = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:\Software\Microsoft\Updates\" -Name UpdateExeVolatile -ErrorAction SilentlyContinue -ErrorVariable +srvError}) | foreach { $_.UpdateExeVolatile }
if ($PakVal -ne $null) {$PakBoot = "Yes"}
else {$PakBoot = "No"}
#Package Installer - Wow64
$PakWowVal = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:\Software\Wow6432Node\Microsoft\Updates\" -Name UpdateExeVolatile -ErrorAction SilentlyContinue -ErrorVariable +srvError}) | foreach { $_.UpdateExeVolatile }
if ($PakWowVal -ne $null) {$PakWowBoot = "Yes"}
else {$PakWowBoot = "No"}
#Pending File Rename Operation
$RenFileVal = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\" -Name PendingFileRenameOperations -ErrorAction SilentlyContinue -ErrorVariable +srvError}) | foreach { $_.PendingFileRenameOperations }
if ($RenFileVal -ne $null) {$RenFileBoot = "Yes"}
else {$RenFileBoot = "No"}#>
#Pending Computer Rename
$PCnameIs = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName" -Name ComputerName -ErrorAction SilentlyContinue -ErrorVariable +srvError}) | foreach { $_.ComputerName }
$PCnameBe = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName" -Name ComputerName -ErrorAction SilentlyContinue -ErrorVariable +srvError}) | foreach { $_.ComputerName }
if ($PCnameIs -eq $PCnameBe) {$PCnameBoot = "No"}
else {$PCnameBoot = "Yes"}
#Component Based Servicing
$CBSVal = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\" -Name RebootPending -ErrorAction SilentlyContinue -ErrorVariable +srvError}) | foreach { $_.RebootPending }
if ($CBSVal -ne $null) {$CBSBoot = "Yes"}
else {$CBSBoot = "No"}
$rebootTime = (Invoke-command -computer $PC.DNSHostName {Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\" -Name RebootPending -ErrorAction SilentlyContinue -ErrorVariable +srvError})

#Email HTML Content - append loop
$Content += "<td bgcolor=#dddddd align=left><b>$serverName</b></td>"      #1
if (($WUboot,$PakBoot,$PakWowBoot,$RenFileBoot,$PCnameBoot,$CBSBoot) -contains "Yes")
#if (($WUboot,$PakBoot,$PakWowBoot,$PCnameBoot,$CBSBoot) -contains "Yes")
    {$Content += "<td bgcolor=#ff4000 align=center>Yes</td>"} #2
else
    {$Content += "<td bgcolor=#65ff00 align=center>No</td>"} #2
    $Content += "<td bgcolor=#f5f5f5 align=center>$WUboot</td>" #3
    $Content += "<td bgcolor=#f5f5f5 align=center>$PakBoot</td>" #4
    $Content += "<td bgcolor=#f5f5f5 align=center>$PakWowBoot</td>" #5
    $Content += "<td bgcolor=#f5f5f5 align=center>$RenFileBoot</td>" #6
    $Content += "<td bgcolor=#f5f5f5 align=center>$PCnameBoot</td>"#7
    $Content += "<td bgcolor=#f5f5f5 align=center>$CBSBoot</td>" #8
    $Content += "<td bgcolor=#f5f5f5 align=center>$lastLogon</td>" #9
    $Content += "</tr>"
    }

else {
    #$serverName = $PC.DNSHostName
    $Content += "<tr>"
    $Content += "<td bgcolor=#ff9999 align=left><b>$serverName</b></td>" #1

    $Content += "<td bgcolor=#ff9999 align=center>Check RPC or WinRM</td>" #2
    $Content += "<td bgcolor=#ff9999 align=center></td>" #3
    $Content += "<td bgcolor=#ff9999 align=center></td>" #4
    $Content += "<td bgcolor=#ff9999 align=center></td>" #5
    $Content += "<td bgcolor=#ff9999 align=center></td>" #6
    $Content += "<td bgcolor=#ff9999 align=center></td>" #7
    $Content += "<td bgcolor=#ff9999 align=center></td>" #8
    $Content += "<td bgcolor=#ff9999 align=center>$lastLogon</td>" 
    $Content += "</tr>"
    Clear-Variable serverName -Force
    }

} <#End of Foreach#>

$timer.stop()
$scriptTime = [math]::Round($timer.Elapsed.TotalMinutes,2)

#Close HTML
$Content += "</table>"
$Content += "<p>Took Script " +$scriptTime+" Minutes to Run</p>"
$Content += "</body>"
$Content += "</html>"

$ErrorLog | Add-Content -Value $srvError
#Send Email Report
Send-MailMessage -From $smtpFrom -To $smtpTo -Subject $Subject -Body $Content -BodyAsHtml -Priority High -dno onSuccess, onFailure -SmtpServer $smtpServer -Attachments $ErrorLog
$NewName = "ErrorLog-"+$date.ToString('dd-MM-yyyy')+".txt"
Get-Item $ErrorLog | Rename-Item -NewName $NewName