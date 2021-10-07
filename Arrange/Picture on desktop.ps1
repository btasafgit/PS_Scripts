# Importing Assembly for Windows Forms 
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$img = [System.Drawing.Image]::Fromfile('C:\Users\adori\Downloads\icon-sf.jpg')

# Main form/SplashScreen Object
$SScreen                   = New-Object system.Windows.Forms.Form
$SScreen.Width             = $img.Width
$SScreen.Height            = $img.Height
$SScreen.TopMost           = $true
$SScreen.BackgroundImage   = $img
$SScreen.AllowTransparency = $true
$SScreen.TransparencyKey   = $SScreen.BackColor
$SScreen.StartPosition     = 1
$SScreen.FormBorderStyle   = 0

# Open the main form
#Start-Process -FilePath "C:\Windows\system32\WindowsPowerShell\v1.0\powershell_ise.exe"

$SScreen.Show()


if((Get-ADComputer $env:COMPUTERNAME).DistinguishedName -like "*Hardening*"){
Start-Sleep -Seconds 5
}
else{
$SScreen.Close()
# tell Windows it can be removed from memory
$SScreen.Dispose()
}