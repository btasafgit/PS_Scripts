<# Vars#>
$cred = Get-Credential
$result = 2
$serverName = "ormat-web1"
$uri = "ormat-web1.ormat.com"

$servicesStatusPre = @()
$isRebooted = 0

<# Gather#>
$servicesStatusPre += Get-Service -ComputerName $serverName |Where-Object {$_.DisplayName -like "Citrix*" `
                    -or $_.DisplayName -like "Netlogon" `
                    -or $_.DisplayName -like "DHCP Client" `
                    -or $_.DisplayName -like "DNS Client" `
                    -or $_.DisplayName -like "World Wide Web Publishing Service"
                    }

$ctxSFPre = Invoke-WebRequest "https://$uri/Citrix/OrmatWeb/"

#Restart-Computer -ComputerName $serverName -Credential $cred

<# Reboot qesuance and testing#>
Write-Host "Waiting for" $serverName "to Reboot" -ForegroundColor Green
do {
    if((Test-NetConnection -ComputerName $serverName).PingSucceeded -eq $True)
    {
        $isRebooted = 0
        Write-Host "." -NoNewline -ForegroundColor Green
    }
    else {
        $isRebooted = 1
        Write-Host "Server has been rebooted"$serverName -ForegroundColor Red
    }
} while ($isRebooted -eq 0)


<# Post reboot validation#>

Write-Host "Waiting for" $serverName "to Reboot" -ForegroundColor Green

do {
    while ($result -ne 0) {
        $result = 2
        $servicesStatusPost = @()
        $servicesStatusPost += Get-Service -ComputerName $serverName |Where-Object {$_.DisplayName -like "Citrix*" `
                    -or $_.DisplayName -like "Netlogon" `
                    -or $_.DisplayName -like "DHCP Client" `
                    -or $_.DisplayName -like "DNS Client" `
                    -or $_.DisplayName -like "World Wide Web Publishing Service"
                    }

        $ctxSFPost = Invoke-WebRequest "https://$uri/Citrix/OrmatWeb/"


        <# Compare Pre and Post#>
        if((Compare-Object $servicesStatusPre $servicesStatusPost -Property Status,DisplayName |Where-Object SideIndicator -EQ "<=") -eq $null){
            Write-Host "Services OK"
            $result -= 1
        }
        else {
            Write-Host "." -NoNewline -ForegroundColor Red
            $result = 2
            
        }

        if(($ctxSFPre.StatusCode -eq 200) -and ($ctxSFPost.StatusCode -eq 200)){
            Write-Host "CTX SF OK"
            $result -= 1
        }
        else {
            Write-Host "." -NoNewline -ForegroundColor Red
            $result = 2
        }
        Write-Host "Result = "$result
    }
} until ($result -eq 0)

Write-Host "Server is up" $serverName -ForegroundColor Green
Write-Host "The following services are UP:
$servicesStatusPost" -ForegroundColor Green
Write-Host "The following web site is UP:" (($ctxSFPost.BaseResponse).ResponseUri).OriginalString -ForegroundColor Green



Clear-Variable servicesStatusPost -force
Clear-Variable ctxSFPost -force







