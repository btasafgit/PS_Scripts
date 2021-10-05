
$user = "oswissa@ormat.com"

$mbx = "ConfYavnePlatanares@ormat.com:\calendar"
Add-MailboxFolderPermission -AccessRights LimitedDetails -Identity $mbx -User $user
sleep 1
$mbx = "ConfYavneSteamboat@ormat.com:\calendar"
Add-MailboxFolderPermission -AccessRights LimitedDetails -Identity $mbx -User $user
sleep 1
$mbx = "ConfYavneMcginnessHills@ormat.com:\calendar"
Add-MailboxFolderPermission -AccessRights LimitedDetails -Identity $mbx -User $user
sleep 1
$mbx = "ConfYavneDonACampbell@ormat.com:\calendar"
Add-MailboxFolderPermission -AccessRights LimitedDetails -Identity $mbx -User $user
sleep 1
$mbx = "ConfYavneJerseyValley@ormat.com:\calendar"
Add-MailboxFolderPermission -AccessRights LimitedDetails -Identity $mbx -User $user
sleep 1






Get-MailboxFolderPermission -Identity $mbx
