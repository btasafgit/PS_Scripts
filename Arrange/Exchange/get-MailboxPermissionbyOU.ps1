$mbxs = Get-Mailbox  -OrganizationalUnit "OU=Service Mailbox,OU=Users,OU=Meitav Dash Network,DC=DS-Invest,DC=Local"
foreach($mbx in $mbxs)
{
    $mbxPers = $mbx | Get-MailboxPermission |select User,AccessRights
    foreach($mbxPer in $mbxPers)
    {
    $out = $mbx.Name.ToString() +","+ $mbxPer.User +","+ $mbxPer.AccessRights
    out-file c:\abt\MBXPermissions.csv -InputObject $out -Append
    
    
}
}