# Gets all users from all domains
# Returns all Actual user objects

$forest = Get-ADForest
$domains = $forest.domains
$allUsers = @()
ForEach ($d in $domains)
{
    $allUsers += get-aduser -Filter * -Properties DistinguishedName,EmployeeID,Enabled,GivenName,MemberOf,Name,SamAccountName,SID,Surname,UserPrincipalName,LastLogonDate  `
     -Server (Get-ADDomainController -DomainName $d -Discover -ForceDiscover)
}

return $allUsers