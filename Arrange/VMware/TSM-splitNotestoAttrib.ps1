
$vms = get-VM nsx* -server md-vc
$tbl = @()
foreach($vm in $vms){
$vmNotes = ($vm |Select-Object -ExpandProperty Notes).Split([Environment]::NewLine)

$vm.Name
#last run
$lastRun = ($vmNotes |select-string "Last Run Time").toString()
$lastRun = [Datetime]($lastRun.Split("\'")[1])
#status
$status = ($vmNotes |select-string "status").toString()
$status = ($status.substring($status.IndexOf(("'")))).Trim("'")
#Data transmitted
$dataTrans = ($vmNotes |select-string "Data Transmitted").toString()
$dataTrans = ($dataTrans.substring($dataTrans.IndexOf(("'")))).Trim("'")

#duration
$duration = ($vmNotes |select-string "Duration").toString()
$duration = ($duration.substring($duration.IndexOf(("'")))).Trim("'")

$bkpType = ($vmNotes |select-string "Type=")[0].toString()
$bkpType = ($bkpType.substring($bkpType.IndexOf(("'")))).Trim("'")

$sched = ($vmNotes |select-string "Schedule").toString()
$sched = ($sched.substring($sched.IndexOf(("'")))).Trim("'")

$dataMover = ($vmNotes |select-string "Data Mover").toString()
$dataMover = ($dataMover.substring($dataMover.IndexOf(("'")))).Trim("'")

#$snapType = ($vmNotes |select-string "Snapshot Type").toString()

#$appProtec = ($vmNotes |select-string "Application Protection").toString()
$obj = New-Object -TypeName PSCustomObject -Property @{
        "VM Name" = $vm.Name
        "Last Backup date" = $lastRun
        "Status" = $status
        "Backedup Data" = $dataTrans
        "Backup Duration" = $duration
        "Backup Type" = $bkpType
        "Backup Schedule" = $sched
        "Data Mover" = $dataMover}
$tbl += $obj
}
Clear-Variable -Name tbl -Force
Clear-Variable -Name vm -Force
Clear-Variable -Name lastRun -Force
Clear-Variable -Name status -Force
Clear-Variable -Name dataTrans -Force
Clear-Variable -Name duration -Force
Clear-Variable -Name bkpType -Force
Clear-Variable -Name sched -Force
Clear-Variable -Name dataMover -Force
$tbl |ft
