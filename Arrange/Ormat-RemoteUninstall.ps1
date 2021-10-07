$srv = get-content C:\ABT\srv.txt

foreach($i in $srv){

if($b = Get-WmiObject -Class win32_product -ComputerName $i -Filter "Name like 'Zoom'"){
Write-host $i "has Zoom installed"}

}