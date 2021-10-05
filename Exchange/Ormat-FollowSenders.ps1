$exServer = "Ormat-MBX16.ormat.com"
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionURI http://$exServer/powershell/ -Authentication kerberos
import-PSSession $session 


$res = Get-MessageTrackingLog -Server $exServer -Start "1/1/2010" -End (Get-Date) -ResultSize 1000 #|select ClientIp,ClientHostname,ServerIp,ConnectorId,EventId,Source,Timestamp #| Export-Csv C:\ABT\MBX-Connector-Info.csv -NoTypeInformation

Get-MessageTrackingLog -Server $exServer -Start "1/1/2010" -End (Get-Date) -ResultSize unlimited| where {$_.Sender -like "PFdial-in@ormat.com" -or $_.Recipients -like "PFdial-in@ormat.com"}


$r = Get-MessageTrackingLog -Server $exServer -Start "1/1/2010" -End (Get-Date) -ResultSize unlimited
$r | select Sender,Recipients |export-csv c:\abt\dls.csv -NoTypeInformation

$g = Get-MessageTrace -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date)

$g |Select-Object -Last 100

$rec = "emonitorexormat@ormat.com"


$grp = Get-ADGroup -SearchBase "OU=Distribution,OU=IL-Groups,DC=ORMAT,DC=com" -Filter * -Properties * |sort Name
foreach($i in $grp){
    #write-host "Started Working on"$i.mail
    if((Get-MessageTrackingLog -ResultSize unlimited -Recipients $i.mail -Start (Get-Date).AddDays(-1825) -End (Get-Date)) -eq $null){
        Write-Host $i.mail
    }
    #write-host "Finished Working on $i.mail"
}


$a = "FAXport-Users-ex2k@ormat.com"
Get-MessageTrace -RecipientAddress $a -StartDate (Get-Date).AddDays(-30) -EndDate (Get-Date) #|Get-MessageTraceDetail -Event EXPAND
Get-MessageTrackingLog -ResultSize unlimited -Recipients $a -Start (Get-Date).AddDays(-1825) -End (Get-Date)
Get-MessageTraceDetail | ? {$_.RelatedRecipientAddress -like "distributiongroup@domain.com"} | ft Timestamp,Sender,MessageSubject -Autosize


$mID = "<AM4PR07MB33646DC4D2ECB0A96F0B1F2EA2F30@AM4PR07MB3364.eurprd07.prod.outlook.com>"
$res = Get-MessageTrace -StartDate (Get-Date).AddDays(-1) -EndDate (Get-Date) -MessageId $mID

$res
