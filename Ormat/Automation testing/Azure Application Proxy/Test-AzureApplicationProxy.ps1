Import-Module 
$serverToReboot = "ORMAADAPC01"
$AdminUsername = "adori@ormat.com"
$AdminPassword = "M@rin2806Q32021"
$SecurePassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $AdminUsername,$SecurePassword
Connect-AzureAD -Credential $cred
$serviceStatus=0


<#Pre#>
Get-AzureADApplicationProxyConnector |where {$_.MachineName -like "$serverToReboot*"}
Get-Service -ComputerName $serverToReboot -Name WAPCSvc
Get-Service -ComputerName $serverToReboot -Name WAPCUpdaterSvc
Get-Service -ComputerName $serverToReboot -Name Netlogon
Invoke-Command -ComputerName $serverToReboot -ScriptBlock {Get-}

$u = "asafpm@ormat.com"
$p = ""
$sp = ConvertTo-SecureString $p -AsPlainText -Force
$cred2 = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $u,$sp
Invoke-Command -ComputerName $serverToReboot -Credential $cred2 -ScriptBlock {Restart-Computer -Force}



############################### Works till here
while((Test-Connection $serverToReboot -Count 1).StatusCode -eq 0){
(Test-Connection $serverToReboot).StatusCode
#Write-host $serverToReboot "Still didnt reboot"
sleep 1
}



<#Post#>
While($serviceStatus -ne 4)
{

    if((Get-AzureADApplicationProxyConnector |where {$_.MachineName -like "$serverToReboot*"}).Status -eq "active"){$serviceStatus+=1}
    if((Get-Service -ComputerName $serverToReboot -Name WAPCSvc).Status -eq "Running"){$serviceStatus+=1}
    if((Get-Service -ComputerName $serverToReboot -Name WAPCUpdaterSvc).Status -eq "Running"){$serviceStatus+=1}
    if((Get-Service -ComputerName $serverToReboot -Name Netlogon).Status -eq "Running"){$serviceStatus+=1}
    $serviceStatu
Start-Sleep 2
}#End of WHILE

