$cred = Get-Credential
Connect-AzureAD -Credential $cred

function Check-UserPhoto() {
    param(
        [Boolean]$download = $false,
        [String]$u
    )
    $a = "No AD pic"
    $b = "No 365 pic"
    $uName = (Get-AzureADUser -SearchString $u | where { $_.UserPrincipalName -eq $u + "@ormat.com" }).DisplayName
    $uID = (Get-AzureADUser -SearchString $u | where { $_.UserPrincipalName -eq $u + "@ormat.com" }).ObjectId
    #$uID = (Get-AzureADUser -SearchString $u).ObjectId
    
    if ((Get-ADUser $u -Properties thumbnailphoto).thumbnailphoto -ne $null) {
        $a = "AD Pic"
        Write-Host -ForegroundColor Green "AD = "$a
    }
    else { Write-Host -ForegroundColor Red "AD ="$a }
    
    if ((Get-AzureADUserThumbnailPhoto -ObjectId $uID).Width -ne "") {
        $b = "365 Pic"
        
        if ($download -eq $true) {
            Get-AzureADUserThumbnailPhoto -ObjectId $uID -FilePath C:\Users\adori\Downloads\Temp -FileName $uName
            Write-Host -ForegroundColor Green "365 = "$b "File will be downloaded"
        }
        else { Write-Host -ForegroundColor Green  "365 = "$b }
    }
    else {
        if ($download -eq $true) {
            Get-AzureADUserThumbnailPhoto -ObjectId $uID -FilePath C:\Users\adori\Downloads\Temp -FileName $uName
            Write-Host -ForegroundColor Red "365 = "$b "File will be downloaded"
            }
        else
            {Write-Host -ForegroundColor Red "365 = "$b}
        }
        
}
$e = @()
$ok = @()
foreach($i in $u){
    try{Write-host $i.Name
        Check-UserPhoto -u harar #-download $true
        $ok += $i
    }
    catch{
        $e += $i
        }
}

#Rename files from jpeg to jpg
$items = Get-ChildItem -Path "C:\Users\adori\Downloads\Temp"
foreach($i in $items){
    $newName = ($i.Name).Replace(".jpeg",".jpg")
Rename-Item $i.FullName -NewName $newName
}


#Get users by employeeID
$csv = Import-Csv "C:\users\adori\Downloads\noPhoto.csv"
$u = @()
foreach ($i in $csv) {
    $empID = $i.id
    $u += Get-ADUser -Filter {employeeID -eq $empID} -Properties employeeID,UserPrincipalName
}