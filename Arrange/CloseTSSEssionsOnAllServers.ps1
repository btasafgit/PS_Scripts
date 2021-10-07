
cls
Write-Host
Write-Host

$ServersArrey = '10.1.72.210','10.1.72.211','10.1.72.212','10.1.72.213','10.1.72.214','10.1.72.215','10.1.72.216','10.1.72.217','10.1.72.218','10.1.72.219','10.1.72.220','10.1.72.221','10.1.72.222','10.1.72.223','10.1.72.224'
$sbname = Read-Host 'Please Enter the SB Name what you want to LOGOFF'
Write-Host
Write-Host
Write-Host
Write-Host

#Write-Host $sbname was found and removed from the following Servers:

Write-Host
Write-Host
 
for($i=0; $i -le $ServersArrey.length-1 ;$i++)

{
        Get-TSSession -ComputerName $ServersArrey[$i]  -UserName  *$sbname*
        Write-Host 'Cheking TS Session on ' $ServersArrey[$i]
        Write-Host
        Start-Sleep -s 1
        Get-TSSession -ComputerName $ServersArrey[$i]  -UserName  *$sbname*  | Disconnect-TSSession  -Force
        
        Get-TSSession -ComputerName $ServersArrey[$i]  -UserName  *$sbname*  | Stop-TSSession  -Force
        
      
}
Write-Host 'Thank you !!!!'
Start-Sleep -s 10