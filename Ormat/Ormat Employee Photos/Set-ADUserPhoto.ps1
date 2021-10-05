

Function OrmatGetUserDetails{
    Clear-Host
    $a = Read-Host "Enter Username: "
    Start-Sleep 2
    $usr = get-aduser $a -Properties Name,SamAccountName,employeeID
    return $usr
}

Function OrmatVerifyUserDetails{

    Param(
    [Parameter(Mandatory=$true)]
        $usr,
    )

    Write-Host "Please verify user details
    Name: $($usr.Name)
    Username: $($usr.SamAccountName)
    Employee ID: $($usr.employeeID)
    "
    $approve = Read-Host "Please approve [y/n]"
    $approve = $approve.ToLower()
    return $approve
}

Function OrmatSetUserPhoto{
    Param(
    [Parameter(Mandatory=$true)]
        $User,
        $Photo = $null
    )
    Set-ADUser $User -Replace @{thumbnailPhoto=([byte[]](Get-Content $Photo -Encoding byte))}
}


Clear-Host



if($approve -eq "y"){
    write-host "OK"
}



$original = [system.io.file]::ReadAllBytes('C:\Users\adori\OneDrive - Ormat\Documents\PS Projects\PS\Ormat Scripts\Projects\Ormat Employee Photos\Source\IMG_0103.JPG')

$original 
