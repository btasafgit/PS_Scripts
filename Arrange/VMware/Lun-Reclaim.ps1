#Import PowerCLI
cd "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\"
.\Initialize-PowerCLIEnvironment.ps1
#--Initial Variables
$vc = 'md-vc'
$username = "DS-invest\vc_usr"
$password = ConvertTo-SecureString "hLW1Wlnv" -AsPlainText -Force
#---ESX Cresentials
$path = "C:\ABT\vMware\LunReclaim"

#Connect to Some ESX
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
Connect-VIServer $vc -Credential $cred
$esxcli = Get-EsxCli -Server $vc -VMHost mduesx01.ds-invest.local


#---to run manually on specific volume
$ds = Get-Datastore -Server $vc -Name dev_vmfs_ds004,prod_vmfs_ds019,prod_vmfs_ds009

#---to run on all datastores
#$ds = Get-Datastore |where {$_.Name -notlike "*local*" -and $_.Type -ne "NFS"}
foreach($i in $ds)
{
    $res = $esxcli.storage.vmfs.unmap(60000,$i, $null)
    $date = Get-Date -Format dd/MM/yyyy
    $time = get-date -Format HH:MM:ss
    New-Object -TypeName PSCustomObject -Property @{
        "Datastore Name" = $i
        "Reclaim Status" = $res
        "Date" = $date
        "Time" = $time
        } |select 'Datastore Name','Reclaim Status','Time','Date' #| export-csv "$path\lunReclaim.csv" -Append
    #Write-host "Finished Reclimation for " $i.Name -ForegroundColor Black -BackgroundColor Yellow
}


