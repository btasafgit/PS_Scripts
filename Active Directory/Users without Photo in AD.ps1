$a = get-aduser -Filter * -Properties thumbnailPhoto,Enabled,EmployeeID |Where-Object {$_.thumbnailPhoto -eq $null -and `
    $_.enabled -eq $true -and `
    ($_.EmployeeID -ne "0" -or $_.EmployeeID -ne "0")}
    #((Get-UserPhoto $i.UserPrincipalName).PictureData -eq $null) -and 
$out = @()
$err = @()
foreach ($i in $a)
{
    try{
    if (($i.thumbnailPhoto -eq $null)) {
        $out += $i
    }
    }
    catch{
        $err += "Error on user $i.UserPrincipalName"
    }
}
$out | export-csv -Path "c:\abt\noPhoto.csv" -NoTypeInformation
$err | Out-File "c:\abt\Error-noPhoto.txt"
Clear-Variable out -Force


