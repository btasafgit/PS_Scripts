#$servers = Get-ADComputer -server "nv-il-dc1.nv.us.ormat.com" -Filter 'operatingsystem -like "*server*" -and enabled -eq "true"' |where {$_.Name -notlike "*DC*"}
$servers = get-adcomputer ORMAT-KASPERSKY

function Change-Administrator($ComputerName){

    try {
        $dec = "Built-in account for IT Admins only!! "
        $pass = ConvertTo-SecureString 'z7q$C8EX*Kyn9J%@@*zU' -AsPlainText -Force
        Invoke-Command -ComputerName $ComputerName -Command {
        #Set-LocalUser -Name "Administrator" -AccountNeverExpires -Description $USING:dec -Password $USING:pass -PasswordNeverExpires $true
        net user "Administrator" 'z7q$C8EX*Kyn9J%@@*zU' /usercomment: "Built-in account for IT Admins only!!" /passwordchg:no
        }
        return 0x0,$ComputerName
    }
    catch {
        return 0x1,$ComputerName
        $Error[0] | Out-File "c:\ABT\ServersAdmin-err.log" -Append
    }
}


foreach ($i in $servers) {

    $a = Change-Administrator -ComputerName $i.DNSHostName
    
    if($a[0] -eq 0){$a[1] | Out-File "c:\abt\Change-Administrator-OK.csv" -Append}
    elseif($a[0] -eq 1){$a[1] | Out-File "c:\abt\Change-Administrator-Not.csv" -Append}
    else {
        
    }
}


foreach ($i in $servers) {
    Invoke-Command -ComputerName $i.DNSHostName -Command {
        #if(net user "ORMSRV"){write-host $env:COMPUTERNAME "OK"}
        #else {write-host $env:COMPUTERNAME "Not OK"}
        #$pass = ConvertTo-SecureString  -AsPlainText -Force
        net user /add "Administrator"  /usercomment:"Authorized use only!!" /passwordchg:no
        net localgroup administrators ORMSRV /add
        net localgroup users ORMSRV /delete
    }
}


$logPath = "C:\Support\"
$locUsers = Get-LocalUser
$locGroup = Get-LocalGroupMember -Group Administrators


if (-not($locUsers | Where-Object { $_.Name -eq "ITLab" })) {
    $newUsr = New-LocalUser -Name "ITLab" -AccountNeverExpires -Description $dec  -Password $pass -PasswordNeverExpires
    Add-LocalGroupMember -Group Administrators -Member $newUsr
    break
}
sleep 2
#If User Exists but not in Administrators group
if (-not($locGroup | Where-Object { $_.Name -like "*ITLab" })) {
    Add-LocalGroupMember -Group Administrators -Member (Get-LocalUser | Where-Object { $_.Name -eq "ITLab" })
}
#Set pass anyway Force
if (Set-LocalUser -Name "ITLab" -AccountNeverExpires -Description $dec -Password $pass -PasswordNeverExpires $true) {
    return 0
}
else { return 0x1 }