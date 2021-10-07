$srv = get-content C:\ABT\srv.txt

foreach($i in $srv){
    if(-not($b = Get-WmiObject -Class win32_product -ComputerName $i |where {$_.Name -like "Zoom*"})){
        Write-Host "No Zoom on: " $i
    }
    else
    {
        if($b.Uninstall()){
            Write-Host "Uninstalled successfully from: " $i
        }
    }
}
