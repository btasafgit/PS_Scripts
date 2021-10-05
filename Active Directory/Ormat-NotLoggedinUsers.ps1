<# This script ouputs a list of users that did not logged in to the network in the last 90 days#>
$outPath = "noLogonUsers.txt"
$date = get-date
$usrs = Get-ADUser -Filter * -Properties *

$obj = @()
foreach($usr in $usrs){
    #$usr.SamAccountName
    
    if(($usr.PasswordLastSet) -eq $null)
    {$passLastSetD = "Null"}
    else{$passLastSetD = $usr.PasswordLastSet.ToShortDateString()}
    if(($usr.LastLogonDate) -eq $null)
    {$lastLogonD = "Null"}
    else{$lastLogonD = $usr.LastLogonDate.ToShortDateString()}


    $obj += New-Object -TypeName PSCustomObject -Property @{
    "Given Name" = $usr.GivenName
    "SurName" = $usr.sn
    "Full Name" = $usr.Name
    "Mail" = $usr.mail
    "Employee ID" = $usr.EmployeeID
    "Enabled" = $usr.Enabled
    "Username" = $usr.samAccountName #username
    "Password Never Expires" = $usr.PasswordNeverExpires
    "Password Expired" = $usr.PasswordExpired
    "PasswordLastSet Date" = $passLastSetD
    "PasswordLastSet Ticks" = [datetime]::FromFileTime($usr.pwdLastSet)
    "DN" = $usr.DistinguishedName.Substring($usr.DistinguishedName.IndexOf(',')+1) #Distinguish Name
    "Last Logon" = [datetime]::FromFileTime($usr.lastLogon) #lastLogon
    "Last Logon TS" = [datetime]::FromFileTime($usr.lastLogonTimestamp) #lastLogonTimestamp
    "LastLogon Date" = $lastLogonD 
    "Description" = $usr.Description
    "UPN" = $usr.UserPrincipalName
    "Title" = $usr.Title
    } #end of New Object

    
} #end of For Each


$obj |Export-Csv Users.csv -NoTypeInformation


Clear-Variable obj -Force