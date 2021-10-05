<# Vars#>
$serverName = "Ormat-MBX16.ormat.com"
$uri = "mail2.ormat.com"
$result = 3
$servicesStatusPre = @()
$isRebooted = 0

<# Gather#>
$servicesStatusPre += Get-Service -ComputerName $serverName |Where-Object {$_.DisplayName -like "Microsoft Exchange*" `
                    -or $_.DisplayName -like "Netlogon" `
                    -or $_.DisplayName -like "DHCP Client" `
                    -or $_.DisplayName -like "DNS Client" `
                    -or $_.DisplayName -like "IIS Admin Service" `
                    -or $_.DisplayName -like "Remote Procedure Call (RPC)" `
                    -or $_.DisplayName -like "NetBackup*"
                    }

$exchECPPre = Invoke-WebRequest "https://$uri/ecp"
$exchOWAPre = Invoke-WebRequest "https://$uri/owa"


<# Reboot qesuance and testing#>

do {
    if((Test-NetConnection -ComputerName $serverName).PingSucceeded -eq $True)
    {
        $isRebooted = 0
        Write-Host "Server is not rebooted "$serverName -ForegroundColor Green
    }
    else {
        $isRebooted = 1
        Write-Host "Server is rebooted "$serverName -ForegroundColor Red
    }
} while ($isRebooted -eq 0)


<# Post reboot validation#>
do {
    while ($result -ne 0) {
        $servicesStatusPost = @()
        $servicesStatusPost += Get-Service -ComputerName $serverName |Where-Object {$_.DisplayName -like "Microsoft Exchange*" `
            -or $_.DisplayName -like "Netlogon" `
            -or $_.DisplayName -like "DHCP Client" `
            -or $_.DisplayName -like "DNS Client" `
            -or $_.DisplayName -like "IIS Admin Service" `
            -or $_.DisplayName -like "Remote Procedure Call (RPC)" `
            -or $_.DisplayName -like "NetBackup*"
            }

        $exchECPPost = Invoke-WebRequest "https://$uri/ecp"
        $exchOWAPost = Invoke-WebRequest "https://$uri/owa"


        <# Compare Pre and Post#>
        if((Compare-Object $servicesStatusPre $servicesStatusPost -Property Status,DisplayName |Where-Object SideIndicator -EQ "<=") -eq $null){
            Write-Host "Services OK"
            $result -= 1
        }
        else {
            Write-Host "Services Falied"
            
        }

        if((Compare-Object $exchECPPre.StatusCode $exchECPPost.StatusCode) -eq $null){
            Write-Host "Exchange ECP OK"
            $result -= 1
        }
        else {
            Write-Host "Exchange ECP Falied"
        }

        if((Compare-Object $exchOWAPre.StatusCode $exchOWAPost.StatusCode) -eq $null){
            Write-Host "Exchange OWA OK"
            $result -= 1
        }
        else {
            Write-Host "Exchange OWA Falied"
        }
        
    }
} until ($result -eq 0)







