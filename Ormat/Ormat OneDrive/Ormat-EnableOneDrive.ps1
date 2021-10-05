$url = "https://ormat-admin.sharepoint.com"
Connect-SPOService -Url $url -Credential "adori@ormat.com"

$logPath = "c:\abt\error.log"


$usr = Read-Host "Enter a a username: "

try {
    $adUser = Get-ADUser $usr -Properties * -ErrorAction Stop -ErrorVariable err
    
    Request-SPOPersonalSite -UserEmails $adUser.mail -Nowait -ErrorAction Stop -ErrorVariable +err -InformationVariable +err
}
catch {
    Out-File $logPath -InputObject $err -Append
}