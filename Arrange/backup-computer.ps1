$path = "C:\Users\$env:USERNAME\OneDrive - Ormat\Backup"

$software = Get-WmiObject win32_product
$userLang = Get-WinUserLanguageList
Export-StartLayout -Path $path\startLayoutBackup.xml

<# Notepad++ backup#>
$nppPath = "C:\Users\$env:USERNAME\AppData\Roaming\Notepad++\backup"
Get-ChildItem $nppPath |Copy-Item -Destination "$path\Notepad++ Backup\"