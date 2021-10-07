
$Identity = "email@address.com"
get-MailboxRegionalConfiguration -Identity $Identity
Set-MailboxRegionalConfiguration -Identity $Identity -TimeZone "Eastern Standard Time"

$tz = Get-ChildItem "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Time zones" | foreach {Get-ItemProperty $_.PSPath}; $TimeZone 
$tz |where {$_.PSChildName -like "*Eastern*"} |ft


foreach($i in $del){
Search-Mailbox -identity $i -SearchQuery ‘subject:Plant Managers/IT Meeting’ -LogLevel full -TargetMailbox serviceadmin@ormat.com -TargetFolder SearchResults -DeleteContent -confirm $false
}




Request-SPOPersonalSite -UserEmails Sdagan@ORMAT.COM -Nowait
Install-Module MCAS
Import-Module PowerShellGet
Install-Module -scope currentuser AzureADPreview -AllowClobber -Confirm:$false




$a = Get-ADUser -Properties extensionAttribute2,OtherPager -Filter * |where {$_.extensionAttribute2 -ne $null -and $_.enabled -eq $true}
$a |select NAme,samaccontname,extensionAttribute2,OtherPager

foreach($d in $a)
{
    $pager = ($d.extensionAttribute2).split(',')
    foreach($p in $pager)
    {
        
        Set-ADUser $d.samaccountname -Add @{OtherPager=$p}
    }
}