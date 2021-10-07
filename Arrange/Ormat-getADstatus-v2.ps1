Import-Module activedirectory
<# Mail variables#>
$emailFrom = "adori@ormat.com" 
$emailTo = "adori@ormat.com"
$smtpserver= "mail2.ormat.com"

$today = get-date 
$today = $today.ToString('dd-MM')

<# DCs Info#>
$GC = "ormat-isr1.ormat.com"
$GC = $GC+":3268"
$outFile = "C:\ABT\ADStatus\LOG_"
$DomainControllers = Get-ADComputer -server $GC -Filter {(primaryGroupID -eq "516") -or (primaryGroupID -eq "521")}

###### Function to Check Service Status ######
Function Getservicestatus($service, $server)
{
$st = Get-service -computername $server | where-object { $_.name -eq $service }
if($st)
{$servicestatus= $st.status}
else
{$servicestatus = "Not found"}
Return $servicestatus
}

####### Find Domain Controllers in Forest  ########

$Forest = [system.directoryservices.activedirectory.Forest]::GetCurrentForest()

[string[]]$computername = $Forest.domains | ForEach-Object {$_.DomainControllers} | ForEach-Object {$_.Name} 


<# HTML Building#>
$Header = @"
<style>
TABLE {border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}
TH {border-width: 2px;padding: 3px;border-style: solid;border-color: black;background-color: #6495ED;}
TD {border-width: 2px;padding: 3px;border-style: solid;border-color: black;}
.odd  { background-color:#ffffff; }
.even { background-color:#dddddd; }
</style>
<title>
Title of my Report
</title>
"@

####### Check Server Availability ###########

$report1= @()
foreach ($server in $computername){
$temp1 = "" | select server, pingstatus
if ( Test-Connection -ComputerName $server -Count 1 -ErrorAction SilentlyContinue ) {
$temp1.pingstatus = "Pinging"
}
else {
$temp1.pingstatus = "Not pinging"
}
$temp1.server = $server
$report1+=$temp1
}

$b = $report1 | select server, pingstatus  | ConvertTo-HTML  -Head $Header -As Table -PreContent "<h2>Server Availability</h2>" | Out-String

########## Check Service Status ####################

$report = @()

foreach ($server in $computername){
$temp = "" | select server, NTDS, DNS, DFSR, netlogon, w32Time
$temp.server = $server

$temp.NTDS = Getservicestatus -service "NTDS" -server $server
$temp.DNS = Getservicestatus -service "DNS" -server $server
$temp.DFSR = Getservicestatus -service "DFSR" -server $server
$temp.netlogon = Getservicestatus -service "netlogon" -server $server
$temp.w32Time = Getservicestatus -service "w32Time" -server $server
$report+=$temp
}

$b+= $REPORT | select server, NTDS, DNS, DFSR, netlogon, w32Time | ConvertTo-HTML -Head $Header -As Table -PreContent "<h2>Service Status</h2>" | Out-String


add-type -AssemblyName microsoft.visualbasic 
$strings = "microsoft.visualbasic.strings" -as [type] 


######### Check netLogon Status #############

$report = @()
foreach ($server in $computername){
$temp = "" | select server, SysvolTest
$temp.server = $server
$svt = dcdiag /test:netlogons /s:$server
if($strings::instr($svt, "passed test NetLogons")){$temp.SysvolTest = "Passed"}
else
{$temp.SysvolTest = "Failed"}
$report+=$temp
}
$b+= $REPORT | select server, SysvolTest | ConvertTo-HTML -Fragment -As Table -PreContent "<h2>NetLogon Test</h2>" | Out-String


######## Test Replication Status #############


$workfile = C:\Windows\System32\repadmin.exe /showrepl * /csv 
$results = ConvertFrom-Csv -InputObject $workfile 
 
$results = $results 
    $results = $results | select "Source DSA", "Naming Context", "Destination DSA" ,"Number of Failures", "Last Failure Time", "Last Success Time", "Last Failure Status"
    $b+= $results | select "Source DSA", "Naming Context", "Destination DSA" ,"Number of Failures", "Last Failure Time", "Last Success Time", "Last Failure Status" | ConvertTo-HTML -Head $Header -As Table -PreContent "<h2>Replication Status</h2>" | Out-String    

$head = @'
<style>
body { font-family:Tahoma;
       font-size:12pt; }
td, th { border:1px solid black; 
         border-collapse:collapse; }
th { color:white;
     background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px }
table { margin-left:50px; }
</style>
'@

ForEach ($DC in $DomainControllers.DNShostname) {
        dcdiag /a /s:$DC | Out-File $outFile$today.log -Append
        REPADMIN /syncall /A /e /q $DC | Out-File $outFile$today.log -Append
        REPADMIN /kcc  $DC  | Out-File $outFile$today.log -Append
        REPADMIN /showrepl  $DC  | Out-File $outFile$today.log -Append
        REPADMIN /queue  $DC  | Out-File $outFile$today.log -Append
} 

##Search daily logs for issues and send mail
if (Select-String -Path $outFile$today.log -pattern "failed")
{$s = ConvertTo-HTML -head $head -PostContent $b -Body "<h1> <font color='#FF0000'>ERRORS DETECTED IN LOG FILE PLEASE REVIEW ASAP</font></h1> <br /> Detailed logfile - $outFile$today.log" | Out-string
    <#
    $smtp=new-object Net.Mail.SmtpClient($smtpServer)
    $msg = new-object Net.Mail.MailMessage
    $msg.From = $emailFrom
    $msg.To.Add($emailTo)
    $msg.IsBodyHTML = $true
    $msg.subject="Active Directory Health Check Report" 
    $msg.Body = $s
    $smtp.Send($msg)
    #>
}
else{$s = ConvertTo-HTML -head $head -PostContent $b -Body "<h2>Active Directory Checklist <br />  Detailed logfile - $outFile$today.log </h2>" | Out-string
    <#
    $smtp=new-object Net.Mail.SmtpClient($smtpServer)
    $msg = new-object Net.Mail.MailMessage
    $msg.From = $emailFrom
    $msg.To.Add($emailTo)
    $msg.IsBodyHTML = $true
    $msg.subject="Active Directory Health Check Report" 
    $msg.Body = $s
    $smtp.Send($msg)#>
}

<# Email properties#>
$from = $emailFrom
$to = $emailTo
$subject = "Active Directory Health Check Report"
$body = $s
Send-MailMessage -From $from -To $to -Subject $subject -Body $body -BodyAsHtml -SmtpServer $smtpserver #-Attachments $body
