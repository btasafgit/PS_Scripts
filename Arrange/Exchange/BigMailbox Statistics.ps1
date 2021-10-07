Get-MailboxFolderStatistics vip |where {$_.ItemsInFolder -gt 100000}|select FolderPath,ItemsInFolder
Get-MailboxFolderStatistics pensya |where {$_.ItemsInFolder -gt 100000}|ft FolderPath,ItemsInFolder
Get-MailboxFolderStatistics gemel-p |where {$_.ItemsInFolder -gt 100000}|ft FolderPath,ItemsInFolder
Get-MailboxFolderStatistics gemel |where {$_.ItemsInFolder -gt 100000}|ft FolderPath,ItemsInFolder
Get-MailboxFolderStatistics mvip |where {$_.ItemsInFolder -gt 100000}|ft FolderPath,ItemsInFolder



Get-MailboxFolderStatistics vip |where {$_.ItemsInFolder -gt 10000}| select export-csv c:\abt\BIGMBX.csv -Encoding Unicode -Append
Get-MailboxFolderStatistics pensya |where {$_.ItemsInFolder -gt 10000}|export-csv c:\abt\BIGMBX.csv -Encoding Unicode -Append
Get-MailboxFolderStatistics gemel-p |where {$_.ItemsInFolder -gt 10000}|export-csv c:\abt\BIGMBX.csv -Encoding Unicode -Append
Get-MailboxFolderStatistics gemel |where {$_.ItemsInFolder -gt 10000}|export-csv c:\abt\BIGMBX.csv -Encoding Unicode -Append
Get-MailboxFolderStatistics mvip |where {$_.ItemsInFolder -gt 10000}|export-csv c:\abt\BIGMBX.csv -Encoding Unicode -Append

Get-Mailbox pensya |ft identity,Name

Get-MailboxFolderStatistics arc-pensya2017 | where {$_.ItemsInFolder -gt 10000}

"DS-Invest.Local/Meitav Dash Network/Users/Service Mailbox/Archive Mailbox/Pensya"
"DS-Invest.Local/Meitav Dash Network/Users/Service Mailbox/Pensya"


Get-MailboxFolderStatistics -Identity "DS-Invest.Local/Meitav Dash Network/Users/Service Mailbox/Pensya" `
| where {$_.ItemsInFolder -gt 10000} |ft Name,FolderSize,ItemsInFolderAndSubfolders



$mbxs = Get-Mailbox -ResultSize unlimited
$mbx
foreach($mbx in $mbxs)
{
    $identity = $mbx.idendity


}


