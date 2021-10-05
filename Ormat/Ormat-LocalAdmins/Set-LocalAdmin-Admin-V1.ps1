$logPath = "C:\Support\"
$locUsers = Get-LocalUser
$locGroup = Get-LocalGroupMember -Group Administrators
$dec = "Account for IT use only!! " + (get-date)
$cngUser = "Administrator"
$pass = ConvertTo-SecureString "" -AsPlainText -Force

#If user does not exist
if(($locUsers | Where-Object {$_.Name -eq $cngUserr})){
    $newUsr = New-LocalUser -Name $cngUser -AccountNeverExpires -Description $dec  -Password $pass -PasswordNeverExpires
    Add-LocalGroupMember -Group Administrators -Member $newUsr
    break
    }
sleep 2
#If User Exists but not in Administrators group
if(-not($locGroup | Where-Object {$_.Name -like "*$cngUser"})){
    Add-LocalGroupMember -Group Administrators -Member (Get-LocalUser | Where-Object {$_.Name -eq "$cngUser"})
    }
#Set pass anyway Force
if(Set-LocalUser -Name $cngUser -AccountNeverExpires -Description $dec -Password $pass -PasswordNeverExpires $true
    ){
    Disable-LocalUser -Name $cngUser
    return 0
}
else {
Disable-LocalUser -Name $cngUser
return 0x1}