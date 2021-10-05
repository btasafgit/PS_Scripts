<#
Gets a list of computers based on OU annd verifies if it has SMB1 Enabled
#>

$cred = Get-Credential
$OU = ""
$servers = get-adcomputer -Filter * -SearchBase $OU


foreach($i in $servers.Name){
Write-host $i
    
        try{
            
            Invoke-Command -Credential $cred -ComputerName $i -scriptBlock `
            { 
                $lastReboot = (Get-CimInstance -ClassName win32_operatingsystem).lastbootuptime
                if((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation -Name DependOnService).DependOnService -cnotcontains "MRxSmb10" -and `
                ((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\services\mrxsmb10 -Name Start).Start -eq "4") -and `
                ((Get-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters -Name SMB1).SMB1 -eq "0")
                )
                 {Write-host $env:computername "SMB1 is Disabled >> Last Rebooted: "$lastReboot  -ForegroundColor Green}
                 else
                 {Write-host $env:computername "SMB1 is Enabled >> Last Rebooted: "$lastReboot -ForegroundColor Red}
                 }#end of invoke
        }
        catch{
            Write-host $i " Error :" $Error[0]
        }


} #End of Foreach


