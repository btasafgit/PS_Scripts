##############################################################
# Geathering information on mailboxes that are not complient
# with microsoft limitations
#  - Folders over 50K/100K items
#  - Calendar and Contact item count
#  - Mailbox Sizes
#  - Connected users
##############################################################


#$mbxs = get-mailbox -ResultSize unlimited
#get-mailbox gemel



for($i=0; $i -le $mbxs.Length-1 ;$i++){

$mbxStat = Get-MailboxFolderStatistics $mbxs[$i].DistinguishedName

#Count of folders with more than 100K items
$folder100K = $mbxStat | where {$_.ItemsInFolder -ge "100000"}
#Count of folders with more than 50K items
$folder50K = $mbxStat | where {$_.ItemsInFolder -ge "50000" -and $_.ItemsInFolder -le "99999"}
#Count of contacts
$contactCount = $mbxStat | where {$_.FolderPath -like "/Contacts"}
#count of Calendar
$calCount = $mbxStat | where {$_.FolderPath -like "/Calendar"}
#mailbox Size
$mbxSize = (Get-MailboxStatistics -Identity $mbxs[$i].Identity).TotalItemSize
#Connected users
$connectedUsers = (Get-MailboxPermission $mbxs[$i].PrimarySmtpAddress |where { `
$_.user -ne "NT AUTHORITY\SELF" `
-and $_.user -notlike "S-1-5*" `
-and $_.user -ne "DS-INVEST\nir" `
-and $_.user -ne "DS-INVEST\btasaf" `
-and $_.user -ne "DS-INVEST\Domain Admins" `
-and $_.user -ne "DS-INVEST\tamir" `
-and $_.user -ne "DS-INVEST\ev_svc" `
-and $_.user -ne "DS-INVEST\Enterprise Admins" `
-and $_.user -ne "DS-INVEST\Organization Management" `
-and $_.user -ne "DS-INVEST\backup" `
-and $_.user -ne "DS-INVEST\Dash" `
-and $_.user -ne "DS-INVEST\Exchange Servers" `
-and $_.user -ne "DS-INVEST\Public Folder Management" `
-and $_.user -ne "DS-INVEST\Delegated Setup" `
-and $_.user -ne "NT AUTHORITY\NETWORK SERVICE" `
-and $_.user -ne "NT AUTHORITY\SYSTEM" `
-and $_.user -ne "DS-INVEST\Exchange Domain Servers" `
-and $_.user -ne "DS-INVEST\Exchange Trusted Subsystem" })

#Count Groups
$connectedGRPCount = 0
$connectedUserCount = 0
foreach($connectedUser in $connectedUsers)
{
    $connectedUser = $connectedUser.user
    $connectedUser = $connectedUser.Substring($connectedUser.IndexOf("\")+1)
    
    #$connectedUser
    #sleep 1

    $ifUser = Get-ADUser "$connectedUser" -Properties * -ErrorAction Ignore
    $ifGroup = Get-ADGroup "$connectedUser" -Properties * -ErrorAction Ignore
    
    if($ifUser.ObjectClass -eq "user"){
    write-host $ifUser.NAme "is A User in MBX: " $mbxs[$i].PrimarySmtpAddress
    $connectedUserCount++
    }
    elseif($ifGroup.ObjectClass -eq "group"){
    write-host $ifGroup.Name "is A Group in MBX: " $mbxs[$i].PrimarySmtpAddress
    $connectedGRPCount = (Get-ADGroupMember $connectedUser -ErrorAction SilentlyContinue -Recursive).count
    }
    else{
    write-host "====================="
    }


    ###################OLD IFS

    ###################
        $connectedUserCount = $connectedUserCount + $connectedGRPCount
        $connectedGRPCount = 0
        #Sleep 5
        #$connectedUserCount

        Clear-Variable connectedUser -Force
}

New-Object PSCustomObject -Property @{
        "MBX Name" = $mbxs[$i].PrimarySmtpAddress
        "folder100K" = $folder100K.Count
        "folder50K" = $folder50K.Count
        "contactCount" = $contactCount.ItemsInFolderAndSubfolders
        "calCount" = $calCount.ItemsInFolderAndSubfolders
        "mbxSize" = $mbxSize.substring(0,$mbxSize.IndexOf(' ('))
        "connectedUsers" = $connectedUserCount
        } | Select 'MBX Name','folder100K','folder50K','contactCount','calCount','mbxSize','connectedUsers' |Export-Csv -Path "C:\ABT\MBX\MailboxStat.csv" -Append -Encoding UTF8 -NoTypeInformation


#$i

}