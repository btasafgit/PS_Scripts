Import-module MSOnline,ActiveDirectory,Microsoft.Online.SharePoint.PowerShell
<###Connect To MsolService###
$pass = cat C:\Jenkins\Scripts\O365\365securestring.txt | ConvertTo-SecureString -Force
$mycred = new-object -typename System.Management.Automation.PSCredential -argumentlist "admin@ormat.onmicrosoft.com",$pass

$O365Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid -Credential $mycred -Authentication Basic -AllowRedirection 
Import-PSSession $O365Session -AllowClobber
Connect-SPOService -Url https://ormat-admin.sharepoint.com -Credential $mycred
#>
<# Import Users#>
Set-Location "C:\Users\Adori\OneDrive - Ormat\Documents\PS Projects\Ormat OneDrive\Code"
$date = get-date -Format dd-MM-yyyy
$usersManagement = .\getUsers.ps1 |where {$_.Enabled -eq $true} |sort Name
$allowShareGroup = "OneDrive-Allow-ShareExternal"
$AllowedAccounts = @()
$BlockedAccounts = @()
$err = @()
$SPOSites = Get-SPOSite -IncludePersonalSite:$true -Filter {URL -like "*/personal/*"} -Limit ALL |Sort-Object Owner

foreach ($i in $usersManagement) {
    $k = (($i.UserPrincipalName).Replace('@','_')).replace('.','_')
    write-host $k
    $spo = $SPOSites |where {$_.Url -eq "https://ormat-my.sharepoint.com/personal/"+$k}
    try{
if($i.memberof -like "*${allowShareGroup}*"){
    $AllowedAccounts += $i
    Write-Host "Allowed: "$i.SamAccountName
    #Get-SPOSite -IncludePersonalSite:$true -Filter {URL -like "*/personal/*"} -Limit ALL |Sort-Object Owner |Where-Object {$_.Owner -like "*$i.UserPrincipalName*"} |Set-SPOSite -SharingCapability ExternalUserSharingOnly
    Set-SPOSite -Identity $spo -SharingCapability ExternalUserSharingOnly -ErrorAction SilentlyContinue
}
else {
    $BlockedAccounts += $i
    Write-Host "Disabled: "$i.SamAccountName
    #Get-SPOSite -IncludePersonalSite:$true -Filter {URL -like "*/personal/*"} -Limit ALL |Sort-Object Owner |Where-Object {$_.Owner -like "*$i.UserPrincipalName*"} |Set-SPOSite -SharingCapability Disabled
    Set-SPOSite -Identity $spo -SharingCapability Disabled -ErrorAction SilentlyContinue
}
}
catch{
    $err += $Error[0]
}
Clear-Variable k -Force
Clear-Variable spo -Force
}



$AllowedAccounts |export-csv ..\Output\AllowedAccounts-$date.csv -NoTypeInformation
$BlockedAccounts |export-csv ..\Output\BlockedAccounts-$date.csv -NoTypeInformation
$err | Out-File ..\Output\Err-$date.txt

<# Cleanup!!! 

Clear-Variable allowShareGroup -Force
Clear-Variable usersManagement -Force
Clear-Variable BlockedAccounts -Force
Clear-Variable AllowedAccounts -Force
#>


#Get-SPOSite -IncludePersonalSite:$true -Filter {URL -like "*/personal/*"} -Limit ALL |Sort-Object Owner |Where-Object {$_.Owner -like "*$upn*"} |Set-SPOSite -SharingCapability Disabled
<#
https://docs.microsoft.com/en-us/powershell/module/sharepoint-online/set-sposite?view=sharepoint-ps

Disabled - don't allow sharing outside your organization
ExistingExternalUserSharingOnly - Allow sharing only with the external users that already exist in your organization's directory - Bottom
ExternalUserSharingOnly - allow external users who accept sharing invitations and sign in as authenticated users - Top
ExternalUserAndGuestSharing - allow sharing with all external users, and by using anonymous access links - Middle
#>