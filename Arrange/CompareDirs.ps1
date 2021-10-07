
param([string]$DirA,[string]$DirB,[string]$outPath)

#Variable Input
$a = Get-ChildItem $DirA
$b = Get-ChildItem $DirB

#Comparing with output
if($outPath -eq $null){
Compare-Object $a $b |select InputObject
}
else{
Compare-Object $a $b |select InputObject |Export-Csv $outPath -NoTypeInformation
}

