# SCHANNEL Ciphers
$ciPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"
$ciphers = @("DES 56","DES 56$([char]0x2215)56","NULL","RC2 40$([char]0x2215)128","RC2 56$([char]0x2215)128","RC4 128$([char]0x2215)128", `
"RC4 40$([char]0x2215)128","RC4 56$([char]0x2215)128","RC4 64$([char]0x2215)128","Triple DES 168")


foreach($p in $ciphers){
    
    if(-not(Get-Item -Path "$ciPath\${p}")){
        New-Item -Path "$ciPath\${p}\"
        New-ItemProperty -Path "$ciPath\${p}\" -Name Enabled -Value 0 -PropertyType DWORD -Force | Out-Null
        }
    else{
        New-ItemProperty -Path "$ciPath\${p}\" -Name Enabled -Value 0 -PropertyType DWORD -Force | Out-Null
    }

}






# SCHANNEL Protocols
$protPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols"
$protocols = @("PCT 1.0","SSL 2.0","SSL 3.0","TLS 1.0","TLS 1.1")

foreach($p in $protocols){
    
    if(-not(Get-Item -Path "$protPath\$p")){
        New-Item -Path "$protPath\$p\"
        }
    if(-not(Get-Item -Path "$protPath\$p\Server")){
        New-Item -Path "$protPath\$p\" -Name Server
        New-ItemProperty -Path "$protPath\$p\Server" -Name Enabled -Value 0 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path "$protPath\$p\Server" -Name DisabledByDefault -Value 1 -PropertyType DWORD -Force | Out-Null
    }
    if(-not(Get-Item -Path "$protPath\$p\Client")){
        New-Item -Path "$protPath\$p\" -Name Client
        New-ItemProperty -Path "$protPath\$p\Client" -Name Enabled -Value 0 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path "$protPath\$p\Client" -Name DisabledByDefault -Value 1 -PropertyType DWORD -Force | Out-Null
    }
}


