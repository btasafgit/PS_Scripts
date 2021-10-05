$logPath = "C:\Support\"
$locUsers = Get-LocalUser
$locGroup = Get-LocalGroupMember -Group Administrators
$dec = "Account for IT use only!! " + (get-date)

$pass = ConvertTo-SecureString "*****" -AsPlainText -Force

if(-not($locUsers | Where-Object {$_.Name -eq "ITLab"})){
    $newUsr = New-LocalUser -Name "ITLab" -AccountNeverExpires -Description $dec  -Password $pass -PasswordNeverExpires
    Add-LocalGroupMember -Group Administrators -Member $newUsr
    break
    }
sleep 2
#If User Exists but not in Administrators group
if(-not($locGroup | Where-Object {$_.Name -like "*ITLab"})){
    Add-LocalGroupMember -Group Administrators -Member (Get-LocalUser | Where-Object {$_.Name -eq "ITLab"})
    }
#Set pass anyway Force
if(Set-LocalUser -Name "ITLab" -AccountNeverExpires -Description $dec -Password $pass -PasswordNeverExpires $true){
    return 0
}
else {return 0x1}