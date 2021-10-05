$O365AdminSite = "https://outlook.office365.com/powershell-liveid/"
$cred = Get-Credential -UserName adori@ormat.com -m "aaa"
$O365ExOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $O365AdminSite -Credential $cred -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue
Import-PSSession $O365ExOSession -AllowClobber -DisableNameChecking|out-null

$mbx = Get-Mailbox hkattan@ormat.com
$mbxFol = $mbx| Get-MailboxFolderPermission
$exclude = "personal"


foreach($i in $mbxFol){
    Get-MailboxPermission hkattan@ormat.com
}


Get-MailboxFolderPermission $mbx.WindowsEmailAddress -Identity 

$LASTEXITCODE = $r
$LASTEXITCODE

#========================================================================
#Proof of concept code to apply mailbox
#folder permissions to all folders in
#a mailbox
$O365AdminSite = "https://outlook.office365.com/powershell-liveid/"
$cred = Get-Credential -UserName adori@ormat.com -m "aaa"
$O365ExOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $O365AdminSite -Credential $cred -Authentication Basic -AllowRedirection -WarningAction SilentlyContinue
Import-PSSession $O365ExOSession -AllowClobber -DisableNameChecking|out-null
    <#AccessRight 
    ChangeOwner
    ChangePermission
    DeleteItem
    ExternalAccount
    FullAccess
    ReadPermission    
    #>

function Add-MailboxFolderReadOnly{
[CmdletBinding()]
param (
    #Mailbox to grant permissions to
	[Parameter( Mandatory=$true)]
	[string]$Mailbox,
    #User to be granted permissions on the mailbox
	[Parameter( Mandatory=$true)]
	[string]$User,
	[bool]$Test=$true,
    [Parameter( Mandatory=$true)]
    [bool]$Remove,
  	[Parameter( Mandatory=$true)]
	[string]$Access
)

$exclusions = @("\personal","\Tasks\Personnal","\Personnal")

<# For Multiple exclusions
@("/Sync Issues",
                "/Sync Issues/Conflicts",
                "/Sync Issues/Local Failures",
                "/Sync Issues/Server Failures",
                "/Recoverable Items",
                "/Deletions",
                "/Purges",
                "/Versions"
                )
#>

$mailboxfolders = @(Get-MailboxFolderStatistics $Mailbox | Where {!($exclusions -icontains $_.FolderPath)} | Select FolderPath)

foreach ($mailboxfolder in $mailboxfolders)
{
    $folder = $mailboxfolder.FolderPath.Replace("/","\")
    if ($folder -match "Top of Information Store")
    {
       $folder = $folder.Replace("\Top of Information Store","\")
    }
    $identity = "$($mailbox):$folder"

    #Decision if to Add or remove
    if($Remove -eq $false){ #To Add
        if($Test -eq $true)
        {Add-MailboxFolderPermission -Identity $identity -User $user -AccessRights $Access -WhatIf}
        else
        {Write-Host "Adding $user to $identity with $access permissions" -ForegroundColor Green
         Add-MailboxFolderPermission -Identity $identity -User $user -AccessRights $Access -Confirm:$false}

        }
    else #To Remove
    {
        if($Test -eq $true)
        {Remove-MailboxFolderPermission -Identity $identity -User $user -Confirm:$false -WhatIf}
        else
        {Write-Host "Removing $user to $identity permissions" -ForegroundColor Red
         Remove-MailboxFolderPermission -Identity $identity -User $user -Confirm:$false}
        } #End of Else
    
} #End of Foreach




} #End of Function

Add-MailboxFolderReadOnly -Mailbox hkattan@ormat.com -User adori@ORMAT.COM -Access NonEditingAuthor -Remove $true  -Test $false


Remove-MailboxFolderPermission -Identity hkattan@ormat.com:\Personnal -User jwoelfel@ORMAT.COM -Confirm:$false
Remove-MailboxFolderPermission -Identity hkattan@ormat.com:\Personnal -User adori@ORMAT.COM -Confirm:$false




Remove-MailboxFolderPermission -Identity "HKattan@ormat.com:\Calendar" -User jwoelfel@ORMAT.COM -Confirm:$false







