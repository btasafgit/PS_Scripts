#Pre-requisites
Set-Location "C:\Users\Adori\OneDrive - Ormat\Documents\PS Projects\"
if(-not(Get-Module PSPKI))
{import-module PSPKI
    
Install-Module PSPKI}
Import-Module VMware.PowerCLI
Import-Module "C:\Users\adori\OneDrive - Ormat\Documents\PS Projects\PS\Ormat Scripts\Projects\New CRL\Send-VMKeystrokes.psm1"
$vc = "Ormat-vc.ormat.com"
$a = Connect-VIServer $vc
$a.IsConnected

$user = ".\administrator"
$pass = ConvertTo-SecureString "Adv1234" -AsPlainText -Force
$rcaCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $user, $pass


$rcaServer = "10.10.3.180"
$rcaVM = "Ormat-RootCA"
$BL = "C12345min!@#" #Bitlocker passcode
$scaServer = "Ormat-Subca.ormat.com" 
$crlCert = "\\cdp01.ormat.com\c$\inetpub\wwwroot\cdp\ormatrca.crl"

<# Powering on the ROOTCA vm#>
if(-not(Test-Connection $rcaServer -Count 1 -ErrorAction SilentlyContinue)){
    Start-VM -VM $rcaVM -Server $vc -ErrorAction SilentlyContinue
    Start-Sleep 5
    Set-VMKeystrokes -VMName $rcaVM -StringInput $BL -ReturnCarriage $true -ErrorAction SilentlyContinue
    Start-Sleep 5
    
}

$sess = New-PSSession -ComputerName $rcaServer -Credential $rcaCred
#Check CRL
$crl = get-crl $crlCert
if((($crl.NextUpdate) - (get-date)) -le "1")
{
    Invoke-Command -Session $sess -ScriptBlock {c:\windows\system32\certutil.exe -CRL}
    # Copy RootCA CRL
    Invoke-Command -Session $sess -ScriptBlock {
        $cFrom = "C:\windows\System32\CertSrv\CertEnroll\ormatrca.crl"
        $cTo = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll"
        Copy-Item $cFrom -Destination $cTo -Force

        $cFrom = "C:\Windows\System32\certsrv\CertEnroll\ormatsca.crt"
        $cTo = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll"
        Copy-Item $cFrom -Destination $cTo -Force
    }


    
}

<# Try to add this#>
$scaCred = new-object -typename System.Management.Automation.PSCredential -argumentlist $env:vcUser, $env:vcPass

$scaSess = New-PSSession -ComputerName $scaServer -Credential $scaCred
    <# Copy From: #>
    Invoke-Command -Session $scaSess -ScriptBlock {
        $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ormatsca.crl"
        $cTo = "\\ormat-cdp1.ormat.com\c$\inetpub\wwwroot\cdp"
        Copy-Item $cFrom -Destination $cTo -Force
        $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ormatsca.crt"
        Copy-Item $cFrom -Destination $cTo -Force
    }



    $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ormatrca.crl"
    $cTo = "\\ormat-cdp2.ormat.com\c$\inetpub\wwwroot\cdp"
    Copy-Item $cFrom -Destination $cTo -Force

    


    $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ormatsca.crt"
    $cTo = "\\ormat-cdp2.ormat.com\c$\inetpub\wwwroot\cdp"
    Copy-Item $cFrom -Destination $cTo -Force
    
    $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ORMATRCA_OrmatRCA.crt"
    $cTo = "\\ormat-cdp2.ormat.com\c$\inetpub\wwwroot\cdp"
    Copy-Item $cFrom -Destination $cTo -Force
    
    $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ORMATRCA_OrmatRCA.crt"
    $cTo = "\\ormat-cdp2.ormat.com\c$\inetpub\wwwroot\cdp"
    Copy-Item $cFrom -Destination $cTo -Force
    
    $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ormatsca.crl"
    $cTo = "\\ormat-cdp2.ormat.com\c$\inetpub\wwwroot\cdp"
    Copy-Item $cFrom -Destination $cTo -Force
    
    $cFrom = "\\ormat-subca.ormat.com\C$\Windows\System32\certsrv\CertEnroll\ormatsca.crl"
    $cTo = "\\ormat-cdp2.ormat.com\c$\inetpub\wwwroot\cdp"
    Copy-Item $cFrom -Destination $cTo -Force


$mailTo = "adori@ormat.com"
$mailFrom = "CRL@ormat.com"
$Subject = "PKI Cert and CRL update"
$SMTPServer = "Ormat-mbx16.ormat.com"
Send-MailMessage -From $mailFrom -To $mailTo -Subject $Subject -SmtpServer $SMTPServer
