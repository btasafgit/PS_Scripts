<# CPU report of all ormat servers

the script checks the servers in every domain

#>
<#

$fileOut = "c:\abt\CPUs123.csv"
$Servers = @()
$licOut = @()
$Servers += Get-ADComputer -Filter * -Server "ormat-isr1.ormat.com"  -Properties * |Where-Object {$_.OperatingSystem -like "Windows Server*"}
$Servers += Get-ADComputer -Filter * -Server "ke-il-dc1.ke.ormat.com"  -Properties * |Where-Object {$_.OperatingSystem -like "Windows Server*"}
$Servers += Get-ADComputer -Filter * -Server "us-il-dc1.us.ormat.com"  -Properties * |Where-Object {$_.OperatingSystem -like "Windows Server*"} 
$Servers += Get-ADComputer -Filter * -Server "ca-il-dc1.ca.us.ormat.com"  -Properties * |Where-Object {$_.OperatingSystem -like "Windows Server*"} 
$Servers += Get-ADComputer -Filter * -Server "hi-il-dc1.hi.us.ormat.com"  -Properties * |Where-Object {$_.OperatingSystem -like "Windows Server*"} 
$Servers += Get-ADComputer -Filter * -Server "mammoth-il-dc1.mammoth.us.ormat.com"  -Properties * |Where-Object {$_.OperatingSystem -like "Windows Server*"} 
$Servers += Get-ADComputer -Filter * -Server "nv-il-dc1.nv.us.ormat.com"  -Properties * |Where-Object {$_.OperatingSystem -like "Windows Server*"}

foreach($Server in $Servers){

    if(Test-Connection -ComputerName $Server.DNSHostName -Protocol WSMan -Count 1 -ErrorAction SilentlyContinue){
        Write-host $Server.DNSHostName
        $srvAvail = "True"
        $cpu = Get-WmiObject -ComputerName $Server.DNSHostName -class Win32_ComputerSystem -ErrorAction SilentlyContinue
    if((Get-WmiObject -ComputerName $Server.DNSHostName -Class Win32_BIOS -ErrorAction SilentlyContinue).SerialNumber -like "VMware*")
        {$isVM = "True"}
    else
        {$isVM = "False"}

    } #End of Test Connection 
    else{
        $srvAvail = "False"
        $isVM = "NA"
        
        } 

    $licOut += New-Object -TypeName PSCustomObject -Property @{
        "Name" = $Server.DNSHostName
        "Available" = $srvAvail
        "isVM" = $isVM
        "cpuSoc" = $cpu.numberofprocessors
        "cpuCores" = ($cpu.numberoflogicalprocessors)/2
        "cpuCoresHT" = $cpu.numberoflogicalprocessors
        "LastLogon" = $Server.lastLogon
    }   |Select-Object 'Name','Available','isVM','cpuSoc','cpuCores','cpuCoresHT','LastLogon'

}

$licOut |select Name,Available,isVM,cpuSoc,cpuCores |Export-Csv $fileOut -NoTypeInformation

clear-variable vmLst -force
clear-variable pLst -force
clear-variable Servers -force
clear-variable fltLst -force
clear-variable pLst -force
#>

$gpos1 = Get-GPO -Server $closestDC -Domain hi.us.ormat.com -all

$Path = "C:\ABT\HI"
$domain = "hi.ormat.com"
$closestDC = "hi-il-dc1.hi.us.ormat.com"
foreach($gpo in $gpos1)
            {
              $gpoName = $gpo.DisplayName
              if(-not(Get-Item $Path\$domain\$gpoName -ErrorAction SilentlyContinue))
                {
                  New-Item -Name $gpoName -Path $Path\$domain -type directory -ErrorAction SilentlyContinue
                }
                Backup-GPO -Name $gpoName -Server $closestDC -Domain $domain -Path $Path\$domain\$gpoName

            } #end of foreach GPO