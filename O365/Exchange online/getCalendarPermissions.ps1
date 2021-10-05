<#
    The script is used for manageing calendar permissions to a specific user.
    The permissions grants only specific user
#>

###Variables

$userMng = Read-Host "Write_Your_UPN_Account" # i.e user@domain.com - an administrative account
$LiveCred = Get-Credential -UserName $userMng -Message "Enter Credentials" 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic –AllowRedirection
Import-PSSession $Session -AllowClobber

$srchUser = Read-Host "Enter the UPN address for permission check"
Get-MailboxFolderPermission -Identity ${srchUser}:\calendar

Set-MailboxFolderPermission -Identity ${srchUser}:\calendar -AccessRights AvailabilityOnly -User $srchUser -Confirm:$false


