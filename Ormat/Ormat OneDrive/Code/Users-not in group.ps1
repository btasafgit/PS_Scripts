Import-module ActiveDirectory

Set-Location "C:\Users\Adori\OneDrive - Ormat\Documents\PS Projects\Ormat OneDrive\Code"
$date = get-date -Format dd-MM-yyyy
$usersManagement = .\getUsers.ps1 |where {$_.Enabled -eq $true} |sort Name
$allowShareGroup = "Azure-AddUsers-CASB"
$inGroup = @()
$notInGroup = @()
$err = @()

foreach ($i in $usersManagement) {
    write-host $k
    try{
    if($i.memberof -like "*${allowShareGroup}*"){
        $inGroup += $i
        #Write-Host "Allowed: "$i.SamAccountName
    }
    else {
        $notInGroup += $i
        #Write-Host "Disabled: "$i.SamAccountName
    }
    }
    catch{
        $err += $Error[0]
    }


}



$inGroup |export-csv ..\Output\InGroup-$date.csv -NoTypeInformation
$notInGroup |export-csv ..\Output\NotInGroup-$date.csv -NoTypeInformation
$err | Out-File ..\Output\Err-$date.txt

# Cleanup!!! 

Clear-Variable allowShareGroup -Force
Clear-Variable usersManagement -Force
Clear-Variable inGroup -Force
Clear-Variable inGroup -Force


$usersManagement

get-aduser -Filter * -Properties LastLogonDate |where {$_.LastLogonDate -le (get-date).adddays(-90)} |Export-Csv c:\abt\usersNoLogon90Days.csv -NoTypeInformation

([Datetime]((get-aduser adori -Properties LastLogonDate).LastLogonDate)) - (get-date).adddays(-30)
