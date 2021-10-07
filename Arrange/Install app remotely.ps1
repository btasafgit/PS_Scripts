$a = Get-ADComputer -Filter * -SearchBase "OU=Domain Controllers,DC=NV,DC=US,DC=ORMAT,DC=com" -Server nv-il-dc1.nv.us.ormat.com|Sort-Object DNSHostName

foreach($i in $a){
$LASTEXITCODE = 0;
Write-Host -ForegroundColor Yellow -BackgroundColor Black "Installing Gytpol on" $i.DNSHostName "================="
    try{
    Invoke-Command -ComputerName $i.DNSHostName -ScriptBlock {
        Start-Process msiexec.exe -Wait -ArgumentList "/i \\ormat-sccm\sources\system\Gytpol\16122020\gytpolClient_x64.msi /qn"
            }
        $r=0;
        }
    catch{
        $r=1;
       }
    if($LASTEXITCODE -eq 0){Write-Host -ForegroundColor green "Server" $i.DNSHostName "Finished successfully"}
    elseif($LASTEXITCODE -eq 1){Write-Host -ForegroundColor red "Server" $i.DNSHostName "Failed"}
    sleep 1
}
